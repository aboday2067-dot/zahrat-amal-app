import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// نظام عرض بيانات الأعضاء التفصيلية - v8.0.0
/// يعرض معلومات شاملة عن المستخدمين (تجار، مشترين، مكاتب توصيل)
/// مع تاريخ المعاملات والدردشات

class AdminUserDetailsSystem extends StatefulWidget {
  const AdminUserDetailsSystem({Key? key}) : super(key: key);

  @override
  State<AdminUserDetailsSystem> createState() => _AdminUserDetailsSystemState();
}

class _AdminUserDetailsSystemState extends State<AdminUserDetailsSystem> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 بيانات الأعضاء التفصيلية'),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.store), text: 'التجار'),
            Tab(icon: Icon(Icons.shopping_bag), text: 'المشترين'),
            Tab(icon: Icon(Icons.local_shipping), text: 'مكاتب التوصيل'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUsersList('merchant'),
                _buildUsersList('buyer'),
                _buildUsersList('delivery'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: TextField(
        controller: _searchController,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: 'ابحث عن مستخدم...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase().trim();
          });
        },
      ),
    );
  }

  Widget _buildUsersList(String userType) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: userType)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('خطأ: ${snapshot.error}'),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getUserIcon(userType),
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'لا يوجد ${_getUserTypeLabel(userType)}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        var users = snapshot.data!.docs;

        // تصفية النتائج بناءً على البحث
        if (_searchQuery.isNotEmpty) {
          users = users.where((doc) {
            final userData = doc.data() as Map<String, dynamic>;
            final name = (userData['name'] ?? '').toString().toLowerCase();
            final email = (userData['email'] ?? '').toString().toLowerCase();
            final phone = (userData['phone'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery) ||
                email.contains(_searchQuery) ||
                phone.contains(_searchQuery);
          }).toList();
        }

        if (users.isEmpty) {
          return const Center(child: Text('لا توجد نتائج'));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userDoc = users[index];
            final userData = userDoc.data() as Map<String, dynamic>;

            return _buildUserCard(userDoc.id, userData, userType);
          },
        );
      },
    );
  }

  Widget _buildUserCard(String userId, Map<String, dynamic> userData, String userType) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailScreen(
                userId: userId,
                userData: userData,
                userType: userType,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // أيقونة المستخدم
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF6B9AC4).withOpacity(0.2),
                child: Icon(
                  _getUserIcon(userType),
                  size: 30,
                  color: const Color(0xFF6B9AC4),
                ),
              ),
              const SizedBox(width: 16),

              // معلومات المستخدم
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData['name'] ?? 'بدون اسم',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.email, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          userData['email'] ?? 'لا يوجد',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          userData['phone'] ?? 'لا يوجد',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // زر السهم
              const Icon(Icons.arrow_forward_ios, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getUserIcon(String userType) {
    switch (userType) {
      case 'merchant':
        return Icons.store;
      case 'buyer':
        return Icons.shopping_bag;
      case 'delivery':
        return Icons.local_shipping;
      default:
        return Icons.person;
    }
  }

  String _getUserTypeLabel(String userType) {
    switch (userType) {
      case 'merchant':
        return 'تجار';
      case 'buyer':
        return 'مشترين';
      case 'delivery':
        return 'مكاتب توصيل';
      default:
        return 'مستخدمين';
    }
  }
}

