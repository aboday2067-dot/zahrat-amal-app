import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'firebase_options.dart';
import 'complete_profile_system.dart';
import 'advanced_auth_system.dart';
import 'user_profiles_system.dart';
import 'local_payment_system.dart';
import 'chat_system.dart';
import 'receipt_upload_system.dart';
import 'connection_checker.dart';

// ============ LANGUAGE PROVIDER ============
class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'ar';
  
  String get currentLanguage => _currentLanguage;
  bool get isArabic => _currentLanguage == 'ar';
  
  void toggleLanguage() {
    _currentLanguage = _currentLanguage == 'ar' ? 'en' : 'ar';
    notifyListeners();
  }
  
  String translate(String ar, String en) {
    return _currentLanguage == 'ar' ? ar : en;
  }
}

// ============ THEME PROVIDER ============
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  
  ThemeData get themeData {
    return _isDarkMode ? ThemeData.dark() : ThemeData.light();
  }
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

// ============ COUPON PROVIDER ============
class CouponProvider extends ChangeNotifier {
  String? _appliedCoupon;
  double _discountPercentage = 0;
  
  String? get appliedCoupon => _appliedCoupon;
  double get discountPercentage => _discountPercentage;
  
  Future<bool> applyCoupon(String code) async {
    // Simulate coupon validation
    final coupons = {
      'WELCOME10': 10.0,
      'SAVE20': 20.0,
      'MEGA50': 50.0,
    };
    
    if (coupons.containsKey(code.toUpperCase())) {
      _appliedCoupon = code.toUpperCase();
      _discountPercentage = coupons[code.toUpperCase()]!;
      notifyListeners();
      return true;
    }
    return false;
  }
  
  void removeCoupon() {
    _appliedCoupon = null;
    _discountPercentage = 0;
    notifyListeners();
  }
  
  double calculateDiscount(double amount) {
    return amount * (_discountPercentage / 100);
  }
}

// ============ FIREBASE BACKGROUND HANDLER ============
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  debugPrint('🚀 Initializing app...');
  
  // 🔥 Initialize Firebase (مع معالجة أفضل للأخطاء)
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
    firebaseInitialized = true;
  } catch (e) {
    debugPrint('⚠️ Firebase initialization failed: $e');
    debugPrint('⚠️ التطبيق سيعمل في وضع Offline');
  }
  
  debugPrint('🎉 App ready!');
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CouponProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// ============ PROVIDERS ============

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _cartItems = [];
  
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
  final List<Map<String, dynamic>> _notifications = [];
  
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

class ChatProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _messages = [];
  
  List<Map<String, dynamic>> get messages => _messages;
  
  void addMessage(String sender, String text) {
    _messages.add({
      'sender': sender,
      'text': text,
      'time': DateTime.now(),
    });
    notifyListeners();
  }
  
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}

