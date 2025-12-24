// ============================================
// نظام المصادقة المتقدم - Advanced Authentication System
// ✅ تسجيل المستخدمين الجدد
// ✅ تسجيل الدخول الآمن
// ✅ التحقق من البريد الإلكتروني
// ✅ استعادة كلمة المرور
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'main.dart';

// ========== نموذج المستخدم ==========
class UserModel {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String city;
  final String district;
  final String role; // buyer, merchant, delivery_office
  final DateTime createdAt;
  final bool isEmailVerified;
  final bool isActive;
  
  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.district,
    required this.role,
    required this.createdAt,
    this.isEmailVerified = false,
    this.isActive = true,
  });
  
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'name': name,
    'email': email,
    'phone': phone,
    'city': city,
    'district': district,
    'role': role,
    'createdAt': createdAt.toIso8601String(),
    'isEmailVerified': isEmailVerified,
    'isActive': isActive,
  };
  
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    userId: json['userId'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
    city: json['city'],
    district: json['district'],
    role: json['role'],
    createdAt: DateTime.parse(json['createdAt']),
    isEmailVerified: json['isEmailVerified'] ?? false,
    isActive: json['isActive'] ?? true,
  );
}

// ========== مدير المصادقة ==========
class AuthManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // تشفير كلمة المرور
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // التحقق من صحة البريد الإلكتروني
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
  
  // التحقق من قوة كلمة المرور
  static bool isStrongPassword(String password) {
    // على الأقل 8 أحرف، تحتوي على حروف وأرقام
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Za-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    return true;
  }
  
  // تسجيل مستخدم جديد
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String city,
    required String district,
    required String role,
  }) async {
    try {
      // التحقق من البيانات
      if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
        return {'success': false, 'message': 'جميع الحقول مطلوبة'};
      }
      
      if (!isValidEmail(email)) {
        return {'success': false, 'message': 'البريد الإلكتروني غير صحيح'};
      }
      
      if (!isStrongPassword(password)) {
        return {'success': false, 'message': 'كلمة المرور ضعيفة (على الأقل 8 أحرف مع حروف وأرقام)'};
      }
      
      // التحقق من عدم وجود المستخدم مسبقاً
      final existingUser = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (existingUser.docs.isNotEmpty) {
        return {'success': false, 'message': 'البريد الإلكتروني مسجل مسبقاً'};
      }
      
      // إنشاء المستخدم
      final userId = 'USR-${DateTime.now().millisecondsSinceEpoch}';
      final hashedPassword = hashPassword(password);
      
      final user = UserModel(
        userId: userId,
        name: name,
        email: email,
        phone: phone,
        city: city,
        district: district,
        role: role,
        createdAt: DateTime.now(),
      );
      
      // حفظ المستخدم في Firebase
      await _firestore.collection('users').doc(userId).set(user.toJson());
      
      // حفظ كلمة المرور (مشفرة)
      await _firestore.collection('user_credentials').doc(userId).set({
        'userId': userId,
        'passwordHash': hashedPassword,
        'createdAt': DateTime.now().toIso8601String(),
      });
      
      return {
        'success': true,
        'message': 'تم التسجيل بنجاح',
        'user': user,
      };
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Registration error: $e');
      }
      return {'success': false, 'message': 'حدث خطأ أثناء التسجيل'};
    }
  }
  
  // تسجيل الدخول
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return {'success': false, 'message': 'البريد الإلكتروني وكلمة المرور مطلوبان'};
      }
      
      // البحث عن المستخدم
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (userQuery.docs.isEmpty) {
        return {'success': false, 'message': 'البريد الإلكتروني أو كلمة المرور غير صحيحة'};
      }
      
      final userData = userQuery.docs.first.data();
      final userId = userData['userId'];
      
      // التحقق من كلمة المرور
      final credDoc = await _firestore.collection('user_credentials').doc(userId).get();
      
      if (!credDoc.exists) {
        return {'success': false, 'message': 'خطأ في بيانات المصادقة'};
      }
      
      final storedPasswordHash = credDoc.data()!['passwordHash'];
      final inputPasswordHash = hashPassword(password);
      
      if (storedPasswordHash != inputPasswordHash) {
        return {'success': false, 'message': 'البريد الإلكتروني أو كلمة المرور غير صحيحة'};
      }
      
      // التحقق من الحساب النشط
      if (userData['isActive'] == false) {
        return {'success': false, 'message': 'حسابك معطل، يرجى التواصل مع الدعم'};
      }
      
      // حفظ بيانات الجلسة
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);
      await prefs.setString('userName', userData['name']);
      await prefs.setString('userEmail', userData['email']);
      await prefs.setString('userPhone', userData['phone']);
      await prefs.setString('userCity', userData['city']);
      await prefs.setString('userDistrict', userData['district']);
      await prefs.setString('userRole', userData['role']);
      await prefs.setBool('isLoggedIn', true);
      
      final user = UserModel.fromJson(userData);
      
      return {
        'success': true,
        'message': 'تم تسجيل الدخول بنجاح',
        'user': user,
      };
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Login error: $e');
      }
      return {'success': false, 'message': 'حدث خطأ أثناء تسجيل الدخول'};
    }
  }
  
  // تسجيل الخروج
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  
  // التحقق من حالة تسجيل الدخول
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
  
  // جلب بيانات المستخدم الحالي
  static Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) return null;
      
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (!doc.exists) return null;
      
      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting current user: $e');
      }
      return null;
    }
  }
}

