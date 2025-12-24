import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// نظام الدردشة الفورية - v7.0.0
/// يربط بين التجار والمشترين ومكاتب التوصيل
/// مع دعم الرسائل النصية والصور والإشعارات الفورية

class ChatSystem extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;
  final String currentUserType; // merchant, buyer, delivery

  const ChatSystem({
    Key? key,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserType,
  }) : super(key: key);

  @override
  State<ChatSystem> createState() => _ChatSystemState();
}

class _ChatSystemState extends State<ChatSystem> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
        title: const Text('الرسائل'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment),
            tooltip: 'محادثة جديدة',
            onPressed: () => _showNewChatDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث
          _buildSearchBar(),
          
          // قائمة المحادثات
          Expanded(
            child: _buildChatsList(),
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
          hintText: 'ابحث عن محادثة...',
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

  Widget _buildChatsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('chats')
          .where('participants', arrayContains: widget.currentUserId)
          .orderBy('last_message_time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('خطأ: ${snapshot.error}'),
          );
        }

        final chats = snapshot.data?.docs ?? [];

        if (chats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'لا توجد محادثات بعد',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'ابدأ محادثة جديدة الآن',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        // تصفية المحادثات حسب البحث
        final filteredChats = _searchQuery.isEmpty
            ? chats
            : chats.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final otherUserId = _getOtherUserId(data['participants']);
                // هنا يمكن البحث حسب اسم المستخدم الآخر
                return true; // سيتم تحسينه لاحقاً
              }).toList();

        return ListView.builder(
          itemCount: filteredChats.length,
          itemBuilder: (context, index) {
            final chatDoc = filteredChats[index];
            final chatData = chatDoc.data() as Map<String, dynamic>;
            return _buildChatCard(chatDoc.id, chatData);
          },
        );
      },
    );
  }

  String _getOtherUserId(List<dynamic> participants) {
    return participants.firstWhere(
      (id) => id != widget.currentUserId,
      orElse: () => '',
    );
  }

  Widget _buildChatCard(String chatId, Map<String, dynamic> chatData) {
    final participants = List<String>.from(chatData['participants'] ?? []);
    final otherUserId = _getOtherUserId(participants);
    
    if (otherUserId.isEmpty) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(otherUserId).get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const SizedBox.shrink();
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
        if (userData == null) {
          return const SizedBox.shrink();
        }

        final otherUserName = userData['name'] ?? 'غير معروف';
        final otherUserType = userData['user_type'] ?? 'buyer';
        final lastMessage = chatData['last_message'] ?? '';
        final lastSenderId = chatData['last_sender_id'] ?? '';
        
        // أيقونة ولون حسب نوع المستخدم
        IconData icon;
        Color color;
        
        switch (otherUserType) {
          case 'merchant':
            icon = Icons.store;
            color = Colors.purple;
            break;
          case 'delivery':
            icon = Icons.delivery_dining;
            color = Colors.orange;
            break;
          default:
            icon = Icons.person;
            color = Colors.blue;
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
            title: Text(
              otherUserName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.right,
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    lastMessage,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (lastSenderId == widget.currentUserId)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.done_all,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ),
              ],
            ),
            trailing: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .where('is_read', isEqualTo: false)
                  .where('sender_id', isEqualTo: otherUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                final unreadCount = snapshot.data?.docs.length ?? 0;
                
                if (unreadCount == 0) {
                  return const SizedBox.shrink();
                }
                
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    currentUserId: widget.currentUserId,
                    currentUserName: widget.currentUserName,
                    currentUserType: widget.currentUserType,
                    otherUserId: otherUserId,
                    otherUserName: otherUserName,
                    otherUserType: otherUserType,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showNewChatDialog() {
    showDialog(
      context: context,
      builder: (context) => NewChatDialog(
        currentUserId: widget.currentUserId,
        currentUserName: widget.currentUserName,
        currentUserType: widget.currentUserType,
      ),
    );
  }
}

/// نافذة بدء محادثة جديدة
class NewChatDialog extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;
  final String currentUserType;

  const NewChatDialog({
    Key? key,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserType,
  }) : super(key: key);

  @override
  State<NewChatDialog> createState() => _NewChatDialogState();
}

