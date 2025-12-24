import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart';
import 'admin_messaging_system.dart';
import 'merchants_approval_system.dart';
import 'delivery_approval_system.dart';
import 'admin_auth_system.dart';
import 'admin_user_details_system.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // إنشاء حساب المدير الافتراضي إذا لم يكن موجوداً
  await AdminAuthSystem().createDefaultAdmin();
  
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'لوحة إدارة زهرة الأمل',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B9AC4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/admin-login',
      routes: {
        '/admin-login': (context) => const AdminLoginScreen(),
        '/admin-dashboard': (context) => const AdminDashboard(),
        '/admin-profile': (context) => const AdminProfileScreen(),
      },
      home: const AdminLoginScreen(),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardHome(),
    AdminUserDetailsSystem(), // نظام عرض بيانات الأعضاء التفصيلية
    ProductsManagement(),
    OrdersManagement(),
    MerchantsManagement(),
    DeliveryOfficesManagement(),
    NotificationsManagement(),
    AdminMessagingSystemPage(), // نظام المراسلة الفورية
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة إدارة زهرة الأمل'),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/admin-profile');
            },
            tooltip: 'الملف الشخصي',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'تحديث',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF6B9AC4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.admin_panel_settings, size: 50, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'لوحة الإدارة',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Admin Dashboard',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(0, Icons.dashboard, 'لوحة المعلومات', 'Dashboard'),
            _buildDrawerItem(1, Icons.people, 'بيانات الأعضاء', 'User Details'),
            _buildDrawerItem(2, Icons.inventory, 'المنتجات', 'Products'),
            _buildDrawerItem(3, Icons.shopping_cart, 'الطلبات', 'Orders'),
            _buildDrawerItem(4, Icons.store, 'التجار', 'Merchants'),
            _buildDrawerItem(5, Icons.local_shipping, 'مكاتب التوصيل', 'Delivery'),
            _buildDrawerItem(6, Icons.notifications, 'الإشعارات', 'Notifications'),
            _buildDrawerItem(7, Icons.chat, 'المراسلة الفورية', 'Messaging'),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text('الملف الشخصي'),
              subtitle: const Text('Admin Profile', style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pushNamed(context, '/admin-profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('تسجيل الخروج'),
              subtitle: const Text('Logout', style: TextStyle(fontSize: 12)),
              onTap: () async {
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
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/admin-login');
                  }
                }
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }

  Widget _buildDrawerItem(int index, IconData icon, String title, String subtitle) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFF6B9AC4) : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF6B9AC4) : Colors.black,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      selected: isSelected,
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }
}

// ========== Dashboard Home ==========
class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 لوحة المعلومات',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Statistics Cards
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, usersSnapshot) {
              final usersCount = usersSnapshot.data?.docs.length ?? 0;
              
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('products').snapshots(),
                builder: (context, productsSnapshot) {
                  final productsCount = productsSnapshot.data?.docs.length ?? 0;
                  
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('orders').snapshots(),
                    builder: (context, ordersSnapshot) {
                      final ordersCount = ordersSnapshot.data?.docs.length ?? 0;
                      
                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('merchants').snapshots(),
                        builder: (context, merchantsSnapshot) {
                          final merchantsCount = merchantsSnapshot.data?.docs.length ?? 0;
                          
                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.5,
                            children: [
                              _buildStatCard('المستخدمين', usersCount, Icons.people, Colors.blue),
                              _buildStatCard('المنتجات', productsCount, Icons.inventory, Colors.green),
                              _buildStatCard('الطلبات', ordersCount, Icons.shopping_cart, Colors.orange),
                              _buildStatCard('التجار', merchantsCount, Icons.store, Colors.purple),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 30),
          // Recent Orders
          const Text(
            '📦 آخر الطلبات',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .orderBy('createdAt', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.data!.docs.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text('لا توجد طلبات بعد')),
                  ),
                );
              }
              
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final order = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF6B9AC4),
                        child: Icon(Icons.shopping_bag, color: Colors.white),
                      ),
                      title: Text('طلب #${order['orderId'] ?? 'N/A'}'),
                      subtitle: Text('العميل: ${order['customerName'] ?? 'غير محدد'}'),
                      trailing: Text(
                        '${order['total'] ?? 0} ج',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              count.toString(),
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
            ),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ========== Users Management ==========
