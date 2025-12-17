enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  outForDelivery,
  delivered,
  cancelled,
  refunded
}

class OrderItem {
  final String productId;
  final String productName;
  final String productNameAr;
  final String productImage;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productNameAr,
    required this.productImage,
    required this.quantity,
    required this.price,
  });

  double get totalPrice => quantity * price;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      productNameAr: json['product_name_ar'] as String,
      productImage: json['product_image'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_name_ar': productNameAr,
      'product_image': productImage,
      'quantity': quantity,
      'price': price,
    };
  }
}

class OrderModel {
  final String id;
  final String userId;
  final String userName;
  final List<OrderItem> items;
  final double totalAmount;
  final String currency;
  final OrderStatus status;
  final String deliveryAddress;
  final String? deliveryPhone;
  final String? deliveryOfficeId;
  final String? deliveryOfficeName;
  final String? trackingNumber;
  final String paymentMethod;
  final bool isPaid;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String? notes;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.items,
    required this.totalAmount,
    this.currency = 'SDG',
    required this.status,
    required this.deliveryAddress,
    this.deliveryPhone,
    this.deliveryOfficeId,
    this.deliveryOfficeName,
    this.trackingNumber,
    required this.paymentMethod,
    this.isPaid = false,
    required this.createdAt,
    this.deliveredAt,
    this.notes,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'SDG',
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${json['status']}',
        orElse: () => OrderStatus.pending,
      ),
      deliveryAddress: json['delivery_address'] as String,
      deliveryPhone: json['delivery_phone'] as String?,
      deliveryOfficeId: json['delivery_office_id'] as String?,
      deliveryOfficeName: json['delivery_office_name'] as String?,
      trackingNumber: json['tracking_number'] as String?,
      paymentMethod: json['payment_method'] as String,
      isPaid: json['is_paid'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'items': items.map((item) => item.toJson()).toList(),
      'total_amount': totalAmount,
      'currency': currency,
      'status': status.toString().split('.').last,
      'delivery_address': deliveryAddress,
      'delivery_phone': deliveryPhone,
      'delivery_office_id': deliveryOfficeId,
      'delivery_office_name': deliveryOfficeName,
      'tracking_number': trackingNumber,
      'payment_method': paymentMethod,
      'is_paid': isPaid,
      'created_at': createdAt.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'notes': notes,
    };
  }
}
