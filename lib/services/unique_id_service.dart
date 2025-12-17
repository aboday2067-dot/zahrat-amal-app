import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة توليد وإدارة المعرفات الفريدة للمستخدمين
/// نظام: ZA-YYYY-NNNNNN
/// مثال: ZA-2025-001234
class UniqueIdService {
  static const String _counterKey = 'unique_id_counter';
  static const String _prefix = 'ZA';
  
  /// توليد معرف فريد جديد
  static Future<String> generateUniqueId() async {
    final prefs = await SharedPreferences.getInstance();
    
    // الحصول على آخر رقم تسلسلي
    int counter = prefs.getInt(_counterKey) ?? 0;
    counter++;
    
    // حفظ الرقم التسلسلي الجديد
    await prefs.setInt(_counterKey, counter);
    
    // الحصول على السنة الحالية
    final year = DateTime.now().year;
    
    // تنسيق الرقم التسلسلي (6 أرقام)
    final serialNumber = counter.toString().padLeft(6, '0');
    
    // تكوين المعرف الفريد
    return '$_prefix-$year-$serialNumber';
  }
  
  /// التحقق من صحة المعرف الفريد
  static bool isValidUniqueId(String uniqueId) {
    // نمط المعرف الفريد: ZA-YYYY-NNNNNN
    final pattern = RegExp(r'^ZA-\d{4}-\d{6}$');
    return pattern.hasMatch(uniqueId);
  }
  
  /// استخراج السنة من المعرف الفريد
  static int? getYearFromUniqueId(String uniqueId) {
    if (!isValidUniqueId(uniqueId)) return null;
    final parts = uniqueId.split('-');
    return int.tryParse(parts[1]);
  }
  
  /// استخراج الرقم التسلسلي من المعرف الفريد
  static int? getSerialNumberFromUniqueId(String uniqueId) {
    if (!isValidUniqueId(uniqueId)) return null;
    final parts = uniqueId.split('-');
    return int.tryParse(parts[2]);
  }
  
  /// إعادة تعيين العداد (للاختبار فقط)
  static Future<void> resetCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_counterKey);
  }
  
  /// توليد معرف فريد مؤقت للاختبار
  static String generateTestId() {
    final random = Random();
    final year = DateTime.now().year;
    final serialNumber = random.nextInt(999999).toString().padLeft(6, '0');
    return '$_prefix-$year-$serialNumber';
  }
}
