# 📧📱 دليل تكامل SendGrid و Twilio

## نظرة عامة

هذا الدليل يشرح كيفية دمج خدمات SendGrid (للبريد الإلكتروني) و Twilio (للرسائل النصية) في تطبيق ZahratAmal.

---

## 📧 الجزء الأول: تكامل SendGrid (البريد الإلكتروني)

### 1️⃣ إنشاء حساب SendGrid

1. انتقل إلى: **https://sendgrid.com/**
2. اضغط على **"Start for Free"**
3. أكمل التسجيل وتحقق من بريدك الإلكتروني
4. احصل على **API Key**:
   - اذهب إلى **Settings** → **API Keys**
   - اضغط **Create API Key**
   - اختر **Full Access**
   - انسخ المفتاح (لن تستطيع رؤيته مرة أخرى!)

### 2️⃣ إضافة SendGrid إلى Flutter

أضف الحزمة إلى `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.5.0  # موجودة بالفعل
  # لا حاجة لحزمة إضافية - سنستخدم HTTP API مباشرة
```

### 3️⃣ إنشاء خدمة SendGrid

**الملف**: `lib/services/sendgrid_service.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class SendGridService {
  // ضع مفتاح API الخاص بك هنا (أو استخدم متغيرات البيئة)
  static const String _apiKey = 'SG.YOUR_API_KEY_HERE';
  static const String _endpoint = 'https://api.sendgrid.com/v3/mail/send';
  
  // البريد الإلكتروني المرسل (يجب أن يكون معتمد في SendGrid)
  static const String _fromEmail = 'noreply@zahrat.sd';
  static const String _fromName = 'زهرة الأمل';

  /// إرسال بريد إلكتروني بسيط
  static Future<bool> sendEmail({
    required String toEmail,
    required String subject,
    required String htmlContent,
    String? textContent,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'personalizations': [
            {
              'to': [
                {'email': toEmail}
              ],
              'subject': subject,
            }
          ],
          'from': {
            'email': _fromEmail,
            'name': _fromName,
          },
          'content': [
            {
              'type': 'text/html',
              'value': htmlContent,
            },
            if (textContent != null)
              {
                'type': 'text/plain',
                'value': textContent,
              },
          ],
        }),
      );

      if (response.statusCode == 202) {
        print('✅ Email sent successfully to $toEmail');
        return true;
      } else {
        print('❌ SendGrid Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ SendGrid Exception: $e');
      return false;
    }
  }

  /// إرسال بريد إلكتروني باستخدام قالب SendGrid
  static Future<bool> sendTemplateEmail({
    required String toEmail,
    required String templateId,
    required Map<String, dynamic> dynamicData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'personalizations': [
            {
              'to': [
                {'email': toEmail}
              ],
              'dynamic_template_data': dynamicData,
            }
          ],
          'from': {
            'email': _fromEmail,
            'name': _fromName,
          },
          'template_id': templateId,
        }),
      );

      return response.statusCode == 202;
    } catch (e) {
      print('❌ SendGrid Template Exception: $e');
      return false;
    }
  }

  /// إرسال بريد إلى عدة مستلمين
  static Future<bool> sendBulkEmail({
    required List<String> toEmails,
    required String subject,
    required String htmlContent,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'personalizations': toEmails.map((email) => {
            'to': [{'email': email}],
            'subject': subject,
          }).toList(),
          'from': {
            'email': _fromEmail,
            'name': _fromName,
          },
          'content': [
            {
              'type': 'text/html',
              'value': htmlContent,
            }
          ],
        }),
      );

      return response.statusCode == 202;
    } catch (e) {
      print('❌ SendGrid Bulk Exception: $e');
      return false;
    }
  }
}
```

---

## 📱 الجزء الثاني: تكامل Twilio (الرسائل النصية)

### 1️⃣ إنشاء حساب Twilio

1. انتقل إلى: **https://www.twilio.com/**
2. اضغط **"Sign up"**
3. أكمل التسجيل وتحقق من رقم هاتفك
4. احصل على بيانات الحساب:
   - **Account SID**
   - **Auth Token**
   - **Twilio Phone Number** (رقم الإرسال)

### 2️⃣ إنشاء خدمة Twilio