// ========== صفحة التسجيل ==========
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  
  String _selectedRole = 'buyer';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  final List<String> _roles = [
    'buyer',
    'merchant',
    'delivery_office',
  ];
  
  final Map<String, String> _roleNames = {
    'buyer': 'مشتري',
    'merchant': 'تاجر',
    'delivery_office': 'مكتب توصيل',
  };
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('تسجيل حساب جديد', 'Create Account')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B9AC4).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(
                    Icons.person_add,
                    size: 60,
                    color: Color(0xFF6B9AC4),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                lang.translate('إنشاء حساب جديد', 'Create New Account'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lang.translate('املأ البيانات للتسجيل', 'Fill the form to register'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              
              // Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: lang.translate('الاسم الكامل', 'Full Name'),
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return lang.translate('الاسم مطلوب', 'Name is required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: lang.translate('البريد الإلكتروني', 'Email'),
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return lang.translate('البريد الإلكتروني مطلوب', 'Email is required');
                  }
                  if (!AuthManager.isValidEmail(value)) {
                    return lang.translate('البريد الإلكتروني غير صحيح', 'Invalid email');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Phone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: lang.translate('رقم الهاتف', 'Phone Number'),
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return lang.translate('رقم الهاتف مطلوب', 'Phone is required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // City
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: lang.translate('المدينة', 'City'),
                  prefixIcon: const Icon(Icons.location_city),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return lang.translate('المدينة مطلوبة', 'City is required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // District
              TextFormField(
                controller: _districtController,
                decoration: InputDecoration(
                  labelText: lang.translate('الحي', 'District'),
                  prefixIcon: const Icon(Icons.home),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return lang.translate('الحي مطلوب', 'District is required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Role
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: lang.translate('نوع الحساب', 'Account Type'),
                  prefixIcon: const Icon(Icons.badge),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _roles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(_roleNames[role]!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: lang.translate('كلمة المرور', 'Password'),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return lang.translate('كلمة المرور مطلوبة', 'Password is required');
                  }
                  if (!AuthManager.isStrongPassword(value)) {
                    return lang.translate('كلمة المرور ضعيفة (8 أحرف على الأقل)', 'Weak password (min 8 chars)');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: lang.translate('تأكيد كلمة المرور', 'Confirm Password'),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return lang.translate('تأكيد كلمة المرور مطلوب', 'Confirm password');
                  }
                  if (value != _passwordController.text) {
                    return lang.translate('كلمات المرور غير متطابقة', 'Passwords do not match');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // Register Button
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B9AC4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        lang.translate('تسجيل', 'Register'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              
              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(lang.translate('لديك حساب؟', 'Have an account?')),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      lang.translate('تسجيل الدخول', 'Login'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B9AC4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final result = await AuthManager.registerUser(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      city: _cityController.text.trim(),
      district: _districtController.text.trim(),
      role: _selectedRole,
    );
    
    if (mounted) {
      setState(() => _isLoading = false);
      
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// ========== صفحة تسجيل الدخول المحسّنة ==========
class EnhancedLoginScreen extends StatefulWidget {
  const EnhancedLoginScreen({super.key});
  
  @override
  State<EnhancedLoginScreen> createState() => _EnhancedLoginScreenState();
}

class _EnhancedLoginScreenState extends State<EnhancedLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Logo
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B9AC4).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(70),
                    ),
                    child: const Icon(
                      Icons.storefront,
                      size: 80,
                      color: Color(0xFF6B9AC4),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                const Text(
                  'زهرة الأمل',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B9AC4),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  lang.translate('سوق السودان الذكي', 'Sudan Smart Market'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 48),
                
                Text(
                  lang.translate('تسجيل الدخول', 'Login'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: lang.translate('البريد الإلكتروني', 'Email'),
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return lang.translate('البريد الإلكتروني مطلوب', 'Email is required');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: lang.translate('كلمة المرور', 'Password'),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return lang.translate('كلمة المرور مطلوبة', 'Password is required');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B9AC4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          lang.translate('تسجيل الدخول', 'Login'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(lang.translate('ليس لديك حساب؟', 'No account?')),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: Text(
                        lang.translate('تسجيل حساب جديد', 'Create Account'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B9AC4),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final result = await AuthManager.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    
    if (mounted) {
      setState(() => _isLoading = false);
      
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to main screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
