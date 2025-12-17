import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'add_edit_delivery_screen.dart';

class ManageDeliveryOfficesScreen extends StatefulWidget {
  const ManageDeliveryOfficesScreen({super.key});

  @override
  State<ManageDeliveryOfficesScreen> createState() => _ManageDeliveryOfficesScreenState();
}

class _ManageDeliveryOfficesScreenState extends State<ManageDeliveryOfficesScreen> {
  List<Map<String, dynamic>> _deliveryOffices = [];
  List<Map<String, dynamic>> _filteredOffices = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDeliveryOffices();
  }

  Future<void> _loadDeliveryOffices() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/delivery_offices.json');
      final List<dynamic> data = json.decode(jsonString);
      setState(() {
        _deliveryOffices = data.cast<Map<String, dynamic>>();
        _filteredOffices = _deliveryOffices;
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

  void _filterOffices() {
    setState(() {
      _filteredOffices = _deliveryOffices.where((office) {
        return office['name']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()) ||
            office['city'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  Future<void> _addOffice() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditDeliveryScreen(),
      ),
    );
    if (result == true) {
      _loadDeliveryOffices();
    }
  }

  Future<void> _editOffice(Map<String, dynamic> office) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditDeliveryScreen(delivery: office),
      ),
    );
    if (result == true) {
      _loadDeliveryOffices();
    }
  }

  Future<void> _deleteOffice(Map<String, dynamic> office) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل تريد حذف مكتب "${office['name']}"؟'),
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
        _deliveryOffices.removeWhere((d) => d['id'] == office['id']);
        _filterOffices();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف مكتب التوصيل بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة مكاتب التوصيل'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addOffice,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() => _isLoading = true);
                _loadDeliveryOffices();
              },
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey[100],
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'بحث عن مكتب توصيل...',
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
                        _filterOffices();
                      },
                    ),
                  ),

                  // Stats Summary
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: Colors.orange.withValues(alpha: 0.1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('إجمالي المكاتب', _deliveryOffices.length.toString()),
                        _buildStatItem('نتائج البحث', _filteredOffices.length.toString()),
                      ],
                    ),
                  ),

                  // Offices List
                  Expanded(
                    child: _filteredOffices.isEmpty
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
                            itemCount: _filteredOffices.length,
                            itemBuilder: (context, index) {
                              final office = _filteredOffices[index];
                              return _buildOfficeCard(office);
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildOfficeCard(Map<String, dynamic> office) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.orange.withValues(alpha: 0.1),
          child: const Icon(Icons.local_shipping, color: Colors.orange, size: 28),
        ),
        title: Text(
          office['name'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_city, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(office['city'], style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.phone, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(office['phone'], style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
                _buildInfoRow(Icons.email, 'البريد الإلكتروني', office['email']),
                _buildInfoRow(Icons.location_on, 'العنوان', office['address']),
                const SizedBox(height: 12),
                const Text(
                  'مناطق التغطية:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (office['coverage_areas'] as List).map((area) {
                    return Chip(
                      label: Text(area),
                      backgroundColor: Colors.orange.withValues(alpha: 0.1),
                      labelStyle: const TextStyle(fontSize: 11, color: Colors.orange),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editOffice(office),
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
                        onPressed: () => _deleteOffice(office),
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
}
