import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// نظام تأكيد الطلبات للتاجر - v7.0.0
/// يتيح للتجار مراجعة الطلبات والإيصالات وتأكيدها
/// بعد التأكيد، يتم إرسال الإيصال للمشتري ومكتب التوصيل تلقائياً

class MerchantOrderConfirmationSystem extends StatefulWidget {
  final String merchantId;

  const MerchantOrderConfirmationSystem({
    Key? key,
    required this.merchantId,
  }) : super(key: key);

  @override
  State<MerchantOrderConfirmationSystem> createState() => 
      _MerchantOrderConfirmationSystemState();
}

class _MerchantOrderConfirmationSystemState 
    extends State<MerchantOrderConfirmationSystem> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedFilter = 'pending'; // pending, all, confirmed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات تحتاج تأكيد'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildFilterTabs(),
        ),
      ),
      body: _buildOrdersList(),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: _buildFilterTab('pending', 'قيد الانتظار', Colors.orange)),
          const SizedBox(width: 8),
          Expanded(child: _buildFilterTab('confirmed', 'مؤكدة', Colors.green)),
          const SizedBox(width: 8),
          Expanded(child: _buildFilterTab('all', 'الكل', Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String filter, String label, Color color) {
    final isSelected = _selectedFilter == filter;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    Query query = _firestore
        .collection('orders')
        .where('merchant_id', isEqualTo: widget.merchantId)
        .where('payment_status', isEqualTo: 'completed');

    if (_selectedFilter == 'pending') {
      query = query.where('merchant_confirmed', isEqualTo: false);
    } else if (_selectedFilter == 'confirmed') {
      query = query.where('merchant_confirmed', isEqualTo: true);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.orderBy('created_at', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('خطأ: ${snapshot.error}'));
        }

        final orders = snapshot.data?.docs ?? [];

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedFilter == 'pending'
                      ? 'لا توجد طلبات تحتاج تأكيد'
                      : _selectedFilter == 'confirmed'
                          ? 'لا توجد طلبات مؤكدة'
                          : 'لا توجد طلبات',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final orderDoc = orders[index];
            final orderData = orderDoc.data() as Map<String, dynamic>;
            return _buildOrderCard(orderDoc.id, orderData);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(String orderId, Map<String, dynamic> orderData) {
    final isConfirmed = orderData['merchant_confirmed'] ?? false;
    final hasReceipt = orderData['receipt_uploaded'] ?? false;
    final totalPrice = (orderData['total_price'] ?? 0).toDouble();
    final buyerName = orderData['buyer_name'] ?? 'غير معروف';
    final orderNumber = orderData['order_number'] ?? orderId;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showOrderDetails(orderId, orderData),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // العنوان
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isConfirmed)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.verified, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'مؤكد',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.pending, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'يحتاج تأكيد',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    'طلب #$orderNumber',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // معلومات العميل
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    buyerName,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // المبلغ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${totalPrice.toStringAsFixed(2)} ج.س',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  const Text(
                    'المبلغ الإجمالي',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // حالة الإيصال
              if (hasReceipt)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.receipt_long, color: Colors.green, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'تم رفع إيصال الدفع',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.warning_amber, color: Colors.red, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'لم يتم رفع إيصال بعد',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              
              if (!isConfirmed && hasReceipt)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _rejectOrder(orderId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('رفض'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () => _confirmOrder(orderId, orderData),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.check_circle, size: 20),
                              SizedBox(width: 8),
                              Text('تأكيد الطلب'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(String orderId, Map<String, dynamic> orderData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => OrderDetailsSheet(
        orderId: orderId,
        orderData: orderData,
        onConfirm: () {
          Navigator.pop(context);
          _confirmOrder(orderId, orderData);
        },
        onReject: () {
          Navigator.pop(context);
          _rejectOrder(orderId);
        },
      ),
    );
  }

  Future<void> _confirmOrder(String orderId, Map<String, dynamic> orderData) async {
    try {
      // تحديث حالة الطلب
      await _firestore.collection('orders').doc(orderId).update({
        'merchant_confirmed': true,
        'status': 'confirmed',
        'confirmed_at': FieldValue.serverTimestamp(),
      });

      // إنشاء إيصال رسمي
      await _generateOfficialReceipt(orderId, orderData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تأكيد الطلب بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('خطأ في تأكيد الطلب: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل تأكيد الطلب'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateOfficialReceipt(
    String orderId,
    Map<String, dynamic> orderData,
  ) async {
    try {
      // إنشاء إيصال رسمي في Firebase
      final receiptRef = await _firestore.collection('official_receipts').add({
        'order_id': orderId,
        'buyer_id': orderData['buyer_id'],
        'merchant_id': widget.merchantId,
        'delivery_office_id': orderData['delivery_office_id'],
        'total_amount': orderData['total_price'],
        'items': orderData['items'] ?? [],
        'merchant_name': orderData['merchant_name'],
        'buyer_name': orderData['buyer_name'],
        'receipt_number': 'REC${DateTime.now().millisecondsSinceEpoch}',
        'status': 'confirmed',
        'created_at': FieldValue.serverTimestamp(),
      });

      // إرسال إشعار للمشتري
      await _firestore.collection('notifications').add({
        'user_id': orderData['buyer_id'],
        'title': 'تم تأكيد طلبك',
        'body': 'تم تأكيد طلبك #${orderData['order_number']} من قبل التاجر',
        'type': 'order_confirmed',
        'order_id': orderId,
        'receipt_id': receiptRef.id,
        'is_read': false,
        'created_at': FieldValue.serverTimestamp(),
      });

      // إرسال إشعار لمكتب التوصيل (إذا كان محدداً)
      if (orderData['delivery_office_id'] != null) {
        await _firestore.collection('notifications').add({
          'user_id': orderData['delivery_office_id'],
          'title': 'طلب جديد للتوصيل',
          'body': 'طلب #${orderData['order_number']} جاهز للتوصيل',
          'type': 'new_delivery',
          'order_id': orderId,
          'receipt_id': receiptRef.id,
          'is_read': false,
          'created_at': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('خطأ في إنشاء الإيصال الرسمي: $e');
      }
    }
  }

  Future<void> _rejectOrder(String orderId) async {
    // عرض نافذة لإدخال سبب الرفض
    showDialog(
      context: context,
      builder: (context) => RejectOrderDialog(
        onReject: (reason) async {
          try {
            await _firestore.collection('orders').doc(orderId).update({
              'merchant_confirmed': false,
              'status': 'rejected',
              'rejection_reason': reason,
              'rejected_at': FieldValue.serverTimestamp(),
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم رفض الطلب'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('خطأ في رفض الطلب: $e');
            }
          }
        },
      ),
    );
  }
}

/// نافذة تفاصيل الطلب
class OrderDetailsSheet extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;
  final VoidCallback onConfirm;
  final VoidCallback onReject;

  const OrderDetailsSheet({
    Key? key,
    required this.orderId,
    required this.orderData,
    required this.onConfirm,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasReceipt = orderData['receipt_uploaded'] ?? false;
    final receiptUrl = orderData['receipt_url'];
    final isConfirmed = orderData['merchant_confirmed'] ?? false;

    return Container(
      padding: const EdgeInsets.all(20),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // العنوان
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                const Text(
                  'تفاصيل الطلب',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // معلومات الطلب
            _buildInfoRow('رقم الطلب', orderData['order_number'] ?? orderId),
            _buildInfoRow('اسم العميل', orderData['buyer_name'] ?? 'غير معروف'),
            _buildInfoRow(
              'المبلغ',
              '${orderData['total_price']} ج.س',
            ),
            
            const SizedBox(height: 20),
            
            // إيصال الدفع
            if (hasReceipt && receiptUrl != null) ...[
              const Text(
                'إيصال الدفع',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  receiptUrl,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 300,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // أزرار الإجراءات
            if (!isConfirmed && hasReceipt)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onReject,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Text('رفض الطلب'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Text('تأكيد الطلب'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

/// نافذة رفض الطلب
class RejectOrderDialog extends StatefulWidget {
  final Function(String reason) onReject;

  const RejectOrderDialog({
    Key? key,
    required this.onReject,
  }) : super(key: key);

  @override
  State<RejectOrderDialog> createState() => _RejectOrderDialogState();
}

class _RejectOrderDialogState extends State<RejectOrderDialog> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'سبب رفض الطلب',
        textAlign: TextAlign.right,
      ),
      content: TextField(
        controller: _reasonController,
        maxLines: 4,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: 'اكتب سبب الرفض...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            final reason = _reasonController.text.trim();
            if (reason.isNotEmpty) {
              widget.onReject(reason);
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('رفض الطلب'),
        ),
      ],
    );
  }
}
