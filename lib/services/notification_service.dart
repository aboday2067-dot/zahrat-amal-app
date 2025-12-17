import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'sendgrid_service.dart';
import 'twilio_service.dart';

/// خدمة إرسال الإشعارات عبر البريد الإلكتروني والهاتف
/// 
/// تستخدم SendGrid للبريد الإلكتروني و Twilio للرسائل النصية
class NotificationService {
  /// إرسال إشعار عبر البريد الإلكتروني باستخدام SendGrid
  static Future<bool> sendEmailNotification({
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
      // تحويل الرسالة النصية إلى HTML منسق
      final htmlContent = SendGridService.formatHtmlEmail(
        title: subject,
        content: message,
      );
      
      // إرسال عبر SendGrid
      final success = await SendGridService.sendEmail(
        toEmail: email,
        subject: subject,
        htmlContent: htmlContent,
        textContent: message,
      );
      
      // تسجيل الإشعار محليًا
      await _logNotification(
        type: 'email',
        recipient: email,
        content: '$subject: $message',
        success: success,
      );
      
      return success;
    } catch (e) {
      // في حالة الخطأ، نسجل الإشعار محليًا
      await _logNotification(
        type: 'email',
        recipient: email,
        content: '$subject: $message',
        success: false,
      );
      return false;
    }
  }
  
  /// إرسال إشعار عبر الرسائل النصية باستخدام Twilio
  static Future<bool> sendSmsNotification({
    required String phone,
    required String message,
  }) async {
    try {
      // إرسال عبر Twilio
      final result = await TwilioService.sendSMS(
        toNumber: phone,
        message: message,
      );
      
      final success = result['success'] == true;
      
      // تسجيل الإشعار محليًا
      await _logNotification(
        type: 'sms',
        recipient: phone,
        content: message,
        success: success,
      );
      
      return success;
    } catch (e) {
      // في حالة الخطأ، نسجل الإشعار محليًا
      await _logNotification(
        type: 'sms',
        recipient: phone,
        content: message,
        success: false,
      );
      return false;
    }
  }
  
  /// إرسال إشعار تسجيل دخول جديد
  static Future<void> sendLoginNotification({
    required String email,
    required String phone,
    required String userName,
    required String uniqueId,
  }) async {
    final message = '''
مرحباً $userName،
تم تسجيل دخول جديد إلى حسابك.
المعرف الفريد: $uniqueId
التاريخ: ${DateTime.now().toString()}
إذا لم تكن أنت، يرجى الاتصال بنا فورًا.
''';
    
    // إرسال عبر البريد والهاتف
    await Future.wait([
      sendEmailNotification(
        email: email,
        subject: 'تسجيل دخول جديد - زهرة الأمل',
        message: message,
      ),
      sendSmsNotification(
        phone: phone,
        message: 'تم تسجيل دخول جديد لحسابك في زهرة الأمل. المعرف: $uniqueId',
      ),
    ]);
  }
  
  /// إرسال إشعار طلب جديد
  static Future<void> sendOrderNotification({
    required String email,
    required String phone,
    required String orderNumber,
    required double totalAmount,
  }) async {
    final message = '''
طلبك رقم $orderNumber تم استلامه بنجاح!
المبلغ الإجمالي: ${totalAmount.toStringAsFixed(2)} جنيه سوداني
شكراً لتسوقك معنا.
''';
    
    await Future.wait([
      sendEmailNotification(
        email: email,
        subject: 'طلب جديد #$orderNumber - زهرة الأمل',
        message: message,
      ),
      sendSmsNotification(
        phone: phone,
        message: 'طلبك #$orderNumber تم استلامه. المبلغ: $totalAmount SDG',
      ),
    ]);
  }
  
  /// إرسال إشعار تسجيل مستخدم جديد
  static Future<void> sendWelcomeNotification({
    required String email,
    required String phone,
    required String userName,
    required String uniqueId,
  }) async {
    final message = '''
مرحباً $userName!
شكراً لانضمامك إلى زهرة الأمل.
معرفك الفريد: $uniqueId
يمكنك استخدام هذا المعرف لتسجيل الدخول.
نتمنى لك تجربة تسوق رائعة!
''';
    
    await Future.wait([
      sendEmailNotification(
        email: email,
        subject: 'مرحباً بك في زهرة الأمل',
        message: message,
      ),
      sendSmsNotification(
        phone: phone,
        message: 'مرحباً $userName! معرفك الفريد: $uniqueId - زهرة الأمل',
      ),
    ]);
  }
  
  /// تسجيل الإشعارات محليًا للمراجعة
  static Future<void> _logNotification({
    required String type,
    required String recipient,
    required String content,
    required bool success,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = prefs.getStringList('notification_logs') ?? [];
    
    final log = json.encode({
      'type': type,
      'recipient': recipient,
      'content': content,
      'success': success,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    logs.add(log);
    
    // الاحتفاظ بآخر 100 إشعار فقط
    if (logs.length > 100) {
      logs.removeRange(0, logs.length - 100);
    }
    
    await prefs.setStringList('notification_logs', logs);
  }
  
  /// الحصول على سجل الإشعارات المحلية
  static Future<List<Map<String, dynamic>>> getNotificationLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final logs = prefs.getStringList('notification_logs') ?? [];
    
    return logs.map((log) => json.decode(log) as Map<String, dynamic>).toList();
  }
  
  /// مسح سجل الإشعارات
  static Future<void> clearNotificationLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notification_logs');
  }
}