// ============ MAIN APP ============

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
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
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B9AC4),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
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
    try {
      // انتظر ثانية واحدة فقط
      await Future.delayed(const Duration(seconds: 1));
      
      if (!mounted) return;
      
      // الانتقال مباشرة للشاشة الرئيسية
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } catch (e) {
      debugPrint('⚠️ Initialization error: $e');
      
      // في حالة الخطأ، انتقل للشاشة الرئيسية
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(langProvider.translate('الرجاء ملء جميع الحقول', 'Please fill all fields')),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // استخدام نظام المصادقة المتقدم
      final result = await AuthManager.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (mounted) {
        setState(() => _isLoading = false);
        
        if (result['success']) {
          final user = result['user'] as UserModel;
          
          // عرض رسالة نجاح
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(langProvider.translate('تم تسجيل الدخول بنجاح', 'Login successful')),
              backgroundColor: Colors.green,
            ),
          );
          
          // الانتقال للشاشة المناسبة حسب نوع الحساب
          if (user.role == 'merchant') {
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
          // عرض رسالة خطأ
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(langProvider.translate('حدث خطأ أثناء تسجيل الدخول', 'Login error occurred')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => langProvider.toggleLanguage(),
                    icon: const Icon(Icons.language),
                    label: Text(langProvider.isArabic ? 'EN' : 'عربي'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
              Text(
                langProvider.translate('مرحباً بك!', 'Welcome!'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: langProvider.translate('البريد الإلكتروني', 'Email'),
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
                  labelText: langProvider.translate('كلمة المرور', 'Password'),
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
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        langProvider.translate('تسجيل الدخول', 'Login'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              // زر التسجيل
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    langProvider.translate('ليس لديك حساب؟', 'No account?'),
                    style: const TextStyle(fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: Text(
                      langProvider.translate('تسجيل حساب جديد', 'Create Account'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B9AC4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // خيار تخطي تسجيل الدخول
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                },
                child: Text(
                  langProvider.translate('تخطي وتصفح التطبيق', 'Skip and browse'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
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
    final langProvider = Provider.of<LanguageProvider>(context);
    
    final List<Widget> screens = [
      const ProductsScreen(),
      const CouponsScreen(),
      const ChatScreen(),
      const NotificationsScreen(),
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
        selectedFontSize: 11,
        unselectedFontSize: 10,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_bag, size: 22),
            label: langProvider.translate('المنتجات', 'Products'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.local_offer, size: 22),
            label: langProvider.translate('العروض', 'Offers'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat, size: 22),
            label: langProvider.translate('الدردشة', 'Chat'),
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('${notificationProvider.unreadCount}'),
              isLabelVisible: notificationProvider.unreadCount > 0,
              child: const Icon(Icons.notifications, size: 22),
            ),
            label: langProvider.translate('الإشعارات', 'Notifications'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person, size: 22),
            label: langProvider.translate('الحساب', 'Profile'),
          ),
        ],
      ),
    );
  }
}

// ============ PRODUCTS SCREEN WITH REVIEWS ============

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.translate('المنتجات', 'Products')),
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
            return Center(child: Text(langProvider.translate('خطأ في التحميل', 'Loading Error')));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!.docs;

          if (products.isEmpty) {
            return Center(child: Text(langProvider.translate('لا توجد منتجات', 'No Products')));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index].data() as Map<String, dynamic>;
              final productId = products[index].id;
              
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(productId: productId, product: product),
                    ),
                  );
                },
                child: Card(
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
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 14, color: Colors.amber),
                                Text(' ${product['rating'] ?? 4.5}', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${product['price'] ?? 0} ${langProvider.translate('جنيه', 'SDG')}',
                              style: const TextStyle(color: Color(0xFF6B9AC4), fontSize: 14, fontWeight: FontWeight.bold),
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
                                    SnackBar(
                                      content: Text(langProvider.translate('تمت الإضافة للسلة', 'Added to Cart')),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6B9AC4),
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(
                                  langProvider.translate('أضف', 'Add'),
                                  style: const TextStyle(fontSize: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
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

// ============ PRODUCT DETAIL SCREEN WITH REVIEWS ============

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> product;
  
  const ProductDetailScreen({super.key, required this.productId, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _reviewController = TextEditingController();
  double _rating = 5.0;

  Future<void> _submitReview() async {
    if (_reviewController.text.isEmpty) return;
    
    await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .collection('reviews')
        .add({
      'rating': _rating,
      'comment': _reviewController.text,
      'user_name': 'أحمد المشتري',
      'created_at': FieldValue.serverTimestamp(),
    });
    
    _reviewController.clear();
    setState(() => _rating = 5.0);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إضافة التقييم بنجاح')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product['name'] ?? ''),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.product['image_url'] ?? '',
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 300,
                color: Colors.grey[200],
                child: const Icon(Icons.image, size: 100),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product['name'] ?? '',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      Text(' ${widget.product['rating'] ?? 4.5}'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${widget.product['price'] ?? 0} ${langProvider.translate('جنيه', 'SDG')}',
                    style: const TextStyle(fontSize: 28, color: Color(0xFF6B9AC4), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.product['description'] ?? langProvider.translate('لا يوجد وصف', 'No description'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  Text(
                    langProvider.translate('التقييمات', 'Reviews'),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('products')
                        .doc(widget.productId)
                        .collection('reviews')
                        .orderBy('created_at', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      
                      final reviews = snapshot.data!.docs;
                      
                      if (reviews.isEmpty) {
                        return Text(langProvider.translate('لا توجد تقييمات بعد', 'No reviews yet'));
                      }
                      
                      return Column(
                        children: reviews.map((review) {
                          final data = review.data() as Map<String, dynamic>;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF6B9AC4),
                                child: Text(data['user_name'][0]),
                              ),
                              title: Row(
                                children: [
                                  Text(data['user_name']),
                                  const SizedBox(width: 8),
                                  ...List.generate(
                                    data['rating'].toInt(),
                                    (index) => const Icon(Icons.star, size: 14, color: Colors.amber),
                                  ),
                                ],
                              ),
                              subtitle: Text(data['comment']),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    langProvider.translate('أضف تقييمك', 'Add Your Review'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(langProvider.translate('التقييم:', 'Rating:')),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Slider(
                          value: _rating,
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: _rating.toString(),
                          onChanged: (value) => setState(() => _rating = value),
                        ),
                      ),
                      Text(_rating.toStringAsFixed(1)),
                    ],
                  ),
                  TextField(
                    controller: _reviewController,
                    decoration: InputDecoration(
                      hintText: langProvider.translate('اكتب تعليقك...', 'Write your comment...'),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B9AC4),
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    child: Text(
                      langProvider.translate('إرسال التقييم', 'Submit Review'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ CART SCREEN WITH COUPONS ============

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final couponProvider = Provider.of<CouponProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    
    final subtotal = cartProvider.totalAmount;
    final discount = couponProvider.calculateDiscount(subtotal);
    final total = subtotal - discount;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.translate('السلة', 'Cart')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: cartProvider.cartItems.isEmpty
          ? Center(child: Text(langProvider.translate('السلة فارغة', 'Cart is Empty')))
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
                        subtitle: Text('${item['price']} ${langProvider.translate('جنيه', 'SDG')}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => cartProvider.removeFromCart(index),
                        ),
                      );
                    },
                  ),
                ),
                if (couponProvider.appliedCoupon != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.green[50],
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${langProvider.translate('كوبون', 'Coupon')}: ${couponProvider.appliedCoupon} (${couponProvider.discountPercentage}% ${langProvider.translate('خصم', 'OFF')})',
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => couponProvider.removeCoupon(),
                        ),
                      ],
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
                          Text(langProvider.translate('المجموع الفرعي:', 'Subtotal:'), style: const TextStyle(fontSize: 16)),
                          Text('${subtotal.toInt()} ${langProvider.translate('جنيه', 'SDG')}', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      if (discount > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(langProvider.translate('الخصم:', 'Discount:'), style: const TextStyle(fontSize: 16, color: Colors.green)),
                            Text('-${discount.toInt()} ${langProvider.translate('جنيه', 'SDG')}', style: const TextStyle(fontSize: 16, color: Colors.green)),
                          ],
                        ),
                      ],
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(langProvider.translate('الإجمالي:', 'Total:'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('${total.toInt()} ${langProvider.translate('جنيه', 'SDG')}', style: const TextStyle(fontSize: 20, color: Color(0xFF6B9AC4), fontWeight: FontWeight.bold)),
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
                        child: Text(
                          langProvider.translate('متابعة الدفع', 'Continue to Payment'),
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ============ COUPONS SCREEN ============

class CouponsScreen extends StatelessWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final couponProvider = Provider.of<CouponProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final couponController = TextEditingController();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.translate('العروض والكوبونات', 'Offers & Coupons')),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    langProvider.translate('أدخل كود الخصم', 'Enter Coupon Code'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: couponController,
                          decoration: InputDecoration(
                            hintText: langProvider.translate('أدخل الكود', 'Enter Code'),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final success = await couponProvider.applyCoupon(couponController.text);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? langProvider.translate('تم تفعيل الكوبون!', 'Coupon Applied!')
                                      : langProvider.translate('كوبون غير صالح', 'Invalid Coupon'),
                                ),
                                backgroundColor: success ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B9AC4)),
                        child: Text(langProvider.translate('تفعيل', 'Apply'), style: const TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            langProvider.translate('الكوبونات المتاحة', 'Available Coupons'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildCouponCard(context, 'WELCOME10', '10% ${langProvider.translate('خصم', 'OFF')}', langProvider.translate('للمستخدمين الجدد', 'For New Users')),
          _buildCouponCard(context, 'SAVE20', '20% ${langProvider.translate('خصم', 'OFF')}', langProvider.translate('على جميع المنتجات', 'On All Products')),
          _buildCouponCard(context, 'MEGA50', '50% ${langProvider.translate('خصم', 'OFF')}', langProvider.translate('عرض محدود!', 'Limited Time!')),
        ],
      ),
    );
  }
  
  Widget _buildCouponCard(BuildContext context, String code, String discount, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF6B9AC4),
          child: Icon(Icons.local_offer, color: Colors.white),
        ),
        title: Text(code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(discount, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            Text(description, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: code));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$code copied!')),
            );
          },
          child: const Text('Copy'),
        ),
      ),
    );
  }
}