**الملف**: `lib/services/twilio_service.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class TwilioService {
  // بيانات Twilio الخاصة بك
  static const String _accountSid = 'YOUR_ACCOUNT_SID';
  static const String _authToken = 'YOUR_AUTH_TOKEN';
  static const String _twilioNumber = '+1234567890'; // رقم Twilio الخاص بك
  
  static String get _endpoint =>
      'https://api.twilio.com/2010-04-01/Accounts/$_accountSid/Messages.json';

  /// إرسال رسالة نصية
  static Future<bool> sendSMS({
    required String toNumber,
    required String message,
  }) async {
    try {
      // تنسيق رقم الهاتف (يجب أن يبدأ بـ +)
      final formattedNumber = toNumber.startsWith('+') 
          ? toNumber 
          : '+$toNumber';

      // إنشاء Basic Auth
      final credentials = base64Encode(utf8.encode('$_accountSid:$_authToken'));

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
        print('✅ SMS sent successfully to $formattedNumber');
        final data = jsonDecode(response.body);
        print('Message SID: ${data['sid']}');
        return true;
      } else {
        print('❌ Twilio Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Twilio Exception: $e');
      return false;
    }
  }

  /// إرسال رسالة نصية باستخدام قالب
  static Future<bool> sendTemplateSMS({
    required String toNumber,
    required String templateName,
    required Map<String, String> variables,
  }) async {
    // يمكنك إنشاء قوالب خاصة بك
    String message = _getTemplate(templateName);
    
    // استبدال المتغيرات
    variables.forEach((key, value) {
      message = message.replaceAll('{{$key}}', value);
    });

    return await sendSMS(toNumber: toNumber, message: message);
  }

  /// الحصول على قالب رسالة
  static String _getTemplate(String templateName) {
    final templates = {
      'welcome': 'مرحباً {{name}}! شكراً لانضمامك إلى زهرة الأمل. معرفك: {{uniqueId}}',
      'order_confirm': 'طلبك #{{orderId}} تم استلامه. المبلغ: {{amount}} SDG',
      'login': 'تسجيل دخول جديد لحسابك. المعرف: {{uniqueId}}',
    };
    
    return templates[templateName] ?? 'زهرة الأمل - {{message}}';
  }

  /// التحقق من حالة الرسالة
  static Future<String?> getMessageStatus(String messageSid) async {
    try {
      final credentials = base64Encode(utf8.encode('$_accountSid:$_authToken'));
      final url = 'https://api.twilio.com/2010-04-01/Accounts/$_accountSid/Messages/$messageSid.json';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Basic $credentials',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'];
      }
    } catch (e) {
      print('❌ Error getting message status: $e');
    }
    return null;
  }

  /// إرسال رسائل نصية متعددة
  static Future<List<bool>> sendBulkSMS({
    required List<String> toNumbers,
    required String message,
  }) async {
    final results = <bool>[];
    
    for (final number in toNumbers) {
      final success = await sendSMS(toNumber: number, message: message);
      results.add(success);
      
      // تأخير بسيط لتجنب تجاوز الحد (Rate Limiting)
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    return results;
  }
}
```

---

## 🔗 الجزء الثالث: دمج الخدمات مع NotificationService

### تحديث `lib/services/notification_service.dart`:

```dart
import 'sendgrid_service.dart';
import 'twilio_service.dart';

class NotificationService {
  // استبدال الدوال القديمة
  
  /// إرسال إشعار عبر البريد الإلكتروني (SendGrid)
  static Future<bool> sendEmailNotification({
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
      // تحويل الرسالة النصية إلى HTML
      final htmlMessage = '''
      <html>
        <body style="font-family: Arial, sans-serif; direction: rtl;">
          <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
            <h2 style="color: #009688;">$subject</h2>
            <div style="white-space: pre-line;">$message</div>
            <hr style="margin: 20px 0;">
            <p style="color: #666; font-size: 12px;">
              زهرة الأمل - منصة السودان للتجارة الإلكترونية
            </p>
          </div>
        </body>
      </html>
      ''';
      
      return await SendGridService.sendEmail(
        toEmail: email,
        subject: subject,
        htmlContent: htmlMessage,
        textContent: message,
      );
    } catch (e) {
      print('خطأ في إرسال البريد الإلكتروني: $e');
      return false;
    }
  }
  
  /// إرسال إشعار عبر الرسائل النصية (Twilio)
  static Future<bool> sendSmsNotification({
    required String phone,
    required String message,
  }) async {
    try {
      return await TwilioService.sendSMS(
        toNumber: phone,
        message: message,
      );
    } catch (e) {
      print('خطأ في إرسال الرسالة النصية: $e');
      return false;
    }
  }
  
  // باقي الدوال تبقى كما هي...
}
```

---

## 🔐 الجزء الرابع: أمان API Keys

### ⚠️ لا تضع API Keys مباشرة في الكود!

### الطريقة الآمنة:

#### 1️⃣ استخدام ملف `.env`:

```bash
# .env (لا تضعه في Git!)
SENDGRID_API_KEY=SG.xxxxxxxxxxxxxx
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxxxxxxxx
TWILIO_PHONE_NUMBER=+1234567890
```

#### 2️⃣ إضافة حزمة للبيئة:

```yaml
# pubspec.yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

#### 3️⃣ تحميل المتغيرات:

```dart
// main.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

