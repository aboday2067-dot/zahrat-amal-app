// ============================================
// نسخة Demo سريعة - بدون Firebase
// Quick Demo Version - Without Firebase
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'زهرة الأمل - Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DemoHomeScreen(),
    );
  }
}

class LanguageProvider with ChangeNotifier {
  String _currentLanguage = 'ar';
  
  String get currentLanguage => _currentLanguage;
  
  void toggleLanguage() {
    _currentLanguage = _currentLanguage == 'ar' ? 'en' : 'ar';
    notifyListeners();
  }
  
  String translate(String ar, String en) {
    return _currentLanguage == 'ar' ? ar : en;
  }
}

class DemoHomeScreen extends StatelessWidget {
  const DemoHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('زهرة الأمل', 'ZahratAmal')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => lang.toggleLanguage(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // رأس التطبيق
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.shopping_bag,
                    size: 80,
                    color: Color(0xFF6B9AC4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    lang.translate('زهرة الأمل', 'ZahratAmal'),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lang.translate('سوق السودان الذكي', 'Sudan Smart Marketplace'),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // الميزات
          _buildFeatureCard(
            lang,
            Icons.local_shipping,
            lang.translate('مكاتب التوصيل', 'Delivery Offices'),
            lang.translate('4 مكاتب • 17 سائق • 12 مركبة', '4 offices • 17 drivers • 12 vehicles'),
            () => _showDemoOffices(context, lang),
          ),
          
          _buildFeatureCard(
            lang,
            Icons.person,
            lang.translate('السائقين', 'Drivers'),
            lang.translate('17 سائق نشط مع تقييمات', '17 active drivers with ratings'),
            () => _showDemoDrivers(context, lang),
          ),
          
          _buildFeatureCard(
            lang,
            Icons.directions_car,
            lang.translate('المركبات', 'Vehicles'),
            lang.translate('12 مركبة متنوعة', '12 various vehicles'),
            () => _showDemoVehicles(context, lang),
          ),
          
          _buildFeatureCard(
            lang,
            Icons.sort,
            lang.translate('الفرز الذكي', 'Smart Sorting'),
            lang.translate('حسب المدينة، القرب، التقييم، السعر', 'By city, distance, rating, price'),
            () => _showDemoSorting(context, lang),
          ),
          
          _buildFeatureCard(
            lang,
            Icons.offline_bolt,
            lang.translate('العمل بدون إنترنت', 'Offline Mode'),
            lang.translate('تخزين مؤقت ذكي للبيانات', 'Smart data caching'),
            () => _showDemoOffline(context, lang),
          ),
          
          const SizedBox(height: 24),
          
          // معلومات الإصدار
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    lang.translate('الإصدار v5.0', 'Version v5.0'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lang.translate('نظام مكاتب التوصيل المتقدم', 'Advanced Delivery System'),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    lang.translate('حجم APK: 50 MB فقط!', 'APK Size: Only 50 MB!'),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureCard(
    LanguageProvider lang,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF6B9AC4),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
  
  void _showDemoOffices(BuildContext context, LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.translate('مكاتب التوصيل', 'Delivery Offices')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOfficeItem('البرق للشحن والتوصيل', 'الخرطوم', 4.8, 450),
              _buildOfficeItem('النجم الساطع', 'أم درمان', 4.6, 380),
              _buildOfficeItem('الأمانة للتوصيل', 'بحري', 4.9, 520),
              _buildOfficeItem('سريع للتوصيل', 'الخرطوم', 4.5, 290),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.translate('إغلاق', 'Close')),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOfficeItem(String name, String city, double rating, int deliveries) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.local_shipping, color: Color(0xFF6B9AC4)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$city • ⭐ $rating • $deliveries توصيلة'),
      ),
    );
  }
  
  void _showDemoDrivers(BuildContext context, LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.translate('السائقين', 'Drivers')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDriverItem('محمد أحمد علي', '0918762927', 4.6),
              _buildDriverItem('عثمان إبراهيم', '0912461268', 4.2),
              _buildDriverItem('حسن علي محمد', '0915508993', 4.9),
              _buildDriverItem('أحمد عبد الرحمن', '0912418035', 4.7),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.translate('إغلاق', 'Close')),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDriverItem(String name, String phone, double rating) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF6B9AC4),
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$phone • ⭐ $rating'),
      ),
    );
  }
  
  void _showDemoVehicles(BuildContext context, LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.translate('المركبات', 'Vehicles')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVehicleItem('Toyota Yaris', 'أ 9544 أ', 'سيارة صغيرة', 200),
              _buildVehicleItem('Nissan Sunny', 'د 6679 و', 'سيارة صغيرة', 300),
              _buildVehicleItem('Yamaha YBR125', 'أ 3576 ج', 'دراجة نارية', 75),
              _buildVehicleItem('Mitsubishi L200', 'ز 6414 ج', 'شاحنة صغيرة', 1500),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.translate('إغلاق', 'Close')),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVehicleItem(String model, String plate, String type, int capacity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          type == 'دراجة نارية' ? Icons.two_wheeler :
          type == 'شاحنة صغيرة' ? Icons.local_shipping : Icons.directions_car,
          color: const Color(0xFF6B9AC4),
        ),
        title: Text(model, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$plate • $type • $capacity كجم'),
      ),
    );
  }
  
  void _showDemoSorting(BuildContext context, LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.translate('خيارات الفرز', 'Sorting Options')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSortOption(Icons.stars, lang.translate('الأفضل', 'Best'), lang),
            _buildSortOption(Icons.near_me, lang.translate('الأقرب', 'Nearest'), lang),
            _buildSortOption(Icons.star, lang.translate('التقييم', 'Rating'), lang),
            _buildSortOption(Icons.attach_money, lang.translate('السعر', 'Price'), lang),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.translate('إغلاق', 'Close')),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSortOption(IconData icon, String label, LanguageProvider lang) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6B9AC4)),
      title: Text(label),
      trailing: const Icon(Icons.check_circle, color: Colors.green),
    );
  }
  
  void _showDemoOffline(BuildContext context, LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.translate('الوضع غير المتصل', 'Offline Mode')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.offline_bolt, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              lang.translate(
                'يعمل التطبيق بدون إنترنت مع:\n• تخزين مؤقت ذكي\n• مراقبة حالة الشبكة\n• جلب بيانات ذكي\n• دعم Firestore المؤقت',
                'App works offline with:\n• Smart caching\n• Network monitoring\n• Smart data fetching\n• Firestore persistence',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.translate('إغلاق', 'Close')),
          ),
        ],
      ),
    );
  }
}
