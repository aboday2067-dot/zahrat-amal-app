import 'package:cloud_firestore/cloud_firestore.dart';

/// 🧾 نموذج الإيصال
class Receipt {
  final String id;
  final String orderId;
  final String receiptNumber;
  final DateTime date;
  final String merchantId;
  final String merchantName;
  final String merchantPhone;
  final String merchantAddress;
  final String buyerId;
  final String buyerName;
  final String buyerPhone;
  final String buyerAddress;
  final List<ReceiptItem> items;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double discount;
  final double total;
  final String paymentMethod;
  final String status;
  final String? notes;
  final DateTime createdAt;

  Receipt({
    required this.id,
    required this.orderId,
    required this.receiptNumber,
    required this.date,
    required this.merchantId,
    required this.merchantName,
    required this.merchantPhone,
    required this.merchantAddress,
    required this.buyerId,
    required this.buyerName,
    required this.buyerPhone,
    required this.buyerAddress,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  /// إنشاء من Firestore
  factory Receipt.fromFirestore(Map<String, dynamic> data, String id) {
    return Receipt(
      id: id,
      orderId: data['order_id'] ?? '',
      receiptNumber: data['receipt_number'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      merchantId: data['merchant_id'] ?? '',
      merchantName: data['merchant_name'] ?? '',
      merchantPhone: data['merchant_phone'] ?? '',
      merchantAddress: data['merchant_address'] ?? '',
      buyerId: data['buyer_id'] ?? '',
      buyerName: data['buyer_name'] ?? '',
      buyerPhone: data['buyer_phone'] ?? '',
      buyerAddress: data['buyer_address'] ?? '',
      items: (data['items'] as List<dynamic>?)
              ?.map((item) => ReceiptItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (data['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      tax: (data['tax'] as num?)?.toDouble() ?? 0.0,
      discount: (data['discount'] as num?)?.toDouble() ?? 0.0,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: data['payment_method'] ?? 'cash',
      status: data['status'] ?? 'paid',
      notes: data['notes'],
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// تحويل إلى Map
  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'receipt_number': receiptNumber,
      'date': Timestamp.fromDate(date),
      'merchant_id': merchantId,
      'merchant_name': merchantName,
      'merchant_phone': merchantPhone,
      'merchant_address': merchantAddress,
      'buyer_id': buyerId,
      'buyer_name': buyerName,
      'buyer_phone': buyerPhone,
      'buyer_address': buyerAddress,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'tax': tax,
      'discount': discount,
      'total': total,
      'payment_method': paymentMethod,
      'status': status,
      'notes': notes,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  /// توليد رقم إيصال تلقائي
  static String generateReceiptNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString().substring(5);
    return 'REC-${now.year}${now.month.toString().padLeft(2, '0')}-$timestamp';
  }
}

/// 🛍️ عنصر الإيصال
class ReceiptItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final double total;

  ReceiptItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory ReceiptItem.fromMap(Map<String, dynamic> data) {
    return ReceiptItem(
      productId: data['product_id'] ?? '',
      productName: data['product_name'] ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }
}
