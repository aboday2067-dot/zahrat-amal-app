import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// نظام المراسلة الفورية للمدير - v7.0.0
/// يتيح للمدير مراسلة جميع المستخدمين (تجار، مشتريين، مكاتب توصيل)
/// مع دعم الإشعارات الفورية والمحادثات الشخصية

class AdminMessagingSystem extends StatefulWidget {
  final String adminId;
  final String adminName;

  const AdminMessagingSystem({
    Key? key,
    required this.adminId,
    required this.adminName,
  }) : super(key: key);

  @override
  State<AdminMessagingSystem> createState() => _AdminMessagingSystemState();
}

class _AdminMessagingSystemState extends State<AdminMessagingSystem> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedTab = 'all'; // all, merchants, buyers, delivery
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💬 مراسلة المستخدمين'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.broadcast_on_personal),
            tooltip: 'إرسال رسالة جماعية',
            onPressed: () => _showBroadcastMessageDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث
          _buildSearchBar(),
          
          // التبويبات (الكل، التجار، المشترين، التوصيل)
          _buildTabBar(),
          
          // قائمة المستخدمين
          Expanded(
            child: _buildUsersList(),
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

  Widget _buildTabBar() {
    return Container(
      color: Colors.blue[700],
      child: Row(
        children: [
          _buildTab('all', 'الكل', Icons.people),
          _buildTab('merchants', 'التجار', Icons.store),
          _buildTab('buyers', 'المشترين', Icons.shopping_cart),
          _buildTab('delivery', 'التوصيل', Icons.delivery_dining),
        ],
      ),
    );
  }

  Widget _buildTab(String tabId, String label, IconData icon) {
    final isSelected = _selectedTab == tabId;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = tabId;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.blue[700] : Colors.white,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.blue[700] : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('خطأ: ${snapshot.error}'),
          );
        }

        final users = snapshot.data?.docs ?? [];
        
        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'لا يوجد مستخدمين',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // تصفية المستخدمين حسب البحث
        final filteredUsers = users.where((doc) {
          if (_searchQuery.isEmpty) return true;
          
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toString().toLowerCase();
          final email = (data['email'] ?? '').toString().toLowerCase();
          final phone = (data['phone'] ?? '').toString().toLowerCase();
          
          return name.contains(_searchQuery) ||
                 email.contains(_searchQuery) ||
                 phone.contains(_searchQuery);
        }).toList();

        if (filteredUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'لا توجد نتائج للبحث',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final userDoc = filteredUsers[index];
            final userData = userDoc.data() as Map<String, dynamic>;
            return _buildUserCard(userDoc.id, userData);
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> _getUsersStream() {
    Query query = _firestore.collection('users');
    
    // تصفية حسب النوع
    if (_selectedTab != 'all') {
      String userType = '';
      switch (_selectedTab) {
        case 'merchants':
          userType = 'merchant';
          break;
        case 'buyers':
          userType = 'buyer';
          break;
        case 'delivery':
          userType = 'delivery';
          break;
      }
      query = query.where('user_type', isEqualTo: userType);
    }
    
    return query.orderBy('created_at', descending: true).snapshots();
  }

  Widget _buildUserCard(String userId, Map<String, dynamic> userData) {
    final name = userData['name'] ?? 'غير معروف';
    final email = userData['email'] ?? '';
    final userType = userData['user_type'] ?? 'buyer';
    final isApproved = userData['is_approved'] ?? false;
    
    // أيقونة ولون حسب نوع المستخدم
    IconData icon;
    Color color;
    String typeLabel;
    
    switch (userType) {
      case 'merchant':
        icon = Icons.store;
        color = Colors.purple;
        typeLabel = 'تاجر';
        break;
      case 'delivery':
        icon = Icons.delivery_dining;
        color = Colors.orange;
        typeLabel = 'توصيل';
        break;
      default:
        icon = Icons.person;
        color = Colors.blue;
        typeLabel = 'مشتري';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          radius: 30,
          child: Icon(icon, color: color, size: 30),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            if (!isApproved && userType != 'buyer')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'قيد المراجعة',
                  style: TextStyle(color: Colors.red, fontSize: 10),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 4),
            Text(
              email,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  typeLabel,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(icon, color: color, size: 14),
              ],
            ),
          ],
        ),
        trailing: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('chats')
              .doc('${widget.adminId}_$userId')
              .collection('messages')
              .where('is_read', isEqualTo: false)
              .where('sender_id', isEqualTo: userId)
              .snapshots(),
          builder: (context, snapshot) {
            final unreadCount = snapshot.data?.docs.length ?? 0;
            
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chat_bubble),
                  color: Colors.blue[700],
                  onPressed: () => _openChat(userId, userData),
                ),
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            );
          },
        ),
        onTap: () => _openChat(userId, userData),
      ),
    );
  }

  void _openChat(String userId, Map<String, dynamic> userData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminChatScreen(
          adminId: widget.adminId,
          adminName: widget.adminName,
          userId: userId,
          userName: userData['name'] ?? 'غير معروف',
          userType: userData['user_type'] ?? 'buyer',
        ),
      ),
    );
  }

  void _showBroadcastMessageDialog() {
    final TextEditingController messageController = TextEditingController();
    String targetGroup = 'all';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'إرسال رسالة جماعية',
            textAlign: TextAlign.right,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'اختر المستهدفين:',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: targetGroup,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('الكل')),
                  DropdownMenuItem(value: 'merchants', child: Text('التجار فقط')),
                  DropdownMenuItem(value: 'buyers', child: Text('المشترين فقط')),
                  DropdownMenuItem(value: 'delivery', child: Text('التوصيل فقط')),
                ],
                onChanged: (value) {
                  setDialogState(() {
                    targetGroup = value ?? 'all';
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                maxLines: 4,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'اكتب الرسالة هنا...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final message = messageController.text.trim();
                if (message.isNotEmpty) {
                  _sendBroadcastMessage(targetGroup, message);
                  Navigator.pop(context);
                }
              },
              child: const Text('إرسال'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendBroadcastMessage(String targetGroup, String message) async {
    try {
      // جلب المستخدمين المستهدفين
      Query query = _firestore.collection('users');
      
      if (targetGroup != 'all') {
        String userType = '';
        switch (targetGroup) {
          case 'merchants':
            userType = 'merchant';
            break;
          case 'buyers':
            userType = 'buyer';
            break;
          case 'delivery':
            userType = 'delivery';
            break;
        }
        query = query.where('user_type', isEqualTo: userType);
      }
      
      final usersSnapshot = await query.get();
      
      // إرسال الرسالة لكل مستخدم
      final batch = _firestore.batch();
      
      for (var userDoc in usersSnapshot.docs) {
        final chatId = '${widget.adminId}_${userDoc.id}';
        final messageRef = _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc();
        
        batch.set(messageRef, {
          'sender_id': widget.adminId,
          'sender_name': widget.adminName,
          'sender_type': 'admin',
          'receiver_id': userDoc.id,
          'message': message,
          'is_read': false,
          'is_broadcast': true,
          'created_at': FieldValue.serverTimestamp(),
        });
        
        // تحديث آخر رسالة في المحادثة
        batch.set(
          _firestore.collection('chats').doc(chatId),
          {
            'last_message': message,
            'last_message_time': FieldValue.serverTimestamp(),
            'last_sender_id': widget.adminId,
            'participants': [widget.adminId, userDoc.id],
          },
          SetOptions(merge: true),
        );
      }
      
      await batch.commit();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إرسال الرسالة إلى ${usersSnapshot.docs.length} مستخدم'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('خطأ في إرسال الرسالة الجماعية: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل إرسال الرسالة'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// شاشة المحادثة المباشرة بين المدير والمستخدم
class AdminChatScreen extends StatefulWidget {
  final String adminId;
  final String adminName;
  final String userId;
  final String userName;
  final String userType;

  const AdminChatScreen({
    Key? key,
    required this.adminId,
    required this.adminName,
    required this.userId,
    required this.userName,
    required this.userType,
  }) : super(key: key);

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late String _chatId;

  @override
  void initState() {
    super.initState();
    _chatId = '${widget.adminId}_${widget.userId}';
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _markMessagesAsRead() async {
    try {
      final unreadMessages = await _firestore
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .where('is_read', isEqualTo: false)
          .where('sender_id', isEqualTo: widget.userId)
          .get();

      final batch = _firestore.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'is_read': true});
      }
      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('خطأ في تحديث حالة القراءة: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData userIcon;
    Color userColor;
    
    switch (widget.userType) {
      case 'merchant':
        userIcon = Icons.store;
        userColor = Colors.purple;
        break;
      case 'delivery':
        userIcon = Icons.delivery_dining;
        userColor = Colors.orange;
        break;
      default:
        userIcon = Icons.person;
        userColor = Colors.blue;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 2),
                Text(
                  _getUserTypeLabel(widget.userType),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: userColor.withOpacity(0.2),
              child: Icon(userIcon, color: userColor),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // قائمة الرسائل
          Expanded(
            child: _buildMessagesList(),
          ),
          
          // حقل إدخال الرسالة
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .orderBy('created_at', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('خطأ: ${snapshot.error}'));
        }

        final messages = snapshot.data?.docs ?? [];

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'لا توجد رسائل بعد',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'ابدأ المحادثة الآن',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        // التمرير إلى آخر رسالة
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final messageDoc = messages[index];
            final messageData = messageDoc.data() as Map<String, dynamic>;
            return _buildMessageBubble(messageData);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> messageData) {
    final isAdmin = messageData['sender_id'] == widget.adminId;
    final message = messageData['message'] ?? '';
    final timestamp = messageData['created_at'] as Timestamp?;
    final isBroadcast = messageData['is_broadcast'] ?? false;

    return Align(
      alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isAdmin ? Colors.blue[600] : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isAdmin ? const Radius.circular(4) : const Radius.circular(16),
            bottomRight: isAdmin ? const Radius.circular(16) : const Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isBroadcast)
              Container(
                padding: const EdgeInsets.all(4),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.campaign,
                      size: 14,
                      color: isAdmin ? Colors.white : Colors.black87,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'رسالة جماعية',
                      style: TextStyle(
                        fontSize: 10,
                        color: isAdmin ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              message,
              style: TextStyle(
                color: isAdmin ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(timestamp),
              style: TextStyle(
                color: isAdmin ? Colors.white70 : Colors.black54,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // زر الإرسال
            Container(
              decoration: BoxDecoration(
                color: Colors.blue[600],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
            const SizedBox(width: 12),
            
            // حقل النص
            Expanded(
              child: TextField(
                controller: _messageController,
                textAlign: TextAlign.right,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    try {
      // إضافة الرسالة
      await _firestore
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .add({
        'sender_id': widget.adminId,
        'sender_name': widget.adminName,
        'sender_type': 'admin',
        'receiver_id': widget.userId,
        'message': message,
        'is_read': false,
        'is_broadcast': false,
        'created_at': FieldValue.serverTimestamp(),
      });

      // تحديث آخر رسالة
      await _firestore.collection('chats').doc(_chatId).set({
        'last_message': message,
        'last_message_time': FieldValue.serverTimestamp(),
        'last_sender_id': widget.adminId,
        'participants': [widget.adminId, widget.userId],
      }, SetOptions(merge: true));

      _messageController.clear();
      
      // التمرير إلى الأسفل
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('خطأ في إرسال الرسالة: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل إرسال الرسالة'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'أمس ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _getUserTypeLabel(String userType) {
    switch (userType) {
      case 'merchant':
        return 'تاجر';
      case 'delivery':
        return 'مكتب توصيل';
      default:
        return 'مشتري';
    }
  }
}
