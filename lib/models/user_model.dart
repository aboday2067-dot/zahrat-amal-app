class UserModel {
  final String uniqueId; // رقم فريد مثل: ZA-2025-001234
  final String name;
  final String email;
  final String phone;
  final String userType; // buyer, merchant, delivery, admin
  final DateTime createdAt;
  final bool isActive;

  UserModel({
    required this.uniqueId,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    required this.createdAt,
    this.isActive = true,
  });

  // توليد رقم فريد
  static String generateUniqueId(String userType) {
    final now = DateTime.now();
    final year = now.year;
    final random = now.millisecondsSinceEpoch % 1000000;
    
    String prefix;
    switch (userType) {
      case 'buyer':
        prefix = 'ZA-B';
        break;
      case 'merchant':
        prefix = 'ZA-M';
        break;
      case 'delivery':
        prefix = 'ZA-D';
        break;
      case 'admin':
        prefix = 'ZA-A';
        break;
      default:
        prefix = 'ZA-U';
    }
    
    return '$prefix-$year-${random.toString().padLeft(6, '0')}';
  }

  Map<String, dynamic> toJson() => {
        'uniqueId': uniqueId,
        'name': name,
        'email': email,
        'phone': phone,
        'userType': userType,
        'createdAt': createdAt.toIso8601String(),
        'isActive': isActive,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uniqueId: json['uniqueId'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      userType: json['userType'],
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? true,
    );
  }
}
