import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'زهرة الأمل',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B9AC4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// ============ نماذج البيانات ============

class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String imageUrl;
  final int stock;
  final String merchantId;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.stock,
    required this.merchantId,
  });
}

class Merchant {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final double rating;
  final int totalSales;

  Merchant({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.rating,
    required this.totalSales,
  });
}

class Buyer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final int totalOrders;

  Buyer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.totalOrders,
  });
}

class DeliveryOffice {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String city;
  final List<String> coverageAreas;
  final double rating;
  final int totalDeliveries;

  DeliveryOffice({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    required this.coverageAreas,
    required this.rating,
    required this.totalDeliveries,
  });
}

// ============ بيانات محلية ============

class LocalData {
  // التجار
  static List<Merchant> getMerchants() {
    return [
      Merchant(
        id: 'm1',
        name: 'متجر الأناقة السودانية',
        email: 'elegance@sudan.com',
        phone: '+249912345678',
        address: 'شارع النيل، الخرطوم',
        city: 'الخرطوم',
        rating: 4.8,
        totalSales: 1250,
      ),
      Merchant(
        id: 'm2',
        name: 'عطور الشرق',
        email: 'perfumes@east.sd',
        phone: '+249923456789',
        address: 'سوق العربي، الخرطوم',
        city: 'الخرطوم',
        rating: 4.6,
        totalSales: 890,
      ),
      Merchant(
        id: 'm3',
        name: 'إلكترونيات الحديثة',
        email: 'modern@tech.sd',
        phone: '+249934567890',
        address: 'شارع الجامعة، أم درمان',
        city: 'أم درمان',
        rating: 4.9,
        totalSales: 2100,
      ),
      Merchant(
        id: 'm4',
        name: 'أزياء المدينة',
        email: 'city@fashion.sd',
        phone: '+249945678901',
        address: 'السوق الكبير، بحري',
        city: 'بحري',
        rating: 4.5,
        totalSales: 670,
      ),
    ];
  }

  // المشترين
  static List<Buyer> getBuyers() {
    return [
      Buyer(
        id: 'b1',
        name: 'أحمد محمد علي',
        email: 'ahmed.ali@gmail.com',
        phone: '+249911111111',
        address: 'حي الرياض، الخرطوم',
        city: 'الخرطوم',
        totalOrders: 15,
      ),
      Buyer(
        id: 'b2',
        name: 'فاطمة إبراهيم',
        email: 'fatima.ibrahim@yahoo.com',
        phone: '+249922222222',
        address: 'حي العمارات، أم درمان',
        city: 'أم درمان',
        totalOrders: 23,
      ),
      Buyer(
        id: 'b3',
        name: 'محمد عبدالله',
        email: 'mohamed.abdullah@hotmail.com',
        phone: '+249933333333',
        address: 'حي الديوم، الخرطوم',
        city: 'الخرطوم',
        totalOrders: 8,
      ),
      Buyer(
        id: 'b4',
        name: 'سارة أحمد',
        email: 'sara.ahmed@gmail.com',
        phone: '+249944444444',
        address: 'حي الصافية، بحري',
        city: 'بحري',
        totalOrders: 31,
      ),
      Buyer(
        id: 'b5',
        name: 'عمر حسن',
        email: 'omar.hassan@gmail.com',
        phone: '+249955555555',
        address: 'حي المعمورة، الخرطوم',
        city: 'الخرطوم',
        totalOrders: 12,
      ),
    ];
  }

  // مكاتب التوصيل
  static List<DeliveryOffice> getDeliveryOffices() {
    return [
      DeliveryOffice(
        id: 'd1',
        name: 'التوصيل السريع',
        phone: '+249900000001',
        address: 'شارع الستين، الخرطوم',
        city: 'الخرطوم',
        coverageAreas: ['الخرطوم', 'الخرطوم بحري', 'الخرطوم شرق'],
        rating: 4.7,
        totalDeliveries: 5600,
      ),
      DeliveryOffice(
        id: 'd2',
        name: 'مكتب النيل للتوصيل',
        phone: '+249900000002',
        address: 'شارع الجامعة، أم درمان',
        city: 'أم درمان',
        coverageAreas: ['أم درمان', 'الموردة', 'أبو روف'],
        rating: 4.5,
        totalDeliveries: 3200,
      ),
      DeliveryOffice(
        id: 'd3',
        name: 'خدمات بحري للتوصيل',
        phone: '+249900000003',
        address: 'السوق الكبير، بحري',
        city: 'بحري',
        coverageAreas: ['بحري', 'الكدرو', 'شمبات'],
        rating: 4.8,
        totalDeliveries: 4100,
      ),
      DeliveryOffice(
        id: 'd4',
        name: 'التوصيل الممتاز',
        phone: '+249900000004',
        address: 'شارع القصر، الخرطوم',
        city: 'الخرطوم',
        coverageAreas: ['الخرطوم', 'أم درمان', 'بحري', 'جميع المدن'],
        rating: 4.9,
        totalDeliveries: 8900,
      ),
    ];
  }

