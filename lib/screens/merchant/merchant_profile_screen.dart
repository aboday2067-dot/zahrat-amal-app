import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class MerchantProfileScreen extends StatefulWidget {
  const MerchantProfileScreen({super.key});

  @override
  State<MerchantProfileScreen> createState() => _MerchantProfileScreenState();
}

class _MerchantProfileScreenState extends State<MerchantProfileScreen> {
  Map<String, dynamic>? _merchantData;
  bool _isLoading = true;
  bool _isEditing = false;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _storeNameController;
  late TextEditingController _storeDescriptionController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _storeNameController = TextEditingController();
    _storeDescriptionController = TextEditingController();
    _addressController = TextEditingController();
    _loadMerchantData();
  }

  Future<void> _loadMerchantData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('userEmail') ?? '';

      final jsonString = await rootBundle.loadString('assets/data/merchants.json');
      final List<dynamic> merchants = json.decode(jsonString);

      // البحث عن التاجر بالبريد الإلكتروني أو أخذ أول تاجر
      final merchant = merchants.firstWhere(
        (m) => m['email'] == userEmail,
        orElse: () => merchants.first,
      );

      setState(() {
        _merchantData = merchant;
        _nameController.text = merchant['name'];
        _emailController.text = merchant['email'];
        _phoneController.text = merchant['phone'];
        _storeNameController.text = merchant['storeName'];
        _storeDescriptionController.text = merchant['storeDescription'];
        _addressController.text = merchant['address'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل البيانات: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      // محاكاة حفظ البيانات
      setState(() {
        _merchantData!['name'] = _nameController.text;
        _merchantData!['phone'] = _phoneController.text;
        _merchantData!['storeName'] = _storeNameController.text;
        _merchantData!['storeDescription'] = _storeDescriptionController.text;
        _merchantData!['address'] = _addressController.text;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ البيانات بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: Colors.blue,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMerchantData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 20),
                      _buildStatsCards(),
                      const SizedBox(height: 20),
                      _buildPersonalInfoSection(),
                      const SizedBox(height: 20),
                      _buildStoreInfoSection(),
                      const SizedBox(height: 20),
                      _buildLocationSection(),
                      const SizedBox(height: 20),
                      _buildStatusSection(),
                      if (_isEditing) ...[
                        const SizedBox(height: 20),
                        _buildActionButtons(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.store,
              size: 40,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _merchantData!['storeName'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _merchantData!['name'],
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      _merchantData!['rating'].toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (_merchantData!['isVerified'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.verified, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'موثق',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
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
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'المنتجات',
            _merchantData!['totalProducts'].toString(),
            Icons.inventory_2,
            Colors.purple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'الطلبات',
            _merchantData!['totalOrders'].toString(),
            Icons.shopping_bag,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'الإيرادات',
            '${(_merchantData!['totalRevenue'] / 1000).toStringAsFixed(1)}K',
            Icons.attach_money,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      'المعلومات الشخصية',
      Icons.person,
      [
        _buildTextField(
          'الاسم',
          _nameController,
          Icons.person_outline,
          enabled: _isEditing,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'البريد الإلكتروني',
          _emailController,
          Icons.email_outlined,
          enabled: false, // البريد لا يتغير
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'الهاتف',
          _phoneController,
          Icons.phone_outlined,
          enabled: _isEditing,
        ),
      ],
    );
  }

  Widget _buildStoreInfoSection() {
    return _buildSection(
      'معلومات المتجر',
      Icons.store,
      [
        _buildTextField(
          'اسم المتجر',
          _storeNameController,
          Icons.storefront,
          enabled: _isEditing,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'وصف المتجر',
          _storeDescriptionController,
          Icons.description,
          maxLines: 3,
          enabled: _isEditing,
        ),
        const SizedBox(height: 12),
        _buildInfoRow('الفئة', _merchantData!['category'], Icons.category),
      ],
    );
  }

  Widget _buildLocationSection() {
    return _buildSection(
      'الموقع',
      Icons.location_on,
      [
        _buildTextField(
          'العنوان',
          _addressController,
          Icons.home_outlined,
          enabled: _isEditing,
        ),
        const SizedBox(height: 12),
        _buildInfoRow('المدينة', _merchantData!['city'], Icons.location_city),
        const SizedBox(height: 12),
        _buildInfoRow('الولاية', _merchantData!['state'], Icons.map),
      ],
    );
  }

  Widget _buildStatusSection() {
    return _buildSection(
      'حالة الحساب',
      Icons.info_outline,
      [
        _buildInfoRow(
          'الحالة',
          _merchantData!['isActive'] ? 'نشط' : 'غير نشط',
          Icons.power_settings_new,
          valueColor: _merchantData!['isActive'] ? Colors.green : Colors.red,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          'التوثيق',
          _merchantData!['isVerified'] ? 'موثق' : 'غير موثق',
          Icons.verified_user,
          valueColor: _merchantData!['isVerified'] ? Colors.green : Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          'تاريخ الانضمام',
          _formatDate(_merchantData!['joinedDate']),
          Icons.calendar_today,
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue, size: 24),
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
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool enabled = true,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'هذا الحقل مطلوب';
        }
        return null;
      },
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveProfile,
            icon: const Icon(Icons.save),
            label: const Text('حفظ التغييرات'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _isEditing = false;
                _nameController.text = _merchantData!['name'];
                _phoneController.text = _merchantData!['phone'];
                _storeNameController.text = _merchantData!['storeName'];
                _storeDescriptionController.text = _merchantData!['storeDescription'];
                _addressController.text = _merchantData!['address'];
              });
            },
            icon: const Icon(Icons.cancel),
            label: const Text('إلغاء'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _storeNameController.dispose();
    _storeDescriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
