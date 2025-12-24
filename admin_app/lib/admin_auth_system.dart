import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// نظام تسجيل الدخول والخروج للمدير - v8.0.0
/// يتيح للمدير تسجيل الدخول والوصول إلى صفحة الملف الشخصي

class AdminAuthSystem {
  static final AdminAuthSystem _instance = AdminAuthSystem._internal();
  factory AdminAuthSystem() => _instance;
  AdminAuthSystem._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _adminIdKey = 'admin_id';
  static const String _adminNameKey = 'admin_name';
  static const String _adminEmailKey = 'admin_email';

  // تسجيل دخول المدير
  Future<AdminLoginResult> loginAdmin(String email, String password) async {
    try {
      debugPrint('🔐 محاولة تسجيل دخول المدير: $email');

      // التحقق من بيانات المدير في Firestore
      final adminQuery = await _firestore
          .collection('admins')
          .where('email', isEqualTo: email.trim())
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (adminQuery.docs.isEmpty) {
        debugPrint('❌ بيانات تسجيل الدخول غير صحيحة');
        return AdminLoginResult(
          success: false,
          message: 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
        );
      }

      final adminDoc = adminQuery.docs.first;
      final adminData = adminDoc.data();

      // حفظ بيانات المدير في SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_adminIdKey, adminDoc.id);
      await prefs.setString(_adminNameKey, adminData['name'] ?? 'المدير');
      await prefs.setString(_adminEmailKey, adminData['email'] ?? email);

      // تحديث آخر تسجيل دخول
      await adminDoc.reference.update({
        'lastLogin': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ تم تسجيل دخول المدير بنجاح');

      return AdminLoginResult(
        success: true,
        message: 'تم تسجيل الدخول بنجاح',
        adminId: adminDoc.id,
        adminName: adminData['name'] ?? 'المدير',
        adminEmail: adminData['email'] ?? email,
      );
    } catch (e) {
      debugPrint('❌ خطأ أثناء تسجيل الدخول: $e');
      return AdminLoginResult(
        success: false,
        message: 'حدث خطأ أثناء تسجيل الدخول: $e',
      );
    }
  }

  // تسجيل خروج المدير
  Future<void> logoutAdmin() async {
    try {
      debugPrint('🚪 تسجيل خروج المدير...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_adminIdKey);
      await prefs.remove(_adminNameKey);
      await prefs.remove(_adminEmailKey);
      debugPrint('✅ تم تسجيل الخروج بنجاح');
    } catch (e) {
      debugPrint('❌ خطأ أثناء تسجيل الخروج: $e');
    }
  }

  // التحقق من حالة تسجيل الدخول
  Future<bool> isAdminLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminId = prefs.getString(_adminIdKey);
      return adminId != null && adminId.isNotEmpty;
    } catch (e) {
      debugPrint('❌ خطأ أثناء التحقق من حالة تسجيل الدخول: $e');
      return false;
    }
  }

  // الحصول على معلومات المدير المسجل
  Future<Map<String, String>?> getAdminInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminId = prefs.getString(_adminIdKey);
      final adminName = prefs.getString(_adminNameKey);
      final adminEmail = prefs.getString(_adminEmailKey);

      if (adminId != null) {
        return {
          'id': adminId,
          'name': adminName ?? 'المدير',
          'email': adminEmail ?? '',
        };
      }
      return null;
    } catch (e) {
      debugPrint('❌ خطأ أثناء الحصول على معلومات المدير: $e');
      return null;
    }
  }

  // إنشاء حساب مدير جديد (للاستخدام مرة واحدة)
  Future<void> createDefaultAdmin() async {
    try {
      final existingAdmin = await _firestore
          .collection('admins')
          .where('email', isEqualTo: 'admin@zahrat.sd')
          .limit(1)
          .get();

      if (existingAdmin.docs.isEmpty) {
        await _firestore.collection('admins').add({
          'name': 'المدير العام',
          'email': 'admin@zahrat.sd',
          'password': 'admin123',
          'phone': '+249123456789',
          'role': 'superadmin',
          'createdAt': DateTime.now().toIso8601String(),
          'lastLogin': null,
        });
        debugPrint('✅ تم إنشاء حساب المدير الافتراضي');
      } else {
        debugPrint('ℹ️ حساب المدير موجود بالفعل');
      }
    } catch (e) {
      debugPrint('❌ خطأ أثناء إنشاء حساب المدير: $e');
    }
  }
}

