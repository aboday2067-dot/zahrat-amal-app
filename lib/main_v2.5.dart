import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart';

// ============ FIREBASE BACKGROUND HANDLER ============
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize Firebase Messaging
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await FirebaseMessaging.instance.requestPermission();
    
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase initialization failed: $e');
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// ============ PROVIDERS ============

class CartProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];
  
  List<Map<String, dynamic>> get cartItems => _cartItems;
  
  int get itemCount => _cartItems.length;
  
  double get totalAmount {
    return _cartItems.fold(0.0, (sum, item) => sum + (item['price'] as double));
  }
  
  void addToCart(Map<String, dynamic> product) {
    _cartItems.add(product);
    notifyListeners();
  }
  
  void removeFromCart(int index) {
    _cartItems.removeAt(index);
    notifyListeners();
  }
  
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}

class NotificationProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];
  
  List<Map<String, dynamic>> get notifications => _notifications;
  
  int get unreadCount => _notifications.where((n) => !n['read']).length;
  
  void addNotification(String title, String body) {
    _notifications.insert(0, {
      'title': title,
      'body': body,
      'time': DateTime.now(),
      'read': false,
    });
    notifyListeners();
  }
  
  void markAsRead(int index) {
    _notifications[index]['read'] = true;
    notifyListeners();
  }
  
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}

// ============ MAIN APP ============

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

// ============ SPLASH SCREEN ============

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Setup Firebase Messaging
    _setupFirebaseMessaging();
    
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userRole = prefs.getString('userRole') ?? 'buyer';
    
    if (mounted) {
      if (isLoggedIn) {
        if (userRole == 'merchant') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MerchantDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }
  
  void _setupFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        Provider.of<NotificationProvider>(context, listen: false).addNotification(
          message.notification!.title ?? '',
          message.notification!.body ?? '',
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.notification!.body ?? ''),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
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

// ============ LOGIN SCREEN ============

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _userRole = 'buyer';

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
    await prefs.setString('userName', _userRole == 'merchant' ? 'محمد التاجر' : 'أحمد المشتري');
    await prefs.setString('userPhone', '+249912345678');
    await prefs.setString('userId', _userRole == 'merchant' ? 'm1' : 'b1');
    await prefs.setString('userRole', _userRole);

    if (mounted) {
      if (_userRole == 'merchant') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MerchantDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
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
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('مشتري'),
                      value: 'buyer',
                      groupValue: _userRole,
                      onChanged: (value) => setState(() => _userRole = value!),
                      activeColor: const Color(0xFF6B9AC4),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('تاجر'),
                      value: 'merchant',
                      groupValue: _userRole,
                      onChanged: (value) => setState(() => _userRole = value!),
                      activeColor: const Color(0xFF6B9AC4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
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
            ],
          ),
        ),
      ),
    );
  }
}

// ============ MAIN SCREEN (BUYER) ============

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    
    final List<Widget> screens = [
      const ProductsScreen(),
      const PaymentScreen(),
      const NotificationsScreen(),
      const TrackingScreen(),
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
            icon: Icon(Icons.payment),
            label: 'الدفع',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('${notificationProvider.unreadCount}'),
              isLabelVisible: notificationProvider.unreadCount > 0,
              child: const Icon(Icons.notifications),
            ),
            label: 'الإشعارات',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'التتبع',
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

// ============ PRODUCTS SCREEN ============

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('المنتجات'),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Badge(
              label: Text('${cartProvider.itemCount}'),
              isLabelVisible: cartProvider.itemCount > 0,
              child: const Icon(Icons.shopping_cart),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('is_active', isEqualTo: true)
            .limit(20)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!.docs;

          if (products.isEmpty) {
            return const Center(child: Text('لا توجد منتجات متاحة'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index].data() as Map<String, dynamic>;
              final productId = products[index].id;
              
              return Card(
                elevation: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          product['image_url'] ?? '',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image, size: 50),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${product['price'] ?? 0} جنيه',
                            style: const TextStyle(color: Color(0xFF6B9AC4), fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                cartProvider.addToCart({
                                  'id': productId,
                                  'name': product['name'],
                                  'price': (product['price'] as num).toDouble(),
                                  'image_url': product['image_url'],
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('تمت الإضافة إلى السلة'), duration: Duration(seconds: 1)),
                                );
                              },
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
          );
        },
      ),
    );
  }
}

