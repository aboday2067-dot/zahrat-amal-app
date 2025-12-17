import 'dart:convert';
import 'package:http/http.dart' as http;

/// خدمة SendGrid لإرسال البريد الإلكتروني
/// 
/// للاستخدام:
/// 1. احصل على API Key من https://sendgrid.com/
/// 2. ضع المفتاح في _apiKey أو استخدم متغيرات البيئة
/// 3. تحقق من domain المرسل في SendGrid Dashboard
class SendGridService {
  // ⚠️ استبدل هذا بمفتاح API الخاص بك
  // للأمان، استخدم flutter_dotenv أو Firebase Remote Config
  static const String _apiKey = 'YOUR_SENDGRID_API_KEY_HERE';
  static const String _endpoint = 'https://api.sendgrid.com/v3/mail/send';
  
  // البريد الإلكتروني المرسل (يجب أن يكون معتمد في SendGrid)
  static const String _fromEmail = 'noreply@zahrat.sd';
  static const String _fromName = 'زهرة الأمل - ZahratAmal';

  /// إرسال بريد إلكتروني بسيط
  /// 
  /// [toEmail]: عنوان البريد المستلم
  /// [subject]: موضوع البريد
  /// [htmlContent]: محتوى HTML للبريد
  /// [textContent]: محتوى نصي بديل (اختياري)
  static Future<bool> sendEmail({
    required String toEmail,
    required String subject,
    required String htmlContent,
    String? textContent,
  }) async {
    // التحقق من وجود API Key
    if (_apiKey == 'YOUR_SENDGRID_API_KEY_HERE') {
      print('⚠️ تحذير: يرجى تعيين SendGrid API Key');
      return false;
    }

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
        print('✅ تم إرسال البريد الإلكتروني إلى: $toEmail');
        return true;
      } else {
        print('❌ خطأ SendGrid: ${response.statusCode}');
        print('التفاصيل: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ استثناء SendGrid: $e');
      return false;
    }
  }

  /// إرسال بريد إلكتروني باستخدام قالب SendGrid
  /// 
  /// [toEmail]: عنوان البريد المستلم
  /// [templateId]: معرف القالب من SendGrid Dashboard
  /// [dynamicData]: البيانات الديناميكية للقالب
  static Future<bool> sendTemplateEmail({
    required String toEmail,
    required String templateId,
    required Map<String, dynamic> dynamicData,
  }) async {
    if (_apiKey == 'YOUR_SENDGRID_API_KEY_HERE') {
      print('⚠️ تحذير: يرجى تعيين SendGrid API Key');
      return false;
    }

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

      if (response.statusCode == 202) {
        print('✅ تم إرسال البريد من القالب إلى: $toEmail');
        return true;
      } else {
        print('❌ خطأ في القالب: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ استثناء القالب: $e');
      return false;
    }
  }

  /// إرسال بريد إلى عدة مستلمين
  /// 
  /// [toEmails]: قائمة عناوين البريد
  /// [subject]: موضوع البريد
  /// [htmlContent]: محتوى HTML
  static Future<bool> sendBulkEmail({
    required List<String> toEmails,
    required String subject,
    required String htmlContent,
  }) async {
    if (_apiKey == 'YOUR_SENDGRID_API_KEY_HERE') {
      print('⚠️ تحذير: يرجى تعيين SendGrid API Key');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'personalizations': toEmails
              .map((email) => {
                    'to': [
                      {'email': email}
                    ],
                    'subject': subject,
                  })
              .toList(),
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

      if (response.statusCode == 202) {
        print('✅ تم إرسال ${toEmails.length} بريد إلكتروني');
        return true;
      } else {
        print('❌ خطأ في الإرسال الجماعي: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ استثناء الإرسال الجماعي: $e');
      return false;
    }
  }

  /// إرسال بريد مع مرفق
  /// 
  /// [toEmail]: عنوان البريد المستلم
  /// [subject]: موضوع البريد
  /// [htmlContent]: محتوى HTML
  /// [attachmentBase64]: الملف المرفق (Base64)
  /// [attachmentFilename]: اسم الملف المرفق
  /// [attachmentType]: نوع MIME للملف
  static Future<bool> sendEmailWithAttachment({
    required String toEmail,
    required String subject,
    required String htmlContent,
    required String attachmentBase64,
    required String attachmentFilename,
    String attachmentType = 'application/pdf',
  }) async {
    if (_apiKey == 'YOUR_SENDGRID_API_KEY_HERE') {
      print('⚠️ تحذير: يرجى تعيين SendGrid API Key');
      return false;
    }

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
            }
          ],
          'attachments': [
            {
              'content': attachmentBase64,
              'filename': attachmentFilename,
              'type': attachmentType,
              'disposition': 'attachment',
            }
          ],
        }),
      );

      if (response.statusCode == 202) {
        print('✅ تم إرسال البريد مع المرفق إلى: $toEmail');
        return true;
      } else {
        print('❌ خطأ في إرسال المرفق: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ استثناء المرفق: $e');
      return false;
    }
  }

  /// تنسيق رسالة HTML بشكل جميل
  /// 
  /// [title]: عنوان الرسالة
  /// [content]: محتوى الرسالة
  /// [buttonText]: نص الزر (اختياري)
  /// [buttonUrl]: رابط الزر (اختياري)
  static String formatHtmlEmail({
    required String title,
    required String content,
    String? buttonText,
    String? buttonUrl,
  }) {
    return '''
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            font-family: 'Arial', 'Segoe UI', sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 600px;
            margin: 20px auto;
            background-color: #ffffff;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .header {
            background: linear-gradient(135deg, #009688 0%, #00796b 100%);
            color: white;
            padding: 30px 20px;
            text-align: center;
        }
        .header h1 {
            margin: 0;
            font-size: 24px;
        }
        .content {
            padding: 30px 20px;
            color: #333;
            line-height: 1.6;
        }
        .button {
            display: inline-block;
            padding: 12px 30px;
            background-color: #009688;
            color: white !important;
            text-decoration: none;
            border-radius: 4px;
            margin: 20px 0;
        }
        .footer {
            background-color: #f9f9f9;
            padding: 20px;
            text-align: center;
            color: #666;
            font-size: 12px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🌸 زهرة الأمل</h1>
        </div>
        <div class="content">
            <h2>$title</h2>
            <div style="white-space: pre-line;">$content</div>
            ${buttonText != null && buttonUrl != null ? '<a href="$buttonUrl" class="button">$buttonText</a>' : ''}
        </div>
        <div class="footer">
            <p>زهرة الأمل - منصة السودان للتجارة الإلكترونية</p>
            <p>للدعم: support@zahrat.sd</p>
        </div>
    </div>
</body>
</html>
    ''';
  }
}
