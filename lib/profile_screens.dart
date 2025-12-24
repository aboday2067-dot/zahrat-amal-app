import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Import main providers
import 'main.dart';

// ============ ENHANCED PROFILE SCREEN ============

class EnhancedProfileScreen extends StatelessWidget {
  const EnhancedProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.translate('الملف الشخصي', 'Profile')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _loadUserData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFF6B9AC4),
                      backgroundImage: userData['userImage'] != null && userData['userImage']!.isNotEmpty
                          ? NetworkImage(userData['userImage']!)
                          : null,
                      child: userData['userImage'] == null || userData['userImage']!.isEmpty
                          ? const Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFF6B9AC4),
                        radius: 18,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                          onPressed: () {
                            // TODO: Add image picker
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  userData['userName'] ?? langProvider.translate('المستخدم', 'User'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  userData['userEmail'] ?? 'email@example.com',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  userData['userPhone'] ?? '+249',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 32),
                
                // Personal Information Section
                _buildSectionHeader(context, langProvider.translate('المعلومات الشخصية', 'Personal Information')),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildInfoTile(
                        context,
                        icon: Icons.person,
                        title: langProvider.translate('الاسم الكامل', 'Full Name'),
                        value: userData['userName'] ?? '-',
                      ),
                      const Divider(height: 1),
                      _buildInfoTile(
                        context,
                        icon: Icons.email,
                        title: langProvider.translate('البريد الإلكتروني', 'Email'),
                        value: userData['userEmail'] ?? '-',
                      ),
                      const Divider(height: 1),
                      _buildInfoTile(
                        context,
                        icon: Icons.phone,
                        title: langProvider.translate('رقم الهاتف', 'Phone'),
                        value: userData['userPhone'] ?? '-',
                      ),
                      const Divider(height: 1),
                      _buildInfoTile(
                        context,
                        icon: Icons.cake,
                        title: langProvider.translate('تاريخ الميلاد', 'Birth Date'),
                        value: userData['birthDate'] ?? langProvider.translate('لم يتم التحديد', 'Not Set'),
                      ),
                      const Divider(height: 1),
                      _buildInfoTile(
                        context,
                        icon: Icons.wc,
                        title: langProvider.translate('الجنس', 'Gender'),
                        value: userData['gender'] ?? langProvider.translate('لم يتم التحديد', 'Not Set'),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Addresses Section
                _buildSectionHeader(context, langProvider.translate('العناوين', 'Addresses')),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListTile(
                    leading: const Icon(Icons.location_on, color: Color(0xFF6B9AC4)),
                    title: Text(langProvider.translate('إدارة العناوين', 'Manage Addresses')),
                    subtitle: Text(langProvider.translate('عناوين التوصيل المحفوظة', 'Saved Delivery Addresses')),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddressesScreen()),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Orders Section
                _buildSectionHeader(context, langProvider.translate('الطلبات', 'Orders')),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.shopping_bag, color: Color(0xFF6B9AC4)),
                        title: Text(langProvider.translate('طلباتي', 'My Orders')),
                        subtitle: Text(langProvider.translate('عرض جميع الطلبات', 'View All Orders')),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const UserOrdersScreen()),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.favorite, color: Colors.red),
                        title: Text(langProvider.translate('المفضلة', 'Favorites')),
                        subtitle: Text(langProvider.translate('المنتجات المفضلة', 'Favorite Products')),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // TODO: Navigate to favorites
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Settings Section
                _buildSectionHeader(context, langProvider.translate('الإعدادات', 'Settings')),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode, color: const Color(0xFF6B9AC4)),
                        title: Text(langProvider.translate('الوضع الليلي', 'Dark Mode')),
                        subtitle: Text(langProvider.translate('تفعيل الوضع المظلم', 'Enable Dark Theme')),
                        value: themeProvider.isDarkMode,
                        onChanged: (value) => themeProvider.toggleTheme(),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.language, color: Color(0xFF6B9AC4)),
                        title: Text(langProvider.translate('اللغة', 'Language')),
                        subtitle: Text(langProvider.isArabic ? 'العربية' : 'English'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => langProvider.toggleLanguage(),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.notifications, color: Color(0xFF6B9AC4)),
                        title: Text(langProvider.translate('الإشعارات', 'Notifications')),
                        subtitle: Text(langProvider.translate('إدارة تفضيلات الإشعارات', 'Manage Notification Preferences')),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.security, color: Color(0xFF6B9AC4)),
                        title: Text(langProvider.translate('الخصوصية والأمان', 'Privacy & Security')),
                        subtitle: Text(langProvider.translate('تغيير كلمة المرور', 'Change Password')),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SecurityScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Help & Support Section
                _buildSectionHeader(context, langProvider.translate('المساعدة والدعم', 'Help & Support')),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.help, color: Color(0xFF6B9AC4)),
                        title: Text(langProvider.translate('مركز المساعدة', 'Help Center')),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.info, color: Color(0xFF6B9AC4)),
                        title: Text(langProvider.translate('عن التطبيق', 'About App')),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: langProvider.translate('زهرة الأمل', 'Zahrat Amal'),
                            applicationVersion: 'v3.0.0 Ultimate',
                            applicationIcon: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6B9AC4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.shopping_bag, color: Colors.white, size: 30),
                            ),
                            children: [
                              Text(langProvider.translate('سوق السودان الذكي', 'Sudan Smart Market')),
                              const SizedBox(height: 8),
                              Text(langProvider.translate('13 ميزة متقدمة', '13 Advanced Features')),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(langProvider.translate('تسجيل الخروج', 'Logout')),
                          content: Text(langProvider.translate('هل أنت متأكد من تسجيل الخروج؟', 'Are you sure you want to logout?')),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(langProvider.translate('إلغاء', 'Cancel')),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: Text(langProvider.translate('تسجيل الخروج', 'Logout')),
                            ),
                          ],
                        ),
                      );
                      
                      if (confirm == true) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      langProvider.translate('تسجيل الخروج', 'Logout'),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B9AC4),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6B9AC4)),
      title: Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }

  Future<Map<String, String>> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userName': prefs.getString('userName') ?? 'المستخدم',
      'userEmail': prefs.getString('userEmail') ?? 'email@example.com',
      'userPhone': prefs.getString('userPhone') ?? '+249',
      'userImage': prefs.getString('userImage') ?? '',
      'birthDate': prefs.getString('birthDate') ?? '',
      'gender': prefs.getString('gender') ?? '',
    };
  }
}

