import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/cart_provider.dart';
import 'screens/home_screen.dart';
import 'screens/auth/enhanced_login_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/manage_merchants_screen.dart';
import 'screens/admin/manage_buyers_screen.dart';
import 'screens/admin/manage_delivery_offices_screen.dart';
import 'screens/merchant/merchant_dashboard.dart';
import 'screens/merchant/merchant_profile_screen.dart';
import 'screens/merchant/payment_methods_screen.dart';
import 'screens/merchant/warehouse_management_screen.dart';
import 'screens/merchant/add_product_screen.dart';
import 'screens/buyer/buyer_profile_screen.dart';
import 'screens/delivery/delivery_dashboard.dart';
import 'screens/delivery/delivery_profile_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      return const EnhancedLoginScreen();
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
          '/login': (context) => const EnhancedLoginScreen(),
          '/cart': (context) => const CartScreen(),

          
          // Admin Routes
          '/admin': (context) => const AdminDashboard(),
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
          
          // Delivery Routes
          '/delivery/dashboard': (context) => const DeliveryDashboard(),
          '/delivery/profile': (context) => const DeliveryProfileScreen(),
        },
      ),
    );
  }
}
