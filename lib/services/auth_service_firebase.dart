import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/unique_id_service.dart';
import 'package:flutter/foundation.dart';

/// خدمة المصادقة باستخدام Firebase Authentication + Firestore
/// تتعامل مع تسجيل الدخول، التسجيل، واستعادة كلمة المرور
/// مع نسخ احتياطي محلي في SharedPreferences
class AuthServiceFirebase {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// الحصول على المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  /// تسجيل مستخدم جديد
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String displayName,
    required String phone,
    required String userType,
  }) async {
    try {
      // التحقق من البيانات
      if (email.isEmpty || !email.contains('@')) {
        return {
          'success': false,
          'message': 'البريد الإلكتروني غير صحيح',
        };
      }

      if (password.length < 6) {
        return {
          'success': false,
          'message': 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
        };
      }

      // إنشاء حساب في Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user == null) {
        return {
          'success': false,
          'message': 'فشل إنشاء الحساب',
        };
      }

      // تحديث اسم المستخدم
      await user.updateDisplayName(displayName);

      // توليد معرف فريد
      String uniqueId = await UniqueIdService.generateUniqueId();

      // حفظ نسخة احتياطية محلياً أولاً (للتأكد من عدم فقدان البيانات)
      await _saveUserDataLocally(user.uid, email, displayName, phone, userType, uniqueId);

      // محاولة حفظ بيانات المستخدم في Firestore
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'displayName': displayName,
          'phone': phone,
          'userType': userType,
          'uniqueId': uniqueId,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'isActive': true,
        });
        
        if (kDebugMode) {
          debugPrint('✅ Firebase Firestore: تم حفظ بيانات المستخدم');
        }
      } catch (firestoreError) {
        if (kDebugMode) {
          debugPrint('⚠️ Firestore Error: $firestoreError');
          debugPrint('✅ البيانات محفوظة محلياً فقط');
        }
        // نستمر بدون إيقاف - البيانات محفوظة محلياً
      }

      if (kDebugMode) {
        debugPrint('✅ Firebase: تم إنشاء حساب جديد - المعرف الفريد: $uniqueId');
      }

      return {
        'success': true,
        'message': 'تم إنشاء الحساب بنجاح',
        'userId': user.uid,
        'uniqueId': uniqueId,
      };
    } on FirebaseAuthException catch (e) {
      String message = _getArabicErrorMessage(e.code);
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ: $e',
      };
    }
  }

  /// تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // التحقق من البيانات
      if (email.isEmpty || !email.contains('@')) {
        return {
          'success': false,
          'message': 'البريد الإلكتروني غير صحيح',
        };
      }

      // تسجيل الدخول
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user == null) {
        return {
          'success': false,
          'message': 'فشل تسجيل الدخول',
        };
      }

      // جلب بيانات المستخدم من Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) {
        return {
          'success': false,
          'message': 'حساب المستخدم غير موجود في قاعدة البيانات',
        };
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // تحديث آخر تسجيل دخول
      await _firestore.collection('users').doc(user.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      // حفظ نسخة احتياطية محلياً
      await _saveUserDataLocally(
        user.uid,
        userData['email'] ?? email,
        userData['displayName'] ?? 'مستخدم',
        userData['phone'] ?? '',
        userData['userType'] ?? 'buyer',
        userData['uniqueId'] ?? '',
      );

      if (kDebugMode) {
        debugPrint('✅ Firebase: تم تسجيل الدخول - نوع المستخدم: ${userData['userType']}');
      }

      return {
        'success': true,
        'message': 'تم تسجيل الدخول بنجاح',
        'userId': user.uid,
        'userType': userData['userType'] ?? 'buyer',
      };
    } on FirebaseAuthException catch (e) {
      String message = _getArabicErrorMessage(e.code);
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ: $e',
      };
    }
  }

  /// تسجيل الدخول بالمعرف الفريد (ZA-YYYY-NNNNNN)
  Future<Map<String, dynamic>> signInWithUniqueId({
    required String uniqueId,
    required String password,
  }) async {
    try {
      // البحث عن المستخدم بالمعرف الفريد
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('uniqueId', isEqualTo: uniqueId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {
          'success': false,
          'message': 'المعرف الفريد غير موجود',
        };
      }

      DocumentSnapshot userDoc = querySnapshot.docs.first;
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String email = userData['email'];

      // تسجيل الدخول بالبريد وكلمة المرور
      return await signInWithEmail(email: email, password: password);
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ: $e',
      };
    }
  }

  /// تسجيل الدخول برقم الهاتف وكلمة المرور
  Future<Map<String, dynamic>> signInWithPhone({
    required String phone,
    required String password,
  }) async {
    try {
      // البحث عن المستخدم برقم الهاتف
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {
          'success': false,
          'message': 'رقم الهاتف غير مسجل',
        };
      }

      DocumentSnapshot userDoc = querySnapshot.docs.first;
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String email = userData['email'];

      // تسجيل الدخول بالبريد وكلمة المرور
      return await signInWithEmail(email: email, password: password);
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ: $e',
      };
    }
  }

  /// إرسال بريد إعادة تعيين كلمة المرور
  Future<Map<String, dynamic>> resetPassword({
    required String email,
  }) async {
    try {
      if (email.isEmpty || !email.contains('@')) {
        return {
          'success': false,
          'message': 'البريد الإلكتروني غير صحيح',
        };
      }

      await _auth.sendPasswordResetEmail(email: email);
      
      if (kDebugMode) {
        debugPrint('✅ Firebase: تم إرسال رابط إعادة تعيين كلمة المرور');
      }

      return {
        'success': true,
        'message': 'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
      };
    } on FirebaseAuthException catch (e) {
      String message = _getArabicErrorMessage(e.code);
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ: $e',
      };
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
    
    // حذف البيانات المحلية
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userId');
    await prefs.remove('userEmail');
    await prefs.remove('userName');
    await prefs.remove('userPhone');
    await prefs.remove('userType');
    await prefs.remove('userUniqueId');

    if (kDebugMode) {
      debugPrint('✅ Firebase: تم تسجيل الخروج بنجاح');
    }
  }

  /// حفظ بيانات المستخدم محلياً (نسخة احتياطية)
  Future<void> _saveUserDataLocally(
    String uid,
    String email,
    String displayName,
    String phone,
    String userType,
    String uniqueId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', uid);
    await prefs.setString('userEmail', email);
    await prefs.setString('userName', displayName);
    await prefs.setString('userPhone', phone);
    await prefs.setString('userType', userType);
    await prefs.setString('userUniqueId', uniqueId);
    
    // تحديث آخر تسجيل دخول
    await prefs.setString('lastLogin', DateTime.now().toIso8601String());
  }

  /// ترجمة رسائل الخطأ من Firebase إلى العربية
  String _getArabicErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'user-not-found':
        return 'المستخدم غير موجود';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'too-many-requests':
        return 'محاولات كثيرة جداً، يرجى المحاولة لاحقاً';
      case 'operation-not-allowed':
        return 'العملية غير مسموح بها';
      case 'network-request-failed':
        return 'خطأ في الاتصال بالإنترنت';
      case 'invalid-credential':
        return 'بيانات الاعتماد غير صحيحة';
      default:
        return 'حدث خطأ: $errorCode';
    }
  }
}