// ============ CHAT SCREEN ============

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;
    
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.addMessage('me', _messageController.text);
    
    // Simulate merchant reply
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        chatProvider.addMessage('merchant', 'شكراً لرسالتك! سنرد عليك قريباً');
      }
    });
    
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.translate('الدردشة مع التاجر', 'Chat with Merchant')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: chatProvider.messages.isEmpty
                ? Center(child: Text(langProvider.translate('ابدأ المحادثة', 'Start Conversation')))
                : ListView.builder(
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatProvider.messages[index];
                      final isMe = message['sender'] == 'me';
                      
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFF6B9AC4) : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['text'],
                                style: TextStyle(color: isMe ? Colors.white : Colors.black),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('HH:mm').format(message['time']),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: langProvider.translate('اكتب رسالتك...', 'Type message...'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF6B9AC4),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
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

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final couponProvider = Provider.of<CouponProvider>(context);
    
    final subtotal = cartProvider.totalAmount;
    final discount = couponProvider.calculateDiscount(subtotal);
    final total = subtotal - discount;
    
    // استخدام نظام الدفع المحلي المتقدم
    return LocalPaymentSystem(
      userId: 'CURRENT_USER', // يجب استبداله بمعرف المستخدم الفعلي
      orderId: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      totalAmount: total,
      onPaymentComplete: (paymentData) {
        final paymentMethod = paymentData['method'] ?? 'unknown';
        // مسح السلة بعد الدفع
        cartProvider.clearCart();
        couponProvider.removeCoupon();
        
        // إظهار رسالة نجاح
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم الدفع بنجاح عبر $paymentMethod'),
            backgroundColor: Colors.green,
          ),
        );
        
        // الرجوع للصفحة الرئيسية
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }
}

