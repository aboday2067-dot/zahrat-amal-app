# 🚀 تعليمات النشر - زهرة الأمل

## ✅ معلومات مشروع Firebase

```
Project Name: zahratamal
Project ID: zahratamal-36602
Project Number: 29498082606
```

---

## 📦 الملفات الجاهزة

✅ جميع الملفات محدثة ومُعدّة بمعرف مشروعك الصحيح!

---

## 🎯 خطوات النشر (3 دقائق)

### الخطوة 1️⃣: تثبيت Firebase CLI

**على جهازك (Windows/Mac/Linux)**:
```bash
npm install -g firebase-tools
```

---

### الخطوة 2️⃣: تسجيل الدخول

```bash
firebase login
```

سيفتح المتصفح - سجل دخول بنفس حساب Google المستخدم في Firebase Console.

---

### الخطوة 3️⃣: تحميل المشروع

**حمّل مجلد المشروع الكامل**:
```
/home/user/flutter_app/
```

أو ملف ZIP يحتوي على:
```
firebase.json
.firebaserc
build/web/ (المجلد بالكامل مع محتوياته)
```

---

### الخطوة 4️⃣: النشر

**في terminal على جهازك**:

```bash
# انتقل إلى مجلد المشروع
cd /path/to/flutter_app

# تأكد من المشروع
firebase use zahratamal-36602

# نشر التطبيق
firebase deploy --only hosting
```

---

## 🎉 النتيجة المتوقعة

بعد اكتمال النشر (1-2 دقيقة)، ستظهر رسالة:

```
✔ Deploy complete!

Project Console: https://console.firebase.google.com/project/zahratamal-36602/overview
Hosting URL: https://zahratamal-36602.web.app
```

---

## 🔗 روابط التطبيق

### الرابط الرئيسي:
```
https://zahratamal-36602.web.app
```

### الرابط البديل:
```
https://zahratamal-36602.firebaseapp.com
```

---

## 🌐 ربط دومين مخصص (sd.zahrat.amal)

### إذا أردت رابط مخصص بدلاً من zahratamal-36602.web.app:

1. **في Firebase Console**:
   ```
   → اذهب إلى Hosting
   → اضغط "Add custom domain"
   → أدخل: sd.zahrat.amal
   ```

2. **سيعطيك Firebase سجلات DNS**:
   ```
   Type: A
   Name: @
   Value: 151.101.1.195
   
   Type: A
   Name: @
   Value: 151.101.65.195
   ```

3. **في لوحة تحكم النطاق**:
   - أضف السجلات
   - احفظ التغييرات
   - انتظر 24-48 ساعة

4. **النتيجة**:
   ```
   https://sd.zahrat.amal
   ```

---

## 🔄 تحديث التطبيق

عند إجراء تعديلات:

```bash
# بناء التطبيق
flutter build web --release

# نشر التحديث
firebase deploy --only hosting
```

---

## 📱 بيانات الاختبار

### حساب المسؤول:
```
البريد: admin@zahrat.sd
كلمة المرور: admin123
```

### حساب مستخدم:
```
البريد: أي بريد إلكتروني
الهاتف: أي رقم
المعرف: ZA-2025-001234
كلمة المرور: 123456
```

---

## 🆘 استكشاف الأخطاء

### "Firebase command not found"
```bash
npm install -g firebase-tools
```

### "Permission denied" (Mac/Linux)
```bash
sudo npm install -g firebase-tools
```

### "Error: HTTP Error: 404, Project does not exist"
تأكد من:
```bash
firebase use zahratamal-36602
firebase projects:list
```

---

## 📊 معلومات المشروع

```
Project Name: zahratamal
Project ID: zahratamal-36602
Package Name: sd.zahrat.amal
حجم التطبيق: 3.1 MB
```

---

## 💡 نصائح

1. **احفظ معرف المشروع**: `zahratamal-36602`
2. **استخدم نفس حساب Google** في CLI و Console
3. **تأكد من تحميل build/web** كاملاً
4. **راقب Hosting Dashboard** للإحصائيات

---

## 🔗 روابط سريعة

- **Firebase Console**: https://console.firebase.google.com/project/zahratamal-36602
- **Hosting Dashboard**: https://console.firebase.google.com/project/zahratamal-36602/hosting
- **Firebase Docs**: https://firebase.google.com/docs/hosting

---

**📝 معرف المشروع**: zahratamal-36602  
**✅ الحالة**: جاهز للنشر  
**⏱️ الوقت المتوقع**: 3-5 دقائق  
**🇸🇩 صُنع بـ ❤️ للسودان**

---

**🌸 الخطوة التالية**:
1. ثبّت Firebase CLI على جهازك
2. سجل دخول: `firebase login`
3. انشر: `firebase deploy --only hosting`
4. افتح الرابط! 🚀
