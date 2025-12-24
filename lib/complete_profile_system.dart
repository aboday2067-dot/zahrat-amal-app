// ============================================
// نظام الملف الشخصي المتكامل
// Complete Profile System with Full Data
// ============================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'main.dart'; // للوصول إلى Providers
import 'profile_image_upload.dart'; // نظام رفع الصور
import 'firebase_orders_system.dart'; // نظام الطلبات مع Firebase
import 'notifications_system.dart' as notify_system; // نظام الإشعارات

// ========== نموذج بيانات المستخدم ==========
class UserProfileData {
  final String name;
  final String email;
  final String phone;
  final String city;
  final String district;
  final String role;
  final String joinDate;
  final String? profileImage;
  final int totalOrders;
  final int totalSpent;
  final int loyaltyPoints;
  
  UserProfileData({
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.district,
    required this.role,
    required this.joinDate,
    this.profileImage,
    this.totalOrders = 0,
    this.totalSpent = 0,
    this.loyaltyPoints = 0,
  });
  
  factory UserProfileData.fromPrefs(SharedPreferences prefs) {
    return UserProfileData(
      name: prefs.getString('userName') ?? 'أحمد محمد علي',
      email: prefs.getString('userEmail') ?? 'ahmed.mohamed@email.com',
      phone: prefs.getString('userPhone') ?? '+249 91 234 5678',
      city: prefs.getString('userCity') ?? 'الخرطوم',
      district: prefs.getString('userDistrict') ?? 'الخرطوم 2',
      role: prefs.getString('userRole') ?? 'مشتري',
      joinDate: prefs.getString('joinDate') ?? '2024-01-15',
      profileImage: prefs.getString('profileImage'),
      totalOrders: prefs.getInt('totalOrders') ?? 0,
      totalSpent: prefs.getInt('totalSpent') ?? 0,
      loyaltyPoints: prefs.getInt('loyaltyPoints') ?? 0,
    );
  }
  
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
    await prefs.setString('userPhone', phone);
    await prefs.setString('userCity', city);
    await prefs.setString('userDistrict', district);
    await prefs.setString('userRole', role);
    await prefs.setString('joinDate', joinDate);
    if (profileImage != null) {
      await prefs.setString('profileImage', profileImage!);
    }
    await prefs.setInt('totalOrders', totalOrders);
    await prefs.setInt('totalSpent', totalSpent);
    await prefs.setInt('loyaltyPoints', loyaltyPoints);
  }
}

// ========== نموذج العنوان ==========
class Address {
  final String id;
  final String label;
  final String fullAddress;
  final String city;
  final String district;
  final String phone;
  final bool isDefault;
  
  Address({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.city,
    required this.district,
    required this.phone,
    this.isDefault = false,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'fullAddress': fullAddress,
    'city': city,
    'district': district,
    'phone': phone,
    'isDefault': isDefault,
  };
  
  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json['id'],
    label: json['label'],
    fullAddress: json['fullAddress'],
    city: json['city'],
    district: json['district'],
    phone: json['phone'],
    isDefault: json['isDefault'] ?? false,
  );
}

