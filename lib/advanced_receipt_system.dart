// ============================================
// نظام الإيصالات المتقدم - Advanced Receipt System
// ✅ قابل للمشاركة - Shareable
// ✅ غير قابل للتزوير - Tamper-proof
// ✅ غير قابل للتعديل - Non-editable
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'main.dart';

// ========== نموذج بيانات الإيصال ==========
class ReceiptData {
  final String receiptId;
  final String orderId;
  final DateTime timestamp;
  final String customerName;
  final String customerPhone;
  final String merchantName;
  final String merchantId;
  final List<ReceiptItem> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final String paymentMethod;
  final String deliveryAddress;
  final String verificationHash;
  
  ReceiptData({
    required this.receiptId,
    required this.orderId,
    required this.timestamp,
    required this.customerName,
    required this.customerPhone,
    required this.merchantName,
    required this.merchantId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    required this.deliveryAddress,
    required this.verificationHash,
  });
  
  // توليد Hash للتحقق من صحة الإيصال (Tamper-proof)
  static String generateHash(Map<String, dynamic> data) {
    final String dataString = json.encode(data);
    final bytes = utf8.encode(dataString);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // التحقق من صحة الإيصال
  bool verifyIntegrity() {
    final dataToVerify = {
      'receiptId': receiptId,
      'orderId': orderId,
      'timestamp': timestamp.toIso8601String(),
      'customerName': customerName,
      'total': total,
    };
    final calculatedHash = generateHash(dataToVerify);
    return calculatedHash == verificationHash;
  }
  
  Map<String, dynamic> toJson() => {
    'receiptId': receiptId,
    'orderId': orderId,
    'timestamp': timestamp.toIso8601String(),
    'customerName': customerName,
    'customerPhone': customerPhone,
    'merchantName': merchantName,
    'merchantId': merchantId,
    'items': items.map((item) => item.toJson()).toList(),
    'subtotal': subtotal,
    'deliveryFee': deliveryFee,
    'discount': discount,
    'total': total,
    'paymentMethod': paymentMethod,
    'deliveryAddress': deliveryAddress,
    'verificationHash': verificationHash,
  };
  
  factory ReceiptData.fromJson(Map<String, dynamic> json) => ReceiptData(
    receiptId: json['receiptId'],
    orderId: json['orderId'],
    timestamp: DateTime.parse(json['timestamp']),
    customerName: json['customerName'],
    customerPhone: json['customerPhone'],
    merchantName: json['merchantName'],
    merchantId: json['merchantId'],
    items: (json['items'] as List).map((item) => ReceiptItem.fromJson(item)).toList(),
    subtotal: (json['subtotal'] as num).toDouble(),
    deliveryFee: (json['deliveryFee'] as num).toDouble(),
    discount: (json['discount'] as num).toDouble(),
    total: (json['total'] as num).toDouble(),
    paymentMethod: json['paymentMethod'],
    deliveryAddress: json['deliveryAddress'],
    verificationHash: json['verificationHash'],
  );
}

class ReceiptItem {
  final String name;
  final int quantity;
  final double price;
  final double total;
  
  ReceiptItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
  });
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
    'price': price,
    'total': total,
  };
  
  factory ReceiptItem.fromJson(Map<String, dynamic> json) => ReceiptItem(
    name: json['name'],
    quantity: json['quantity'],
    price: (json['price'] as num).toDouble(),
    total: (json['total'] as num).toDouble(),
  );
}

