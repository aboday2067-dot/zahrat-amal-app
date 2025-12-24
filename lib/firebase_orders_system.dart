// ============================================
// نظام سجل الطلبات مع Firebase
// Order History System with Firebase Firestore
// ============================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'main.dart';

// ========== نموذج الطلب ==========
class OrderModel {
  final String id;
  final String userId;
  final DateTime orderDate;
  final String status;
  final double totalAmount;
  final int itemsCount;
  final List<OrderItem> items;
  final String? deliveryAddress;
  final String? phoneNumber;
  
  OrderModel({
    required this.id,
    required this.userId,
    required this.orderDate,
    required this.status,
    required this.totalAmount,
    required this.itemsCount,
    required this.items,
    this.deliveryAddress,
    this.phoneNumber,
  });
  
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      userId: data['user_id'] ?? '',
      orderDate: (data['order_date'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      totalAmount: (data['total_amount'] ?? 0).toDouble(),
      itemsCount: data['items_count'] ?? 0,
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromJson(item))
          .toList() ?? [],
      deliveryAddress: data['delivery_address'],
      phoneNumber: data['phone_number'],
    );
  }
  
  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'order_date': Timestamp.fromDate(orderDate),
    'status': status,
    'total_amount': totalAmount,
    'items_count': itemsCount,
    'items': items.map((item) => item.toJson()).toList(),
    'delivery_address': deliveryAddress,
    'phone_number': phoneNumber,
  };
  
  Color getStatusColor() {
    switch (status) {
      case 'delivered':
        return Colors.green;
      case 'in_delivery':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  String getStatusText(LanguageProvider lang) {
    switch (status) {
      case 'delivered':
        return lang.translate('تم التوصيل', 'Delivered');
      case 'in_delivery':
        return lang.translate('قيد التوصيل', 'In Delivery');
      case 'processing':
        return lang.translate('قيد المعالجة', 'Processing');
      case 'cancelled':
        return lang.translate('ملغي', 'Cancelled');
      default:
        return lang.translate('معلق', 'Pending');
    }
  }
  
  IconData getStatusIcon() {
    switch (status) {
      case 'delivered':
        return Icons.check_circle;
      case 'in_delivery':
        return Icons.local_shipping;
      case 'processing':
        return Icons.hourglass_empty;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }
}

// ========== نموذج عنصر الطلب ==========
class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String? imageUrl;
  
  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });
  
  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    productId: json['product_id'] ?? '',
    productName: json['product_name'] ?? '',
    quantity: json['quantity'] ?? 0,
    price: (json['price'] ?? 0).toDouble(),
    imageUrl: json['image_url'],
  );
  
  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'product_name': productName,
    'quantity': quantity,
    'price': price,
    'image_url': imageUrl,
  };
}

// ========== خدمة إدارة الطلبات ==========
class OrdersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // جلب طلبات المستخدم
  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList();
          // ترتيب حسب التاريخ (الأحدث أولاً)
          orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
          return orders;
        });
  }
  
  // إنشاء طلب جديد
  Future<String?> createOrder(OrderModel order) async {
    try {
      final docRef = await _firestore.collection('orders').add(order.toJson());
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating order: $e');
      return null;
    }
  }
  
  // تحديث حالة الطلب
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('❌ Error updating order status: $e');
      return false;
    }
  }
  
  // حذف طلب
  Future<bool> deleteOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).delete();
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting order: $e');
      return false;
    }
  }
}

