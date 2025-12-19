import 'package:shared_preferences/shared_preferences.dart';
import '../services/unique_id_service.dart';
import 'package:flutter/foundation.dart';

/// خدمة المصادقة باستخدام التخزين المحلي فقط (بدون Firebase)
/// تتعامل مع تسجيل الدخول، التسجيل، واستعادة كلمة المرور
class AuthService {
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

      if (displayName.isEmpty) {
        return {
          'success': false,
          'message': 'يرجى إدخال الاسم الكامل',
        };
      }

      if (phone.isEmpty || phone.length < 10) {
        return {
          'success': false,
          'message': 'رقم الهاتف غير صحيح',
        };
      }

      // التحقق من وجود الحساب مسبقاً
      final prefs = await SharedPreferences.getInstance();
      final existingEmail = prefs.getString('user_$email');
      
      if (existingEmail != null) {
        return {
          'success': false,
          'message': 'البريد الإلكتروني مستخدم بالفعل',
        };
      }

      // توليد معرف فريد
      String uniqueId = await UniqueIdService.generateUniqueId();
      String userId = 'local_${DateTime.now().millisecondsSinceEpoch}';

      // حفظ بيانات المستخدم محلياً
      await prefs.setString('user_$email', userId);
      await prefs.setString('${userId}_email', email);
      await prefs.setString('${userId}_password', password); // في تطبيق حقيقي، استخدم تشفير!
      await prefs.setString('${userId}_displayName', displayName);
      await prefs.setString('${userId}_phone', phone);
      await prefs.setString('${userId}_userType', userType);
      await prefs.setString('${userId}_uniqueId', uniqueId);
      await prefs.setString('${userId}_createdAt', DateTime.now().toIso8601String());

      // تسجيل الدخول تلقائياً
      await _saveUserDataLocally(userId, email, displayName, phone, userType, uniqueId);

      if (kDebugMode) {
        debugPrint('✅ تم إنشاء حساب جديد بنجاح - المعرف الفريد: $uniqueId');
      }

      return {
        'success': true,
        'message': 'تم إنشاء الحساب بنجاح',
        'userId': userId,
        'uniqueId': uniqueId,
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

      if (password.isEmpty) {
        return {
          'success': false,
          'message': 'يرجى إدخال كلمة المرور',
        };
      }

      final prefs = await SharedPreferences.getInstance();
      
      // البحث عن الحساب
      final userId = prefs.getString('user_$email');
      
      if (userId == null) {
        return {
          'success': false,
          'message': 'الحساب غير موجود',
        };
      }

      // التحقق من كلمة المرور
      final savedPassword = prefs.getString('${userId}_password');
      
      if (savedPassword != password) {
        return {
          'success': false,
          'message': 'كلمة المرور غير صحيحة',
        };
      }

      // جلب بيانات المستخدم
      String displayName = prefs.getString('${userId}_displayName') ?? 'مستخدم';
      String phone = prefs.getString('${userId}_phone') ?? '';
      String userType = prefs.getString('${userId}_userType') ?? 'buyer';
      String uniqueId = prefs.getString('${userId}_uniqueId') ?? '';

      // حفظ حالة تسجيل الدخول
      await _saveUserDataLocally(userId, email, displayName, phone, userType, uniqueId);

      if (kDebugMode) {
        debugPrint('✅ تم تسجيل الدخول بنجاح - نوع المستخدم: $userType');
      }

      return {
        'success': true,
        'message': 'تم تسجيل الدخول بنجاح',
        'userId': userId,
        'userType': userType,
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
      final prefs = await SharedPreferences.getInstance();
      
      // البحث عن المستخدم بالمعرف الفريد
      final keys = prefs.getKeys();
      String? foundUserId;
      String? foundEmail;

      for (String key in keys) {
        if (key.endsWith('_uniqueId')) {
          final storedUniqueId = prefs.getString(key);
          if (storedUniqueId == uniqueId) {
            foundUserId = key.replaceAll('_uniqueId', '');
            foundEmail = prefs.getString('${foundUserId}_email');
            break;
          }
        }
      }

      if (foundUserId == null || foundEmail == null) {
        return {
          'success': false,
          'message': 'المعرف الفريد غير موجود',
        };
      }

      // تسجيل الدخول بالبريد وكلمة المرور
      return await signInWithEmail(email: foundEmail, password: password);
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
      final prefs = await SharedPreferences.getInstance();
      
      // البحث عن المستخدم برقم الهاتف
      final keys = prefs.getKeys();
      String? foundUserId;
      String? foundEmail;

      for (String key in keys) {
        if (key.endsWith('_phone')) {
          final storedPhone = prefs.getString(key);
          if (storedPhone == phone) {
            foundUserId = key.replaceAll('_phone', '');
            foundEmail = prefs.getString('${foundUserId}_email');
            break;
          }
        }
      }

      if (foundUserId == null || foundEmail == null) {
        return {
          'success': false,
          'message': 'رقم الهاتف غير مسجل',
        };
      }

      // تسجيل الدخول بالبريد وكلمة المرور
      return await signInWithEmail(email: foundEmail, password: password);
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ: $e',
      };
    }
  }

  /// إرسال بريد إعادة تعيين كلمة المرور (محاكاة)
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

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_$email');
      
      if (userId == null) {
        return {
          'success': false,
          'message': 'البريد الإلكتروني غير مسجل',
        };
      }

      // في تطبيق حقيقي، يتم إرسال بريد إلكتروني
      // هنا نقوم بمحاكاة العملية فقط
      if (kDebugMode) {
        debugPrint('✉️ محاكاة: تم إرسال رابط إعادة تعيين كلمة المرور إلى $email');
      }

      return {
        'success': true,
        'message': 'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
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
    final prefs = await SharedPreferences.getInstance();
    
    // حذف بيانات الجلسة الحالية فقط
    await prefs.remove('isLoggedIn');
    await prefs.remove('userId');
    await prefs.remove('userEmail');
    await prefs.remove('userName');
    await prefs.remove('userPhone');
    await prefs.remove('userType');
    await prefs.remove('userUniqueId');

    if (kDebugMode) {
      debugPrint('✅ تم تسجيل الخروج بنجاح');
    }
  }

  /// حفظ بيانات المستخدم محلياً
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
    await prefs.setString('${uid}_lastLogin', DateTime.now().toIso8601String());
  }
}