class UsersManagement extends StatelessWidget {
  const UsersManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('👥 إدارة المستخدمين', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddUserDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('إضافة مستخدم'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B9AC4),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('لا يوجد مستخدمين'));
              }
              
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final user = doc.data() as Map<String, dynamic>;
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF6B9AC4),
                        child: Text(user['name']?.substring(0, 1) ?? 'U'),
                      ),
                      title: Text(user['name'] ?? 'غير محدد'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('📧 ${user['email'] ?? ''}'),
                          Text('📱 ${user['phone'] ?? ''}'),
                          Text('👤 ${user['role'] ?? 'buyer'}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditUserDialog(context, doc.id, user),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteUser(context, doc.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddUserDialog(BuildContext context) {
    // TODO: Implement add user dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('استخدم صفحة التسجيل في التطبيق الرئيسي')),
    );
  }

  void _showEditUserDialog(BuildContext context, String userId, Map<String, dynamic> user) {
    // TODO: Implement edit user dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('قريباً...')),
    );
  }

  void _deleteUser(BuildContext context, String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا المستخدم؟'),
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
    );
    
    if (confirm == true) {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ تم حذف المستخدم'), backgroundColor: Colors.green),
        );
      }
    }
  }
}

// ========== Products Management =========
class ProductsManagement extends StatelessWidget {
  const ProductsManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('📦 إدارة المنتجات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddProductScreen()),
                ),
                icon: const Icon(Icons.add),
                label: const Text('إضافة منتج'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B9AC4),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('products').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 20),
                      Text('لا توجد منتجات', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      SizedBox(height: 10),
                      Text('اضغط على زر "إضافة منتج" لإضافة منتج جديد'),
                    ],
                  ),
                );
              }
              
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final product = doc.data() as Map<String, dynamic>;
                  
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.grey[200],
                            child: product['images'] != null && (product['images'] as List).isNotEmpty
                                ? Image.network(
                                    product['images'][0],
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(child: Icon(Icons.image, size: 50));
                                    },
                                  )
                                : const Center(child: Icon(Icons.image, size: 50)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'] ?? 'بدون اسم',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${product['price'] ?? 0} ج',
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditProductScreen(productId: doc.id, product: product),
                                        ),
                                      ),
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Expanded(
                                    child: IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      onPressed: () => _deleteProduct(context, doc.id),
                                      color: Colors.red,
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
        ),
      ],
    );
  }

  void _deleteProduct(BuildContext context, String productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا المنتج؟'),
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
    );
    
    if (confirm == true) {
      await FirebaseFirestore.instance.collection('products').doc(productId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ تم حذف المنتج'), backgroundColor: Colors.green),
        );
      }
    }
  }
}

