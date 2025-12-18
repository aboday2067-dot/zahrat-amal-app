import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/unique_id_service.dart';

/// شاشة تسجيل الدخول الجديدة مع Firebase Authentication
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

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
    
    return 'unknown';
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final identifier = _identifierController.text.trim();
      final password = _passwordController.text;
      final identifierType = _detectIdentifierType(identifier);

      Map<String, dynamic> result;

      if (identifierType == 'uniqueId') {
        // تسجيل الدخول بالمعرف الفريد
        result = await _authService.signInWithUniqueId(
          uniqueId: identifier,
          password: password,
        );
      } else if (identifierType == 'email') {
        // تسجيل الدخول بالبريد الإلكتروني
        result = await _authService.signInWithEmail(
          email: identifier,
          password: password,
        );
      } else {
        result = {
          'success': false,
          'message': 'الرجاء إدخال بريد إلكتروني صحيح أو معرف فريد',
        };
      }

      if (!mounted) return;

      if (result['success']) {
        // عرض رسالة نجاح
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // التوجيه حسب نوع المستخدم
        String route = '/';
        String userType = result['userType'] ?? 'buyer';
        
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
        _showErrorDialog('فشل تسجيل الدخول', result['message']);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('خطأ', 'حدث خطأ غير متوقع: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                
                // شعار التطبيق
                const Icon(
                  Icons.shopping_bag,
                  size: 80,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),

                // عنوان التطبيق
                const Text(
                  'زهرة الأمل',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'سوق السودان الذكي',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // حقل البريد/المعرف
                TextFormField(
                  controller: _identifierController,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني أو المعرف الفريد',
                    hintText: 'email@example.com أو ZA-2025-001234',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال البريد أو المعرف';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // حقل كلمة المرور
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                      return 'الرجاء إدخال كلمة المرور';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // رابط نسيت كلمة المرور
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot-password');
                    },
                    child: const Text('نسيت كلمة المرور؟'),
                  ),
                ),
                const SizedBox(height: 24),

                // زر تسجيل الدخول
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
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
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'تسجيل الدخول',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
                const SizedBox(height: 24),

                // خط فاصل
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('أو'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // زر إنشاء حساب جديد
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'إنشاء حساب جديد',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
