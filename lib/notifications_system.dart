// ============================================
// نظام الإشعارات المتقدم
// Advanced Notifications System with FCM
// ============================================

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'main.dart';

// معالج الإشعارات في الخلفية
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📨 Background message received: ${message.notification?.title}');
  
  // حفظ الإشعار في قاعدة البيانات المحلية
  await _saveNotificationLocally(message);
}

Future<void> _saveNotificationLocally(RemoteMessage message) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userEmail') ?? 'guest';
    
    await FirebaseFirestore.instance.collection('notifications').add({
      'user_id': userId,
      'title': message.notification?.title ?? '',
      'body': message.notification?.body ?? '',
      'data': message.data,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
  } catch (e) {
    debugPrint('❌ Error saving notification: $e');
  }
}

// ========== نموذج الإشعار ==========
class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool read;
  
  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.data,
    required this.timestamp,
    required this.read,
  });
  
  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      userId: data['user_id'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] ?? false,
    );
  }
  
  IconData getIcon() {
    final type = data['type'] ?? 'general';
    switch (type) {
      case 'order':
        return Icons.shopping_bag;
      case 'delivery':
        return Icons.local_shipping;
      case 'payment':
        return Icons.payment;
      case 'promo':
        return Icons.local_offer;
      default:
        return Icons.notifications;
    }
  }
  
  Color getColor() {
    final type = data['type'] ?? 'general';
    switch (type) {
      case 'order':
        return Colors.blue;
      case 'delivery':
        return Colors.green;
      case 'payment':
        return Colors.orange;
      case 'promo':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

// ========== خدمة الإشعارات ==========
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // إعداد الإشعارات
  Future<void> initialize() async {
    try {
      // طلب الصلاحيات
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ Notification permission granted');
        
        // الحصول على FCM Token
        final token = await _messaging.getToken();
        if (token != null) {
          debugPrint('📱 FCM Token: $token');
          await _saveTokenToFirestore(token);
        }
        
        // الاستماع لتحديثات Token
        _messaging.onTokenRefresh.listen(_saveTokenToFirestore);
        
        // معالج الإشعارات في المقدمة
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        
        // معالج النقر على الإشعار
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
        
        // معالج الإشعارات في الخلفية
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      } else {
        debugPrint('❌ Notification permission denied');
      }
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
    }
  }
  
  // حفظ Token في Firestore
  Future<void> _saveTokenToFirestore(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userEmail') ?? 'guest';
      
      await _firestore.collection('fcm_tokens').doc(userId).set({
        'token': token,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      debugPrint('✅ FCM token saved to Firestore');
    } catch (e) {
      debugPrint('❌ Error saving FCM token: $e');
    }
  }
  
  // معالج الإشعارات في المقدمة
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📨 Foreground message: ${message.notification?.title}');
    _saveNotificationLocally(message);
    
    // عرض الإشعار كـ Banner في التطبيق
    // (سيتم إضافته لاحقاً في الـ UI)
  }
  
  // معالج النقر على الإشعار
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('👆 Notification tapped: ${message.data}');
    // التوجيه إلى الصفحة المناسبة بناءً على البيانات
  }
  
  // جلب إشعارات المستخدم
  Stream<List<AppNotification>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromFirestore(doc))
            .toList());
  }
  
  // وضع علامة مقروء على إشعار
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'read': true,
      });
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
    }
  }
  
  // حذف إشعار
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      debugPrint('❌ Error deleting notification: $e');
    }
  }
  
  // حذف جميع الإشعارات
  Future<void> deleteAllNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: userId)
          .get();
      
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('❌ Error deleting all notifications: $e');
    }
  }
  
  // إرسال إشعار لمستخدم معين (للمسؤولين)
  Future<bool> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'user_id': userId,
        'title': title,
        'body': body,
        'data': data ?? {},
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
      return true;
    } catch (e) {
      debugPrint('❌ Error sending notification: $e');
      return false;
    }
  }
}

// ========== صفحة الإشعارات ==========
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final notificationService = NotificationService();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('الإشعارات', 'Notifications')),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text(lang.translate('وضع علامة مقروء على الكل', 'Mark all as read')),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getString('userEmail') ?? 'guest';
                  
                  final snapshot = await FirebaseFirestore.instance
                      .collection('notifications')
                      .where('user_id', isEqualTo: userId)
                      .where('read', isEqualTo: false)
                      .get();
                  
                  for (var doc in snapshot.docs) {
                    await doc.reference.update({'read': true});
                  }
                },
              ),
              PopupMenuItem(
                child: Text(
                  lang.translate('حذف الكل', 'Delete all'),
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getString('userEmail') ?? 'guest';
                  await notificationService.deleteAllNotifications(userId);
                },
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: _getUserId(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final userId = userSnapshot.data!;
          
          return StreamBuilder<List<AppNotification>>(
            stream: notificationService.getUserNotifications(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    lang.translate('حدث خطأ في جلب الإشعارات', 'Error loading notifications'),
                  ),
                );
              }
              
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        lang.translate('لا توجد إشعارات', 'No notifications'),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              final notifications = snapshot.data!;
              
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _buildNotificationCard(context, notification, lang, notificationService);
                },
              );
            },
          );
        },
      ),
    );
  }
  
  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail') ?? 'guest';
  }
  
  Widget _buildNotificationCard(
    BuildContext context,
    AppNotification notification,
    LanguageProvider lang,
    NotificationService service,
  ) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: notification.read ? 0 : 2,
      color: notification.read ? Colors.grey[100] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Dismissible(
        key: Key(notification.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (direction) {
          service.deleteNotification(notification.id);
        },
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: notification.getColor().withValues(alpha: 0.2),
            child: Icon(
              notification.getIcon(),
              color: notification.getColor(),
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
              fontSize: 15,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(
                notification.body,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                dateFormat.format(notification.timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          trailing: !notification.read
              ? Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6B9AC4),
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          onTap: () {
            if (!notification.read) {
              service.markAsRead(notification.id);
            }
            
            // التوجيه بناءً على نوع الإشعار
            final type = notification.data['type'];
            if (type == 'order' && notification.data['order_id'] != null) {
              // الانتقال لصفحة تفاصيل الطلب
            }
          },
        ),
      ),
    );
  }
}

// ========== Badge للإشعارات غير المقروءة ==========
class NotificationBadge extends StatelessWidget {
  const NotificationBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUserId(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Icon(Icons.notifications);
        
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notifications')
              .where('user_id', isEqualTo: snapshot.data!)
              .where('read', isEqualTo: false)
              .snapshots(),
          builder: (context, snapshot) {
            final unreadCount = snapshot.data?.docs.length ?? 0;
            
            return Stack(
              children: [
                const Icon(Icons.notifications),
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
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
                  ),
              ],
            );
          },
        );
      },
    );
  }
  
  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail') ?? 'guest';
  }
}
