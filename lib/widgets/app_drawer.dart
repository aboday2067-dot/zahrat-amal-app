import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _userType = 'buyer';
  String _userName = 'مستخدم';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userType = prefs.getString('userType') ?? 'buyer';
      _userEmail = prefs.getString('userEmail') ?? '';
      _userName = _userEmail.split('@').first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ..._buildMenuItems(),
              ],
            ),
          ),
          _buildDrawerFooter(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    Color headerColor;
    IconData headerIcon;
    String headerTitle;

    switch (_userType) {
      case 'merchant':
        headerColor = Colors.blue;
        headerIcon = Icons.store;
        headerTitle = 'لوحة التاجر';
        break;
      case 'delivery':
        headerColor = Colors.orange;
        headerIcon = Icons.local_shipping;
        headerTitle = 'لوحة التوصيل';
        break;
      case 'admin':
        headerColor = Colors.teal;
        headerIcon = Icons.admin_panel_settings;
        headerTitle = 'لوحة الإدارة';
        break;
      default:
        headerColor = Colors.green;
        headerIcon = Icons.shopping_bag;
        headerTitle = 'سوق السودان الذكي';
    }

    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [headerColor, headerColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(
          headerIcon,
          size: 40,
          color: headerColor,
        ),
      ),
      accountName: Text(
        _userName,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      accountEmail: Text(_userEmail),
      otherAccountsPictures: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                headerTitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMenuItems() {
    switch (_userType) {
      case 'merchant':
        return _buildMerchantMenu();
      case 'delivery':
        return _buildDeliveryMenu();
      case 'admin':
        return _buildAdminMenu();
      default:
        return _buildBuyerMenu();
    }
  }

  List<Widget> _buildBuyerMenu() {
    return [
      _buildMenuSection('التسوق', Icons.shopping_cart),
      _buildMenuItem(
        'الصفحة الرئيسية',
        Icons.home,
        Colors.green,
        () => Navigator.pushReplacementNamed(context, '/home'),
      ),
      _buildMenuItem(
        'السلة',
        Icons.shopping_cart,
        Colors.orange,
        () => Navigator.pushNamed(context, '/cart'),
      ),
      _buildMenuItem(
        'المنتجات المفضلة',
        Icons.favorite,
        Colors.red,
        () => Navigator.pushNamed(context, '/buyer/favorites'),
      ),
      const Divider(),
      _buildMenuSection('حسابي', Icons.person),
      _buildMenuItem(
        'الملف الشخصي',
        Icons.account_circle,
        Colors.blue,
        () => Navigator.pushNamed(context, '/buyer/profile'),
      ),
      _buildMenuItem(
        'طلباتي',
        Icons.list_alt,
        Colors.purple,
        () => Navigator.pushNamed(context, '/buyer/orders'),
      ),
      _buildMenuItem(
        'عناويني',
        Icons.location_on,
        Colors.teal,
        () => Navigator.pushNamed(context, '/buyer/addresses'),
      ),
      _buildMenuItem(
        'المحادثات',
        Icons.chat,
        Colors.indigo,
        () => Navigator.pushNamed(context, '/chats'),
      ),
      const Divider(),
      _buildMenuSection('أخرى', Icons.more_horiz),
      _buildMenuItem(
        'الإعدادات',
        Icons.settings,
        Colors.grey,
        () => Navigator.pushNamed(context, '/settings'),
      ),
      _buildMenuItem(
        'المساعدة والدعم',
        Icons.help,
        Colors.blueGrey,
        () => Navigator.pushNamed(context, '/help'),
      ),
    ];
  }

  List<Widget> _buildMerchantMenu() {
    return [
      _buildMenuSection('إدارة المتجر', Icons.store),
      _buildMenuItem(
        'لوحة التحكم',
        Icons.dashboard,
        Colors.blue,
        () => Navigator.pushReplacementNamed(context, '/merchant/dashboard'),
      ),
      _buildMenuItem(
        'الملف الشخصي',
        Icons.account_circle,
        Colors.indigo,
        () => Navigator.pushNamed(context, '/merchant/profile'),
      ),
      _buildMenuItem(
        'إدارة المخزون',
        Icons.inventory,
        Colors.purple,
        () => Navigator.pushNamed(context, '/merchant/warehouse'),
      ),
      _buildMenuItem(
        'طرق الدفع',
        Icons.payment,
        Colors.teal,
        () => Navigator.pushNamed(context, '/merchant/payment'),
      ),
      const Divider(),
      _buildMenuSection('المنتجات والطلبات', Icons.shopping_bag),
      _buildMenuItem(
        'إضافة منتج',
        Icons.add_box,
        Colors.green,
        () => Navigator.pushNamed(context, '/merchant/add-product'),
      ),
      _buildMenuItem(
        'الطلبات',
        Icons.list_alt,
        Colors.orange,
        () => Navigator.pushNamed(context, '/merchant/orders'),
      ),
      _buildMenuItem(
        'التحليلات',
        Icons.analytics,
        Colors.deepPurple,
        () => Navigator.pushNamed(context, '/merchant/analytics'),
      ),
      const Divider(),
      _buildMenuSection('أخرى', Icons.more_horiz),
      _buildMenuItem(
        'الإعدادات',
        Icons.settings,
        Colors.grey,
        () => Navigator.pushNamed(context, '/settings'),
      ),
    ];
  }

  List<Widget> _buildDeliveryMenu() {
    return [
      _buildMenuSection('إدارة التوصيل', Icons.local_shipping),
      _buildMenuItem(
        'لوحة التحكم',
        Icons.dashboard,
        Colors.orange,
        () => Navigator.pushReplacementNamed(context, '/delivery/dashboard'),
      ),
      _buildMenuItem(
        'ملف المكتب',
        Icons.account_circle,
        Colors.deepOrange,
        () => Navigator.pushNamed(context, '/delivery/profile'),
      ),
      _buildMenuItem(
        'التوصيلات النشطة',
        Icons.pending_actions,
        Colors.blue,
        () => Navigator.pushNamed(context, '/delivery/active'),
      ),
      _buildMenuItem(
        'سجل التوصيلات',
        Icons.history,
        Colors.purple,
        () => Navigator.pushNamed(context, '/delivery/history'),
      ),
      const Divider(),
      _buildMenuSection('إدارة الفريق', Icons.people),
      _buildMenuItem(
        'العمال',
        Icons.people_outline,
        Colors.green,
        () => Navigator.pushNamed(context, '/delivery/agents'),
      ),
      _buildMenuItem(
        'مناطق التغطية',
        Icons.map,
        Colors.teal,
        () => Navigator.pushNamed(context, '/delivery/coverage'),
      ),
      const Divider(),
      _buildMenuSection('أخرى', Icons.more_horiz),
      _buildMenuItem(
        'الإحصائيات',
        Icons.bar_chart,
        Colors.indigo,
        () => Navigator.pushNamed(context, '/delivery/statistics'),
      ),
      _buildMenuItem(
        'الإعدادات',
        Icons.settings,
        Colors.grey,
        () => Navigator.pushNamed(context, '/settings'),
      ),
    ];
  }

  List<Widget> _buildAdminMenu() {
    return [
      _buildMenuSection('الإدارة', Icons.admin_panel_settings),
      _buildMenuItem(
        'لوحة التحكم',
        Icons.dashboard,
        Colors.teal,
        () => Navigator.pushReplacementNamed(context, '/admin'),
      ),
      const Divider(),
      _buildMenuSection('إدارة المستخدمين', Icons.people),
      _buildMenuItem(
        'التجار',
        Icons.store,
        Colors.blue,
        () => Navigator.pushNamed(context, '/admin/merchants'),
      ),
      _buildMenuItem(
        'المشترين',
        Icons.shopping_bag,
        Colors.green,
        () => Navigator.pushNamed(context, '/admin/buyers'),
      ),
      _buildMenuItem(
        'مكاتب التوصيل',
        Icons.local_shipping,
        Colors.orange,
        () => Navigator.pushNamed(context, '/admin/delivery'),
      ),
      const Divider(),
      _buildMenuSection('إدارة المحتوى', Icons.inventory),
      _buildMenuItem(
        'المنتجات',
        Icons.inventory_2,
        Colors.purple,
        () => Navigator.pushNamed(context, '/admin/products'),
      ),
      _buildMenuItem(
        'الطلبات',
        Icons.list_alt,
        Colors.indigo,
        () => Navigator.pushNamed(context, '/admin/orders'),
      ),
      const Divider(),
      _buildMenuSection('التقارير', Icons.assessment),
      _buildMenuItem(
        'التقارير المالية',
        Icons.attach_money,
        Colors.green,
        () => Navigator.pushNamed(context, '/admin/financial'),
      ),
      _buildMenuItem(
        'تحليلات المنصة',
        Icons.analytics,
        Colors.deepPurple,
        () => Navigator.pushNamed(context, '/admin/analytics'),
      ),
    ];
  }

  Widget _buildMenuSection(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDrawerFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.logout, color: Colors.red, size: 20),
            ),
            title: const Text(
              'تسجيل الخروج',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Smart Bazaar v1.0',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