// ========== صفحة الملف الشخصي المتكاملة ==========
class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  UserProfileData? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userData = UserProfileData.fromPrefs(prefs);
      isLoading = false;
    });
  }

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
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(userData: userData!),
                ),
              ).then((_) => _loadUserData());
            },
          ),
        ],
      ),
      body: isLoading || userData == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // صورة البروفايل
                  _buildProfileHeader(context, userData!, langProvider),
                  const SizedBox(height: 24),

                  // الإحصائيات
                  _buildStatsRow(context, userData!, langProvider),
                  const SizedBox(height: 24),

                  // المعلومات الشخصية
                  _buildInfoCard(
                    context,
                    langProvider.translate('المعلومات الشخصية', 'Personal Info'),
                    Icons.person,
                    [
                      _buildInfoRow(Icons.email, langProvider.translate('البريد الإلكتروني', 'Email'), userData!.email),
                      _buildInfoRow(Icons.phone, langProvider.translate('الهاتف', 'Phone'), userData!.phone),
                      _buildInfoRow(Icons.location_city, langProvider.translate('المدينة', 'City'), userData!.city),
                      _buildInfoRow(Icons.home, langProvider.translate('الحي', 'District'), userData!.district),
                      _buildInfoRow(Icons.calendar_today, langProvider.translate('تاريخ الانضمام', 'Join Date'), userData!.joinDate),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // الخيارات السريعة
                  _buildActionCard(
                    context,
                    langProvider.translate('الخيارات', 'Quick Actions'),
                    Icons.dashboard,
                    [
                      ListTile(
                        leading: const Icon(Icons.shopping_bag, color: Color(0xFF6B9AC4)),
                        title: Text(langProvider.translate('طلباتي', 'My Orders')),
                        subtitle: Text(langProvider.translate('عرض جميع الطلبات', 'View all orders')),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const FirebaseOrdersHistoryScreen()),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.location_on, color: Color(0xFF6B9AC4)),
                        title: Text(langProvider.translate('عناويني', 'My Addresses')),
                        subtitle: Text(langProvider.translate('إدارة عناوين التوصيل', 'Manage delivery addresses')),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddressManagementScreen()),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.favorite, color: Color(0xFF6B9AC4)),
                        title: Text(langProvider.translate('المفضلة', 'Favorites')),
                        subtitle: Text(langProvider.translate('المنتجات المحفوظة', 'Saved products')),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // الانتقال لصفحة المفضلة
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.notifications, color: Color(0xFF6B9AC4)),
                        title: Text(langProvider.translate('الإشعارات', 'Notifications')),
                        subtitle: Text(langProvider.translate('إدارة الإشعارات', 'Manage notifications')),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const notify_system.NotificationsScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // الإعدادات
                  _buildSettingsCard(context, themeProvider, langProvider),
                  const SizedBox(height: 16),

                  // زر تسجيل الخروج
                  ElevatedButton.icon(
                    onPressed: () => _handleLogout(context, langProvider),
                    icon: const Icon(Icons.logout),
                    label: Text(
                      langProvider.translate('تسجيل الخروج', 'Logout'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfileData data, LanguageProvider lang) {
    return Center(
      child: Column(
        children: [
          ProfileImageWidget(
            imageUrl: data.profileImage,
            radius: 60,
            onImageChanged: _loadUserData,
          ),
          const SizedBox(height: 16),
          Text(
            data.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_user, size: 16, color: Colors.green),
                const SizedBox(width: 6),
                Text(
                  data.role,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, UserProfileData data, LanguageProvider lang) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            lang.translate('الطلبات', 'Orders'),
            data.totalOrders.toString(),
            Icons.shopping_bag,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            lang.translate('الإنفاق', 'Spent'),
            '${data.totalSpent} ${lang.translate('ج', 'SDG')}',
            Icons.attach_money,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            lang.translate('النقاط', 'Points'),
            data.loyaltyPoints.toString(),
            Icons.stars,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF6B9AC4)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF6B9AC4)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, ThemeProvider theme, LanguageProvider lang) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.settings, color: Color(0xFF6B9AC4)),
                const SizedBox(width: 8),
                Text(
                  lang.translate('الإعدادات', 'Settings'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SwitchListTile(
            title: Text(lang.translate('الوضع الليلي', 'Dark Mode')),
            subtitle: Text(lang.translate('تفعيل الوضع المظلم', 'Enable dark theme')),
            value: theme.isDarkMode,
            onChanged: (value) => theme.toggleTheme(),
            secondary: Icon(theme.isDarkMode ? Icons.dark_mode : Icons.light_mode),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(lang.translate('اللغة', 'Language')),
            subtitle: Text(lang.isArabic ? 'العربية' : 'English'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => lang.toggleLanguage(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, LanguageProvider lang) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.translate('تأكيد', 'Confirm')),
        content: Text(lang.translate('هل تريد تسجيل الخروج؟', 'Are you sure you want to logout?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(lang.translate('إلغاء', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(lang.translate('تسجيل الخروج', 'Logout')),
          ),
        ],
      ),
    );
    
    if (confirm == true && context.mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}

// ========== صفحة تعديل الملف الشخصي ==========
class EditProfileScreen extends StatefulWidget {
  final UserProfileData userData;
  
  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController cityController;
  late TextEditingController districtController;
  
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.userData.name);
    phoneController = TextEditingController(text: widget.userData.phone);
    cityController = TextEditingController(text: widget.userData.city);
    districtController = TextEditingController(text: widget.userData.district);
  }
  
  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    cityController.dispose();
    districtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('تعديل الملف الشخصي', 'Edit Profile')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: lang.translate('الاسم', 'Name'),
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: phoneController,
            decoration: InputDecoration(
              labelText: lang.translate('الهاتف', 'Phone'),
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: cityController,
            decoration: InputDecoration(
              labelText: lang.translate('المدينة', 'City'),
              prefixIcon: const Icon(Icons.location_city),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: districtController,
            decoration: InputDecoration(
              labelText: lang.translate('الحي', 'District'),
              prefixIcon: const Icon(Icons.home),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final updatedData = UserProfileData(
                name: nameController.text,
                email: widget.userData.email,
                phone: phoneController.text,
                city: cityController.text,
                district: districtController.text,
                role: widget.userData.role,
                joinDate: widget.userData.joinDate,
                profileImage: widget.userData.profileImage,
                totalOrders: widget.userData.totalOrders,
                totalSpent: widget.userData.totalSpent,
                loyaltyPoints: widget.userData.loyaltyPoints,
              );
              
              await updatedData.save();
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(lang.translate('تم حفظ التغييرات', 'Changes saved')),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B9AC4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              lang.translate('حفظ التغييرات', 'Save Changes'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ========== صفحة إدارة العناوين ==========
class AddressManagementScreen extends StatefulWidget {
  const AddressManagementScreen({super.key});

  @override
  State<AddressManagementScreen> createState() => _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> {
  List<Address> addresses = [
    Address(
      id: '1',
      label: 'المنزل',
      fullAddress: 'شارع الجامعة، مربع 15، منزل 234',
      city: 'الخرطوم',
      district: 'الخرطوم 2',
      phone: '+249 91 234 5678',
      isDefault: true,
    ),
    Address(
      id: '2',
      label: 'العمل',
      fullAddress: 'شارع النيل، برج الأعمال، الطابق 5',
      city: 'الخرطوم',
      district: 'الخرطوم',
      phone: '+249 91 234 5678',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('عناويني', 'My Addresses')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final address = addresses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: address.isDefault
                    ? const Color(0xFF6B9AC4)
                    : Colors.grey[300],
                child: Icon(
                  address.isDefault ? Icons.home : Icons.location_on,
                  color: address.isDefault ? Colors.white : Colors.grey[600],
                ),
              ),
              title: Row(
                children: [
                  Text(
                    address.label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (address.isDefault) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        lang.translate('افتراضي', 'Default'),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(address.fullAddress),
                  const SizedBox(height: 4),
                  Text(
                    '${address.city}, ${address.district}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.phone,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Text(lang.translate('تعديل', 'Edit')),
                    onTap: () {
                      // تعديل العنوان
                    },
                  ),
                  if (!address.isDefault)
                    PopupMenuItem(
                      child: Text(lang.translate('جعله افتراضي', 'Set as default')),
                      onTap: () {
                        setState(() {
                          for (var addr in addresses) {
                            addr = Address(
                              id: addr.id,
                              label: addr.label,
                              fullAddress: addr.fullAddress,
                              city: addr.city,
                              district: addr.district,
                              phone: addr.phone,
                              isDefault: addr.id == address.id,
                            );
                          }
                        });
                      },
                    ),
                  PopupMenuItem(
                    child: Text(
                      lang.translate('حذف', 'Delete'),
                      style: const TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      setState(() {
                        addresses.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNewAddressScreen()),
          );
        },
        backgroundColor: const Color(0xFF6B9AC4),
        icon: const Icon(Icons.add),
        label: Text(lang.translate('إضافة عنوان', 'Add Address')),
      ),
    );
  }
}

// ========== صفحة إضافة عنوان جديد ==========
class AddNewAddressScreen extends StatefulWidget {
  const AddNewAddressScreen({super.key});

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final labelController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final phoneController = TextEditingController();
  bool isDefault = false;

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('إضافة عنوان جديد', 'Add New Address')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: labelController,
            decoration: InputDecoration(
              labelText: lang.translate('التسمية (مثلاً: المنزل، العمل)', 'Label (e.g., Home, Work)'),
              prefixIcon: const Icon(Icons.label),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: addressController,
            decoration: InputDecoration(
              labelText: lang.translate('العنوان الكامل', 'Full Address'),
              prefixIcon: const Icon(Icons.location_on),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: cityController,
            decoration: InputDecoration(
              labelText: lang.translate('المدينة', 'City'),
              prefixIcon: const Icon(Icons.location_city),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: districtController,
            decoration: InputDecoration(
              labelText: lang.translate('الحي', 'District'),
              prefixIcon: const Icon(Icons.home),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: phoneController,
            decoration: InputDecoration(
              labelText: lang.translate('رقم الهاتف', 'Phone Number'),
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(lang.translate('جعله عنواناً افتراضياً', 'Set as default address')),
            value: isDefault,
            onChanged: (value) {
              setState(() {
                isDefault = value;
              });
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // حفظ العنوان
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(lang.translate('تم إضافة العنوان', 'Address added')),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B9AC4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              lang.translate('حفظ العنوان', 'Save Address'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ========== صفحة سجل الطلبات ==========
class MyOrdersHistoryScreen extends StatelessWidget {
  const MyOrdersHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    // بيانات تجريبية للطلبات
    final orders = [
      {
        'id': 'ORD-001',
        'date': '2024-12-25',
        'status': 'تم التوصيل',
        'statusEn': 'Delivered',
        'total': 1250,
        'items': 3,
        'color': Colors.green,
      },
      {
        'id': 'ORD-002',
        'date': '2024-12-28',
        'status': 'قيد التوصيل',
        'statusEn': 'In Delivery',
        'total': 890,
        'items': 2,
        'color': Colors.blue,
      },
      {
        'id': 'ORD-003',
        'date': '2025-01-02',
        'status': 'قيد المعالجة',
        'statusEn': 'Processing',
        'total': 2350,
        'items': 5,
        'color': Colors.orange,
      },
      {
        'id': 'ORD-004',
        'date': '2025-01-05',
        'status': 'ملغي',
        'statusEn': 'Cancelled',
        'total': 450,
        'items': 1,
        'color': Colors.red,
      },
    ];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('طلباتي', 'My Orders')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: (order['color'] as Color).withValues(alpha: 0.2),
                child: Icon(
                  Icons.shopping_bag,
                  color: order['color'] as Color,
                ),
              ),
              title: Row(
                children: [
                  Text(
                    order['id'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (order['color'] as Color).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      lang.isArabic ? order['status'] as String : order['statusEn'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: order['color'] as Color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text('${lang.translate('التاريخ', 'Date')}: ${order['date']}'),
                  const SizedBox(height: 4),
                  Text(
                    '${lang.translate('عدد المنتجات', 'Items')}: ${order['items']}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${lang.translate('الإجمالي', 'Total')}: ${order['total']} ${lang.translate('ج', 'SDG')}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B9AC4),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // عرض تفاصيل الطلب
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('${lang.translate('تفاصيل الطلب', 'Order Details')} ${order['id']}'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${lang.translate('التاريخ', 'Date')}: ${order['date']}'),
                        const SizedBox(height: 8),
                        Text('${lang.translate('الحالة', 'Status')}: ${lang.isArabic ? order['status'] : order['statusEn']}'),
                        const SizedBox(height: 8),
                        Text('${lang.translate('عدد المنتجات', 'Items')}: ${order['items']}'),
                        const SizedBox(height: 8),
                        Text('${lang.translate('الإجمالي', 'Total')}: ${order['total']} ${lang.translate('ج', 'SDG')}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(lang.translate('إغلاق', 'Close')),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
