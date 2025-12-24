import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

/// نظام رفع الإيصالات - v7.0.0
/// يتيح للمشترين رفع إيصالات الدفع وربطها بالطلبات
/// مع التحقق من الإيصالات وتأكيدها من قبل التجار

class ReceiptUploadSystem extends StatefulWidget {
  final String orderId;
  final String buyerId;
  final String merchantId;
  final double orderAmount;

  const ReceiptUploadSystem({
    Key? key,
    required this.orderId,
    required this.buyerId,
    required this.merchantId,
    required this.orderAmount,
  }) : super(key: key);

  @override
  State<ReceiptUploadSystem> createState() => _ReceiptUploadSystemState();
}

class _ReceiptUploadSystemState extends State<ReceiptUploadSystem> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  bool _isUploading = false;
  String? _uploadedReceiptUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('رفع إيصال الدفع'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // معلومات الطلب
              _buildOrderInfoCard(),
              
              const SizedBox(height: 24),
              
              // تعليمات رفع الإيصال
              _buildInstructionsCard(),
              
              const SizedBox(height: 24),
              
              // منطقة رفع الإيصال
              _buildUploadArea(),
              
              const SizedBox(height: 24),
              
              // زر تأكيد الرفع
              if (_uploadedReceiptUrl != null)
                _buildConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.blue[700]!, Colors.blue[400]!],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.orderId,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Text(
                  'معلومات الطلب',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.orderAmount.toStringAsFixed(2)} ج.س',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'المبلغ الإجمالي',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'تعليمات رفع الإيصال',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.info_outline, color: Colors.blue[700]),
              ],
            ),
            const SizedBox(height: 16),
            _buildInstructionItem('تأكد من وضوح الصورة وقراءة جميع التفاصيل'),
            _buildInstructionItem('يجب أن يظهر المبلغ المدفوع ورقم المعاملة'),
            _buildInstructionItem('تأكد من مطابقة المبلغ مع قيمة الطلب'),
            _buildInstructionItem('الصورة يجب أن تكون بتنسيق JPG أو PNG'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'سيتم مراجعة الإيصال من قبل التاجر خلال 24 ساعة',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber[900],
                      ),
                      textAlign: TextAlign.right,
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

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.check_circle_outline, color: Colors.green[600], size: 20),
        ],
      ),
    );
  }

  Widget _buildUploadArea() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: _isUploading ? null : _pickAndUploadReceipt,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              if (_uploadedReceiptUrl == null) ...[
                // منطقة رفع الملف
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cloud_upload,
                    size: 60,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _isUploading ? 'جاري رفع الإيصال...' : 'اضغط لرفع صورة الإيصال',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'JPG, PNG (حتى 5MB)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (_isUploading)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: CircularProgressIndicator(color: Colors.blue[700]),
                  ),
              ] else ...[
                // معاينة الإيصال المرفوع
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _uploadedReceiptUrl!,
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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _uploadedReceiptUrl = null;
                        });
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('حذف'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton.icon(
                      onPressed: _pickAndUploadReceipt,
                      icon: const Icon(Icons.edit),
                      label: const Text('تغيير'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue[700],
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

  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: _submitReceipt,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.check_circle),
          SizedBox(width: 12),
          Text(
            'تأكيد رفع الإيصال',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadReceipt() async {
    setState(() {
      _isUploading = true;
    });

    try {
      // في الإنتاج، استخدم image_picker لاختيار صورة
      // هنا سنستخدم URL مؤقت للتوضيح
      
      // محاكاة رفع الصورة
      await Future.delayed(const Duration(seconds: 2));
      
      // URL مؤقت للتوضيح
      final tempUrl = 'https://picsum.photos/400/600?random=${DateTime.now().millisecondsSinceEpoch}';
      
      setState(() {
        _uploadedReceiptUrl = tempUrl;
        _isUploading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم رفع الإيصال بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('خطأ في رفع الإيصال: $e');
      }
      setState(() {
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل رفع الإيصال'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitReceipt() async {
    if (_uploadedReceiptUrl == null) return;

    try {
      // حفظ معلومات الإيصال
      await _firestore.collection('receipts').add({
        'order_id': widget.orderId,
        'buyer_id': widget.buyerId,
        'merchant_id': widget.merchantId,
        'receipt_url': _uploadedReceiptUrl,
        'amount': widget.orderAmount,
        'status': 'pending', // pending, verified, rejected
        'uploaded_at': FieldValue.serverTimestamp(),
      });

      // تحديث حالة الطلب
      await _firestore.collection('orders').doc(widget.orderId).update({
        'receipt_uploaded': true,
        'receipt_url': _uploadedReceiptUrl,
        'receipt_status': 'pending',
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال الإيصال بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('خطأ في حفظ الإيصال: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل إرسال الإيصال'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// عرض الإيصالات للمشتري
class MyReceiptsScreen extends StatelessWidget {
  final String buyerId;

  const MyReceiptsScreen({
    Key? key,
    required this.buyerId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إيصالاتي'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('receipts')
            .where('buyer_id', isEqualTo: buyerId)
            .orderBy('uploaded_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }

          final receipts = snapshot.data?.docs ?? [];

          if (receipts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد إيصالات',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: receipts.length,
            itemBuilder: (context, index) {
              final receiptDoc = receipts[index];
              final receiptData = receiptDoc.data() as Map<String, dynamic>;
              return _buildReceiptCard(context, receiptData);
            },
          );
        },
      ),
    );
  }

  Widget _buildReceiptCard(BuildContext context, Map<String, dynamic> receiptData) {
    final status = receiptData['status'] ?? 'pending';
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'verified':
        statusColor = Colors.green;
        statusText = 'تم التحقق';
        statusIcon = Icons.verified;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'مرفوض';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'قيد المراجعة';
        statusIcon = Icons.pending;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReceiptDetailScreen(receiptData: receiptData),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'طلب #${receiptData['order_id']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${receiptData['amount']} ج.س',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  const Text(
                    'المبلغ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _formatTimestamp(receiptData['uploaded_at'] as Timestamp?),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// تفاصيل الإيصال
class ReceiptDetailScreen extends StatelessWidget {
  final Map<String, dynamic> receiptData;

  const ReceiptDetailScreen({
    Key? key,
    required this.receiptData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = receiptData['status'] ?? 'pending';
    Color statusColor;
    String statusText;

    switch (status) {
      case 'verified':
        statusColor = Colors.green;
        statusText = 'تم التحقق من الإيصال ✓';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'تم رفض الإيصال';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'قيد المراجعة من قبل التاجر';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الإيصال'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // حالة الإيصال
            Container(
              padding: const EdgeInsets.all(20),
              color: statusColor.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    status == 'verified' ? Icons.verified : 
                    status == 'rejected' ? Icons.cancel : Icons.pending,
                    color: statusColor,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // صورة الإيصال
            Padding(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  receiptData['receipt_url'] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 400,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, size: 80),
                    );
                  },
                ),
              ),
            ),
            
            // معلومات الإيصال
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoRow('رقم الطلب', receiptData['order_id'] ?? ''),
                  _buildInfoRow('المبلغ', '${receiptData['amount']} ج.س'),
                  _buildInfoRow(
                    'تاريخ الرفع',
                    _formatTimestamp(receiptData['uploaded_at'] as Timestamp?),
                  ),
                  if (receiptData['rejection_reason'] != null)
                    _buildInfoRow(
                      'سبب الرفض',
                      receiptData['rejection_reason'],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
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

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
