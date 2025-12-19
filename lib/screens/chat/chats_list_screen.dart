import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/chat_service.dart';
import '../../models/chat_message.dart';
import 'chat_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  final ChatService _chatService = ChatService();
  String _currentUserId = '';
  String _currentUserName = '';
  String _currentUserType = '';
  bool _isLoading = true;
  List<Chat> _chats = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    timeago.setLocaleMessages('ar', timeago.ArMessages());
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('userId') ?? '';
      _currentUserName = prefs.getString('displayName') ?? '';
      _currentUserType = prefs.getString('userType') ?? 'buyer';
      _isLoading = false;
    });

    // الاستماع للمحادثات
    _chatService.getUserChats(_currentUserId).listen((chats) {
      setState(() => _chats = chats);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحادثات'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chats.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: _chats.length,
                  itemBuilder: (context, index) {
                    final chat = _chats[index];
                    return _buildChatTile(chat);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSearchDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add_comment),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد محادثات بعد',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ محادثة جديدة الآن',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showSearchDialog,
            icon: const Icon(Icons.add),
            label: const Text('محادثة جديدة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(Chat chat) {
    // تحديد المستخدم الآخر في المحادثة
    final isParticipant1 = chat.participant1Id == _currentUserId;
    final otherUserName = isParticipant1 ? chat.participant2Name : chat.participant1Name;
    final otherUserType = isParticipant1 ? chat.participant2Type : chat.participant1Type;
    final unreadCount = isParticipant1 ? chat.unreadCount1 : chat.unreadCount2;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getUserTypeColor(otherUserType),
          child: Icon(
            _getUserTypeIcon(otherUserType),
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                otherUserName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (unreadCount > 0)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                chat.lastMessage ?? 'لا توجد رسائل',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: unreadCount > 0 ? Colors.black87 : Colors.grey[600],
                  fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (chat.lastMessageTime != null)
              Text(
                timeago.format(chat.lastMessageTime!, locale: 'ar'),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatId: chat.id,
                otherUserId: isParticipant1 ? chat.participant2Id : chat.participant1Id,
                otherUserName: otherUserName,
                otherUserType: otherUserType,
              ),
            ),
          );
        },
        onLongPress: () {
          _showChatOptions(chat);
        },
      ),
    );
  }

  Color _getUserTypeColor(String userType) {
    switch (userType) {
      case 'merchant':
        return Colors.blue;
      case 'delivery':
        return Colors.orange;
      case 'admin':
        return Colors.purple;
      default:
        return Colors.teal;
    }
  }

  IconData _getUserTypeIcon(String userType) {
    switch (userType) {
      case 'merchant':
        return Icons.store;
      case 'delivery':
        return Icons.local_shipping;
      case 'admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  Future<void> _showSearchDialog() async {
    final searchController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('بحث عن مستخدمين'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'اسم المستخدم...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'أو اختر من القائمة',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final query = searchController.text.trim();
                if (query.isNotEmpty) {
                  final users = await _chatService.searchUsers(query, _currentUserId);
                  if (mounted) {
                    _showUsersListDialog(users);
                  }
                }
              },
              child: const Text('بحث'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showUsersListDialog(List<Map<String, dynamic>> users) async {
    if (users.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم يتم العثور على مستخدمين')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('اختر مستخدم'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getUserTypeColor(user['type']),
                    child: Icon(
                      _getUserTypeIcon(user['type']),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(user['name']),
                  subtitle: Text(user['email']),
                  onTap: () async {
                    Navigator.pop(context);
                    await _startNewChat(user);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startNewChat(Map<String, dynamic> user) async {
    try {
      final chatId = await _chatService.getOrCreateChat(
        user1Id: _currentUserId,
        user1Name: _currentUserName,
        user1Type: _currentUserType,
        user2Id: user['id'],
        user2Name: user['name'],
        user2Type: user['type'],
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: chatId,
              otherUserId: user['id'],
              otherUserName: user['name'],
              otherUserType: user['type'],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إنشاء المحادثة: $e')),
        );
      }
    }
  }

  Future<void> _showChatOptions(Chat chat) async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('حذف المحادثة'),
                onTap: () async {
                  Navigator.pop(context);
                  await _chatService.deleteChat(chat.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حذف المحادثة')),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