// ============ EDIT PROFILE SCREEN ============

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  String _gender = 'ذكر';
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('userName') ?? '';
      _emailController.text = prefs.getString('userEmail') ?? '';
      _phoneController.text = prefs.getString('userPhone') ?? '';
      _birthDateController.text = prefs.getString('birthDate') ?? '';
      _gender = prefs.getString('gender') ?? 'ذكر';
    });
  }
  
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text);
    await prefs.setString('userEmail', _emailController.text);
    await prefs.setString('userPhone', _phoneController.text);
    await prefs.setString('birthDate', _birthDateController.text);
    await prefs.setString('gender', _gender);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ التغييرات بنجاح')),
      );
      Navigator.pop(context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.translate('تعديل الملف الشخصي', 'Edit Profile')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: langProvider.translate('الاسم الكامل', 'Full Name'),
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: langProvider.translate('البريد الإلكتروني', 'Email'),
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: langProvider.translate('رقم الهاتف', 'Phone'),
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _birthDateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: langProvider.translate('تاريخ الميلاد', 'Birth Date'),
                prefixIcon: const Icon(Icons.cake),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _birthDateController.text = DateFormat('dd/MM/yyyy').format(date);
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: InputDecoration(
                labelText: langProvider.translate('الجنس', 'Gender'),
                prefixIcon: const Icon(Icons.wc),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: [
                DropdownMenuItem(value: 'ذكر', child: Text(langProvider.translate('ذكر', 'Male'))),
                DropdownMenuItem(value: 'أنثى', child: Text(langProvider.translate('أنثى', 'Female'))),
              ],
              onChanged: (value) => setState(() => _gender = value!),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B9AC4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                langProvider.translate('حفظ التغييرات', 'Save Changes'),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ ADDRESSES SCREEN ============

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.translate('العناوين', 'Addresses')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddEditAddressScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('addresses')
            .where('user_id', isEqualTo: 'b1') // Replace with actual user ID
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(langProvider.translate('خطأ في التحميل', 'Loading Error')));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final addresses = snapshot.data!.docs;

          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    langProvider.translate('لا توجد عناوين محفوظة', 'No Saved Addresses'),
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddEditAddressScreen()),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: Text(langProvider.translate('إضافة عنوان', 'Add Address')),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B9AC4)),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index].data() as Map<String, dynamic>;
              final addressId = addresses[index].id;
              final isDefault = address['is_default'] ?? false;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isDefault ? const Color(0xFF6B9AC4) : Colors.grey,
                    child: Icon(
                      address['type'] == 'home' ? Icons.home : Icons.work,
                      color: Colors.white,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(address['label'] ?? langProvider.translate('عنوان', 'Address')),
                      if (isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            langProvider.translate('افتراضي', 'Default'),
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(address['street'] ?? ''),
                      Text('${address['city'] ?? ''}, ${address['country'] ?? ''}'),
                      Text(langProvider.translate('هاتف:', 'Phone:') + ' ${address['phone'] ?? ''}'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 20),
                            const SizedBox(width: 8),
                            Text(langProvider.translate('تعديل', 'Edit')),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditAddressScreen(
                                addressId: addressId,
                                addressData: address,
                              ),
                            ),
                          );
                        },
                      ),
                      if (!isDefault)
                        PopupMenuItem(
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, size: 20),
                              const SizedBox(width: 8),
                              Text(langProvider.translate('تعيين كافتراضي', 'Set as Default')),
                            ],
                          ),
                          onTap: () async {
                            await FirebaseFirestore.instance
                                .collection('addresses')
                                .doc(addressId)
                                .update({'is_default': true});
                          },
                        ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            const Icon(Icons.delete, size: 20, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              langProvider.translate('حذف', 'Delete'),
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                        onTap: () async {
                          await FirebaseFirestore.instance
                              .collection('addresses')
                              .doc(addressId)
                              .delete();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ============ ADD/EDIT ADDRESS SCREEN ============

class AddEditAddressScreen extends StatefulWidget {
  final String? addressId;
  final Map<String, dynamic>? addressData;
  
  const AddEditAddressScreen({super.key, this.addressId, this.addressData});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _labelController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  String _type = 'home';
  bool _isDefault = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.addressData != null) {
      _labelController.text = widget.addressData!['label'] ?? '';
      _streetController.text = widget.addressData!['street'] ?? '';
      _cityController.text = widget.addressData!['city'] ?? '';
      _countryController.text = widget.addressData!['country'] ?? '';
      _phoneController.text = widget.addressData!['phone'] ?? '';
      _type = widget.addressData!['type'] ?? 'home';
      _isDefault = widget.addressData!['is_default'] ?? false;
    }
  }
  
  Future<void> _saveAddress() async {
    if (_labelController.text.isEmpty || _streetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء ملء جميع الحقول المطلوبة')),
      );
      return;
    }
    
    final addressData = {
      'user_id': 'b1', // Replace with actual user ID
      'label': _labelController.text,
      'street': _streetController.text,
      'city': _cityController.text,
      'country': _countryController.text,
      'phone': _phoneController.text,
      'type': _type,
      'is_default': _isDefault,
      'created_at': FieldValue.serverTimestamp(),
    };
    
    if (widget.addressId != null) {
      await FirebaseFirestore.instance
          .collection('addresses')
          .doc(widget.addressId)
          .update(addressData);
    } else {
      await FirebaseFirestore.instance
          .collection('addresses')
          .add(addressData);
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ العنوان بنجاح')),
      );
      Navigator.pop(context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final isEdit = widget.addressId != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit
              ? langProvider.translate('تعديل العنوان', 'Edit Address')
              : langProvider.translate('إضافة عنوان', 'Add Address'),
        ),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _labelController,
              decoration: InputDecoration(
                labelText: langProvider.translate('التسمية', 'Label') + ' *',
                hintText: langProvider.translate('مثال: المنزل، العمل', 'e.g: Home, Work'),
                prefixIcon: const Icon(Icons.label),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Row(
                      children: [
                        const Icon(Icons.home, size: 20),
                        const SizedBox(width: 8),
                        Text(langProvider.translate('منزل', 'Home')),
                      ],
                    ),
                    value: 'home',
                    groupValue: _type,
                    onChanged: (value) => setState(() => _type = value!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Row(
                      children: [
                        const Icon(Icons.work, size: 20),
                        const SizedBox(width: 8),
                        Text(langProvider.translate('عمل', 'Work')),
                      ],
                    ),
                    value: 'work',
                    groupValue: _type,
                    onChanged: (value) => setState(() => _type = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _streetController,
              decoration: InputDecoration(
                labelText: langProvider.translate('الشارع', 'Street') + ' *',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: langProvider.translate('المدينة', 'City') + ' *',
                prefixIcon: const Icon(Icons.location_city),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _countryController,
              decoration: InputDecoration(
                labelText: langProvider.translate('البلد', 'Country') + ' *',
                prefixIcon: const Icon(Icons.flag),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: langProvider.translate('رقم الهاتف', 'Phone') + ' *',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(langProvider.translate('تعيين كعنوان افتراضي', 'Set as Default Address')),
              subtitle: Text(langProvider.translate('سيتم استخدامه تلقائياً', 'Will be used automatically')),
              value: _isDefault,
              onChanged: (value) => setState(() => _isDefault = value),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B9AC4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                langProvider.translate('حفظ العنوان', 'Save Address'),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ USER ORDERS SCREEN ============

class UserOrdersScreen extends StatelessWidget {
  const UserOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.translate('طلباتي', 'My Orders')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('user_id', isEqualTo: 'b1') // Replace with actual user ID
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(langProvider.translate('خطأ في التحميل', 'Loading Error')));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    langProvider.translate('لا توجد طلبات', 'No Orders Yet'),
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              final orderId = orders[index].id;
              final status = order['status'] ?? 'قيد المعالجة';
              final timestamp = order['created_at'] as Timestamp?;
              final date = timestamp?.toDate() ?? DateTime.now();
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(status),
                    child: const Icon(Icons.shopping_bag, color: Colors.white, size: 20),
                  ),
                  title: Text(
                    '${langProvider.translate('طلب', 'Order')} #${orderId.substring(0, 8)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('dd/MM/yyyy').format(date),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order['total_amount'] ?? 0} ${langProvider.translate('جنيه', 'SDG')}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B9AC4),
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            langProvider.translate('تفاصيل الطلب', 'Order Details'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const Divider(),
                          _buildOrderDetail(langProvider.translate('رقم الطلب', 'Order ID'), orderId.substring(0, 12)),
                          _buildOrderDetail(langProvider.translate('الحالة', 'Status'), status),
                          _buildOrderDetail(langProvider.translate('التاريخ', 'Date'), DateFormat('dd/MM/yyyy - HH:mm').format(date)),
                          _buildOrderDetail(langProvider.translate('المبلغ الإجمالي', 'Total Amount'), '${order['total_amount']} ${langProvider.translate('جنيه', 'SDG')}'),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    // TODO: Track order
                                  },
                                  icon: const Icon(Icons.location_on, size: 18),
                                  label: Text(langProvider.translate('تتبع', 'Track')),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF6B9AC4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // TODO: Reorder
                                  },
                                  icon: const Icon(Icons.refresh, size: 18),
                                  label: Text(langProvider.translate('إعادة طلب', 'Reorder')),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6B9AC4),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  Widget _buildOrderDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label + ':', style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'مكتمل':
        return Colors.green;
      case 'قيد التوصيل':
        return Colors.orange;
      case 'ملغي':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}

// ============ SECURITY SCREEN ============

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.translate('الخصوصية والأمان', 'Privacy & Security')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock, color: Color(0xFF6B9AC4)),
              title: Text(langProvider.translate('تغيير كلمة المرور', 'Change Password')),
              subtitle: Text(langProvider.translate('تحديث كلمة المرور', 'Update Your Password')),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Implement change password
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.fingerprint, color: Color(0xFF6B9AC4)),
              title: Text(langProvider.translate('البصمة/الوجه', 'Biometric')),
              subtitle: Text(langProvider.translate('تسجيل الدخول بالبصمة', 'Login with Biometric')),
              trailing: Switch(value: false, onChanged: (v) {}),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.shield, color: Color(0xFF6B9AC4)),
              title: Text(langProvider.translate('المصادقة الثنائية', 'Two-Factor Auth')),
              subtitle: Text(langProvider.translate('طبقة أمان إضافية', 'Extra Security Layer')),
              trailing: Switch(value: false, onChanged: (v) {}),
            ),
          ),
        ],
      ),
    );
  }
}
