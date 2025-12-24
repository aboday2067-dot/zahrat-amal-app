import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      home: const SplashScreen(),
    );
  }
}

// ============ DATA MODELS ============

class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String imageUrl;
  final int stock;
  final String merchantId;
  final double rating;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.stock,
    required this.merchantId,
    required this.rating,
    required this.description,
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
  final String category;

  Merchant({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.rating,
    required this.totalSales,
    required this.category,
  });
}

class Buyer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final int orderCount;
  final double totalSpent;

  Buyer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.orderCount,
    required this.totalSpent,
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
  final int deliveryCount;
  final double pricePerKm;

  DeliveryOffice({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    required this.coverageAreas,
    required this.rating,
    required this.deliveryCount,
    required this.pricePerKm,
  });
}

class Order {
  final String id;
  final String buyerId;
  final String merchantId;
  final List<String> productIds;
  final double totalAmount;
  final String status;
  final DateTime orderDate;
  final String? deliveryOfficeId;

  Order({
    required this.id,
    required this.buyerId,
    required this.merchantId,
    required this.productIds,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    this.deliveryOfficeId,
  });
}

// ============ LOCAL DATA ============

class LocalData {
  static List<Product> getProducts() {
    return [
      Product(id: '1', name: 'قميص حديث', price: 1455, category: 'ملابس رجالية', imageUrl: 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=400', stock: 21, merchantId: 'm1', rating: 4.5, description: 'قميص قطني عالي الجودة بتصميم عصري'),
      Product(id: '2', name: 'مزهرية راقية', price: 2995, category: 'ديكور منزلي', imageUrl: 'https://images.unsplash.com/photo-1578500494198-246f612d3b3d?w=400', stock: 96, merchantId: 'm2', rating: 4.8, description: 'مزهرية خزف فاخرة للمنزل'),
      Product(id: '3', name: 'عود فاخر', price: 4999, category: 'عطور', imageUrl: 'https://images.unsplash.com/photo-1541643600914-78b084683601?w=400', stock: 58, merchantId: 'm3', rating: 4.9, description: 'عود طبيعي بجودة عالية'),
      Product(id: '4', name: 'عباية حديثة', price: 1827, category: 'ملابس نسائية', imageUrl: 'https://images.unsplash.com/photo-1583391733981-5babdc0fc859?w=400', stock: 54, merchantId: 'm1', rating: 4.7, description: 'عباية أنيقة بتصميم عصري'),
      Product(id: '5', name: 'حذاء رياضي', price: 3144, category: 'أحذية', imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400', stock: 89, merchantId: 'm4', rating: 4.6, description: 'حذاء رياضي مريح وعصري'),
      Product(id: '6', name: 'سماعات لاسلكية', price: 4355, category: 'إلكترونيات', imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', stock: 45, merchantId: 'm4', rating: 4.8, description: 'سماعات بلوتوث بجودة صوت عالية'),
      Product(id: '7', name: 'بخور', price: 3537, category: 'عطور', imageUrl: 'https://images.unsplash.com/photo-1602874801006-96632be89c6b?w=400', stock: 67, merchantId: 'm3', rating: 4.7, description: 'بخور طبيعي برائحة زكية'),
      Product(id: '8', name: 'كابل USB-C', price: 1785, category: 'إلكترونيات', imageUrl: 'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?w=400', stock: 123, merchantId: 'm4', rating: 4.5, description: 'كابل شحن سريع عالي الجودة'),
      Product(id: '9', name: 'شبشب صيفي', price: 2512, category: 'أحذية', imageUrl: 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=400', stock: 78, merchantId: 'm4', rating: 4.4, description: 'شبشب مريح للصيف'),
      Product(id: '10', name: 'دهن عود', price: 1305, category: 'عطور', imageUrl: 'https://images.unsplash.com/photo-1587017539504-67cfbddac569?w=400', stock: 91, merchantId: 'm3', rating: 4.6, description: 'دهن عود طبيعي'),
      Product(id: '11', name: 'ساعة ذكية', price: 5670, category: 'إلكترونيات', imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400', stock: 34, merchantId: 'm4', rating: 4.9, description: 'ساعة ذكية بميزات متقدمة'),
      Product(id: '12', name: 'حقيبة يد فاخرة', price: 3890, category: 'إكسسوارات', imageUrl: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=400', stock: 56, merchantId: 'm2', rating: 4.7, description: 'حقيبة يد جلدية راقية'),
    ];
  }

  static List<Merchant> getMerchants() {
    return [
      Merchant(id: 'm1', name: 'متجر الأناقة السودانية', email: 'anaga@shop.sd', phone: '+249912345001', address: 'شارع الجامعة، حي الرياض', city: 'الخرطوم', rating: 4.8, totalSales: 1250, category: 'ملابس'),
      Merchant(id: 'm2', name: 'بيت الديكور', email: 'decor@home.sd', phone: '+249912345002', address: 'شارع المطار، حي المعمورة', city: 'أم درمان', rating: 4.7, totalSales: 890, category: 'ديكور'),
      Merchant(id: 'm3', name: 'عطور الشرق', email: 'perfumes@east.sd', phone: '+249912345003', address: 'سوق العربي، وسط البلد', city: 'الخرطوم', rating: 4.9, totalSales: 2100, category: 'عطور'),
      Merchant(id: 'm4', name: 'تك ستور', email: 'tech@store.sd', phone: '+249912345004', address: 'شارع الستين، حي الديوم', city: 'الخرطوم بحري', rating: 4.6, totalSales: 1650, category: 'إلكترونيات'),
    ];
  }

  static List<Buyer> getBuyers() {
    return [
      Buyer(id: 'b1', name: 'أحمد محمد علي', email: 'ahmed@example.com', phone: '+249911111111', address: 'شارع الحرية، حي العمارات', city: 'الخرطوم', orderCount: 15, totalSpent: 45670),
      Buyer(id: 'b2', name: 'فاطمة حسن إبراهيم', email: 'fatima@example.com', phone: '+249922222222', address: 'شارع النيل، حي الصفا', city: 'أم درمان', orderCount: 23, totalSpent: 67890),
      Buyer(id: 'b3', name: 'محمود عبدالله', email: 'mahmoud@example.com', phone: '+249933333333', address: 'شارع البلدية، حي الشهداء', city: 'الخرطوم', orderCount: 8, totalSpent: 23450),
      Buyer(id: 'b4', name: 'سارة أحمد', email: 'sara@example.com', phone: '+249944444444', address: 'شارع الجامعة، حي الثورة', city: 'الخرطوم بحري', orderCount: 31, totalSpent: 89230),
      Buyer(id: 'b5', name: 'عمر الطيب', email: 'omar@example.com', phone: '+249955555555', address: 'شارع المك نمر، حي الإنقاذ', city: 'أم درمان', orderCount: 19, totalSpent: 54320),
    ];
  }

  static List<DeliveryOffice> getDeliveryOffices() {
    return [
      DeliveryOffice(id: 'd1', name: 'التوصيل السريع', phone: '+249900000001', address: 'شارع الجامعة', city: 'الخرطوم', coverageAreas: ['الخرطوم', 'أم درمان', 'بحري'], rating: 4.7, deliveryCount: 5600, pricePerKm: 5.0),
      DeliveryOffice(id: 'd2', name: 'خدمات النقل الذهبية', phone: '+249900000002', address: 'شارع المطار', city: 'أم درمان', coverageAreas: ['أم درمان', 'الخرطوم'], rating: 4.8, deliveryCount: 4200, pricePerKm: 4.5),
      DeliveryOffice(id: 'd3', name: 'بريد السودان السريع', phone: '+249900000003', address: 'وسط البلد', city: 'الخرطوم', coverageAreas: ['جميع أنحاء السودان'], rating: 4.9, deliveryCount: 8900, pricePerKm: 6.0),
      DeliveryOffice(id: 'd4', name: 'الشحن الفوري', phone: '+249900000004', address: 'شارع الستين', city: 'الخرطوم بحري', coverageAreas: ['بحري', 'الخرطوم'], rating: 4.6, deliveryCount: 3400, pricePerKm: 5.5),
    ];
  }

  static List<Order> getOrders() {
    return [
      Order(id: 'o1', buyerId: 'b1', merchantId: 'm1', productIds: ['1', '4'], totalAmount: 3282, status: 'قيد التوصيل', orderDate: DateTime.now().subtract(const Duration(days: 2)), deliveryOfficeId: 'd1'),
      Order(id: 'o2', buyerId: 'b2', merchantId: 'm3', productIds: ['3', '7'], totalAmount: 8536, status: 'مكتمل', orderDate: DateTime.now().subtract(const Duration(days: 5)), deliveryOfficeId: 'd2'),
      Order(id: 'o3', buyerId: 'b3', merchantId: 'm4', productIds: ['6', '11'], totalAmount: 10025, status: 'قيد المعالجة', orderDate: DateTime.now().subtract(const Duration(days: 1))),
      Order(id: 'o4', buyerId: 'b4', merchantId: 'm2', productIds: ['2', '12'], totalAmount: 6885, status: 'مكتمل', orderDate: DateTime.now().subtract(const Duration(days: 7)), deliveryOfficeId: 'd3'),
      Order(id: 'o5', buyerId: 'b5', merchantId: 'm4', productIds: ['5', '8', '9'], totalAmount: 7441, status: 'قيد التوصيل', orderDate: DateTime.now().subtract(const Duration(days: 3)), deliveryOfficeId: 'd4'),
    ];
  }
}

// ============ Splash Screen ============

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    if (mounted) {
      if (isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6B9AC4),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.shopping_bag,
                size: 60,
                color: Color(0xFF6B9AC4),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'زهرة الأمل',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'سوق السودان الذكي',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// ============ Login Screen ============

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء ملء جميع الحقول')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', _emailController.text);
    await prefs.setString('userName', 'أحمد محمد');
    await prefs.setString('userPhone', '+249912345678');
    await prefs.setString('userId', 'b1');

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B9AC4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.shopping_bag,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'مرحباً بك!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'سجل دخولك للمتابعة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7F8C8D),
                ),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                textDirection: TextDirection.ltr,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B9AC4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'تسجيل الدخول',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFF6B9AC4)),
                ),
                child: const Text(
                  'إنشاء حساب جديد',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ Signup Screen ============

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signup() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _cityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء ملء جميع الحقول')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', _emailController.text);
    await prefs.setString('userName', _nameController.text);
    await prefs.setString('userPhone', _phoneController.text);
    await prefs.setString('userAddress', _addressController.text);
    await prefs.setString('userCity', _cityController.text);
    await prefs.setString('userId', 'b_new');

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد'),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'الاسم الكامل',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                textDirection: TextDirection.ltr,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                textDirection: TextDirection.ltr,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'العنوان',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'المدينة',
                  prefixIcon: const Icon(Icons.location_city),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B9AC4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'إنشاء الحساب',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ Main Screen with Bottom Navigation ============

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<int> _cartItems = [];
  final List<String> _favoriteIds = [];