// نتيجة تسجيل الدخول
class AdminLoginResult {
  final bool success;
  final String message;
  final String? adminId;
  final String? adminName;
  final String? adminEmail;

  AdminLoginResult({
    required this.success,
    required this.message,
    this.adminId,
    this.adminName,
    this.adminEmail,
  });
}

// صفحة تسجيل دخول المدير
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@zahrat.sd');
  final _passwordController = TextEditingController(text: 'admin123');
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AdminAuthSystem().loginAdmin(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${result.message}'),
            backgroundColor: Colors.green,
          ),
        );
        // الانتقال إلى لوحة الإدارة
        Navigator.of(context).pushReplacementNamed('/admin-dashboard');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
              const Color(0xFF6B9AC4),
              const Color(0xFF97C4E8),
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
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // شعار التطبيق
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B9AC4).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings,
                            size: 60,
                            color: Color(0xFF6B9AC4),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // العنوان
                        const Text(
                          'لوحة إدارة زهرة الأمل',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B9AC4),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'تسجيل دخول المدير',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // حقل البريد الإلكتروني
                        TextFormField(
                          controller: _emailController,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            hintText: 'admin@zahrat.sd',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال البريد الإلكتروني';
                            }
                            if (!value.contains('@')) {
                              return 'البريد الإلكتروني غير صحيح';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // حقل كلمة المرور
                        TextFormField(
                          controller: _passwordController,
                          textAlign: TextAlign.right,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور',
                            hintText: '••••••••',
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
                              return 'الرجاء إدخال كلمة المرور';
                            }
                            if (value.length < 6) {
                              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // زر تسجيل الدخول
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B9AC4),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'تسجيل الدخول',
                                    style: TextStyle(fontSize: 18),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // معلومات تجريبية
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'بيانات تسجيل الدخول الافتراضية:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'البريد: admin@zahrat.sd',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                'كلمة المرور: admin123',
                                style: TextStyle(fontSize: 12),
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

// صفحة الملف الشخصي للمدير
class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({Key? key}) : super(key: key);

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  Map<String, String>? _adminInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
  }

  Future<void> _loadAdminInfo() async {
    final info = await AdminAuthSystem().getAdminInfo();
    setState(() {
      _adminInfo = info;
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AdminAuthSystem().logoutAdmin();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم تسجيل الخروج بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/admin-login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_adminInfo == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('لم يتم العثور على معلومات المدير'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/admin-login');
                },
                child: const Text('تسجيل الدخول'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // صورة المدير وبياناته الأساسية
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B9AC4).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        size: 80,
                        color: Color(0xFF6B9AC4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _adminInfo!['name']!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _adminInfo!['email']!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'مدير النظام',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // قائمة الإعدادات
            _buildSettingItem(
              icon: Icons.person,
              title: 'معلومات الحساب',
              subtitle: 'عرض وتعديل معلومات الحساب',
              onTap: () {
                // TODO: فتح صفحة تعديل معلومات الحساب
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('قريباً...')),
                );
              },
            ),
            _buildSettingItem(
              icon: Icons.lock,
              title: 'تغيير كلمة المرور',
              subtitle: 'تحديث كلمة المرور',
              onTap: () {
                // TODO: فتح صفحة تغيير كلمة المرور
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('قريباً...')),
                );
              },
            ),
            _buildSettingItem(
              icon: Icons.notifications,
              title: 'الإشعارات',
              subtitle: 'إدارة إعدادات الإشعارات',
              onTap: () {
                // TODO: فتح صفحة إعدادات الإشعارات
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('قريباً...')),
                );
              },
            ),
            _buildSettingItem(
              icon: Icons.security,
              title: 'الأمان',
              subtitle: 'إعدادات الأمان والخصوصية',
              onTap: () {
                // TODO: فتح صفحة إعدادات الأمان
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('قريباً...')),
                );
              },
            ),
            const SizedBox(height: 24),

            // زر تسجيل الخروج
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text(
                      'تسجيل الخروج',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6B9AC4).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF6B9AC4)),
        ),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
