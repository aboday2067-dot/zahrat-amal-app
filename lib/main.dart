import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/cart_provider.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/admin_login_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_dashboard_fixed.dart';
import 'screens/admin/ai_developer_screen.dart';
import 'screens/admin/manage_merchants_screen.dart';
import 'screens/admin/manage_buyers_screen.dart';
import 'screens/admin/manage_delivery_offices_screen.dart';
import 'screens/chat/chats_list_screen.dart';
import 'screens/merchant/merchant_dashboard.dart';
import 'screens/merchant/merchant_profile_screen.dart';
import 'screens/merchant/payment_methods_screen.dart';
import 'screens/merchant/warehouse_management_screen.dart';
import 'screens/merchant/add_product_screen.dart';
import 'screens/buyer/buyer_profile_screen.dart';
import 'screens/delivery/delivery_dashboard.dart';
import 'screens/delivery/delivery_profile_screen.dart';
import 'screens/buyer/favorites_screen.dart';
import 'screens/buyer/my_orders_screen.dart';
import 'screens/buyer/addresses_screen.dart';
import 'screens/buyer/checkout_screen.dart';
import 'screens/merchant/merchant_orders_screen.dart';
import 'screens/merchant/merchant_analytics_screen.dart';
import 'screens/delivery/active_deliveries_screen.dart';
import 'screens/delivery/delivery_agents_screen.dart';
import 'screens/delivery/coverage_areas_screen.dart';
import 'screens/delivery/delivery_history_screen.dart';
import 'screens/delivery/delivery_statistics_screen.dart';
import 'screens/admin/admin_products_screen.dart';
import 'screens/admin/admin_orders_screen.dart';
import 'screens/admin/financial_reports_screen.dart';
import 'screens/admin/platform_analytics_screen.dart';
import 'screens/common/settings_screen.dart';
import 'screens/common/help_support_screen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase تم تهيئته بنجاح');
  } catch (e) {
    debugPrint('❌ فشل في تهيئة Firebase: $e');
    debugPrint('⚠️ التطبيق سيعمل بالنظام المحلي فقط');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userType = prefs.getString('userType') ?? 'buyer';

    if (isLoggedIn && userType == 'admin') {
      return const AdminDashboard();
    } else if (isLoggedIn) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
            title: 'ZahratAmal - زهرة الأمل',
            debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarThemeData(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => FutureBuilder<Widget>(
                future: _getInitialScreen(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return snapshot.data!;
                  }
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                },
              ),
          // Common Routes
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/cart': (context) => const CartScreen(),

          // Admin Secret Login
          '/admin-login': (context) => const AdminLoginScreen(),
          
          // Admin Routes
          '/admin': (context) => const AdminDashboard(),
          '/admin-dashboard': (context) => const AdminDashboardFixed(),
          '/admin/ai-developer': (context) => const AIDeveloperScreen(),
          '/admin/merchants': (context) => const ManageMerchantsScreen(),
          '/admin/buyers': (context) => const ManageBuyersScreen(),
          '/admin/delivery': (context) => const ManageDeliveryOfficesScreen(),
          
          // Merchant Routes
          '/merchant/dashboard': (context) => const MerchantDashboard(),
          '/merchant/profile': (context) => const MerchantProfileScreen(),
          '/merchant/payment': (context) => const PaymentMethodsScreen(),
          '/merchant/warehouse': (context) => const WarehouseManagementScreen(),
          '/merchant/add-product': (context) => const AddProductScreen(),
          
          // Buyer Routes
          '/buyer/profile': (context) => const BuyerProfileScreen(),
          '/buyer/favorites': (context) => const FavoritesScreen(),
          '/buyer/orders': (context) => const MyOrdersScreen(),
          '/buyer/addresses': (context) => const AddressesScreen(),
          '/buyer/checkout': (context) => const CheckoutScreen(),
          
          // Merchant Routes (Extended)
          '/merchant/orders': (context) => const MerchantOrdersScreen(),
          '/merchant/analytics': (context) => const MerchantAnalyticsScreen(),
          
          // Chat Routes
          '/chats': (context) => const ChatsListScreen(),
          
          // Delivery Routes
          '/delivery/dashboard': (context) => const DeliveryDashboard(),
          '/delivery/profile': (context) => const DeliveryProfileScreen(),
          '/delivery/active': (context) => const ActiveDeliveriesScreen(),
          '/delivery/history': (context) => const DeliveryHistoryScreen(),
          '/delivery/agents': (context) => const DeliveryAgentsScreen(),
          '/delivery/coverage': (context) => const CoverageAreasScreen(),
          '/delivery/statistics': (context) => const DeliveryStatisticsScreen(),
          
          // Admin Routes (Extended)
          '/admin/products': (context) => const AdminProductsScreen(),
          '/admin/orders': (context) => const AdminOrdersScreen(),
          '/admin/financial': (context) => const FinancialReportsScreen(),
          '/admin/analytics': (context) => const PlatformAnalyticsScreen(),
          
          // Common Routes
          '/settings': (context) => const SettingsScreen(),
          '/help': (context) => const HelpSupportScreen(),
        },
      ),
    );
  }
}
