import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'add_edit_merchant_screen.dart';

class ManageMerchantsScreen extends StatefulWidget {
  const ManageMerchantsScreen({super.key});

  @override
  State<ManageMerchantsScreen> createState() => _ManageMerchantsScreenState();
}

class _ManageMerchantsScreenState extends State<ManageMerchantsScreen> {
  List<Map<String, dynamic>> _merchants = [];
  List<Map<String, dynamic>> _filteredMerchants = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterCategory = 'الكل';

  @override
  void initState() {
    super.initState();
    _loadMerchants();
  }

  Future<void> _loadMerchants() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/merchants.json');
      final List<dynamic> data = json.decode(jsonString);
      setState(() {
        _merchants = data.cast<Map<String, dynamic>>();
        _filteredMerchants = _merchants;
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

  void _filterMerchants() {
    setState(() {
      _filteredMerchants = _merchants.where((merchant) {
        final matchesSearch = merchant['storeName']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            merchant['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesCategory = _filterCategory == 'الكل' || merchant['category'] == _filterCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['الكل', ...{..._merchants.map((m) => m['category'] as String)}];

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة التجار'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addMerchant(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadMerchants();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search and Filter Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'بحث عن تاجر...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          _searchQuery = value;
                          _filterMerchants();
                        },
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: categories.map((category) {
                            final isSelected = category == _filterCategory;
                            return Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: FilterChip(
                                label: Text(category),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _filterCategory = category;
                                    _filterMerchants();
                                  });
                                },
                                backgroundColor: Colors.white,
                                selectedColor: Colors.blue.withValues(alpha: 0.2),
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.blue : Colors.grey[700],
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Stats Summary
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.blue.withValues(alpha: 0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('إجمالي التجار', _merchants.length.toString(), Icons.store),
                      _buildStatItem(
                        'موثق',
                        _merchants.where((m) => m['isVerified'] == true).length.toString(),
                        Icons.verified,
                      ),
                      _buildStatItem('نتائج البحث', _filteredMerchants.length.toString(), Icons.search),
                    ],
                  ),
                ),

                // Merchants List
                Expanded(
                  child: _filteredMerchants.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد نتائج',
                                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredMerchants.length,
                          itemBuilder: (context, index) {
                            final merchant = _filteredMerchants[index];
                            return _buildMerchantCard(merchant);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMerchantCard(Map<String, dynamic> merchant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.blue.withValues(alpha: 0.1),
          child: const Icon(Icons.store, color: Colors.blue, size: 28),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                merchant['storeName'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            if (merchant['isVerified'] == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    const Text(
                      'موثق',
                      style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(merchant['name'], style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.category, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(merchant['category'], style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(width: 12),
                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(merchant['city'], style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
        children: [
          Divider(height: 1, color: Colors.grey[300]),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.email, 'البريد الإلكتروني', merchant['email']),
                _buildInfoRow(Icons.phone, 'الهاتف', merchant['phone']),
                _buildInfoRow(Icons.location_city, 'العنوان', merchant['address']),
                _buildInfoRow(Icons.map, 'الولاية', merchant['state']),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatChip(
                      Icons.inventory,
                      'المنتجات',
                      merchant['totalProducts'].toString(),
                      Colors.purple,
                    ),
                    _buildStatChip(
                      Icons.shopping_bag,
                      'الطلبات',
                      merchant['totalOrders'].toString(),
                      Colors.orange,
                    ),
                    _buildStatChip(
                      Icons.star,
                      'التقييم',
                      merchant['rating'].toString(),
                      Colors.amber,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_money, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'إجمالي الإيرادات: ${(merchant['totalRevenue'] as num).toStringAsFixed(0)} SDG',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: (merchant['paymentMethods'] as List).map((method) {
                    return Chip(
                      label: Text(method),
                      backgroundColor: Colors.teal.withValues(alpha: 0.1),
                      labelStyle: const TextStyle(fontSize: 11, color: Colors.teal),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editMerchant(merchant),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('تعديل'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteMerchant(merchant),
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('حذف'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
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
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
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
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Future<void> _addMerchant() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditMerchantScreen(),
      ),
    );
    if (result == true) {
      _loadMerchants();
    }
  }

  Future<void> _editMerchant(Map<String, dynamic> merchant) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditMerchantScreen(merchant: merchant),
      ),
    );
    if (result == true) {
      _loadMerchants();
    }
  }

  Future<void> _deleteMerchant(Map<String, dynamic> merchant) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل تريد حذف التاجر "${merchant['storeName']}"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      setState(() {
        _merchants.removeWhere((m) => m['id'] == merchant['id']);
        _filterMerchants();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف التاجر بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