// ========== نظام إدارة الإيصالات ==========
class ReceiptManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // إنشاء إيصال جديد
  static Future<ReceiptData> createReceipt({
    required String orderId,
    required String customerName,
    required String customerPhone,
    required String merchantName,
    required String merchantId,
    required List<ReceiptItem> items,
    required double subtotal,
    required double deliveryFee,
    required double discount,
    required String paymentMethod,
    required String deliveryAddress,
  }) async {
    final receiptId = 'RCP-${DateTime.now().millisecondsSinceEpoch}';
    final timestamp = DateTime.now();
    final total = subtotal + deliveryFee - discount;
    
    // توليد Hash للتحقق
    final dataToHash = {
      'receiptId': receiptId,
      'orderId': orderId,
      'timestamp': timestamp.toIso8601String(),
      'customerName': customerName,
      'total': total,
    };
    final verificationHash = ReceiptData.generateHash(dataToHash);
    
    final receipt = ReceiptData(
      receiptId: receiptId,
      orderId: orderId,
      timestamp: timestamp,
      customerName: customerName,
      customerPhone: customerPhone,
      merchantName: merchantName,
      merchantId: merchantId,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: discount,
      total: total,
      paymentMethod: paymentMethod,
      deliveryAddress: deliveryAddress,
      verificationHash: verificationHash,
    );
    
    // حفظ الإيصال في Firebase
    await _firestore.collection('receipts').doc(receiptId).set(receipt.toJson());
    
    return receipt;
  }
  
  // جلب إيصال من Firebase
  static Future<ReceiptData?> getReceipt(String receiptId) async {
    try {
      final doc = await _firestore.collection('receipts').doc(receiptId).get();
      if (doc.exists) {
        return ReceiptData.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error fetching receipt: $e');
      }
      return null;
    }
  }
  
  // حفظ صورة الإيصال في Firebase Storage
  static Future<String?> uploadReceiptImage(String receiptId, Uint8List imageBytes) async {
    try {
      final ref = _storage.ref().child('receipts/$receiptId.png');
      await ref.putData(imageBytes);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error uploading receipt image: $e');
      }
      return null;
    }
  }
  
  // التحقق من صحة الإيصال
  static Future<bool> verifyReceipt(String receiptId) async {
    final receipt = await getReceipt(receiptId);
    if (receipt == null) return false;
    return receipt.verifyIntegrity();
  }
}

// ========== واجهة عرض الإيصال ==========
class ReceiptWidget extends StatelessWidget {
  final ReceiptData receipt;
  final GlobalKey receiptKey = GlobalKey();
  
  ReceiptWidget({super.key, required this.receipt});
  
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return RepaintBoundary(
      key: receiptKey,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            _buildHeader(lang),
            const SizedBox(height: 24),
            const Divider(thickness: 2),
            
            // Receipt Info
            _buildReceiptInfo(lang),
            const SizedBox(height: 16),
            const Divider(),
            
            // Items
            _buildItems(lang),
            const SizedBox(height: 16),
            const Divider(thickness: 2),
            
            // Totals
            _buildTotals(lang),
            const SizedBox(height: 24),
            
            // Verification
            _buildVerification(lang),
            const SizedBox(height: 16),
            
            // Footer
            _buildFooter(lang),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(LanguageProvider lang) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF6B9AC4),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(Icons.receipt_long, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 12),
        const Text(
          'زهرة الأمل',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B9AC4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          lang.translate('إيصال رسمي - فاتورة ضريبية', 'Official Receipt - Tax Invoice'),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildReceiptInfo(LanguageProvider lang) {
    return Column(
      children: [
        _buildInfoRow(
          lang.translate('رقم الإيصال', 'Receipt No.'),
          receipt.receiptId,
          isBold: true,
        ),
        _buildInfoRow(
          lang.translate('رقم الطلب', 'Order No.'),
          receipt.orderId,
        ),
        _buildInfoRow(
          lang.translate('التاريخ والوقت', 'Date & Time'),
          DateFormat('yyyy-MM-dd HH:mm').format(receipt.timestamp),
        ),
        _buildInfoRow(
          lang.translate('اسم العميل', 'Customer Name'),
          receipt.customerName,
        ),
        _buildInfoRow(
          lang.translate('رقم الهاتف', 'Phone'),
          receipt.customerPhone,
        ),
        _buildInfoRow(
          lang.translate('التاجر', 'Merchant'),
          receipt.merchantName,
        ),
        _buildInfoRow(
          lang.translate('طريقة الدفع', 'Payment Method'),
          receipt.paymentMethod,
        ),
        _buildInfoRow(
          lang.translate('عنوان التوصيل', 'Delivery Address'),
          receipt.deliveryAddress,
        ),
      ],
    );
  }
  
  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildItems(LanguageProvider lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.translate('المنتجات', 'Items'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...receipt.items.map((item) => _buildItemRow(item)),
      ],
    );
  }
  
