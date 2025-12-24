// ============================================
// أنظمة الملفات الشخصية المتخصصة
// Specialized Profile Systems (Merchant, Buyer, Delivery Office)
// ============================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'main.dart';
import 'profile_image_upload.dart';

// ========== نموذج بيانات التاجر ==========
class MerchantProfileData {
  final String userId;
  final String merchantName;
  final String ownerName;
  final String email;
  final String phone;
  final String businessLicense;
  final String address;
  final String city;
  final String district;
  final String? profileImage;
  final String? storeLogo;
  final double rating;
  final int totalSales;
  final int totalProducts;
  final int totalOrders;
  final String joinDate;
  final bool isVerified;
  final List<String> categories;
  
  MerchantProfileData({
    required this.userId,
    required this.merchantName,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.businessLicense,
    required this.address,
    required this.city,
    required this.district,
    this.profileImage,
    this.storeLogo,
    this.rating = 0.0,
    this.totalSales = 0,
    this.totalProducts = 0,
    this.totalOrders = 0,
    required this.joinDate,
    this.isVerified = false,
    this.categories = const [],
  });
  
  factory MerchantProfileData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MerchantProfileData(
      userId: doc.id,
      merchantName: data['merchant_name'] ?? '',
      ownerName: data['owner_name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      businessLicense: data['business_license'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      district: data['district'] ?? '',
      profileImage: data['profile_image'],
      storeLogo: data['store_logo'],
      rating: (data['rating'] ?? 0).toDouble(),
      totalSales: data['total_sales'] ?? 0,
      totalProducts: data['total_products'] ?? 0,
      totalOrders: data['total_orders'] ?? 0,
      joinDate: data['join_date'] ?? '',
      isVerified: data['is_verified'] ?? false,
      categories: List<String>.from(data['categories'] ?? []),
    );
  }
  
  Map<String, dynamic> toJson() => {
    'merchant_name': merchantName,
    'owner_name': ownerName,
    'email': email,
    'phone': phone,
    'business_license': businessLicense,
    'address': address,
    'city': city,
    'district': district,
    'profile_image': profileImage,
    'store_logo': storeLogo,
    'rating': rating,
    'total_sales': totalSales,
    'total_products': totalProducts,
    'total_orders': totalOrders,
    'join_date': joinDate,
    'is_verified': isVerified,
    'categories': categories,
  };
}

// ========== نموذج بيانات المشتري ==========
class BuyerProfileData {
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final String city;
  final String district;
  final String? profileImage;
  final int totalOrders;
  final double totalSpent;
  final int loyaltyPoints;
  final String joinDate;
  final List<String> favoriteCategories;
  final String membershipLevel; // Bronze, Silver, Gold, Platinum
  
  BuyerProfileData({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.city,
    required this.district,
    this.profileImage,
    this.totalOrders = 0,
    this.totalSpent = 0.0,
    this.loyaltyPoints = 0,
    required this.joinDate,
    this.favoriteCategories = const [],
    this.membershipLevel = 'Bronze',
  });
  
  factory BuyerProfileData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BuyerProfileData(
      userId: doc.id,
      fullName: data['full_name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      city: data['city'] ?? '',
      district: data['district'] ?? '',
      profileImage: data['profile_image'],
      totalOrders: data['total_orders'] ?? 0,
      totalSpent: (data['total_spent'] ?? 0).toDouble(),
      loyaltyPoints: data['loyalty_points'] ?? 0,
      joinDate: data['join_date'] ?? '',
      favoriteCategories: List<String>.from(data['favorite_categories'] ?? []),
      membershipLevel: data['membership_level'] ?? 'Bronze',
    );
  }
  
  Map<String, dynamic> toJson() => {
    'full_name': fullName,
    'email': email,
    'phone': phone,
    'city': city,
    'district': district,
    'profile_image': profileImage,
    'total_orders': totalOrders,
    'total_spent': totalSpent,
    'loyalty_points': loyaltyPoints,
    'join_date': joinDate,
    'favorite_categories': favoriteCategories,
    'membership_level': membershipLevel,
  };
  