// صفحة تفاصيل المستخدم
class UserDetailScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;
  final String userType;

  const UserDetailScreen({
    Key? key,
    required this.userId,
    required this.userData,
    required this.userType,
  }) : super(key: key);

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userData['name'] ?? 'تفاصيل المستخدم'),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'المعلومات'),
            Tab(icon: Icon(Icons.shopping_cart), text: 'المعاملات'),
            Tab(icon: Icon(Icons.chat), text: 'المحادثات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(),
          _buildTransactionsTab(),
          _buildChatsTab(),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // صورة المستخدم
          CircleAvatar(
            radius: 60,
            backgroundColor: const Color(0xFF6B9AC4).withOpacity(0.2),
            child: Icon(
              _getUserIcon(),
              size: 60,
              color: const Color(0xFF6B9AC4),
            ),
          ),
          const SizedBox(height: 16),

          // اسم المستخدم
          Text(
            widget.userData['name'] ?? 'بدون اسم',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // نوع المستخدم
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getUserTypeColor(),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getUserTypeLabel(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // معلومات تفصيلية
          _buildInfoCard('المعلومات الشخصية', [
            _buildInfoRow('الاسم الكامل', widget.userData['name'] ?? 'غير محدد', Icons.person),
            _buildInfoRow('البريد الإلكتروني', widget.userData['email'] ?? 'غير محدد', Icons.email),
            _buildInfoRow('رقم الهاتف', widget.userData['phone'] ?? 'غير محدد', Icons.phone),
            _buildInfoRow('العنوان', widget.userData['address'] ?? 'غير محدد', Icons.location_on),
          ]),
          const SizedBox(height: 16),

          _buildInfoCard('معلومات الحساب', [
            _buildInfoRow('معرف المستخدم', widget.userId, Icons.fingerprint),
            _buildInfoRow('نوع الحساب', _getUserTypeLabel(), Icons.category),
            _buildInfoRow('تاريخ التسجيل', _formatDate(widget.userData['createdAt']), Icons.calendar_today),
            _buildInfoRow('آخر تسجيل دخول', _formatDate(widget.userData['lastLogin']), Icons.access_time),
          ]),
          const SizedBox(height: 16),

          // إحصائيات سريعة
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where(widget.userType == 'merchant' ? 'merchantId' : 'customerId',
              isEqualTo: widget.userId)
          .snapshots(),
      builder: (context, ordersSnapshot) {
        final ordersCount = ordersSnapshot.data?.docs.length ?? 0;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collectionGroup('messages')
              .where('senderId', isEqualTo: widget.userId)
              .snapshots(),
          builder: (context, messagesSnapshot) {
            final messagesCount = messagesSnapshot.data?.docs.length ?? 0;

            return Card(
              color: const Color(0xFF6B9AC4).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'إحصائيات سريعة',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'الطلبات',
                            ordersCount.toString(),
                            Icons.shopping_cart,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'الرسائل',
                            messagesCount.toString(),
                            Icons.message,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: const Color(0xFF6B9AC4)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildTransactionsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where(widget.userType == 'merchant' ? 'merchantId' : 'customerId',
              isEqualTo: widget.userId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('لا توجد معاملات', style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final orderDoc = snapshot.data!.docs[index];
            final orderData = orderDoc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(orderData['status']),
                  child: const Icon(Icons.shopping_bag, color: Colors.white),
                ),
                title: Text('طلب #${orderData['orderId'] ?? orderDoc.id}'),
                subtitle: Text(
                  '${orderData['total'] ?? 0} ج - ${_formatDate(orderData['createdAt'])}',
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(orderData['status']).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusLabel(orderData['status']),
                    style: TextStyle(
                      color: _getStatusColor(orderData['status']),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOrderDetailRow('رقم الطلب', orderData['orderId'] ?? orderDoc.id),
                        _buildOrderDetailRow('المبلغ الإجمالي', '${orderData['total']} ج'),
                        _buildOrderDetailRow('حالة الدفع', orderData['paymentStatus'] ?? 'غير محدد'),
                        _buildOrderDetailRow('طريقة الدفع', orderData['paymentMethod'] ?? 'غير محدد'),
                        _buildOrderDetailRow('عنوان التوصيل', orderData['deliveryAddress'] ?? 'غير محدد'),
                        _buildOrderDetailRow('التاريخ', _formatDate(orderData['createdAt'])),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOrderDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildChatsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: widget.userId)
          .orderBy('last_message_time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.chat_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('لا توجد محادثات', style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final chatDoc = snapshot.data!.docs[index];
            final chatData = chatDoc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF6B9AC4),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                title: Text(chatData['otherUserName'] ?? 'محادثة'),
                subtitle: Text(
                  chatData['last_message'] ?? 'لا توجد رسائل',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  _formatDate(chatData['last_message_time']),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getUserIcon() {
    switch (widget.userType) {
      case 'merchant':
        return Icons.store;
      case 'buyer':
        return Icons.shopping_bag;
      case 'delivery':
        return Icons.local_shipping;
      default:
        return Icons.person;
    }
  }

  String _getUserTypeLabel() {
    switch (widget.userType) {
      case 'merchant':
        return 'تاجر';
      case 'buyer':
        return 'مشتري';
      case 'delivery':
        return 'مكتب توصيل';
      default:
        return 'مستخدم';
    }
  }

  Color _getUserTypeColor() {
    switch (widget.userType) {
      case 'merchant':
        return Colors.purple;
      case 'buyer':
        return Colors.green;
      case 'delivery':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'processing':
        return 'قيد المعالجة';
      case 'shipped':
        return 'تم الشحن';
      case 'delivered':
        return 'تم التوصيل';
      case 'cancelled':
        return 'ملغي';
      default:
        return 'غير محدد';
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'غير محدد';
    
    try {
      DateTime dateTime;
      if (date is Timestamp) {
        dateTime = date.toDate();
      } else if (date is String) {
        dateTime = DateTime.parse(date);
      } else {
        return 'غير محدد';
      }
      
      return DateFormat('yyyy/MM/dd - HH:mm', 'ar').format(dateTime);
    } catch (e) {
      debugPrint('خطأ في تحويل التاريخ: $e');
      return 'غير محدد';
    }
  }
}