// في الخدمات
static String get _apiKey => dotenv.env['SENDGRID_API_KEY'] ?? '';
```

#### 4️⃣ إضافة `.env` إلى `.gitignore`:

```
# .gitignore
.env
*.env
```

---

## 📝 الجزء الخامس: أمثلة الاستخدام

### مثال 1: إرسال إشعار ترحيب

```dart
Future<void> sendWelcomeNotification(String email, String phone, String name, String uniqueId) async {
  // البريد الإلكتروني
  await SendGridService.sendEmail(
    toEmail: email,
    subject: 'مرحباً بك في زهرة الأمل',
    htmlContent: '''
      <h2>مرحباً $name!</h2>
      <p>شكراً لانضمامك إلى منصة زهرة الأمل.</p>
      <p><strong>معرفك الفريد:</strong> $uniqueId</p>
      <p>يمكنك استخدام هذا المعرف لتسجيل الدخول.</p>
    ''',
  );
  
  // الرسالة النصية
  await TwilioService.sendSMS(
    toNumber: phone,
    message: 'مرحباً $name! معرفك الفريد: $uniqueId - زهرة الأمل',
  );
}
```

### مثال 2: إشعار طلب جديد

```dart
Future<void> sendOrderNotification({
  required String email,
  required String phone,
  required String orderNumber,
  required double total,
}) async {
  // البريد مع تفاصيل كاملة
  await SendGridService.sendEmail(
    toEmail: email,
    subject: 'طلبك #$orderNumber تم استلامه',
    htmlContent: '''
      <h2>شكراً لطلبك!</h2>
      <p>رقم الطلب: <strong>$orderNumber</strong></p>
      <p>الإجمالي: <strong>${total.toStringAsFixed(2)} SDG</strong></p>
      <p>سنرسل لك تحديثات عن حالة طلبك.</p>
    ''',
  );
  
  // SMS مختصر
  await TwilioService.sendSMS(
    toNumber: phone,
    message: 'طلبك #$orderNumber تم استلامه. المبلغ: ${total.toStringAsFixed(2)} SDG',
  );
}
```

### مثال 3: استخدام القوالب

```dart
// إنشاء قوالب في SendGrid Dashboard
await SendGridService.sendTemplateEmail(
  toEmail: 'user@example.com',
  templateId: 'd-xxxxxxxxxxxxx', // من SendGrid
  dynamicData: {
    'name': 'أحمد محمد',
    'order_number': 'ORD-123',
    'total': '1,500.00',
  },
);

// استخدام قوالب Twilio
await TwilioService.sendTemplateSMS(
  toNumber: '+249912345678',
  templateName: 'order_confirm',
  variables: {
    'orderId': 'ORD-123',
    'amount': '1,500.00',
  },
);
```

---

## 💰 الجزء السادس: التكاليف والحدود

### SendGrid:
- **المجاني**: 100 بريد/يوم مجاناً
- **Essentials**: $19.95/شهر (50,000 بريد/شهر)
- **Pro**: $89.95/شهر (100,000 بريد/شهر)

### Twilio:
- **Pay as you go**: $0.0075 لكل رسالة SMS
- للسودان: تحقق من الأسعار الدولية
- رصيد تجريبي: $15 عند التسجيل

---

## ✅ الجزء السابع: اختبار التكامل

### اختبار SendGrid:

```dart
void testSendGrid() async {
  final success = await SendGridService.sendEmail(
    toEmail: 'test@example.com',
    subject: 'اختبار SendGrid',
    htmlContent: '<h1>مرحباً من زهرة الأمل!</h1>',
  );
  
  print(success ? '✅ نجح الإرسال' : '❌ فشل الإرسال');
}
```

### اختبار Twilio:

```dart
void testTwilio() async {
  final success = await TwilioService.sendSMS(
    toNumber: '+249912345678',
    message: 'اختبار Twilio من زهرة الأمل',
  );
  
  print(success ? '✅ نجح الإرسال' : '❌ فشل الإرسال');
}
```

---

## 🚨 نصائح مهمة

1. **التحقق من Domain** (SendGrid):
   - تحقق من domain الخاص بك في SendGrid
   - استخدم DNS records للمصادقة

2. **أرقام الهواتف** (Twilio):
   - استخدم صيغة دولية (+249...)
   - تحقق من رقمك في وضع التجربة

3. **Rate Limiting**:
   - لا ترسل الكثير من الرسائل دفعة واحدة
   - استخدم Queue للإرسال التدريجي

4. **تسجيل الأخطاء**:
   - سجل جميع محاولات الإرسال
   - راقب معدل النجاح

5. **Webhook** (اختياري):
   - استقبل تحديثات حالة الرسائل
   - تتبع فتح البريد والنقرات

---

## 📚 مصادر إضافية

- **SendGrid Docs**: https://docs.sendgrid.com/
- **Twilio Docs**: https://www.twilio.com/docs/
- **Flutter HTTP**: https://pub.dev/packages/http
- **Flutter DotEnv**: https://pub.dev/packages/flutter_dotenv

---

**آخر تحديث**: ديسمبر 2025  
**الحالة**: ✅ جاهز للتطبيق

**تم التطوير بـ ❤️ للسودان 🇸🇩**
