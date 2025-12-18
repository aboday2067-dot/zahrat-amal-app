import 'dart:convert';
import 'package:http/http.dart' as http;

/// خدمة Twilio لإرسال الرسائل النصية (SMS)
/// 
/// للاستخدام:
/// 1. احصل على حساب من https://www.twilio.com/
/// 2. احصل على Account SID, Auth Token, وTwilio Phone Number
/// 3. ضع البيانات في المتغيرات أدناه أو استخدم متغيرات البيئة
class TwilioService {
  // ✅ بيانات Twilio - تم التكوين
  static const String _accountSid = 'AC65fcc8417d60897d02602200a9d5a219';
  static const String _authToken = '5bf3eb77203ae9e70b5801a8f046c2bb';
  static const String _twilioNumber = '+18444941678'; // رقم Twilio الخاص بك
  
  static String get _endpoint =>
      'https://api.twilio.com/2010-04-01/Accounts/$_accountSid/Messages.json';

  /// إرسال رسالة نصية (SMS)
  /// 
  /// [toNumber]: رقم الهاتف المستلم (صيغة دولية: +249...)
  /// [message]: نص الرسالة (بحد أقصى 160 حرف لرسالة واحدة)
  static Future<Map<String, dynamic>> sendSMS({
    required String toNumber,
    required String message,
  }) async {
    // التحقق من البيانات
    if (_accountSid == 'YOUR_TWILIO_ACCOUNT_SID') {
      print('⚠️ تحذير: يرجى تعيين بيانات Twilio');
      return {'success': false, 'error': 'Missing Twilio credentials'};
    }

    try {
      // تنسيق رقم الهاتف
      final formattedNumber = _formatPhoneNumber(toNumber);
      
      if (formattedNumber == null) {
        return {
          'success': false,
          'error': 'رقم هاتف غير صحيح. استخدم الصيغة الدولية (+249...)'
        };
      }

      // إنشاء Basic Authentication
      final credentials = base64Encode(
        utf8.encode('$_accountSid:$_authToken'),
      );

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'From': _twilioNumber,
          'To': formattedNumber,
          'Body': message,
        },
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ تم إرسال SMS إلى: $formattedNumber');
        print('Message SID: ${data['sid']}');
        
        return {
          'success': true,
          'messageSid': data['sid'],
          'status': data['status'],
          'to': formattedNumber,
        };
      } else {
        print('❌ خطأ Twilio: ${response.statusCode}');
        print('التفاصيل: ${response.body}');
        
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['message'] ?? 'خطأ في الإرسال',
          'code': error['code'],
        };
      }
    } catch (e) {
      print('❌ استثناء Twilio: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// إرسال رسالة نصية باستخدام قالب
  /// 
  /// [toNumber]: رقم الهاتف المستلم
  /// [templateName]: اسم القالب
  /// [variables]: متغيرات القالب
  static Future<Map<String, dynamic>> sendTemplateSMS({
    required String toNumber,
    required String templateName,
    required Map<String, String> variables,
  }) async {
    String message = _getTemplate(templateName);
    
    // استبدال المتغيرات في القالب
    variables.forEach((key, value) {
      message = message.replaceAll('{{$key}}', value);
    });

    return await sendSMS(toNumber: toNumber, message: message);
  }

  /// الحصول على قالب رسالة حسب الاسم
  static String _getTemplate(String templateName) {
    final templates = {
      'welcome': '''
مرحباً {{name}}!
شكراً لانضمامك إلى زهرة الأمل 🌸
معرفك الفريد: {{uniqueId}}

زهرة الأمل - السودان
      ''',
      'order_confirm': '''
✅ طلبك #{{orderId}} تم استلامه

المبلغ: {{amount}} جنيه سوداني
الحالة: قيد المعالجة

شكراً لثقتك - زهرة الأمل
      ''',
      'login': '''
🔐 تسجيل دخول جديد لحسابك

المعرف: {{uniqueId}}
الوقت: {{time}}

إذا لم تكن أنت، اتصل بنا فوراً
زهرة الأمل
      ''',
      'delivery': '''
🚚 طلبك #{{orderId}} في الطريق

المندوب: {{driver}}
الوصول المتوقع: {{eta}}

زهرة الأمل - التوصيل السريع
      ''',
      'payment': '''
💳 تم استلام دفعة بقيمة {{amount}} SDG

الطلب: #{{orderId}}
الطريقة: {{method}}

شكراً - زهرة الأمل
      ''',
    };
    
    return templates[templateName] ?? 'زهرة الأمل: {{message}}';
  }

  /// التحقق من حالة رسالة مرسلة
  /// 
  /// [messageSid]: معرف الرسالة من Twilio
  static Future<Map<String, dynamic>?> getMessageStatus(
    String messageSid,
  ) async {
    if (_accountSid == 'YOUR_TWILIO_ACCOUNT_SID') {
      print('⚠️ تحذير: يرجى تعيين بيانات Twilio');
      return null;
    }

    try {
      final credentials = base64Encode(
        utf8.encode('$_accountSid:$_authToken'),
      );
      
      final url = 'https://api.twilio.com/2010-04-01/Accounts/$_accountSid/Messages/$messageSid.json';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Basic $credentials',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'sid': data['sid'],
          'status': data['status'],
          'to': data['to'],
          'from': data['from'],
          'body': data['body'],
          'price': data['price'],
          'date_sent': data['date_sent'],
        };
      } else {
        print('❌ خطأ في الحصول على حالة الرسالة: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ استثناء في الحصول على الحالة: $e');
      return null;
    }
  }

  /// إرسال رسائل نصية متعددة (Bulk SMS)
  /// 
  /// [toNumbers]: قائمة أرقام الهواتف
  /// [message]: نص الرسالة
  /// [delayMs]: تأخير بين الرسائل (ms) لتجنب Rate Limiting
  static Future<List<Map<String, dynamic>>> sendBulkSMS({
    required List<String> toNumbers,
    required String message,
    int delayMs = 500,
  }) async {
    final results = <Map<String, dynamic>>[];
    
    for (int i = 0; i < toNumbers.length; i++) {
      final result = await sendSMS(
        toNumber: toNumbers[i],
        message: message,
      );
      
      results.add({
        'index': i,
        'number': toNumbers[i],
        ...result,
      });
      
      // تأخير لتجنب تجاوز الحد
      if (i < toNumbers.length - 1) {
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }
    
    final successCount = results.where((r) => r['success'] == true).length;
    print('✅ تم إرسال $successCount من ${toNumbers.length} رسالة');
    
    return results;
  }

  /// إرسال رسالة مع معرف تتبع مخصص
  /// 
  /// [toNumber]: رقم الهاتف
  /// [message]: نص الرسالة
  /// [statusCallback]: URL لاستقبال تحديثات الحالة
  static Future<Map<String, dynamic>> sendSMSWithTracking({
    required String toNumber,
    required String message,
    String? statusCallback,
  }) async {
    if (_accountSid == 'YOUR_TWILIO_ACCOUNT_SID') {
      print('⚠️ تحذير: يرجى تعيين بيانات Twilio');
      return {'success': false, 'error': 'Missing credentials'};
    }

    try {
      final formattedNumber = _formatPhoneNumber(toNumber);
      if (formattedNumber == null) {
        return {'success': false, 'error': 'رقم هاتف غير صحيح'};
      }

      final credentials = base64Encode(
        utf8.encode('$_accountSid:$_authToken'),
      );

      final body = {
        'From': _twilioNumber,
        'To': formattedNumber,
        'Body': message,
      };

      if (statusCallback != null) {
        body['StatusCallback'] = statusCallback;
      }

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'messageSid': data['sid'],
          'status': data['status'],
        };
      } else {
        return {'success': false, 'error': 'فشل الإرسال'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// تنسيق رقم الهاتف إلى الصيغة الدولية
  /// 
  /// أمثلة:
  /// - "912345678" → "+249912345678"
  /// - "+249912345678" → "+249912345678"
  /// - "0912345678" → "+249912345678"
  static String? _formatPhoneNumber(String phone) {
    // إزالة المسافات والشرطات
    String cleaned = phone.replaceAll(RegExp(r'[\s-]'), '');
    
    // إذا كان يبدأ بـ +، نعيده كما هو
    if (cleaned.startsWith('+')) {
      return cleaned;
    }
    
    // إذا كان يبدأ بـ 0، نزيل الصفر ونضيف +249
    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }
    
    // إذا كان يبدأ بـ 249، نضيف +
    if (cleaned.startsWith('249')) {
      return '+$cleaned';
    }
    
    // إذا كان يبدأ بـ 9 (رقم سوداني بدون 0 أو 249)
    if (cleaned.startsWith('9') && cleaned.length == 9) {
      return '+249$cleaned';
    }
    
    // في حالة عدم التطابق مع أي صيغة
    print('⚠️ رقم هاتف غير مدعوم: $phone');
    return null;
  }

  /// الحصول على معلومات الحساب
  static Future<Map<String, dynamic>?> getAccountInfo() async {
    if (_accountSid == 'YOUR_TWILIO_ACCOUNT_SID') {
      return null;
    }

    try {
      final credentials = base64Encode(
        utf8.encode('$_accountSid:$_authToken'),
      );
      
      final url = 'https://api.twilio.com/2010-04-01/Accounts/$_accountSid.json';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Basic $credentials',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('❌ خطأ في الحصول على معلومات الحساب: $e');
    }
    return null;
  }

  /// تقدير عدد الأحرف والرسائل المطلوبة
  /// 
  /// الرسالة الواحدة = 160 حرف (أو 70 حرف للنصوص غير اللاتينية)
  static Map<String, int> estimateMessageCount(String message) {
    final length = message.length;
    final isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(message);
    final charsPerMessage = isArabic ? 70 : 160;
    final messageCount = (length / charsPerMessage).ceil();

    return {
      'length': length,
      'messageCount': messageCount,
      'charsPerMessage': charsPerMessage,
    };
  }
}