class _NewChatDialogState extends State<NewChatDialog> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedUserType = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                  'محادثة جديدة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // شريط البحث
            TextField(
              controller: _searchController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'ابحث عن مستخدم...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase().trim();
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // فلاتر نوع المستخدم
            Row(
              children: [
                Expanded(child: _buildTypeFilter('all', 'الكل')),
                const SizedBox(width: 8),
                Expanded(child: _buildTypeFilter('merchant', 'التجار')),
                const SizedBox(width: 8),
                Expanded(child: _buildTypeFilter('buyer', 'المشترين')),
                const SizedBox(width: 8),
                Expanded(child: _buildTypeFilter('delivery', 'التوصيل')),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // قائمة المستخدمين
            Expanded(
              child: _buildUsersList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeFilter(String type, String label) {
    final isSelected = _selectedUserType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedUserType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[700] : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    Query query = _firestore.collection('users');
    
    if (_selectedUserType != 'all') {
      query = query.where('user_type', isEqualTo: _selectedUserType);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('خطأ: ${snapshot.error}'));
        }

        final users = snapshot.data?.docs ?? [];
        
        // تصفية المستخدمين
        final filteredUsers = users.where((doc) {
          // استبعاد المستخدم الحالي
          if (doc.id == widget.currentUserId) return false;
          
          // تصفية حسب البحث
          if (_searchQuery.isNotEmpty) {
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['name'] ?? '').toString().toLowerCase();
            final email = (data['email'] ?? '').toString().toLowerCase();
            
            return name.contains(_searchQuery) || email.contains(_searchQuery);
          }
          
          return true;
        }).toList();

        if (filteredUsers.isEmpty) {
          return Center(
            child: Text(
              'لا توجد نتائج',
              style: TextStyle(color: Colors.grey[600]),
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

  Widget _buildUserCard(String userId, Map<String, dynamic> userData) {
    final name = userData['name'] ?? 'غير معروف';
    final userType = userData['user_type'] ?? 'buyer';
    final email = userData['email'] ?? '';
    
    IconData icon;
    Color color;
    
    switch (userType) {
      case 'merchant':
        icon = Icons.store;
        color = Colors.purple;
        break;
      case 'delivery':
        icon = Icons.delivery_dining;
        color = Colors.orange;
        break;
      default:
        icon = Icons.person;
        color = Colors.blue;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.right,
      ),
      subtitle: Text(
        email,
        textAlign: TextAlign.right,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              currentUserId: widget.currentUserId,
              currentUserName: widget.currentUserName,
              currentUserType: widget.currentUserType,
              otherUserId: userId,
              otherUserName: name,
              otherUserType: userType,
            ),
          ),
        );
      },
    );
  }
}

/// شاشة المحادثة المباشرة
class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;
  final String currentUserType;
  final String otherUserId;
  final String otherUserName;
  final String otherUserType;

  const ChatScreen({
    Key? key,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserType,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserType,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late String _chatId;

  @override
  void initState() {
    super.initState();
    _chatId = _generateChatId(widget.currentUserId, widget.otherUserId);
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _generateChatId(String userId1, String userId2) {
    // ترتيب المعرفات أبجدياً لضمان نفس معرف المحادثة
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<void> _markMessagesAsRead() async {
    try {
      final unreadMessages = await _firestore
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .where('is_read', isEqualTo: false)
          .where('sender_id', isEqualTo: widget.otherUserId)
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
    
    switch (widget.otherUserType) {
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
                  widget.otherUserName,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 2),
                Text(
                  _getUserTypeLabel(widget.otherUserType),
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
        actions: [
          // زر المعلومات
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // عرض معلومات المستخدم
            },
          ),
        ],
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
    final isCurrentUser = messageData['sender_id'] == widget.currentUserId;
    final message = messageData['message'] ?? '';
    final timestamp = messageData['created_at'] as Timestamp?;
    final isRead = messageData['is_read'] ?? false;

    return Align(
      alignment: isCurrentUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.blue[600] : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isCurrentUser ? const Radius.circular(4) : const Radius.circular(16),
            bottomRight: isCurrentUser ? const Radius.circular(16) : const Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCurrentUser)
                  Icon(
                    isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: isCurrentUser ? Colors.white70 : Colors.black54,
                  ),
                if (isCurrentUser) const SizedBox(width: 4),
                Text(
                  _formatTimestamp(timestamp),
                  style: TextStyle(
                    color: isCurrentUser ? Colors.white70 : Colors.black54,
                    fontSize: 11,
                  ),
                ),
              ],
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
        'sender_id': widget.currentUserId,
        'sender_name': widget.currentUserName,
        'sender_type': widget.currentUserType,
        'receiver_id': widget.otherUserId,
        'message': message,
        'is_read': false,
        'created_at': FieldValue.serverTimestamp(),
      });

      // تحديث آخر رسالة
      await _firestore.collection('chats').doc(_chatId).set({
        'last_message': message,
        'last_message_time': FieldValue.serverTimestamp(),
        'last_sender_id': widget.currentUserId,
        'participants': [widget.currentUserId, widget.otherUserId],
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
