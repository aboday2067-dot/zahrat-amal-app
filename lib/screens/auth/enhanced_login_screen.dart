import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/unique_id_service.dart';
import '../../services/notification_service.dart';

/// شاشة تسجيل الدخول المحسنة
/// تدعم تسجيل الدخول بـ:
/// - البريد الإلكتروني
/// - رقم الهاتف
/// - المعرف الفريد (ZA-YYYY-NNNNNN)
class EnhancedLoginScreen extends StatefulWidget {
  const EnhancedLoginScreen({super.key});

  @override
  State<EnhancedLoginScreen> createState() => _EnhancedLoginScreenState();
}

class _EnhancedLoginScreenState extends State<EnhancedLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _identifierType = 'auto'; // auto, email, phone, uniqueId

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// تحديد نوع المعرف المدخل
  String _detectIdentifierType(String input) {
    if (input.isEmpty) return 'unknown';
    
    // فحص المعرف الفريد (ZA-YYYY-NNNNNN)
    if (UniqueIdService.isValidUniqueId(input)) {
      return 'uniqueId';
    }
    
    // فحص البريد الإلكتروني
    if (input.contains('@')) {
      return 'email';
    }
    
    // فحص رقم الهاتف
    if (RegExp(r'^\+?[0-9]{10,15}$').hasMatch(input.replaceAll(' ', ''))) {
      return 'phone';
    }
    
    return 'unknown';
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final identifier = _identifierController.text.trim();
      final password = _passwordController.text;
      final identifierType = _detectIdentifierType(identifier);

      // في بيئة الإنتاج، يجب استخدام API حقيقي للمصادقة
      // هنا نستخدم نظام بسيط للتوضيح
      
      bool loginSuccess = false;
      String? userType;
      String? userName;
      String? email;
      String? phone;
      String? uniqueId;

      // محاكاة عملية تسجيل الدخول
      if (identifierType == 'uniqueId') {
        // تسجيل الدخول بالمعرف الفريد
        loginSuccess = await _loginWithUniqueId(identifier, password);
      } else if (identifierType == 'email') {
        // تسجيل الدخول بالبريد الإلكتروني
        loginSuccess = await _loginWithEmail(identifier, password);
      } else if (identifierType == 'phone') {
        // تسجيل الدخول برقم الهاتف
        loginSuccess = await _loginWithPhone(identifier, password);
      }

      if (loginSuccess) {
        // حفظ بيانات تسجيل الدخول
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        
        // جلب بيانات المستخدم
        userType = prefs.getString('userType') ?? 'buyer';
        userName = prefs.getString('userName') ?? 'مستخدم';
        email = prefs.getString('userEmail') ?? '';
        phone = prefs.getString('userPhone') ?? '';
        uniqueId = prefs.getString('userUniqueId') ?? '';

        // إرسال إشعار تسجيل دخول
        if (email.isNotEmpty && phone.isNotEmpty) {
          NotificationService.sendLoginNotification(
            email: email,
            phone: phone,
            userName: userName,
            uniqueId: uniqueId,
          );
        }

        if (!mounted) return;

        // التوجيه حسب نوع المستخدم
        String route = '/';
        switch (userType) {
          case 'admin':
            route = '/admin';
            break;
          case 'merchant':
            route = '/merchant/dashboard';
            break;
          case 'delivery':
            route = '/delivery/dashboard';
            break;
          default:
            route = '/';
        }

        Navigator.pushReplacementNamed(context, route);
      } else {
        if (!mounted) return;
        _showErrorDialog('فشل تسجيل الدخول', 'البيانات المدخلة غير صحيحة');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('خطأ', 'حدث خطأ أثناء تسجيل الدخول: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// تسجيل الدخول بالمعرف الفريد
  Future<bool> _loginWithUniqueId(String uniqueId, String password) async {
    // في بيئة الإنتاج، استخدم API للتحقق
    // هنا نستخدم نظام بسيط للتوضيح
    
    final prefs = await SharedPreferences.getInstance();
    
    // للتوضيح: قبول أي معرف فريد صحيح مع كلمة مرور "123456"
    if (password == '123456') {
      await prefs.setString('userUniqueId', uniqueId);
      await prefs.setString('userName', 'مستخدم ZA');
      await prefs.setString('userEmail', 'user@example.com');
      await prefs.setString('userPhone', '+249912345678');
      await prefs.setString('userType', 'buyer');
      return true;
    }
    
    return false;
  }

  /// تسجيل الدخول بالبريد الإلكتروني
  Future<bool> _loginWithEmail(String email, String password) async {
    // في بيئة الإنتاج، استخدم API للتحقق
    final prefs = await SharedPreferences.getInstance();
    
    // للتوضيح: حسابات اختبارية
    if (email == 'admin@zahrat.sd' && password == 'admin123') {
      await prefs.setString('userType', 'admin');
      await prefs.setString('userName', 'المسؤول');
      await prefs.setString('userEmail', email);
      await prefs.setString('userPhone', '+249912000000');
      await prefs.setString('userUniqueId', await UniqueIdService.generateUniqueId());
      return true;
    }
    
    if (password == '123456') {
      await prefs.setString('userType', 'buyer');
      await prefs.setString('userName', 'مشتري');
      await prefs.setString('userEmail', email);
      await prefs.setString('userPhone', '+249912345678');
      await prefs.setString('userUniqueId', await UniqueIdService.generateUniqueId());
      return true;
    }
    
    return false;
  }

  /// تسجيل الدخول برقم الهاتف
  Future<bool> _loginWithPhone(String phone, String password) async {
    // في بيئة الإنتاج، استخدم API للتحقق
    final prefs = await SharedPreferences.getInstance();
    
    // للتوضيح
    if (password == '123456') {
      await prefs.setString('userType', 'buyer');
      await prefs.setString('userName', 'مشتري');
      await prefs.setString('userEmail', 'user@example.com');
      await prefs.setString('userPhone', phone);
      await prefs.setString('userUniqueId', await UniqueIdService.generateUniqueId());
      return true;
    }
    
    return false;
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal.shade700,
              Colors.teal.shade500,
              Colors.teal.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // شعار التطبيق
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 80,
                          color: Colors.teal.shade700,
                        ),
                        const SizedBox(height: 16),
                        
                        // عنوان التطبيق
                        Text(
                          'زهرة الأمل',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'منصة السودان للتجارة الإلكترونية',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // حقل المعرف (بريد/هاتف/معرف فريد)
                        TextFormField(
                          controller: _identifierController,
                          decoration: InputDecoration(
                            labelText: 'البريد الإلكتروني أو رقم الهاتف أو المعرف الفريد',
                            hintText: 'user@email.com أو +249912345678 أو ZA-2025-001234',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال البريد الإلكتروني أو رقم الهاتف أو المعرف الفريد';
                            }
                            final type = _detectIdentifierType(value);
                            if (type == 'unknown') {
                              return 'يرجى إدخال بريد إلكتروني أو رقم هاتف أو معرف فريد صحيح';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _identifierType = _detectIdentifierType(value);
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // عرض نوع المعرف المكتشف
                        if (_identifierType != 'auto' && _identifierController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                Icon(
                                  _identifierType == 'email'
                                      ? Icons.email
                                      : _identifierType == 'phone'
                                          ? Icons.phone
                                          : Icons.badge,
                                  size: 16,
                                  color: Colors.teal,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _identifierType == 'email'
                                      ? 'تسجيل الدخول بالبريد الإلكتروني'
                                      : _identifierType == 'phone'
                                          ? 'تسجيل الدخول برقم الهاتف'
                                          : 'تسجيل الدخول بالمعرف الفريد',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.teal.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // حقل كلمة المرور
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال كلمة المرور';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // زر تسجيل الدخول
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'تسجيل الدخول',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // معلومات الحسابات التجريبية
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'حسابات تجريبية:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'المسؤول: admin@zahrat.sd / admin123',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.teal.shade800,
                                ),
                              ),
                              Text(
                                'مستخدم: أي بريد أو هاتف / 123456',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.teal.shade800,
                                ),
                              ),
                              Text(
                                'معرف فريد: ZA-2025-001234 / 123456',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.teal.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