  void _addToCart(int productIndex) {
    setState(() {
      _cartItems.add(productIndex);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تمت الإضافة إلى السلة'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _toggleFavorite(String productId) {
    setState(() {
      if (_favoriteIds.contains(productId)) {
        _favoriteIds.remove(productId);
      } else {
        _favoriteIds.add(productId);
      }
    });
  }

  // Cart management handled in products screen

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      ProductsScreen(
        onAddToCart: _addToCart,
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
      ),
      const MerchantsScreen(),
      const OrdersScreen(),
      const DeliveryOfficesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6B9AC4),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'المنتجات',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'التجار',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('${_cartItems.length}'),
              isLabelVisible: _cartItems.isNotEmpty,
              child: const Icon(Icons.receipt_long),
            ),
            label: 'الطلبات',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'التوصيل',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'الحساب',
          ),
        ],
      ),
    );
  }
}

// ============ Products Screen ============

class ProductsScreen extends StatefulWidget {
  final Function(int) onAddToCart;
  final List<String> favoriteIds;
  final Function(String) onToggleFavorite;

  const ProductsScreen({super.key, required this.onAddToCart, required this.favoriteIds, required this.onToggleFavorite});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'الكل';

  @override
  Widget build(BuildContext context) {
    final products = LocalData.getProducts();
    final categories = ['الكل', ...products.map((p) => p.category).toSet().toList()];
    final filtered = products.where((p) {
      final matchesSearch = _searchQuery.isEmpty || p.name.contains(_searchQuery);
      final matchesCategory = _selectedCategory == 'الكل' || p.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('المنتجات'),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'بحث عن منتج...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) => setState(() => _selectedCategory = cat),
                    selectedColor: const Color(0xFF6B9AC4),
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final product = filtered[index];
                final productIndex = products.indexOf(product);
                final isFav = widget.favoriteIds.contains(product.id);

                return Card(
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image, size: 50),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : Colors.grey),
                                  onPressed: () => widget.onToggleFavorite(product.id),
                                  iconSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 14, color: Colors.amber),
                                Text(' ${product.rating}', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${product.price.toInt()} جنيه',
                              style: const TextStyle(color: Color(0xFF6B9AC4), fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'المخزون: ${product.stock}',
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => widget.onAddToCart(productIndex),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6B9AC4),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('أضف للسلة', style: TextStyle(fontSize: 12, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============ Merchants Screen ============

class MerchantsScreen extends StatelessWidget {
  const MerchantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final merchants = LocalData.getMerchants();

    return Scaffold(
      appBar: AppBar(
        title: const Text('التجار'),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: merchants.length,
        itemBuilder: (context, index) {
          final merchant = merchants[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF6B9AC4),
                radius: 30,
                child: Text(
                  merchant.name[0],
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(merchant.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      Text(' ${merchant.rating}', style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 12),
                      const Icon(Icons.shopping_cart, size: 16, color: Colors.grey),
                      Text(' ${merchant.totalSales} مبيعة', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('📍 ${merchant.city}', style: const TextStyle(fontSize: 12)),
                  Text('📞 ${merchant.phone}', style: const TextStyle(fontSize: 12)),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(merchant.name),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildInfoRow('التصنيف', merchant.category),
                          _buildInfoRow('التقييم', '⭐ ${merchant.rating}'),
                          _buildInfoRow('المبيعات', '${merchant.totalSales} عملية'),
                          _buildInfoRow('البريد', merchant.email),
                          _buildInfoRow('الهاتف', merchant.phone),
                          _buildInfoRow('العنوان', merchant.address),
                          _buildInfoRow('المدينة', merchant.city),
                        ],
                      ),
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
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// ============ Orders Screen ============

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = LocalData.getOrders();
    final buyers = LocalData.getBuyers();
    final merchants = LocalData.getMerchants();
    final products = LocalData.getProducts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات'),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          final buyer = buyers.firstWhere((b) => b.id == order.buyerId);
          final merchant = merchants.firstWhere((m) => m.id == order.merchantId);
          final orderProducts = order.productIds.map((pid) => products.firstWhere((p) => p.id == pid)).toList();

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: order.status == 'مكتمل' ? Colors.green : order.status == 'قيد التوصيل' ? Colors.orange : Colors.blue,
                child: Text(order.id.substring(1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              title: Text('طلب ${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الحالة: ${order.status}'),
                  Text('المبلغ: ${order.totalAmount.toInt()} جنيه'),
                  Text('التاريخ: ${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}'),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('تفاصيل الطلب:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Divider(),
                      _buildInfoRow('المشتري', buyer.name),
                      _buildInfoRow('هاتف المشتري', buyer.phone),
                      _buildInfoRow('التاجر', merchant.name),
                      _buildInfoRow('هاتف التاجر', merchant.phone),
                      const SizedBox(height: 8),
                      const Text('المنتجات:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...orderProducts.map<Widget>((p) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Text('• '),
                            Expanded(child: Text(p.name)),
                            Text('${p.price.toInt()} جنيه', style: const TextStyle(color: Color(0xFF6B9AC4))),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// ============ Delivery Offices Screen ============

class DeliveryOfficesScreen extends StatelessWidget {
  const DeliveryOfficesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deliveryOffices = LocalData.getDeliveryOffices();

    return Scaffold(
      appBar: AppBar(
        title: const Text('مكاتب التوصيل'),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: deliveryOffices.length,
        itemBuilder: (context, index) {
          final office = deliveryOffices[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF6B9AC4),
                radius: 30,
                child: Icon(Icons.local_shipping, color: Colors.white, size: 30),
              ),
              title: Text(office.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      Text(' ${office.rating}', style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 12),
                      const Icon(Icons.delivery_dining, size: 16, color: Colors.grey),
                      Text(' ${office.deliveryCount} توصيلة', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('📍 ${office.city}', style: const TextStyle(fontSize: 12)),
                  Text('📞 ${office.phone}', style: const TextStyle(fontSize: 12)),
                  Text('💰 ${office.pricePerKm} جنيه/كم', style: const TextStyle(fontSize: 12)),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(office.name),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildInfoRow('التقييم', '⭐ ${office.rating}'),
                          _buildInfoRow('التوصيلات', '${office.deliveryCount} عملية'),
                          _buildInfoRow('السعر/كم', '${office.pricePerKm} جنيه'),
                          _buildInfoRow('الهاتف', office.phone),
                          _buildInfoRow('العنوان', office.address),
                          _buildInfoRow('المدينة', office.city),
                          const SizedBox(height: 8),
                          const Text('مناطق التغطية:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ...office.coverageAreas.map((area) => Padding(
                            padding: const EdgeInsets.only(right: 16, top: 4),
                            child: Text('• $area'),
                          )),
                        ],
                      ),
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
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// ============ Profile Screen ============

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _loadUserData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data!;

          return ListView(
            children: [
              const SizedBox(height: 32),
              const CircleAvatar(
                radius: 60,
                backgroundColor: Color(0xFF6B9AC4),
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(userData['userName'] ?? 'المستخدم', textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(userData['userEmail'] ?? 'email@example.com', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Text(userData['userPhone'] ?? '+249', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              _buildProfileSection('معلومات الحساب', [
                _buildInfoTile(Icons.email, 'البريد الإلكتروني', userData['userEmail'] ?? ''),
                _buildInfoTile(Icons.phone, 'رقم الهاتف', userData['userPhone'] ?? ''),
                _buildInfoTile(Icons.location_on, 'العنوان', userData['userAddress'] ?? 'لم يتم التحديد'),
                _buildInfoTile(Icons.location_city, 'المدينة', userData['userCity'] ?? 'لم يتم التحديد'),
              ]),
              const SizedBox(height: 16),
              _buildProfileSection('الطلبات والمفضلة', [
                ListTile(
                  leading: const Icon(Icons.shopping_bag),
                  title: const Text('طلباتي'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.favorite),
                  title: const Text('المفضلة'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 16),
              _buildProfileSection('الإعدادات', [
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('الإشعارات'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('اللغة'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('المساعدة'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('تسجيل الخروج', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Future<Map<String, String>> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userName': prefs.getString('userName') ?? 'المستخدم',
      'userEmail': prefs.getString('userEmail') ?? 'email@example.com',
      'userPhone': prefs.getString('userPhone') ?? '+249',
      'userAddress': prefs.getString('userAddress') ?? 'لم يتم التحديد',
      'userCity': prefs.getString('userCity') ?? 'لم يتم التحديد',
    };
  }

  Widget _buildProfileSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6B9AC4))),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6B9AC4)),
      title: Text(title),
      subtitle: Text(value),
    );
  }
}