  Color getMembershipColor() {
    switch (membershipLevel) {
      case 'Platinum':
        return const Color(0xFF1E3A8A);
      case 'Gold':
        return const Color(0xFFD97706);
      case 'Silver':
        return const Color(0xFF9CA3AF);
      default:
        return const Color(0xFF92400E);
    }
  }
  
  IconData getMembershipIcon() {
    switch (membershipLevel) {
      case 'Platinum':
        return Icons.workspace_premium;
      case 'Gold':
        return Icons.military_tech;
      case 'Silver':
        return Icons.stars;
      default:
        return Icons.star;
    }
  }
}

// ========== نموذج بيانات مكتب التوصيل ==========
class DeliveryOfficeProfileData {
  final String userId;
  final String officeName;
  final String managerName;
  final String email;
  final String phone;
  final String address;
  final String city;
  final List<String> coverageAreas;
  final String? profileImage;
  final double rating;
  final int totalDeliveries;
  final int activeDrivers;
  final Map<String, double> deliveryPrices; // منطقة -> سعر
  final String joinDate;
  final bool isActive;
  final String workingHours;
  
  DeliveryOfficeProfileData({
    required this.userId,
    required this.officeName,
    required this.managerName,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.coverageAreas,
    this.profileImage,
    this.rating = 0.0,
    this.totalDeliveries = 0,
    this.activeDrivers = 0,
    this.deliveryPrices = const {},
    required this.joinDate,
    this.isActive = true,
    this.workingHours = '8:00 AM - 10:00 PM',
  });
  
  factory DeliveryOfficeProfileData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DeliveryOfficeProfileData(
      userId: doc.id,
      officeName: data['office_name'] ?? '',
      managerName: data['manager_name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      coverageAreas: List<String>.from(data['coverage_areas'] ?? []),
      profileImage: data['profile_image'],
      rating: (data['rating'] ?? 0).toDouble(),
      totalDeliveries: data['total_deliveries'] ?? 0,
      activeDrivers: data['active_drivers'] ?? 0,
      deliveryPrices: Map<String, double>.from(data['delivery_prices'] ?? {}),
      joinDate: data['join_date'] ?? '',
      isActive: data['is_active'] ?? true,
      workingHours: data['working_hours'] ?? '8:00 AM - 10:00 PM',
    );
  }
  
  Map<String, dynamic> toJson() => {
    'office_name': officeName,
    'manager_name': managerName,
    'email': email,
    'phone': phone,
    'address': address,
    'city': city,
    'coverage_areas': coverageAreas,
    'profile_image': profileImage,
    'rating': rating,
    'total_deliveries': totalDeliveries,
    'active_drivers': activeDrivers,
    'delivery_prices': deliveryPrices,
    'join_date': joinDate,
    'is_active': isActive,
    'working_hours': workingHours,
  };
}

// ========== صفحة ملف التاجر ==========
class MerchantProfileScreen extends StatelessWidget {
  final String merchantId;
  
