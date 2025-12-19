import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _localChatPrefix = 'local_chat_';
  static const String _localMessagesPrefix = 'local_messages_';

  // إنشاء أو الحصول على محادثة بين مستخدمين
  Future<String> getOrCreateChat({
    required String user1Id,
    required String user1Name,
    required String user1Type,
    required String user2Id,
    required String user2Name,
    required String user2Type,
  }) async {
    try {
      // البحث عن محادثة موجودة
      final chatsQuery = await _firestore
          .collection('chats')
          .where('participant1Id', whereIn: [user1Id, user2Id])
          .get();

      for (var doc in chatsQuery.docs) {
        final data = doc.data();
        if ((data['participant1Id'] == user1Id && data['participant2Id'] == user2Id) ||
            (data['participant1Id'] == user2Id && data['participant2Id'] == user1Id)) {
          return doc.id;
        }
      }

      // إنشاء محادثة جديدة
      final newChat = Chat(
        id: '',
        participant1Id: user1Id,
        participant1Name: user1Name,
        participant1Type: user1Type,
        participant2Id: user2Id,
        participant2Name: user2Name,
        participant2Type: user2Type,
        isActive: true,
      );

      final docRef = await _firestore.collection('chats').add(newChat.toMap());
      
      // حفظ نسخة محلية
      await _saveChatLocally(docRef.id, newChat);
      
      return docRef.id;
    } catch (e) {
      // استخدام التخزين المحلي عند فشل Firebase
      return await _createLocalChat(user1Id, user1Name, user1Type, user2Id, user2Name, user2Type);
    }
  }

  // إرسال رسالة
  Future<bool> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String senderType,
    required String receiverId,
    required String message,
    String? imageUrl,
    String? fileUrl,
  }) async {
    try {
      final newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        senderType: senderType,
        receiverId: receiverId,
        message: message,
        timestamp: DateTime.now(),
        isRead: false,
        imageUrl: imageUrl,
        fileUrl: fileUrl,
      );

      // حفظ في Firebase
      await _firestore.collection('messages').add(newMessage.toMap());

      // تحديث آخر رسالة في المحادثة
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': message,
        'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
        // زيادة عداد الرسائل غير المقروءة للمستقبل
        'unreadCount2': FieldValue.increment(1),
      });

      // حفظ نسخة محلية
      await _saveMessageLocally(chatId, newMessage);

      return true;
    } catch (e) {
      // حفظ محلياً عند فشل Firebase
      return await _sendLocalMessage(chatId, senderId, senderName, senderType, receiverId, message);
    }
  }

  // الحصول على جميع محادثات المستخدم
  Stream<List<Chat>> getUserChats(String userId) {
    try {
      return _firestore
          .collection('chats')
          .where('participant1Id', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return Chat.fromMap(doc.data(), doc.id);
        }).toList();
      });
    } catch (e) {
      // إرجاع stream فارغ عند الفشل
      return Stream.value([]);
    }
  }

  // الحصول على رسائل محادثة معينة
  Stream<List<ChatMessage>> getChatMessages(String chatId) {
    try {
      return _firestore
          .collection('messages')
          .where('chatId', isEqualTo: chatId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return ChatMessage.fromMap(doc.data(), doc.id);
        }).toList();
      });
    } catch (e) {
      // إرجاع stream فارغ عند الفشل
      return Stream.value([]);
    }
  }

  // تعليم الرسائل كمقروءة
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      final messagesQuery = await _firestore
          .collection('messages')
          .where('chatId', isEqualTo: chatId)
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in messagesQuery.docs) {
        await doc.reference.update({'isRead': true});
      }

      // إعادة تعيين عداد الرسائل غير المقروءة
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount2': 0,
      });
    } catch (e) {
      // تجاهل الأخطاء في التعليم كمقروءة
    }
  }

  // ==== التخزين المحلي ====

  Future<String> _createLocalChat(
    String user1Id,
    String user1Name,
    String user1Type,
    String user2Id,
    String user2Name,
    String user2Type,
  ) async {
    final chatId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    
    final chat = Chat(
      id: chatId,
      participant1Id: user1Id,
      participant1Name: user1Name,
      participant1Type: user1Type,
      participant2Id: user2Id,
      participant2Name: user2Name,
      participant2Type: user2Type,
      isActive: true,
    );

    await _saveChatLocally(chatId, chat);
    return chatId;
  }

  Future<void> _saveChatLocally(String chatId, Chat chat) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_localChatPrefix$chatId';
    
    // تحويل Chat إلى JSON string للتخزين
    final chatData = chat.toMap();
    await prefs.setString(key, chatData.toString());
  }

  Future<bool> _sendLocalMessage(
    String chatId,
    String senderId,
    String senderName,
    String senderType,
    String receiverId,
    String message,
  ) async {
    final messageId = 'msg_${DateTime.now().millisecondsSinceEpoch}';
    
    final newMessage = ChatMessage(
      id: messageId,
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      senderType: senderType,
      receiverId: receiverId,
      message: message,
      timestamp: DateTime.now(),
      isRead: false,
    );

    await _saveMessageLocally(chatId, newMessage);
    return true;
  }

  Future<void> _saveMessageLocally(String chatId, ChatMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_localMessagesPrefix${chatId}_${message.id}';
    
    // تحويل Message إلى JSON string للتخزين
    final messageData = message.toMap();
    await prefs.setString(key, messageData.toString());
  }

  // الحصول على عدد الرسائل غير المقروءة للمستخدم
  Future<int> getUnreadMessagesCount(String userId) async {
    try {
      final messagesQuery = await _firestore
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return messagesQuery.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // حذف محادثة
  Future<void> deleteChat(String chatId) async {
    try {
      // حذف جميع رسائل المحادثة
      final messagesQuery = await _firestore
          .collection('messages')
          .where('chatId', isEqualTo: chatId)
          .get();

      for (var doc in messagesQuery.docs) {
        await doc.reference.delete();
      }

      // حذف المحادثة
      await _firestore.collection('chats').doc(chatId).delete();
    } catch (e) {
      // تجاهل الأخطاء
    }
  }

  // البحث عن مستخدمين للمحادثة
  Future<List<Map<String, dynamic>>> searchUsers(String query, String currentUserId) async {
    try {
      final usersQuery = await _firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      return usersQuery.docs
          .where((doc) => doc.id != currentUserId)
          .map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['displayName'] ?? 'مستخدم',
          'type': data['userType'] ?? 'buyer',
          'email': data['email'] ?? '',
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
