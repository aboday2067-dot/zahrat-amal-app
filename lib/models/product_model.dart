class ProductModel {
  final String id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final double price;
  final String currency;
  final String category;
  final String categoryAr;
  final List<String> images;
  final String merchantId;
  final String merchantName;
  final int stockQuantity;
  final double rating;
  final int reviewCount;
  final bool isActive;
  final bool isFeatured;
  final DateTime createdAt;
  final List<String> tags;

  ProductModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.price,
    this.currency = 'SDG',
    required this.category,
    required this.categoryAr,
    required this.images,
    required this.merchantId,
    required this.merchantName,
    required this.stockQuantity,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isActive = true,
    this.isFeatured = false,
    required this.createdAt,
    this.tags = const [],
  });

  bool get inStock => stockQuantity > 0;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAr: json['name_ar'] as String,
      description: json['description'] as String,
      descriptionAr: json['description_ar'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'SDG',
      category: json['category'] as String,
      categoryAr: json['category_ar'] as String,
      images: List<String>.from(json['images'] as List),
      merchantId: json['merchant_id'] as String,
      merchantName: json['merchant_name'] as String,
      stockQuantity: json['stock_quantity'] as int,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'description': description,
      'description_ar': descriptionAr,
      'price': price,
      'currency': currency,
      'category': category,
      'category_ar': categoryAr,
      'images': images,
      'merchant_id': merchantId,
      'merchant_name': merchantName,
      'stock_quantity': stockQuantity,
      'rating': rating,
      'review_count': reviewCount,
      'is_active': isActive,
      'is_featured': isFeatured,
      'created_at': createdAt.toIso8601String(),
      'tags': tags,
    };
  }
}