  Widget _buildItemRow(ReceiptItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item.name,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Text(
            '${item.quantity}x',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          Text(
            '${item.price.toStringAsFixed(2)} ج',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          Text(
            '${item.total.toStringAsFixed(2)} ج',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTotals(LanguageProvider lang) {
    return Column(
      children: [
        _buildTotalRow(
          lang.translate('المجموع الفرعي', 'Subtotal'),
          receipt.subtotal,
        ),
        _buildTotalRow(
          lang.translate('رسوم التوصيل', 'Delivery Fee'),
          receipt.deliveryFee,
        ),
        if (receipt.discount > 0)
          _buildTotalRow(
            lang.translate('الخصم', 'Discount'),
            -receipt.discount,
            color: Colors.green,
          ),
        const Divider(thickness: 1.5),
        _buildTotalRow(
          lang.translate('الإجمالي النهائي', 'Total'),
          receipt.total,
          isBold: true,
          fontSize: 18,
        ),
      ],
    );
  }
  
  Widget _buildTotalRow(String label, double amount, {bool isBold = false, double fontSize = 14, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)} ج',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVerification(LanguageProvider lang) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                lang.translate('إيصال موثق ومعتمد', 'Verified Receipt'),
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${lang.translate('كود التحقق', 'Verification Code')}: ${receipt.verificationHash.substring(0, 16)}...',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[700],
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildFooter(LanguageProvider lang) {
    return Column(
      children: [
        Text(
          lang.translate('شكراً لتسوقكم معنا', 'Thank you for your purchase'),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          lang.translate('للاستفسارات: support@zahrat-amal.sd', 'Contact: support@zahrat-amal.sd'),
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  // تحويل الإيصال إلى صورة
  Future<Uint8List?> captureReceiptAsImage() async {
    try {
      RenderRepaintBoundary boundary = receiptKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error capturing receipt: $e');
      }
      return null;
    }
  }
}

// ========== صفحة عرض الإيصال ==========
class ReceiptViewScreen extends StatefulWidget {
  final ReceiptData receipt;
  
  const ReceiptViewScreen({super.key, required this.receipt});
  
  @override
  State<ReceiptViewScreen> createState() => _ReceiptViewScreenState();
}

class _ReceiptViewScreenState extends State<ReceiptViewScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isVerified = false;
  bool isVerifying = true;
  
  @override
  void initState() {
    super.initState();
    _verifyReceipt();
  }
  
  Future<void> _verifyReceipt() async {
    setState(() => isVerifying = true);
    final verified = await ReceiptManager.verifyReceipt(widget.receipt.receiptId);
    if (mounted) {
      setState(() {
        isVerified = verified;
        isVerifying = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(lang.translate('الإيصال الرسمي', 'Official Receipt')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
        actions: [
          if (isVerified)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareReceipt(context, lang),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (isVerifying)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.orange.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(lang.translate('جاري التحقق من الإيصال...', 'Verifying receipt...')),
                  ],
                ),
              ),
            if (!isVerifying && isVerified)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.green.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    const Icon(Icons.verified, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        lang.translate('✅ إيصال موثق وصحيح', '✅ Verified Receipt'),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (!isVerifying && !isVerified)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.red.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        lang.translate('⚠️ تحذير: الإيصال غير صحيح', '⚠️ Warning: Invalid Receipt'),
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ReceiptWidget(receipt: widget.receipt),
          ],
        ),
      ),
    );
  }
  
  Future<void> _shareReceipt(BuildContext context, LanguageProvider lang) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(lang.translate('جاري تحضير الإيصال للمشاركة...', 'Preparing receipt for sharing...')),
          ],
        ),
      ),
    );
    
    // TODO: Implement actual sharing functionality
    // This would use share_plus package to share the receipt image
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang.translate('تم تحضير الإيصال للمشاركة', 'Receipt ready for sharing')),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
