class CartItemModel {
  final String productId;
  final String productName;
  final String productNameAr;
  final String productImage;
  final double price;
  int quantity;

  CartItemModel({
    required this.productId,
    required this.productName,
    required this.productNameAr,
    required this.productImage,
    required this.price,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      productNameAr: json['product_name_ar'] as String,
      productImage: json['product_image'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_name_ar': productNameAr,
      'product_image': productImage,
      'price': price,
      'quantity': quantity,
    };
  }
}
