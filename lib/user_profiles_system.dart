import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// نظام الصفحات الشخصية المفصلة - v7.0.0
/// يدعم ثلاثة أنواع من المستخدمين: التجار، المشترين، مكاتب التوصيل
/// كل نوع له صفحة شخصية مخصصة مع بيانات ومميزات خاصة

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String userType; // merchant, buyer, delivery

  const UserProfileScreen({
    Key? key,
    required this.userId,
    required this.userType,
  }) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isEditing = false;
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(widget.userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 80, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('لا يمكن العثور على البيانات'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('رجوع'),
                  ),
                ],
              ),
            ),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;

        // عرض الصفحة المناسبة حسب نوع المستخدم
        switch (widget.userType) {
          case 'merchant':
            return _MerchantProfileScreen(
              userId: widget.userId,
              userData: userData,
              firestore: _firestore,
            );
          case 'delivery':
            return _DeliveryProfileScreen(
              userId: widget.userId,
              userData: userData,
              firestore: _firestore,
            );
          default:
            return _BuyerProfileScreen(
              userId: widget.userId,
              userData: userData,
              firestore: _firestore,
            );
        }
      },
    );
  }
}

/// صفحة شخصية التاجر
class _MerchantProfileScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;
  final FirebaseFirestore firestore;

  const _MerchantProfileScreen({
    required this.userId,
    required this.userData,
    required this.firestore,
  });

  @override
  State<_MerchantProfileScreen> createState() => _MerchantProfileScreenState();
}

