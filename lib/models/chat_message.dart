class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String senderType; // 'buyer', 'merchant', 'delivery', 'admin'
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  final String? fileUrl;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
    this.fileUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderType': senderType,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
      'imageUrl': imageUrl,
      'fileUrl': fileUrl,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      id: id,
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? 'مستخدم',
      senderType: map['senderType'] ?? 'buyer',
      receiverId: map['receiverId'] ?? '',
      message: map['message'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      isRead: map['isRead'] ?? false,
      imageUrl: map['imageUrl'],
      fileUrl: map['fileUrl'],
    );
  }

  ChatMessage copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? senderType,
    String? receiverId,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? imageUrl,
    String? fileUrl,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderType: senderType ?? this.senderType,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      fileUrl: fileUrl ?? this.fileUrl,
    );
  }
}

class Chat {
  final String id;
  final String participant1Id;
  final String participant1Name;
  final String participant1Type;
  final String participant2Id;
  final String participant2Name;
  final String participant2Type;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount1; // عدد الرسائل غير المقروءة للمشارك 1
  final int unreadCount2; // عدد الرسائل غير المقروءة للمشارك 2
  final bool isActive;

  Chat({
    required this.id,
    required this.participant1Id,
    required this.participant1Name,
    required this.participant1Type,
    required this.participant2Id,
    required this.participant2Name,
    required this.participant2Type,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount1 = 0,
    this.unreadCount2 = 0,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participant1Id': participant1Id,
      'participant1Name': participant1Name,
      'participant1Type': participant1Type,
      'participant2Id': participant2Id,
      'participant2Name': participant2Name,
      'participant2Type': participant2Type,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.millisecondsSinceEpoch,
      'unreadCount1': unreadCount1,
      'unreadCount2': unreadCount2,
      'isActive': isActive,
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map, String id) {
    return Chat(
      id: id,
      participant1Id: map['participant1Id'] ?? '',
      participant1Name: map['participant1Name'] ?? '',
      participant1Type: map['participant1Type'] ?? 'buyer',
      participant2Id: map['participant2Id'] ?? '',
      participant2Name: map['participant2Name'] ?? '',
      participant2Type: map['participant2Type'] ?? 'buyer',
      lastMessage: map['lastMessage'],
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastMessageTime'])
          : null,
      unreadCount1: map['unreadCount1'] ?? 0,
      unreadCount2: map['unreadCount2'] ?? 0,
      isActive: map['isActive'] ?? true,
    );
  }

  Chat copyWith({
    String? id,
    String? participant1Id,
    String? participant1Name,
    String? participant1Type,
    String? participant2Id,
    String? participant2Name,
    String? participant2Type,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount1,
    int? unreadCount2,
    bool? isActive,
  }) {
    return Chat(
      id: id ?? this.id,
      participant1Id: participant1Id ?? this.participant1Id,
      participant1Name: participant1Name ?? this.participant1Name,
      participant1Type: participant1Type ?? this.participant1Type,
      participant2Id: participant2Id ?? this.participant2Id,
      participant2Name: participant2Name ?? this.participant2Name,
      participant2Type: participant2Type ?? this.participant2Type,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount1: unreadCount1 ?? this.unreadCount1,
      unreadCount2: unreadCount2 ?? this.unreadCount2,
      isActive: isActive ?? this.isActive,
    );
  }
}
