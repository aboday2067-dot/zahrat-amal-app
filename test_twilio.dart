import 'lib/services/twilio_service.dart';

/// اختبار بسيط لخدمة Twilio
/// 
/// لتشغيل الاختبار:
/// dart test_twilio.dart
void main() async {
  print('🧪 اختبار خدمة Twilio - زهرة الأمل');
  print('=' * 50);
  
  // رقم الهاتف للاختبار (استبدله برقمك)
  final testPhoneNumber = '+249912345678'; // ضع رقمك هنا
  
  print('\n📱 إرسال رسالة اختبار إلى: $testPhoneNumber');
  print('⏳ جاري الإرسال...\n');
  
  try {
    // إرسال رسالة اختبار
    final result = await TwilioService.sendSMS(
      toNumber: testPhoneNumber,
      message: '🌸 اختبار من زهرة الأمل - Zahrat Amal\nتم تكوين Twilio بنجاح!',
    );
    
    // عرض النتائج
    if (result['success'] == true) {
      print('✅ تم إرسال الرسالة بنجاح!');
      print('📩 Message SID: ${result['messageSid']}');
      print('📊 حالة الرسالة: ${result['status']}');
      print('📞 إلى: ${result['to']}');
    } else {
      print('❌ فشل إرسال الرسالة');
      print('⚠️ الخطأ: ${result['error']}');
      if (result['code'] != null) {
        print('🔢 كود الخطأ: ${result['code']}');
      }
    }
  } catch (e) {
    print('❌ خطأ غير متوقع: $e');
  }
  
  print('\n' + '=' * 50);
  print('✅ انتهى الاختبار');
}