  // المنتجات
  static List<Product> getProducts() {
    return [
      Product(
        id: '1',
        name: 'قميص حديث',
        price: 1455,
        category: 'ملابس رجالية',
        imageUrl: 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=400',
        stock: 21,
        merchantId: 'm1',
      ),
      Product(
        id: '2',
        name: 'مزهرية راقي',
        price: 2995,
        category: 'ديكور منزلي',
        imageUrl: 'https://images.unsplash.com/photo-1578500494198-246f612d3b3d?w=400',
        stock: 96,
        merchantId: 'm1',
      ),
      Product(
        id: '3',
        name: 'عود راقي',
        price: 4999,
        category: 'عطور',
        imageUrl: 'https://images.unsplash.com/photo-1541643600914-78b084683601?w=400',
        stock: 58,
        merchantId: 'm2',
      ),
      Product(
        id: '4',
        name: 'عباية حديثة',
        price: 1827,
        category: 'ملابس نسائية',
        imageUrl: 'https://images.unsplash.com/photo-1583391733981-5babdc0fc859?w=400',
        stock: 54,
        merchantId: 'm1',
      ),
      Product(
        id: '5',
        name: 'حذاء رياضي عصري',
        price: 3144,
        category: 'أحذية',
        imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
        stock: 89,
        merchantId: 'm4',
      ),
      Product(
        id: '6',
        name: 'سماعات راقية',
        price: 4355,
        category: 'إلكترونيات',
        imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
        stock: 45,
        merchantId: 'm3',
      ),
      Product(
        id: '7',
        name: 'بخور عصري',
        price: 3537,
        category: 'عطور',
        imageUrl: 'https://images.unsplash.com/photo-1602874801006-96632be89c6b?w=400',
        stock: 67,
        merchantId: 'm2',
      ),
      Product(
        id: '8',
        name: 'كابل USB-C',
        price: 1785,
        category: 'إلكترونيات',
        imageUrl: 'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?w=400',
        stock: 123,
        merchantId: 'm3',
      ),
      Product(
        id: '9',
        name: 'شبشب حديث',
        price: 2512,
        category: 'أحذية',
        imageUrl: 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=400',
        stock: 78,
        merchantId: 'm4',
      ),
      Product(
        id: '10',
        name: 'دهن عود عصري',
        price: 1305,
        category: 'عطور',
        imageUrl: 'https://images.unsplash.com/photo-1587017539504-67cfbddac569?w=400',
        stock: 91,
        merchantId: 'm2',
      ),
      Product(
        id: '11',
        name: 'ساعة ذكية',
        price: 5670,
        category: 'إلكترونيات',
        imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
        stock: 34,
        merchantId: 'm3',
      ),
      Product(
        id: '12',
        name: 'حقيبة يد نسائية',
        price: 3890,
        category: 'إكسسوارات',
        imageUrl: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=400',
        stock: 56,
        merchantId: 'm1',
      ),
    ];
  }
}

// ============ الشاشة الرئيسية ============

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ProductsTab(),
    const MerchantsTab(),
    const BuyersTab(),
    const DeliveryTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
        title: const Text(
          'سوق السودان الذكي',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('سلة التسوق قريباً!')),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6B9AC4),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'المنتجات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'التجار',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'المشترين',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'التوصيل',
          ),
        ],
      ),
    );
  }
}

// ============ تبويب المنتجات ============