// ========== Add Product Screen ==========
class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _inStock = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة منتج جديد'),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'اسم المنتج*',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'الاسم مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'السعر (بالجنيه)*',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty ?? true ? 'السعر مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'الوصف*',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
              validator: (value) => value?.isEmpty ?? true ? 'الوصف مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'الفئة*',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'الفئة مطلوبة' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'الكمية المتوفرة*',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty ?? true ? 'الكمية مطلوبة' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imageUrlController,
              decoration: InputDecoration(
                labelText: 'رابط الصورة',
                hintText: 'https://example.com/image.jpg',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('متوفر في المخزون'),
              value: _inStock,
              onChanged: (value) => setState(() => _inStock = value),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _addProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B9AC4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('إضافة المنتج', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final productId = 'PROD-${DateTime.now().millisecondsSinceEpoch}';
      
      await FirebaseFirestore.instance.collection('products').doc(productId).set({
        'productId': productId,
        'name': _nameController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0,
        'description': _descriptionController.text.trim(),
        'category': _categoryController.text.trim(),
        'quantity': int.tryParse(_quantityController.text) ?? 0,
        'images': _imageUrlController.text.isNotEmpty ? [_imageUrlController.text.trim()] : [],
        'inStock': _inStock,
        'rating': 5.0,
        'reviewsCount': 0,
        'merchantId': 'ADMIN',
        'merchantName': 'الإدارة',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ تم إضافة المنتج بنجاح'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}

// ========== Edit Product Screen ==========
class EditProductScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> product;

  const EditProductScreen({super.key, required this.productId, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _quantityController;
  late TextEditingController _imageUrlController;
  late bool _inStock;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product['name']);
    _priceController = TextEditingController(text: widget.product['price']?.toString());
    _descriptionController = TextEditingController(text: widget.product['description']);
    _categoryController = TextEditingController(text: widget.product['category']);
    _quantityController = TextEditingController(text: widget.product['quantity']?.toString());
    final images = widget.product['images'] as List?;
    _imageUrlController = TextEditingController(text: images != null && images.isNotEmpty ? images[0] : '');
    _inStock = widget.product['inStock'] ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل المنتج'),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'اسم المنتج*',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'الاسم مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'السعر (بالجنيه)*',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty ?? true ? 'السعر مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'الوصف*',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
              validator: (value) => value?.isEmpty ?? true ? 'الوصف مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'الفئة*',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'الفئة مطلوبة' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'الكمية المتوفرة*',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty ?? true ? 'الكمية مطلوبة' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imageUrlController,
              decoration: InputDecoration(
                labelText: 'رابط الصورة',
                hintText: 'https://example.com/image.jpg',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('متوفر في المخزون'),
              value: _inStock,
              onChanged: (value) => setState(() => _inStock = value),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B9AC4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('حفظ التغييرات', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('products').doc(widget.productId).update({
        'name': _nameController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0,
        'description': _descriptionController.text.trim(),
        'category': _categoryController.text.trim(),
        'quantity': int.tryParse(_quantityController.text) ?? 0,
        'images': _imageUrlController.text.isNotEmpty ? [_imageUrlController.text.trim()] : [],
        'inStock': _inStock,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ تم تحديث المنتج بنجاح'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}

// ========== Orders Management ==========
class OrdersManagement extends StatelessWidget {
  const OrdersManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('📦 إدارة الطلبات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('orders').orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('لا توجد طلبات'));
              }
              
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final order = doc.data() as Map<String, dynamic>;
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ExpansionTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF6B9AC4),
                        child: Icon(Icons.shopping_cart, color: Colors.white),
                      ),
                      title: Text('طلب #${order['orderId'] ?? doc.id}'),
                      subtitle: Text('${order['customerName'] ?? 'غير محدد'} - ${order['total'] ?? 0} ج'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('📱 الهاتف: ${order['customerPhone'] ?? 'غير محدد'}'),
                              Text('📍 العنوان: ${order['deliveryAddress'] ?? 'غير محدد'}'),
                              Text('📅 التاريخ: ${order['createdAt'] ?? 'غير محدد'}'),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _updateOrderStatus(context, doc.id, 'processing'),
                                      child: const Text('قيد المعالجة'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _updateOrderStatus(context, doc.id, 'shipped'),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                      child: const Text('تم الشحن'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _updateOrderStatus(context, doc.id, 'delivered'),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                      child: const Text('تم التوصيل'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _updateOrderStatus(context, doc.id, 'cancelled'),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      child: const Text('إلغاء'),
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
        ),
      ],
    );
  }

  Future<void> _updateOrderStatus(BuildContext context, String orderId, String status) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': DateTime.now().toIso8601String(),
    });
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ تم تحديث حالة الطلب إلى: $status'), backgroundColor: Colors.green),
      );
    }
  }
}

// ========== Merchants Management ==========
class MerchantsManagement extends StatelessWidget {
  const MerchantsManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return MerchantsApprovalScreen();
  }
}

// ========== Delivery Offices Management ==========
class DeliveryOfficesManagement extends StatelessWidget {
  const DeliveryOfficesManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return DeliveryOfficesApprovalScreen();
  }
}

// ========== Notifications Management ==========
class NotificationsManagement extends StatefulWidget {
  const NotificationsManagement({super.key});

  @override
  State<NotificationsManagement> createState() => _NotificationsManagementState();
}

class _NotificationsManagementState extends State<NotificationsManagement> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🔔 إرسال إشعار للجميع', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'عنوان الإشعار',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _messageController,
            decoration: InputDecoration(
              labelText: 'نص الإشعار',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendNotification,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B9AC4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('إرسال الإشعار', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendNotification() async {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ الرجاء ملء جميع الحقول'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Save notification to Firestore for history
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': _titleController.text.trim(),
        'message': _messageController.text.trim(),
        'createdAt': DateTime.now().toIso8601String(),
        'sentBy': 'admin',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ تم إرسال الإشعار بنجاح'), backgroundColor: Colors.green),
        );
        _titleController.clear();
        _messageController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}

// ========== Admin Messaging System Page ==========
class AdminMessagingSystemPage extends StatelessWidget {
  const AdminMessagingSystemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminMessagingSystem(
      adminId: 'admin_001',
      adminName: 'المدير العام',
    );
  }
}