// ============ CART SCREEN ============

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('السلة'),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: cartProvider.cartItems.isEmpty
          ? const Center(child: Text('السلة فارغة'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartProvider.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.cartItems[index];
                      return ListTile(
                        leading: Image.network(item['image_url'], width: 60, errorBuilder: (_, __, ___) => const Icon(Icons.image)),
                        title: Text(item['name']),
                        subtitle: Text('${item['price']} جنيه'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => cartProvider.removeFromCart(index),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الإجمالي:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('${cartProvider.totalAmount.toInt()} جنيه', style: const TextStyle(fontSize: 20, color: Color(0xFF6B9AC4), fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PaymentScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B9AC4),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('متابعة الدفع', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ============ PAYMENT SCREEN ============

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  Future<void> _processPayment(BuildContext context, String method) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final amount = cartProvider.totalAmount;
    
    // Simulate payment processing
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (context.mounted) {
      Navigator.pop(context);
      
      // Add notification
      Provider.of<NotificationProvider>(context, listen: false).addNotification(
        'تم الدفع بنجاح',
        'تم دفع $amount جنيه عبر $method',
      );
      
      // Clear cart
      cartProvider.clearCart();
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('✅ تم الدفع بنجاح'),
          content: Text('تم دفع $amount جنيه عبر $method\nسيتم توصيل طلبك قريباً'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('موافق'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final amount = cartProvider.totalAmount;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('طرق الدفع'),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('المبلغ الإجمالي', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('${amount.toInt()} جنيه', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF6B9AC4))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('اختر طريقة الدفع:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildPaymentOption(
            context,
            icon: Icons.credit_card,
            title: 'بطاقة ائتمان',
            subtitle: 'Visa, Mastercard, Amex',
            onTap: () => _processPayment(context, 'بطاقة ائتمان'),
          ),
          _buildPaymentOption(
            context,
            icon: Icons.account_balance_wallet,
            title: 'فودافون كاش',
            subtitle: 'ادفع عبر محفظتك الإلكترونية',
            onTap: () => _processPayment(context, 'فودافون كاش'),
          ),
          _buildPaymentOption(
            context,
            icon: Icons.wallet,
            title: 'بنكك',
            subtitle: 'ادفع عبر تطبيق بنكك',
            onTap: () => _processPayment(context, 'بنكك'),
          ),
          _buildPaymentOption(
            context,
            icon: Icons.money,
            title: 'الدفع عند الاستلام',
            subtitle: 'ادفع نقداً عند التوصيل',
            onTap: () => _processPayment(context, 'الدفع عند الاستلام'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentOption(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF6B9AC4),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// ============ NOTIFICATIONS SCREEN ============

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final notifications = notificationProvider.notifications;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () => notificationProvider.clearAll(),
              child: const Text('مسح الكل', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('لا توجد إشعارات'))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final isRead = notification['read'] as bool;
                final time = notification['time'] as DateTime;
                
                return Card(
                  color: isRead ? Colors.white : Colors.blue[50],
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isRead ? Colors.grey : const Color(0xFF6B9AC4),
                      child: Icon(Icons.notifications, color: Colors.white, size: 20),
                    ),
                    title: Text(
                      notification['title'],
                      style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification['body']),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd/MM/yyyy - HH:mm').format(time),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    onTap: () => notificationProvider.markAsRead(index),
                  ),
                );
              },
            ),
    );
  }
}

// ============ TRACKING SCREEN ============

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تتبع الطلبات'),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('created_at', descending: true)
            .limit(20)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(child: Text('لا توجد طلبات'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              final orderId = orders[index].id;
              final status = order['status'] ?? 'قيد المعالجة';
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(status),
                    child: const Icon(Icons.shopping_bag, color: Colors.white, size: 20),
                  ),
                  title: Text('طلب #${orderId.substring(0, 8)}'),
                  subtitle: Text('الحالة: $status'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusTimeline(status),
                          const Divider(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _launchPhone('+249912345678'),
                                icon: const Icon(Icons.phone, size: 18),
                                label: const Text('اتصل'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _showMapDialog(context),
                                icon: const Icon(Icons.map, size: 18),
                                label: const Text('الخريطة'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6B9AC4),
                                  foregroundColor: Colors.white,
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
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'مكتمل':
        return Colors.green;
      case 'قيد التوصيل':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
  
  Widget _buildStatusTimeline(String status) {
    final steps = [
      {'title': 'تم الطلب', 'done': true},
      {'title': 'جاري التحضير', 'done': status != 'قيد المعالجة'},
      {'title': 'قيد التوصيل', 'done': status == 'قيد التوصيل' || status == 'مكتمل'},
      {'title': 'تم التوصيل', 'done': status == 'مكتمل'},
    ];
    
    return Column(
      children: steps.map((step) {
        final isDone = step['done'] as bool;
        return Row(
          children: [
            Icon(
              isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isDone ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(
              step['title'] as String,
              style: TextStyle(
                fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                color: isDone ? Colors.black : Colors.grey,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
  
  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
  
  void _showMapDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('موقع المندوب'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, size: 80, color: Color(0xFF6B9AC4)),
            SizedBox(height: 16),
            Text('📍 الخرطوم - شارع الجامعة'),
            SizedBox(height: 8),
            Text('المسافة المتبقية: 2.5 كم'),
            Text('الوقت المتوقع: 15 دقيقة'),
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
  }
}

// ============ PROFILE SCREEN ============

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
              const SizedBox(height: 32),
              ListTile(
                leading: const Icon(Icons.shopping_bag),
                title: const Text('طلباتي'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('الإعدادات'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('المساعدة'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
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
    };
  }
}

// ============ MERCHANT DASHBOARD ============

class MerchantDashboard extends StatefulWidget {
  const MerchantDashboard({super.key});

  @override
  State<MerchantDashboard> createState() => _MerchantDashboardState();
}

class _MerchantDashboardState extends State<MerchantDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const MerchantHomeScreen(),
      const MerchantProductsScreen(),
      const MerchantOrdersScreen(),
      const MerchantProfileScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6B9AC4),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'المنتجات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'الطلبات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'الحساب',
          ),
        ],
      ),
    );
  }
}

// ============ MERCHANT HOME SCREEN ============

class MerchantHomeScreen extends StatelessWidget {
  const MerchantHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم - التاجر'),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          final productCount = snapshot.hasData ? snapshot.data!.docs.length : 0;
          
          return GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildStatCard('المنتجات', '$productCount', Icons.inventory, Colors.blue),
              _buildStatCard('الطلبات', '15', Icons.receipt_long, Colors.orange),
              _buildStatCard('المبيعات', '45,670 جنيه', Icons.attach_money, Colors.green),
              _buildStatCard('التقييم', '⭐ 4.8', Icons.star, Colors.amber),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ============ MERCHANT PRODUCTS SCREEN ============

class MerchantProductsScreen extends StatelessWidget {
  const MerchantProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المنتجات'),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddProductDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!.docs;

          if (products.isEmpty) {
            return const Center(child: Text('لا توجد منتجات'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index].data() as Map<String, dynamic>;
              final productId = products[index].id;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Image.network(
                    product['image_url'] ?? '',
                    width: 60,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image),
                  ),
                  title: Text(product['name'] ?? ''),
                  subtitle: Text('${product['price'] ?? 0} جنيه - المخزون: ${product['stock'] ?? 0}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditProductDialog(context, productId, product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(context, productId),
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
  
  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final imageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة منتج جديد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم المنتج'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'السعر'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'المخزون'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(labelText: 'رابط الصورة'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('products').add({
                'name': nameController.text,
                'price': double.tryParse(priceController.text) ?? 0,
                'stock': int.tryParse(stockController.text) ?? 0,
                'image_url': imageController.text,
                'is_active': true,
                'created_at': FieldValue.serverTimestamp(),
              });
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
  
  void _showEditProductDialog(BuildContext context, String productId, Map<String, dynamic> product) {
    final nameController = TextEditingController(text: product['name']);
    final priceController = TextEditingController(text: product['price'].toString());
    final stockController = TextEditingController(text: product['stock'].toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل المنتج'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم المنتج'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'السعر'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'المخزون'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('products').doc(productId).update({
                'name': nameController.text,
                'price': double.tryParse(priceController.text) ?? 0,
                'stock': int.tryParse(stockController.text) ?? 0,
              });
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteProduct(BuildContext context, String productId) async {
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
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await FirebaseFirestore.instance.collection('products').doc(productId).delete();
    }
  }
}

// ============ MERCHANT ORDERS SCREEN ============

class MerchantOrdersScreen extends StatelessWidget {
  const MerchantOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الطلبات'),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(child: Text('لا توجد طلبات'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              final orderId = orders[index].id;
              final status = order['status'] ?? 'قيد المعالجة';
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(status),
                    child: const Icon(Icons.shopping_bag, color: Colors.white),
                  ),
                  title: Text('طلب #${orderId.substring(0, 8)}'),
                  subtitle: Text('الحالة: $status'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) => _updateOrderStatus(orderId, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'قيد المعالجة', child: Text('قيد المعالجة')),
                      const PopupMenuItem(value: 'قيد التوصيل', child: Text('قيد التوصيل')),
                      const PopupMenuItem(value: 'مكتمل', child: Text('مكتمل')),
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
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'مكتمل':
        return Colors.green;
      case 'قيد التوصيل':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
  
  Future<void> _updateOrderStatus(String orderId, String status) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': status,
    });
  }
}

// ============ MERCHANT PROFILE SCREEN ============

class MerchantProfileScreen extends StatelessWidget {
  const MerchantProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حساب التاجر'),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 32),
          const CircleAvatar(
            radius: 60,
            backgroundColor: Color(0xFF6B9AC4),
            child: Icon(Icons.store, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text('محمد التاجر', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('merchant@example.com', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('التقارير'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('الإعدادات'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
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
      ),
    );
  }
}
