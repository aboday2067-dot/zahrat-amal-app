import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'العربية';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
      _selectedLanguage = prefs.getString('selected_language') ?? 'العربية';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('dark_mode_enabled', _darkModeEnabled);
    await prefs.setString('selected_language', _selectedLanguage);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: const Text(
            'الإعدادات',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // قسم الحساب
            _buildSectionTitle('الحساب'),
            _buildSettingsCard([
              _buildSettingsTile(
                icon: Icons.person,
                title: 'الملف الشخصي',
                subtitle: 'عرض وتعديل معلومات الحساب',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('الملف الشخصي')),
                  );
                },
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.lock,
                title: 'تغيير كلمة المرور',
                subtitle: 'تحديث كلمة المرور الخاصة بك',
                onTap: () {
                  _showChangePasswordDialog();
                },
              ),
            ]),

            const SizedBox(height: 24),

            // قسم الإشعارات
            _buildSectionTitle('الإشعارات'),
            _buildSettingsCard([
              SwitchListTile(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  _saveSettings();
                },
                title: const Text(
                  'تفعيل الإشعارات',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('تلقي إشعارات حول الطلبات والعروض'),
                secondary: Icon(
                  Icons.notifications,
                  color: Colors.teal[600],
                ),
              ),
            ]),

            const SizedBox(height: 24),

            // قسم المظهر
            _buildSectionTitle('المظهر'),
            _buildSettingsCard([
              SwitchListTile(
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });
                  _saveSettings();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('سيتم تطبيق الوضع المظلم في الإصدار القادم'),
                    ),
                  );
                },
                title: const Text(
                  'الوضع المظلم',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('تفعيل الوضع المظلم للتطبيق'),
                secondary: Icon(
                  Icons.dark_mode,
                  color: Colors.teal[600],
                ),
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.language,
                title: 'اللغة',
                subtitle: _selectedLanguage,
                onTap: () {
                  _showLanguageDialog();
                },
              ),
            ]),

            const SizedBox(height: 24),

            // قسم الخصوصية والأمان
            _buildSectionTitle('الخصوصية والأمان'),
            _buildSettingsCard([
              _buildSettingsTile(
                icon: Icons.privacy_tip,
                title: 'سياسة الخصوصية',
                subtitle: 'اطلع على سياسة الخصوصية',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('سياسة الخصوصية')),
                  );
                },
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.description,
                title: 'الشروط والأحكام',
                subtitle: 'اطلع على شروط الاستخدام',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('الشروط والأحكام')),
                  );
                },
              ),
            ]),

            const SizedBox(height: 24),

            // قسم الدعم
            _buildSectionTitle('الدعم'),
            _buildSettingsCard([
              _buildSettingsTile(
                icon: Icons.help,
                title: 'المساعدة والدعم',
                subtitle: 'تواصل مع فريق الدعم',
                onTap: () {
                  Navigator.pushNamed(context, '/help');
                },
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.info,
                title: 'حول التطبيق',
                subtitle: 'الإصدار 1.0.0',
                onTap: () {
                  _showAboutDialog();
                },
              ),
            ]),

            const SizedBox(height: 24),

            // زر تسجيل الخروج
            _buildLogoutButton(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal[600]),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey[300]);
  }

  Widget _buildLogoutButton() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text(
          'تسجيل الخروج',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.red,
          ),
        ),
        onTap: () {
          _showLogoutDialog();
        },
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير كلمة المرور'),
        content: const Text('هذه الميزة ستكون متاحة قريباً'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر اللغة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('العربية'),
              value: 'العربية',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                _saveSettings();
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                _saveSettings();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('اللغة الإنجليزية ستكون متاحة في الإصدار القادم'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حول التطبيق'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'زهرة الأمل - سوق السودان الذكي',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text('الإصدار: 1.0.0'),
            SizedBox(height: 8),
            Text('منصة تجارة إلكترونية شاملة تربط المشترين والتجار ومكاتب التوصيل في السودان'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
