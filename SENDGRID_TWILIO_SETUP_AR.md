# 📧📱 دليل الإعداد السريع - SendGrid و Twilio

## 🚀 البدء السريع (5 دقائق)

### الخطوة 1️⃣: إعداد SendGrid (البريد الإلكتروني)

1. **إنشاء حساب مجاني**: https://sendgrid.com/
2. **الحصول على API Key**:
   - اذهب إلى: Settings → API Keys
   - اضغط "Create API Key"
   - اختر "Full Access"
   - انسخ المفتاح (لن تراه مرة أخرى!)

3. **التحقق من Domain** (اختياري لكن مهم):
   - Settings → Sender Authentication
   - اتبع التعليمات لإضافة DNS records

### الخطوة 2️⃣: إعداد Twilio (الرسائل النصية)

1. **إنشاء حساب**: https://www.twilio.com/
2. **الحصول على البيانات**:
   - من Dashboard، انسخ:
     - Account SID
     - Auth Token
   - احصل على رقم Twilio: Get a Trial Number

### الخطوة 3️⃣: إضافة البيانات إلى المشروع

#### الطريقة 1: مباشرة في الملفات (للتطوير فقط)

**في `lib/services/sendgrid_service.dart`:**
```dart
static const String _apiKey = 'SG.YOUR_ACTUAL_KEY_HERE';
static const String _fromEmail = 'noreply@zahrat.sd'; // أو بريدك
```

**في `lib/services/twilio_service.dart`:**
```dart
static const String _accountSid = 'ACxxxxxxxxxxxxx';
static const String _authToken = 'your_actual_token';
static const String _twilioNumber = '+1234567890'; // رقمك من Twilio
```

#### الطريقة 2: استخدام ملف .env (للإنتاج - مستحسن)

1. انسخ `.env.example` إلى `.env`:
   ```bash
   cp .env.example .env
   ```

2. افتح `.env` وأضف بياناتك:
   ```
   SENDGRID_API_KEY=SG.your_real_key_here
   TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxx
   TWILIO_AUTH_TOKEN=your_real_token_here
   TWILIO_PHONE_NUMBER=+1234567890
   ```

3. أضف الحزمة إلى `pubspec.yaml`:
   ```yaml
   dependencies:
     flutter_dotenv: ^5.1.0
   ```

4. حدث الخدمات لقراءة من .env:
   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart';
   
   static String get _apiKey => dotenv.env['SENDGRID_API_KEY'] ?? '';
   ```

---

## 🧪 الاختبار السريع

### اختبار SendGrid:

```dart
import 'package:zahrat_amal/services/sendgrid_service.dart';

void testEmail() async {
  final success = await SendGridService.sendEmail(
    toEmail: 'test@example.com',
    subject: 'اختبار من زهرة الأمل',
    htmlContent: '<h1>مرحباً! هذه رسالة اختبار 🌸</h1>',
  );
  
  print(success ? '✅ نجح الإرسال' : '❌ فشل الإرسال');
}
```

### اختبار Twilio:

```dart
import 'package:zahrat_amal/services/twilio_service.dart';

void testSMS() async {
  final result = await TwilioService.sendSMS(
    toNumber: '+249912345678', // رقمك
    message: 'اختبار من زهرة الأمل 🌸',
  );
  
  print(result['success'] ? '✅ نجح الإرسال' : '❌ فشل الإرسال');
}
```

---

## 💰 التكاليف

### SendGrid (المجاني):
- ✅ **100 بريد/يوم** مجاناً للأبد
- 📈 للتوسع: $19.95/شهر (50,000 بريد)

### Twilio (الدفع بالاستخدام):
- 💸 **$0.0075 لكل SMS** (حوالي 1 سنت)
- 🎁 **$15 رصيد مجاني** عند التسجيل
- 📱 للسودان: تحقق من الأسعار الدولية

---

## ✅ نصائح مهمة

### 🔐 الأمان:
- ❌ **لا تضع API Keys في Git**
- ✅ استخدم `.env` و `.gitignore`
- ✅ في الإنتاج، استخدم Firebase Remote Config أو AWS Secrets

### 📧 البريد الإلكتروني:
- ✅ تحقق من domain في SendGrid لتجنب Spam
- ✅ استخدم قوالب HTML احترافية
- ✅ راقب معدل الفتح والنقرات

### 📱 الرسائل النصية:
- ✅ استخدم صيغة دولية للأرقام (+249...)
- ✅ الرسائل العربية = 70 حرف/رسالة
- ✅ الرسائل الإنجليزية = 160 حرف/رسالة

### 🚨 Rate Limiting:
- ⏱️ لا ترسل آلاف الرسائل مرة واحدة
- ✅ استخدم تأخير بين الرسائل (500ms)
- ✅ استخدم Queue للإرسال التدريجي

---

## 🔗 روابط مفيدة

- **SendGrid Docs**: https://docs.sendgrid.com/
- **Twilio Docs**: https://www.twilio.com/docs/
- **Flutter DotEnv**: https://pub.dev/packages/flutter_dotenv

---

## 🆘 المشاكل الشائعة

### SendGrid لا يعمل؟
1. تأكد من صحة API Key
2. تحقق من أن بريد المرسل معتمد
3. راجع SendGrid Dashboard للأخطاء

### Twilio لا يرسل؟
1. تأكد من Account SID و Auth Token
2. تحقق من رصيدك في Twilio
3. تأكد من أن رقم الهاتف بصيغة دولية (+249...)

### الرسائل تذهب إلى Spam؟
1. تحقق من domain في SendGrid
2. أضف SPF و DKIM records
3. تجنب الكلمات المشبوهة في الموضوع

---

**📝 آخر تحديث**: ديسمبر 2025  
**✅ الحالة**: جاهز للاستخدام الفوري

**🇸🇩 تم التطوير بـ ❤️ للسودان**