// ========== صفحة سجل الطلبات مع Firebase ==========
class FirebaseOrdersHistoryScreen extends StatelessWidget {
  const FirebaseOrdersHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final ordersService = OrdersService();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('طلباتي', 'My Orders')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<String>(
        future: _getUserId(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final userId = userSnapshot.data!;
          
          return StreamBuilder<List<OrderModel>>(
            stream: ordersService.getUserOrders(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        lang.translate('حدث خطأ في جلب الطلبات', 'Error loading orders'),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        lang.translate('لا توجد طلبات', 'No orders yet'),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lang.translate('ابدأ التسوق الآن!', 'Start shopping now!'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              final orders = snapshot.data!;
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _buildOrderCard(context, order, lang, ordersService);
                },
              );
            },
          );
        },
      ),
    );
  }
  
  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail') ?? 'guest';
  }
  
  Widget _buildOrderCard(
    BuildContext context,
    OrderModel order,
    LanguageProvider lang,
    OrdersService service,
  ) {
    final dateFormat = DateFormat('yyyy-MM-dd', lang.isArabic ? 'ar' : 'en');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showOrderDetails(context, order, lang),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رأس الطلب
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: order.getStatusColor().withValues(alpha: 0.2),
                    child: Icon(
                      order.getStatusIcon(),
                      color: order.getStatusColor(),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${lang.translate('طلب', 'Order')} #${order.id.substring(0, 8)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          dateFormat.format(order.orderDate),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: order.getStatusColor().withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.getStatusText(lang),
                      style: TextStyle(
                        fontSize: 11,
                        color: order.getStatusColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              
              // تفاصيل الطلب
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.shopping_cart,
                      lang.translate('المنتجات', 'Items'),
                      '${order.itemsCount}',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.attach_money,
                      lang.translate('الإجمالي', 'Total'),
                      '${order.totalAmount.toStringAsFixed(0)} ${lang.translate('ج', 'SDG')}',
                    ),
                  ),
                ],
              ),
              
              if (order.deliveryAddress != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.deliveryAddress!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B9AC4),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  void _showOrderDetails(BuildContext context, OrderModel order, LanguageProvider lang) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm', lang.isArabic ? 'ar' : 'en');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${lang.translate('تفاصيل الطلب', 'Order Details')} #${order.id.substring(0, 8)}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                lang.translate('التاريخ', 'Date'),
                dateFormat.format(order.orderDate),
              ),
              _buildDetailRow(
                lang.translate('الحالة', 'Status'),
                order.getStatusText(lang),
              ),
              _buildDetailRow(
                lang.translate('عدد المنتجات', 'Items'),
                '${order.itemsCount}',
              ),
              _buildDetailRow(
                lang.translate('الإجمالي', 'Total'),
                '${order.totalAmount.toStringAsFixed(0)} ${lang.translate('ج', 'SDG')}',
              ),
              if (order.deliveryAddress != null)
                _buildDetailRow(
                  lang.translate('عنوان التوصيل', 'Delivery Address'),
                  order.deliveryAddress!,
                ),
              if (order.phoneNumber != null)
                _buildDetailRow(
                  lang.translate('رقم الهاتف', 'Phone'),
                  order.phoneNumber!,
                ),
              
              if (order.items.isNotEmpty) ...[
                const Divider(height: 24),
                Text(
                  lang.translate('المنتجات', 'Products'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      if (item.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) =>
                                Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image, color: Colors.grey),
                                ),
                          ),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '${item.quantity} × ${item.price.toStringAsFixed(0)} ${lang.translate('ج', 'SDG')}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${(item.quantity * item.price).toStringAsFixed(0)} ${lang.translate('ج', 'SDG')}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B9AC4),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
        actions: [
          if (order.status == 'processing' || order.status == 'pending')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _cancelOrder(context, order.id, lang);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(lang.translate('إلغاء الطلب', 'Cancel Order')),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.translate('إغلاق', 'Close')),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _cancelOrder(BuildContext context, String orderId, LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.translate('تأكيد الإلغاء', 'Confirm Cancellation')),
        content: Text(lang.translate('هل تريد إلغاء هذا الطلب؟', 'Do you want to cancel this order?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.translate('لا', 'No')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final service = OrdersService();
              final success = await service.updateOrderStatus(orderId, 'cancelled');
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? lang.translate('تم إلغاء الطلب', 'Order cancelled')
                          : lang.translate('فشل إلغاء الطلب', 'Failed to cancel order'),
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(lang.translate('نعم، إلغاء', 'Yes, Cancel')),
          ),
        ],
      ),
    );
  }
}
