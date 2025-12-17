import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class WarehouseManagementScreen extends StatefulWidget {
  const WarehouseManagementScreen({super.key});

  @override
  State<WarehouseManagementScreen> createState() => _WarehouseManagementScreenState();
}

class _WarehouseManagementScreenState extends State<WarehouseManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterStatus = 'الكل';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('userEmail') ?? '';

      // تحميل بيانات التجار
      final merchantsJson = await rootBundle.loadString('assets/data/merchants.json');
      final List<dynamic> merchants = json.decode(merchantsJson);
      final merchant = merchants.firstWhere(
        (m) => m['email'] == userEmail,
        orElse: () => merchants.first,
      );

      // تحميل المنتجات
      final productsJson = await rootBundle.loadString('assets/data/products.json');
      final List<dynamic> allProducts = json.decode(productsJson);

      // فلترة منتجات التاجر فقط
      final merchantProducts = allProducts
          .where((p) => p['merchantId'] == merchant['id'])
          .toList();

      setState(() {
        _products = merchantProducts.cast<Map<String, dynamic>>();
        _filteredProducts = _products;
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

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesSearch = product['name']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());

        bool matchesStatus = true;
        if (_filterStatus == 'متوفر') {
          matchesStatus = product['inStock'] == true;
        } else if (_filterStatus == 'نفذ') {
          matchesStatus = product['inStock'] == false;
        }

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('إدارة المخزون'),
        backgroundColor: Colors.purple,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.inventory_2), text: 'المنتجات'),
            Tab(icon: Icon(Icons.warehouse), text: 'المخازن'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addNewProduct(),
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.add),
        label: const Text('إضافة منتج'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductsTab(),
          _buildWarehousesTab(),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              _buildSearchAndFilter(),
              _buildStatsBar(),
              Expanded(
                child: _filteredProducts.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadProducts,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            return _buildProductCard(_filteredProducts[index]);
                          },
                        ),
                      ),
              ),
            ],
          );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'بحث عن منتج...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) {
              _searchQuery = value;
              _filterProducts();
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFilterChip('الكل'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip('متوفر'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip('نفذ'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String status) {
    final isSelected = _filterStatus == status;
    return FilterChip(
      label: Text(status),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = status;
          _filterProducts();
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.purple.withValues(alpha: 0.2),
      checkmarkColor: Colors.purple,
      labelStyle: TextStyle(
        color: isSelected ? Colors.purple : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildStatsBar() {
    final totalProducts = _products.length;
    final inStockProducts = _products.where((p) => p['inStock'] == true).length;
    final outOfStockProducts = totalProducts - inStockProducts;
    final totalValue = _products.fold<double>(
      0,
      (sum, p) => sum + (p['price'] as num).toDouble() * (p['stockQuantity'] as num).toDouble(),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.purple.withValues(alpha: 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('الإجمالي', totalProducts.toString(), Icons.inventory),
          _buildStatItem('متوفر', inStockProducts.toString(), Icons.check_circle, Colors.green),
          _buildStatItem('نفذ', outOfStockProducts.toString(), Icons.cancel, Colors.red),
          _buildStatItem('القيمة', '${(totalValue / 1000).toStringAsFixed(1)}K', Icons.attach_money, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, [Color? color]) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color ?? Colors.purple),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.purple,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final inStock = product['inStock'] as bool;
    final stockQuantity = product['stockQuantity'] as int;
    final lowStock = stockQuantity < 10;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product['imageUrl'],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey),
                  );
                },
              ),
            ),
            title: Text(
              product['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${product['price']} SDG',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      inStock ? Icons.check_circle : Icons.cancel,
                      size: 16,
                      color: inStock ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      inStock ? 'متوفر' : 'نفذ من المخزون',
                      style: TextStyle(
                        fontSize: 12,
                        color: inStock ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (lowStock && inStock) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'مخزون منخفض',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('تعديل'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'stock',
                  child: Row(
                    children: [
                      Icon(Icons.inventory, size: 20),
                      SizedBox(width: 8),
                      Text('تحديث المخزون'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'price',
                  child: Row(
                    children: [
                      Icon(Icons.price_change, size: 20),
                      SizedBox(width: 8),
                      Text('تعديل السعر'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('حذف', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _editProduct(product);
                    break;
                  case 'stock':
                    _updateStock(product);
                    break;
                  case 'price':
                    _updatePrice(product);
                    break;
                  case 'delete':
                    _deleteProduct(product);
                    break;
                }
              },
            ),
          ),
          Divider(height: 1, color: Colors.grey[300]),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip('الكمية', stockQuantity.toString(), Icons.inventory_2),
                _buildInfoChip('المبيعات', product['totalSold'].toString(), Icons.shopping_cart),
                _buildInfoChip('التقييم', product['rating'].toString(), Icons.star, Colors.amber),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon, [Color? color]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? Colors.purple).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? Colors.purple),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color ?? Colors.purple,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarehousesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWarehouseCard(
            'المخزن الرئيسي',
            'الخرطوم - شارع النيل',
            120,
            85,
            true,
          ),
          _buildWarehouseCard(
            'مخزن الفرع الثاني',
            'أم درمان - السوق الشعبي',
            50,
            35,
            true,
          ),
          _buildWarehouseCard(
            'مخزن بحري',
            'بحري - منطقة الصناعة',
            30,
            10,
            false,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('سيتم إضافة مخزن جديد')),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('إضافة مخزن جديد'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.purple,
                side: const BorderSide(color: Colors.purple),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseCard(String name, String location, int totalItems, int lowStockItems, bool isActive) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warehouse,
                  color: isActive ? Colors.purple : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (isActive ? Colors.green : Colors.grey).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isActive ? 'نشط' : 'غير نشط',
                              style: TextStyle(
                                fontSize: 10,
                                color: isActive ? Colors.green : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            location,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWarehouseStat('إجمالي الأصناف', totalItems.toString(), Icons.inventory),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                _buildWarehouseStat('مخزون منخفض', lowStockItems.toString(), Icons.warning, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarehouseStat(String label, String value, IconData icon, [Color? color]) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.purple, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.purple,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'لا توجد منتجات',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بإضافة منتجات جديدة لمتجرك',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _addNewProduct(),
            icon: const Icon(Icons.add),
            label: const Text('إضافة منتج جديد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _addNewProduct() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة منتج جديد'),
        content: const Text('سيتم فتح نموذج إضافة منتج...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إضافة المنتج بنجاح')),
              );
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _editProduct(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل ${product['name']}'),
        content: const Text('سيتم فتح نموذج التعديل...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حفظ التعديلات')),
              );
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _updateStock(Map<String, dynamic> product) {
    final controller = TextEditingController(text: product['stockQuantity'].toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تحديث المخزون'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('المنتج: ${product['name']}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'الكمية الجديدة',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                product['stockQuantity'] = int.parse(controller.text);
                product['inStock'] = int.parse(controller.text) > 0;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحديث المخزون')),
              );
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _updatePrice(Map<String, dynamic> product) {
    final controller = TextEditingController(text: product['price'].toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل السعر'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('المنتج: ${product['name']}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'السعر الجديد (SDG)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                product['price'] = double.parse(controller.text);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحديث السعر')),
              );
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "${product['name']}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _products.remove(product);
                _filterProducts();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حذف المنتج'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