// ============ NOTIFICATIONS SCREEN ============

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final notifications = notificationProvider.notifications;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.translate('الإشعارات', 'Notifications')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () => notificationProvider.clearAll(),
              child: Text(langProvider.translate('مسح الكل', 'Clear All'), style: const TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(child: Text(langProvider.translate('لا توجد إشعارات', 'No Notifications')))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final isRead = notification['read'] as bool;
                final time = notification['time'] as DateTime;
                
                return Card(
                  color: isRead ? null : Colors.blue[50],
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isRead ? Colors.grey : const Color(0xFF6B9AC4),
                      child: const Icon(Icons.notifications, color: Colors.white, size: 20),
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

// ============ PROFILE SCREEN ============
// الآن يستخدم النظام المتكامل من complete_profile_system.dart

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدام CompleteProfileScreen من ملف النظام المتكامل
    return const CompleteProfileScreen();
  }
}

// ============ REPORTS SCREEN ============

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(langProvider.translate('التقارير والتحليلات', 'Reports & Analytics')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final orders = snapshot.data!.docs;
          final totalOrders = orders.length;
          final totalRevenue = orders.fold<double>(0, (sum, order) {
            final data = order.data() as Map<String, dynamic>;
            return sum + ((data['total_amount'] ?? 0) as num).toDouble();
          });
          
          return GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildStatCard(
                langProvider.translate('إجمالي الطلبات', 'Total Orders'),
                '$totalOrders',
                Icons.receipt_long,
                Colors.blue,
              ),
              _buildStatCard(
                langProvider.translate('الإيرادات', 'Revenue'),
                '${totalRevenue.toInt()} ${langProvider.translate('جنيه', 'SDG')}',
                Icons.attach_money,
                Colors.green,
              ),
              _buildStatCard(
                langProvider.translate('متوسط الطلب', 'Avg Order'),
                '${(totalRevenue / (totalOrders > 0 ? totalOrders : 1)).toInt()} ${langProvider.translate('جنيه', 'SDG')}',
                Icons.analytics,
                Colors.orange,
              ),
              _buildStatCard(
                langProvider.translate('نسبة النمو', 'Growth'),
                '+${((totalOrders / 10) * 100).toInt()}%',
                Icons.trending_up,
                Colors.purple,
              ),
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
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
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
      const MerchantReportsScreen(),
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
            icon: Icon(Icons.analytics),
            label: 'التقارير',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
          ),
        ],
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

