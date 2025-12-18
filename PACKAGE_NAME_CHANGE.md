# 📦 تغيير اسم الحزمة (Package Name)

## ✅ التغييرات المنفذة

### اسم الحزمة الجديد
```
sd.zahrat.amal
```

**ملاحظة**: تم استخدام `sd.zahrat.amal` (sd للسودان - Sudan) لأن أسماء الحزم في Android يجب أن تتبع قواعد Java package naming:
- يجب أن تبدأ بحرف صغير
- لا يمكن استخدام أحرف كبيرة في بداية الأجزاء
- الصيغة الصحيحة: نطاق عكسي (reverse domain notation)

---

## 📝 الملفات المحدثة

### 1️⃣ android/app/build.gradle.kts
```kotlin
namespace = "sd.zahrat.amal"
applicationId = "sd.zahrat.amal"
```

### 2️⃣ android/app/src/main/kotlin/sd/zahrat/amal/MainActivity.kt
```kotlin
package sd.zahrat.amal

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
```

**الموقع الجديد:**
```
android/app/src/main/kotlin/
└── sd/
    └── zahrat/
        └── amal/
            └── MainActivity.kt
```

### 3️⃣ android/app/src/main/AndroidManifest.xml
- ✅ لا يحتاج تحديث (يستخدم namespace من build.gradle.kts)

### 4️⃣ android/app/src/debug/AndroidManifest.xml
- ✅ لا يحتاج تحديث (manifest بسيط بدون package)

### 5️⃣ android/app/src/profile/AndroidManifest.xml
- ✅ لا يحتاج تحديث (manifest بسيط بدون package)

---

## 🔍 التحقق من التغييرات

### التحقق من build.gradle.kts:
```bash
grep -E "(namespace|applicationId)" android/app/build.gradle.kts
```

**النتيجة المتوقعة:**
```
namespace = "com.zahratamal"
applicationId = "com.zahratamal"
```

### التحقق من MainActivity:
```bash
head -1 android/app/src/main/kotlin/sd/zahrat/amal/MainActivity.kt
```

**النتيجة المتوقعة:**
```
package sd.zahrat.amal
```

### التحقق من هيكل المجلدات:
```bash
find android/app/src/main/kotlin -name "MainActivity.kt"
```

**النتيجة المتوقعة:**
```
android/app/src/main/kotlin/sd/zahrat/amal/MainActivity.kt
```

---

## 🔄 إعادة البناء

### تنظيف الـ Build Cache:
```bash
cd android
./gradlew clean
```

### أو تنظيف Flutter cache:
```bash
flutter clean
flutter pub get
```

### بناء APK جديد:
```bash
flutter build apk --release
```

---

## ⚠️ ملاحظات مهمة

### إذا كنت تستخدم Firebase:
- ⚠️ **يجب تحديث google-services.json**
- قم بتنزيل ملف جديد من Firebase Console
- تأكد من أن package_name في الملف هو: `com.zahratamal`

### إذا كنت تستخدم خدمات أخرى:
- تحقق من أي خدمات تعتمد على package name
- قد تحتاج لتحديث التكوينات في:
  - Google Play Console
  - Firebase Console
  - AdMob
  - OAuth providers

### الحالات التي تحتاج إعادة التكوين:
- ✅ Firebase (تحديث google-services.json)
- ✅ Google Sign-In (تحديث SHA fingerprints)
- ✅ Facebook Login (تحديث Package Name)
- ✅ Google Play Store (إنشاء تطبيق جديد إذا كان منشور)

---

## 📊 قبل وبعد

### قبل:
```
Package Name: com.smartbazaar.shop
Directory: android/app/src/main/kotlin/com/smartbazaar/shop/
```

### بعد:
```
Package Name: sd.zahrat.amal
Directory: android/app/src/main/kotlin/sd/zahrat/amal/
```

---

## 🚀 الخطوات التالية

1. ✅ تنظيف build cache: `flutter clean`
2. ✅ إعادة تثبيت dependencies: `flutter pub get`
3. ✅ بناء APK: `flutter build apk --release`
4. ⚠️ تحديث Firebase config (إذا كنت تستخدمه)
5. ⚠️ تحديث Google Play listing (إذا كان منشور)

---

## 🆘 استكشاف الأخطاء

### خطأ: "MainActivity not found"
```bash
# تأكد من المسار الصحيح
ls -la android/app/src/main/kotlin/sd/zahrat/amal/MainActivity.kt
```

### خطأ: "Package name mismatch"
```bash
# تحقق من تطابق جميع package names
grep -r "com.smartbazaar.shop" android/
```

### خطأ: "Firebase initialization failed"
```bash
# تحقق من google-services.json
grep "package_name" android/app/google-services.json
```

---

**📝 تاريخ التغيير**: ديسمبر 2025  
**✅ الحالة**: تم التغيير بنجاح  
**🎯 Package Name الجديد**: `sd.zahrat.amal`  
**🇸🇩 SD**: Sudan Domain - للسودان