  const MerchantProfileScreen({super.key, required this.merchantId});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('الملف التجاري', 'Merchant Profile')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // تعديل الملف التجاري
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('merchants')
            .doc(merchantId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.store, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(lang.translate('لم يتم العثور على البيانات', 'Profile not found')),
                ],
              ),
            );
          }
          
          final merchant = MerchantProfileData.fromFirestore(snapshot.data!);
          
          return RefreshIndicator(
            onRefresh: () async {
              // إعادة تحميل البيانات
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // رأس الملف التجاري
                _buildMerchantHeader(context, merchant, lang),
                const SizedBox(height: 24),
                
                // الإحصائيات
                _buildStatsRow(context, merchant, lang),
                const SizedBox(height: 24),
                
                // معلومات العمل
                _buildBusinessInfo(context, merchant, lang),
                const SizedBox(height: 16),
                
                // الفئات
                _buildCategories(context, merchant, lang),
                const SizedBox(height: 16),
                
                // التقييم
                _buildRatingCard(context, merchant, lang),
                const SizedBox(height: 16),
                
                // الإجراءات السريعة
                _buildMerchantActions(context, merchant, lang),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildMerchantHeader(BuildContext context, MerchantProfileData merchant, LanguageProvider lang) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                ProfileImageWidget(
                  imageUrl: merchant.profileImage,
                  radius: 50,
                ),
                if (merchant.isVerified)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified, size: 20, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              merchant.merchantName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.store, size: 16, color: Colors.green),
                  const SizedBox(width: 6),
                  Text(
                    lang.translate('تاجر', 'Merchant'),
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              lang.translate('المالك:', 'Owner:') + ' ${merchant.ownerName}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatsRow(BuildContext context, MerchantProfileData merchant, LanguageProvider lang) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            lang.translate('المبيعات', 'Sales'),
            '${merchant.totalSales} ${lang.translate('ج', 'SDG')}',
            Icons.attach_money,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            lang.translate('المنتجات', 'Products'),
            '${merchant.totalProducts}',
            Icons.inventory,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            lang.translate('الطلبات', 'Orders'),
            '${merchant.totalOrders}',
            Icons.shopping_cart,
            Colors.orange,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
  
  Widget _buildBusinessInfo(BuildContext context, MerchantProfileData merchant, LanguageProvider lang) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business, color: Color(0xFF6B9AC4)),
                const SizedBox(width: 8),
                Text(
                  lang.translate('معلومات العمل', 'Business Information'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.email, lang.translate('البريد', 'Email'), merchant.email),
            _buildInfoRow(Icons.phone, lang.translate('الهاتف', 'Phone'), merchant.phone),
            _buildInfoRow(Icons.location_on, lang.translate('العنوان', 'Address'), merchant.address),
            _buildInfoRow(Icons.location_city, lang.translate('المدينة', 'City'), merchant.city),
            _buildInfoRow(Icons.home, lang.translate('الحي', 'District'), merchant.district),
            _buildInfoRow(Icons.description, lang.translate('السجل التجاري', 'Business License'), merchant.businessLicense),
            _buildInfoRow(Icons.calendar_today, lang.translate('تاريخ الانضمام', 'Join Date'), merchant.joinDate),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategories(BuildContext context, MerchantProfileData merchant, LanguageProvider lang) {
    if (merchant.categories.isEmpty) return const SizedBox.shrink();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.category, color: Color(0xFF6B9AC4)),
                const SizedBox(width: 8),
                Text(
                  lang.translate('الفئات', 'Categories'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: merchant.categories.map((category) => Chip(
                label: Text(category),
                backgroundColor: const Color(0xFF6B9AC4).withValues(alpha: 0.1),
                labelStyle: const TextStyle(color: Color(0xFF6B9AC4)),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRatingCard(BuildContext context, MerchantProfileData merchant, LanguageProvider lang) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 40),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${merchant.rating.toStringAsFixed(1)} / 5.0',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  lang.translate('التقييم', 'Rating'),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMerchantActions(BuildContext context, MerchantProfileData merchant, LanguageProvider lang) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // عرض المنتجات
          },
          icon: const Icon(Icons.inventory),
          label: Text(lang.translate('عرض المنتجات', 'View Products')),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B9AC4),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            // الاتصال بالتاجر
          },
          icon: const Icon(Icons.phone),
          label: Text(lang.translate('الاتصال', 'Call')),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ========== صفحة ملف المشتري ==========
class BuyerProfileScreen extends StatelessWidget {
  final String buyerId;
  
  const BuyerProfileScreen({super.key, required this.buyerId});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('الملف الشخصي', 'Buyer Profile')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // تعديل الملف الشخصي
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('buyers')
            .doc(buyerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(lang.translate('لم يتم العثور على البيانات', 'Profile not found')),
                ],
              ),
            );
          }
          
          final buyer = BuyerProfileData.fromFirestore(snapshot.data!);
          
          return RefreshIndicator(
            onRefresh: () async {},
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // رأس الملف الشخصي
                _buildBuyerHeader(context, buyer, lang),
                const SizedBox(height: 24),
                
                // الإحصائيات
                _buildBuyerStats(context, buyer, lang),
                const SizedBox(height: 24),
                
                // مستوى العضوية
                _buildMembershipCard(context, buyer, lang),
                const SizedBox(height: 16),
                
                // المعلومات الشخصية
                _buildPersonalInfo(context, buyer, lang),
                const SizedBox(height: 16),
                
                // الفئات المفضلة
                if (buyer.favoriteCategories.isNotEmpty)
                  _buildFavoriteCategories(context, buyer, lang),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildBuyerHeader(BuildContext context, BuyerProfileData buyer, LanguageProvider lang) {
    return Center(
      child: Column(
        children: [
          ProfileImageWidget(
            imageUrl: buyer.profileImage,
            radius: 60,
          ),
          const SizedBox(height: 16),
          Text(
            buyer.fullName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shopping_bag, size: 16, color: Colors.blue),
                const SizedBox(width: 6),
                Text(
                  lang.translate('مشتري', 'Buyer'),
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBuyerStats(BuildContext context, BuyerProfileData buyer, LanguageProvider lang) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            lang.translate('الطلبات', 'Orders'),
            '${buyer.totalOrders}',
            Icons.shopping_cart,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            lang.translate('الإنفاق', 'Spent'),
            '${buyer.totalSpent.toStringAsFixed(0)} ${lang.translate('ج', 'SDG')}',
            Icons.attach_money,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            lang.translate('النقاط', 'Points'),
            '${buyer.loyaltyPoints}',
            Icons.stars,
            Colors.orange,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
  
  Widget _buildMembershipCard(BuildContext context, BuyerProfileData buyer, LanguageProvider lang) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: buyer.getMembershipColor().withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(buyer.getMembershipIcon(), size: 48, color: buyer.getMembershipColor()),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.translate('مستوى العضوية', 'Membership Level'),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    buyer.membershipLevel,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: buyer.getMembershipColor(),
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
  
  Widget _buildPersonalInfo(BuildContext context, BuyerProfileData buyer, LanguageProvider lang) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Color(0xFF6B9AC4)),
                const SizedBox(width: 8),
                Text(
                  lang.translate('المعلومات الشخصية', 'Personal Information'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.email, lang.translate('البريد', 'Email'), buyer.email),
            _buildInfoRow(Icons.phone, lang.translate('الهاتف', 'Phone'), buyer.phone),
            _buildInfoRow(Icons.location_city, lang.translate('المدينة', 'City'), buyer.city),
            _buildInfoRow(Icons.home, lang.translate('الحي', 'District'), buyer.district),
            _buildInfoRow(Icons.calendar_today, lang.translate('تاريخ الانضمام', 'Join Date'), buyer.joinDate),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFavoriteCategories(BuildContext context, BuyerProfileData buyer, LanguageProvider lang) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite, color: Color(0xFF6B9AC4)),
                const SizedBox(width: 8),
                Text(
                  lang.translate('الفئات المفضلة', 'Favorite Categories'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: buyer.favoriteCategories.map((category) => Chip(
                label: Text(category),
                avatar: const Icon(Icons.favorite, size: 16),
                backgroundColor: Colors.pink.withValues(alpha: 0.1),
                labelStyle: const TextStyle(color: Colors.pink),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ========== صفحة ملف مكتب التوصيل ==========
class DeliveryOfficeProfileScreen extends StatelessWidget {
  final String officeId;
  
  const DeliveryOfficeProfileScreen({super.key, required this.officeId});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('ملف مكتب التوصيل', 'Delivery Office Profile')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // تعديل الملف
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('delivery_offices')
            .doc(officeId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_shipping, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(lang.translate('لم يتم العثور على البيانات', 'Profile not found')),
                ],
              ),
            );
          }
          
          final office = DeliveryOfficeProfileData.fromFirestore(snapshot.data!);
          
          return RefreshIndicator(
            onRefresh: () async {},
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // رأس مكتب التوصيل
                _buildOfficeHeader(context, office, lang),
                const SizedBox(height: 24),
                
                // الإحصائيات
                _buildOfficeStats(context, office, lang),
                const SizedBox(height: 24),
                
                // معلومات المكتب
                _buildOfficeInfo(context, office, lang),
                const SizedBox(height: 16),
                
                // مناطق التغطية
                _buildCoverageAreas(context, office, lang),
                const SizedBox(height: 16),
                
                // أسعار التوصيل
                _buildDeliveryPrices(context, office, lang),
                const SizedBox(height: 16),
                
                // التقييم
                _buildOfficeRating(context, office, lang),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildOfficeHeader(BuildContext context, DeliveryOfficeProfileData office, LanguageProvider lang) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                ProfileImageWidget(
                  imageUrl: office.profileImage,
                  radius: 50,
                ),
                if (office.isActive)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 16, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              office.officeName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: office.isActive 
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_shipping,
                    size: 16,
                    color: office.isActive ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    office.isActive 
                        ? lang.translate('نشط', 'Active')
                        : lang.translate('غير نشط', 'Inactive'),
                    style: TextStyle(
                      color: office.isActive ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              lang.translate('المدير:', 'Manager:') + ' ${office.managerName}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOfficeStats(BuildContext context, DeliveryOfficeProfileData office, LanguageProvider lang) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            lang.translate('عمليات التوصيل', 'Deliveries'),
            '${office.totalDeliveries}',
            Icons.local_shipping,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            lang.translate('السائقين', 'Drivers'),
            '${office.activeDrivers}',
            Icons.person,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            lang.translate('المناطق', 'Areas'),
            '${office.coverageAreas.length}',
            Icons.location_on,
            Colors.orange,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }
  
  Widget _buildOfficeInfo(BuildContext context, DeliveryOfficeProfileData office, LanguageProvider lang) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, color: Color(0xFF6B9AC4)),
                const SizedBox(width: 8),
                Text(
                  lang.translate('معلومات المكتب', 'Office Information'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.email, lang.translate('البريد', 'Email'), office.email),
            _buildInfoRow(Icons.phone, lang.translate('الهاتف', 'Phone'), office.phone),
            _buildInfoRow(Icons.location_on, lang.translate('العنوان', 'Address'), office.address),
            _buildInfoRow(Icons.location_city, lang.translate('المدينة', 'City'), office.city),
            _buildInfoRow(Icons.access_time, lang.translate('ساعات العمل', 'Working Hours'), office.workingHours),
            _buildInfoRow(Icons.calendar_today, lang.translate('تاريخ الانضمام', 'Join Date'), office.joinDate),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCoverageAreas(BuildContext context, DeliveryOfficeProfileData office, LanguageProvider lang) {
    if (office.coverageAreas.isEmpty) return const SizedBox.shrink();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.map, color: Color(0xFF6B9AC4)),
                const SizedBox(width: 8),
                Text(
                  lang.translate('مناطق التغطية', 'Coverage Areas'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: office.coverageAreas.map((area) => Chip(
                label: Text(area),
                avatar: const Icon(Icons.location_on, size: 16),
                backgroundColor: const Color(0xFF6B9AC4).withValues(alpha: 0.1),
                labelStyle: const TextStyle(color: Color(0xFF6B9AC4)),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDeliveryPrices(BuildContext context, DeliveryOfficeProfileData office, LanguageProvider lang) {
    if (office.deliveryPrices.isEmpty) return const SizedBox.shrink();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_money, color: Color(0xFF6B9AC4)),
                const SizedBox(width: 8),
                Text(
                  lang.translate('أسعار التوصيل', 'Delivery Prices'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            ...office.deliveryPrices.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: const TextStyle(fontSize: 14)),
                  Text(
                    '${entry.value.toStringAsFixed(0)} ${lang.translate('ج', 'SDG')}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B9AC4),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOfficeRating(BuildContext context, DeliveryOfficeProfileData office, LanguageProvider lang) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 40),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${office.rating.toStringAsFixed(1)} / 5.0',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  lang.translate('التقييم', 'Rating'),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