class ProductsTab extends StatelessWidget {
  const ProductsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final products = LocalData.getProducts();
    final merchants = LocalData.getMerchants();
    
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'المنتجات المتاحة',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                '${products.length} منتج',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B9AC4),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final merchant = merchants.firstWhere(
                (m) => m.id == product.merchantId,
                orElse: () => merchants[0],
              );
              
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(product.name, textAlign: TextAlign.right),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product.imageUrl,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text('الفئة: ${product.category}'),
                            const SizedBox(height: 8),
                            Text(
                              'السعر: ${product.price.toStringAsFixed(0)} جنيه',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B9AC4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'المخزون: ${product.stock}',
                              style: TextStyle(
                                color: product.stock > 20 ? Colors.green : Colors.orange,
                              ),
                            ),
                            const Divider(height: 24),
                            Text(
                              'التاجر: ${merchant.name}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('الهاتف: ${merchant.phone}'),
                            Text('المدينة: ${merchant.city}'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('التقييم: ${merchant.rating}'),
                                const Icon(Icons.star, size: 16, color: Colors.amber),
                              ],
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('إغلاق'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('تم إضافة ${product.name} للسلة')),
                            );
                          },
                          child: const Text('أضف للسلة'),
                        ),
                      ],
                    ),
                  );
                },
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.image, size: 48, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                  height: 1.2,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.category,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF7F8C8D),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${product.price.toStringAsFixed(0)} جنيه',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6B9AC4),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.inventory_2,
                                        size: 10,
                                        color: product.stock > 20 ? Colors.green : Colors.orange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${product.stock}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: product.stock > 20 ? Colors.green : Colors.orange,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ============ تبويب التجار ============

class MerchantsTab extends StatelessWidget {
  const MerchantsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final merchants = LocalData.getMerchants();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: merchants.length,
      itemBuilder: (context, index) {
        final merchant = merchants[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF6B9AC4),
              child: Text(
                merchant.name[0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              merchant.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📞 ${merchant.phone}'),
                Text('📍 ${merchant.address}، ${merchant.city}'),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    Text(' ${merchant.rating}'),
                    const SizedBox(width: 16),
                    Text('المبيعات: ${merchant.totalSales}'),
                  ],
                ),
              ],
            ),
            isThreeLine: true,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(merchant.name, textAlign: TextAlign.right),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('البريد: ${merchant.email}'),
                      Text('الهاتف: ${merchant.phone}'),
                      Text('العنوان: ${merchant.address}'),
                      Text('المدينة: ${merchant.city}'),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('التقييم: ${merchant.rating}'),
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                        ],
                      ),
                      Text('إجمالي المبيعات: ${merchant.totalSales}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إغلاق'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ============ تبويب المشترين ============

class BuyersTab extends StatelessWidget {
  const BuyersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final buyers = LocalData.getBuyers();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: buyers.length,
      itemBuilder: (context, index) {
        final buyer = buyers[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF97C4B8),
              child: Text(
                buyer.name[0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              buyer.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📞 ${buyer.phone}'),
                Text('📍 ${buyer.address}، ${buyer.city}'),
                Text('الطلبات: ${buyer.totalOrders}'),
              ],
            ),
            isThreeLine: true,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(buyer.name, textAlign: TextAlign.right),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('البريد: ${buyer.email}'),
                      Text('الهاتف: ${buyer.phone}'),
                      Text('العنوان: ${buyer.address}'),
                      Text('المدينة: ${buyer.city}'),
                      const Divider(),
                      Text('إجمالي الطلبات: ${buyer.totalOrders}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إغلاق'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ============ تبويب التوصيل ============

class DeliveryTab extends StatelessWidget {
  const DeliveryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final offices = LocalData.getDeliveryOffices();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: offices.length,
      itemBuilder: (context, index) {
        final office = offices[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE8B86D),
              child: Icon(Icons.local_shipping, color: Colors.white),
            ),
            title: Text(
              office.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📞 ${office.phone}'),
                Text('📍 ${office.address}، ${office.city}'),
                Text('نطاق التغطية: ${office.coverageAreas.join(", ")}'),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    Text(' ${office.rating}'),
                    const SizedBox(width: 16),
                    Text('التوصيلات: ${office.totalDeliveries}'),
                  ],
                ),
              ],
            ),
            isThreeLine: true,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(office.name, textAlign: TextAlign.right),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('الهاتف: ${office.phone}'),
                      Text('العنوان: ${office.address}'),
                      Text('المدينة: ${office.city}'),
                      const Divider(),
                      const Text(
                        'نطاق التغطية:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...office.coverageAreas.map((area) => Text('• $area')),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('التقييم: ${office.rating}'),
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                        ],
                      ),
                      Text('إجمالي التوصيلات: ${office.totalDeliveries}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إغلاق'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