class _MerchantProfileScreenState extends State<_MerchantProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _shopNameController;
  late TextEditingController _shopDescriptionController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _shopNameController = TextEditingController(text: widget.userData['shop_name'] ?? '');
    _shopDescriptionController = TextEditingController(text: widget.userData['shop_description'] ?? '');
    _phoneController = TextEditingController(text: widget.userData['phone'] ?? '');
    _addressController = TextEditingController(text: widget.userData['address'] ?? '');
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _shopDescriptionController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isApproved = widget.userData['is_approved'] ?? false;
    final name = widget.userData['name'] ?? 'غير معروف';
    final email = widget.userData['email'] ?? '';
    final shopName = widget.userData['shop_name'] ?? 'اسم المتجر';
    final shopDescription = widget.userData['shop_description'] ?? 'وصف المتجر';
    final rating = (widget.userData['rating'] ?? 0.0).toDouble();
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header مع خلفية
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Colors.purple[700]!, Colors.purple[400]!],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.store,
                          size: 50,
                          color: Colors.purple[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isApproved ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          isApproved ? 'تاجر معتمد ✓' : 'قيد المراجعة',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(_isEditing ? Icons.close : Icons.edit),
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                },
              ),
            ],
          ),

          // المحتوى
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // إحصائيات التاجر
                  _buildMerchantStats(),
                  
                  const SizedBox(height: 24),
                  
                  // معلومات المتجر
                  _buildSectionTitle('معلومات المتجر'),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.store_outlined,
                    title: 'اسم المتجر',
                    value: _isEditing ? null : shopName,
                    controller: _isEditing ? _shopNameController : null,
                  ),
                  _buildInfoCard(
                    icon: Icons.description_outlined,
                    title: 'وصف المتجر',
                    value: _isEditing ? null : shopDescription,
                    controller: _isEditing ? _shopDescriptionController : null,
                    maxLines: 3,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // معلومات التواصل
                  _buildSectionTitle('معلومات التواصل'),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.email_outlined,
                    title: 'البريد الإلكتروني',
                    value: email,
                  ),
                  _buildInfoCard(
                    icon: Icons.phone_outlined,
                    title: 'رقم الهاتف',
                    value: _isEditing ? null : (widget.userData['phone'] ?? 'لم يتم التحديد'),
                    controller: _isEditing ? _phoneController : null,
                  ),
                  _buildInfoCard(
                    icon: Icons.location_on_outlined,
                    title: 'العنوان',
                    value: _isEditing ? null : (widget.userData['address'] ?? 'لم يتم التحديد'),
                    controller: _isEditing ? _addressController : null,
                    maxLines: 2,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // منتجات التاجر
                  _buildSectionTitle('منتجاتي'),
                  const SizedBox(height: 12),
                  _buildMerchantProducts(),
                  
                  const SizedBox(height: 24),
                  
                  // التقييمات
                  _buildSectionTitle('التقييمات والمراجعات'),
                  const SizedBox(height: 12),
                  _buildMerchantReviews(),
                  
                  const SizedBox(height: 24),
                  
                  // زر الحفظ في وضع التعديل
                  if (_isEditing)
                    ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'حفظ التعديلات',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildMerchantStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.firestore
          .collection('products')
          .where('merchant_id', isEqualTo: widget.userId)
          .snapshots(),
      builder: (context, productSnapshot) {
        final productCount = productSnapshot.data?.docs.length ?? 0;
        
        return StreamBuilder<QuerySnapshot>(
          stream: widget.firestore
              .collection('orders')
              .where('merchant_id', isEqualTo: widget.userId)
              .snapshots(),
          builder: (context, orderSnapshot) {
            final orderCount = orderSnapshot.data?.docs.length ?? 0;
            final rating = (widget.userData['rating'] ?? 0.0).toDouble();
            final reviewCount = widget.userData['review_count'] ?? 0;
            
            return Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.inventory,
                    title: 'المنتجات',
                    value: '$productCount',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.shopping_bag,
                    title: 'الطلبات',
                    value: '$orderCount',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.star,
                    title: 'التقييم',
                    value: rating.toStringAsFixed(1),
                    subtitle: '($reviewCount تقييم)',
                    color: Colors.amber,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMerchantProducts() {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.firestore
          .collection('products')
          .where('merchant_id', isEqualTo: widget.userId)
          .limit(4)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  'لا توجد منتجات بعد',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final products = snapshot.data!.docs;
        
        return Column(
          children: [
            ...products.map((doc) {
              final product = doc.data() as Map<String, dynamic>;
              return _buildProductCard(product);
            }).toList(),
            if (products.length >= 4)
              TextButton(
                onPressed: () {
                  // الانتقال إلى صفحة المنتجات الكاملة
                },
                child: const Text('عرض جميع المنتجات'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            product['image_url'] ?? 'https://via.placeholder.com/60',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported),
              );
            },
          ),
        ),
        title: Text(
          product['name'] ?? 'بدون اسم',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${product['price'] ?? 0} ج.س'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (product['is_available'] ?? true) ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            (product['is_available'] ?? true) ? 'متاح' : 'غير متاح',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildMerchantReviews() {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.firestore
          .collection('reviews')
          .where('merchant_id', isEqualTo: widget.userId)
          .orderBy('created_at', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.rate_review_outlined, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  'لا توجد تقييمات بعد',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final reviews = snapshot.data!.docs;
        
        return Column(
          children: reviews.map((doc) {
            final review = doc.data() as Map<String, dynamic>;
            return _buildReviewCard(review);
          }).toList(),
        );
      },
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final rating = (review['rating'] ?? 0).toInt();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                ),
                Text(
                  review['buyer_name'] ?? 'مشتري',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review['comment'] ?? '',
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.purple[700],
      ),
      textAlign: TextAlign.right,
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    String? value,
    TextEditingController? controller,
    int maxLines = 1,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.purple[700], size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (controller != null)
                    TextField(
                      controller: controller,
                      maxLines: maxLines,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                  else
                    Text(
                      value ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    try {
      await widget.firestore.collection('users').doc(widget.userId).update({
        'shop_name': _shopNameController.text.trim(),
        'shop_description': _shopDescriptionController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ التعديلات بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('خطأ في حفظ التعديلات: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل حفظ التعديلات'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// صفحة شخصية مكتب التوصيل
class _DeliveryProfileScreen extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> userData;
  final FirebaseFirestore firestore;

  const _DeliveryProfileScreen({
    required this.userId,
    required this.userData,
    required this.firestore,
  });

  @override
  Widget build(BuildContext context) {
    final isApproved = userData['is_approved'] ?? false;
    final name = userData['name'] ?? 'غير معروف';
    final officeName = userData['office_name'] ?? 'مكتب التوصيل';
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Colors.orange[700]!, Colors.orange[400]!],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.delivery_dining,
                          size: 50,
                          color: Colors.orange[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        officeName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isApproved ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          isApproved ? 'مكتب معتمد ✓' : 'قيد المراجعة',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // إحصائيات مكتب التوصيل
                  _buildDeliveryStats(),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('معلومات المكتب', Colors.orange[700]!),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    Icons.business,
                    'اسم المكتب',
                    officeName,
                    Colors.orange[700]!,
                  ),
                  _buildInfoCard(
                    Icons.person,
                    'المسؤول',
                    name,
                    Colors.orange[700]!,
                  ),
                  _buildInfoCard(
                    Icons.email,
                    'البريد الإلكتروني',
                    userData['email'] ?? '',
                    Colors.orange[700]!,
                  ),
                  _buildInfoCard(
                    Icons.phone,
                    'رقم الهاتف',
                    userData['phone'] ?? 'لم يتم التحديد',
                    Colors.orange[700]!,
                  ),
                  _buildInfoCard(
                    Icons.location_on,
                    'العنوان',
                    userData['address'] ?? 'لم يتم التحديد',
                    Colors.orange[700]!,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('الطلبات الحالية', Colors.orange[700]!),
                  const SizedBox(height: 12),
                  _buildDeliveryOrders('current'),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('سجل التوصيل', Colors.orange[700]!),
                  const SizedBox(height: 12),
                  _buildDeliveryOrders('completed'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('orders')
          .where('delivery_office_id', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final allOrders = snapshot.data!.docs;
        final completedOrders = allOrders.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['status'] == 'delivered';
        }).length;
        
        final currentOrders = allOrders.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status'] ?? '';
          return status == 'shipped' || status == 'out_for_delivery';
        }).length;
        
        final rating = (userData['rating'] ?? 0.0).toDouble();
        
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                Icons.local_shipping,
                'الحالية',
                '$currentOrders',
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                Icons.done_all,
                'المكتملة',
                '$completedOrders',
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                Icons.star,
                'التقييم',
                rating.toStringAsFixed(1),
                Colors.amber,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryOrders(String type) {
    Query query = firestore
        .collection('orders')
        .where('delivery_office_id', isEqualTo: userId);
    
    if (type == 'current') {
      query = query.where('status', whereIn: ['shipped', 'out_for_delivery']);
    } else {
      query = query.where('status', isEqualTo: 'delivered');
    }
    
    return StreamBuilder<QuerySnapshot>(
      stream: query.limit(5).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  type == 'current' ? Icons.inbox : Icons.history,
                  size: 60,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  type == 'current' ? 'لا توجد طلبات حالية' : 'لا يوجد سجل',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final orders = snapshot.data!.docs;
        
        return Column(
          children: orders.map((doc) {
            final order = doc.data() as Map<String, dynamic>;
            return _buildOrderCard(order);
          }).toList(),
        );
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] ?? '';
    Color statusColor;
    String statusText;
    
    switch (status) {
      case 'shipped':
        statusColor = Colors.blue;
        statusText = 'قيد الشحن';
        break;
      case 'out_for_delivery':
        statusColor = Colors.orange;
        statusText = 'في الطريق';
        break;
      case 'delivered':
        statusColor = Colors.green;
        statusText = 'تم التوصيل';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'غير معروف';
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.shopping_bag, color: Colors.orange[700]),
        title: Text(
          'طلب #${order['order_number'] ?? 'N/A'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${order['total_price'] ?? 0} ج.س'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            statusText,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      textAlign: TextAlign.right,
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
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

/// صفحة شخصية المشتري
class _BuyerProfileScreen extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> userData;
  final FirebaseFirestore firestore;

  const _BuyerProfileScreen({
    required this.userId,
    required this.userData,
    required this.firestore,
  });

  @override
  Widget build(BuildContext context) {
    final name = userData['name'] ?? 'غير معروف';
    final email = userData['email'] ?? '';
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Colors.blue[700]!, Colors.blue[400]!],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'مشتري',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // إحصائيات المشتري
                  _buildBuyerStats(),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('المعلومات الشخصية', Colors.blue[700]!),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    Icons.person,
                    'الاسم',
                    name,
                    Colors.blue[700]!,
                  ),
                  _buildInfoCard(
                    Icons.email,
                    'البريد الإلكتروني',
                    email,
                    Colors.blue[700]!,
                  ),
                  _buildInfoCard(
                    Icons.phone,
                    'رقم الهاتف',
                    userData['phone'] ?? 'لم يتم التحديد',
                    Colors.blue[700]!,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('طلباتي', Colors.blue[700]!),
                  const SizedBox(height: 12),
                  _buildBuyerOrders(),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('المفضلة', Colors.blue[700]!),
                  const SizedBox(height: 12),
                  _buildFavorites(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('orders')
          .where('buyer_id', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final orders = snapshot.data!.docs;
        final totalOrders = orders.length;
        
        double totalSpent = 0;
        for (var doc in orders) {
          final data = doc.data() as Map<String, dynamic>;
          totalSpent += (data['total_price'] ?? 0).toDouble();
        }
        
        final points = userData['points'] ?? 0;
        
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                Icons.shopping_bag,
                'الطلبات',
                '$totalOrders',
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                Icons.attach_money,
                'الإنفاق',
                '${totalSpent.toStringAsFixed(0)} ج.س',
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                Icons.star,
                'النقاط',
                '$points',
                Colors.amber,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerOrders() {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('orders')
          .where('buyer_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  'لا توجد طلبات بعد',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final orders = snapshot.data!.docs;
        
        return Column(
          children: orders.map((doc) {
            final order = doc.data() as Map<String, dynamic>;
            return _buildOrderCard(order);
          }).toList(),
        );
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] ?? '';
    Color statusColor;
    String statusText;
    
    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'قيد المعالجة';
        break;
      case 'confirmed':
        statusColor = Colors.blue;
        statusText = 'مؤكد';
        break;
      case 'shipped':
        statusColor = Colors.purple;
        statusText = 'قيد الشحن';
        break;
      case 'delivered':
        statusColor = Colors.green;
        statusText = 'تم التوصيل';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'ملغي';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'غير معروف';
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.shopping_bag, color: Colors.blue[700]),
        title: Text(
          'طلب #${order['order_number'] ?? 'N/A'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${order['total_price'] ?? 0} ج.س'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            statusText,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildFavorites() {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('favorites')
          .where('user_id', isEqualTo: userId)
          .limit(4)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.favorite_border, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  'لا توجد منتجات مفضلة',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final favorites = snapshot.data!.docs;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final favorite = favorites[index].data() as Map<String, dynamic>;
            return _buildFavoriteCard(favorite);
          },
        );
      },
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> favorite) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                favorite['product_image'] ?? 'https://via.placeholder.com/150',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  favorite['product_name'] ?? 'بدون اسم',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${favorite['product_price'] ?? 0} ج.س',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      textAlign: TextAlign.right,
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
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
