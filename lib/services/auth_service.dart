import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'dart:convert';

class AuthService {
  static const String _usersKey = 'registered_users';
  static const String _currentUserKey = 'current_user';

  // تسجيل مستخدم جديد
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String userType,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // التحقق من عدم تكرار الإيميل أو الهاتف
      final existingUsers = await _getAllUsers();
      final emailExists = existingUsers.any((u) => u.email == email);
      final phoneExists = existingUsers.any((u) => u.phone == phone);
      
      if (emailExists) {
        return {'success': false, 'message': 'البريد الإلكتروني مسجل مسبقاً'};
      }
      if (phoneExists) {
        return {'success': false, 'message': 'رقم الهاتف مسجل مسبقاً'};
      }

      // إنشاء مستخدم جديد برقم فريد
      final uniqueId = UserModel.generateUniqueId(userType);
      final user = UserModel(
        uniqueId: uniqueId,
        name: name,
        email: email,
        phone: phone,
        userType: userType,
        createdAt: DateTime.now(),
      );

      // حفظ المستخدم
      existingUsers.add(user);
      await _saveUsers(existingUsers);
      
      // حفظ كلمة المرور (في تطبيق حقيقي يجب تشفيرها)
      await prefs.setString('password_$uniqueId', password);

      return {
        'success': true,
        'message': 'تم التسجيل بنجاح',
        'uniqueId': uniqueId,
        'user': user,
      };
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ: $e'};
    }
  }

  // تسجيل الدخول بالإيميل أو الهاتف أو الرقم الفريد
  Future<Map<String, dynamic>> login({
    required String identifier, // email, phone, or uniqueId
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = await _getAllUsers();

      // البحث عن المستخدم
      UserModel? user;
      for (var u in users) {
        if (u.email == identifier ||
            u.phone == identifier ||
            u.uniqueId == identifier) {
          user = u;
          break;
        }
      }

      if (user == null) {
        return {'success': false, 'message': 'المستخدم غير موجود'};
      }

      if (!user.isActive) {
        return {'success': false, 'message': 'الحساب معطل'};
      }

      // التحقق من كلمة المرور
      final savedPassword = prefs.getString('password_${user.uniqueId}');
      if (savedPassword != password) {
        return {'success': false, 'message': 'كلمة المرور غير صحيحة'};
      }

      // حفظ بيانات الجلسة
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userType', user.userType);
      await prefs.setString('uniqueId', user.uniqueId);
      await prefs.setString('userName', user.name);
      await prefs.setString('userEmail', user.email);
      await prefs.setString(_currentUserKey, json.encode(user.toJson()));

      return {
        'success': true,
        'message': 'تم تسجيل الدخول بنجاح',
        'user': user,
      };
    } catch (e) {
      return {'success': false, 'message': 'حدث خطأ: $e'};
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userType');
    await prefs.remove('uniqueId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove(_currentUserKey);
  }

  // الحصول على المستخدم الحالي
  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_currentUserKey);
      if (userJson != null) {
        return UserModel.fromJson(json.decode(userJson));
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  // الحصول على جميع المستخدمين
  Future<List<UserModel>> _getAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);
      if (usersJson != null) {
        final List<dynamic> decoded = json.decode(usersJson);
        return decoded.map((u) => UserModel.fromJson(u)).toList();
      }
    } catch (e) {
      // ignore
    }
    return [];
  }

  // حفظ قائمة المستخدمين
  Future<void> _saveUsers(List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = json.encode(users.map((u) => u.toJson()).toList());
    await prefs.setString(_usersKey, usersJson);
  }

  // إنشاء حساب مدير افتراضي
  Future<void> createDefaultAdmin() async {
    final users = await _getAllUsers();
    if (users.any((u) => u.userType == 'admin')) {
      return; // يوجد مدير بالفعل
    }

    final admin = UserModel(
      uniqueId: 'ZA-A-2025-000001',
      name: 'المدير',
      email: 'admin@zahratamal.sd',
      phone: '0123456789',
      userType: 'admin',
      createdAt: DateTime.now(),
    );

    users.add(admin);
    await _saveUsers(users);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('password_${admin.uniqueId}', 'admin123');
  }
}