// ============ MERCHANT PRODUCTS SCREEN WITH IMAGE UPLOAD ============

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
    XFile? selectedImage;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
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
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    selectedImage = await picker.pickImage(source: ImageSource.gallery);
                    setState(() {});
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('اختر صورة'),
                ),
                if (selectedImage != null) Text('تم اختيار: ${selectedImage!.name}'),
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
                String imageUrl = imageController.text;
                
                if (selectedImage != null) {
                  try {
                    final file = File(selectedImage!.path);
                    final ref = FirebaseStorage.instance
                        .ref()
                        .child('products/${DateTime.now().millisecondsSinceEpoch}.jpg');
                    await ref.putFile(file);
                    imageUrl = await ref.getDownloadURL();
                  } catch (e) {
                    debugPrint('Error uploading image: $e');
                  }
                }
                
                await FirebaseFirestore.instance.collection('products').add({
                  'name': nameController.text,
                  'price': double.tryParse(priceController.text) ?? 0,
                  'stock': int.tryParse(stockController.text) ?? 0,
                  'image_url': imageUrl,
                  'is_active': true,
                  'rating': 4.5,
                  'created_at': FieldValue.serverTimestamp(),
                });
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
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

// ============ MERCHANT REPORTS SCREEN ============

class MerchantReportsScreen extends StatelessWidget {
  const MerchantReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير والتحليلات'),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final orders = snapshot.data!.docs;
          final totalOrders = orders.length;
          final totalRevenue = orders.fold<double>(0, (sum, order) {
            final data = order.data() as Map<String, dynamic>;
            return sum + ((data['total_amount'] ?? 0) as num).toDouble();
          });
          final avgOrder = totalOrders > 0 ? totalRevenue / totalOrders : 0;
          
          return SingleChildScrollView(
            child: Column(
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(16),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildStatCard('إجمالي الطلبات', '$totalOrders', Icons.receipt_long, Colors.blue),
                    _buildStatCard('الإيرادات', '${totalRevenue.toInt()} جنيه', Icons.attach_money, Colors.green),
                    _buildStatCard('متوسط الطلب', '${avgOrder.toInt()} جنيه', Icons.analytics, Colors.orange),
                    _buildStatCard('نسبة النمو', '+${((totalOrders / 10) * 100).toInt()}%', Icons.trending_up, Colors.purple),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('📊 التحليلات الشهرية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                Container(
                  height: 200,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('📈 رسم بياني للمبيعات', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
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
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
