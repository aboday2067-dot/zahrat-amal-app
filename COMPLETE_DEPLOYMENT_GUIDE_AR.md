# 🚀 دليل النشر الكامل - زهرة الأمل

## 📋 نظرة عامة

**مشروع Firebase:** `zahratamal-36602`  
**Package Name:** `sd.zahrat.amal`  
**حجم التطبيق:** 31 MB

---

## 1️⃣ تثبيت Firebase CLI

### Windows

#### الطريقة 1: باستخدام npm (موصى بها)

```bash
# تثبيت Node.js أولاً من:
# https://nodejs.org/

# بعد تثبيت Node.js، افتح Command Prompt وشغّل:
npm install -g firebase-tools

# تحقق من التثبيت
firebase --version
```

#### الطريقة 2: باستخدام المثبت المستقل

1. حمّل Firebase CLI من:
   https://firebase.tools/bin/win/instant/latest
2. شغّل الملف المحمّل
3. اتبع خطوات التثبيت

### macOS

```bash
# باستخدام npm
npm install -g firebase-tools

# أو باستخدام Homebrew
brew install firebase-cli
```

### Linux

```bash
# باستخدام npm
sudo npm install -g firebase-tools

# أو حمّل المثبت المستقل:
curl -sL https://firebase.tools | bash
```

### ✅ التحقق من التثبيت

```bash
firebase --version
# يجب أن يظهر رقم الإصدار مثل: 13.0.0
```

---

## 2️⃣ خطوات النشر التفصيلية

### الخطوة 1: تحميل المشروع

1. **حمّل مجلد المشروع كاملاً:**
   - المسار: `/home/user/flutter_app/`
   - تأكد من تحميل جميع الملفات والمجلدات

2. **محتويات المشروع المطلوبة:**
   ```
   flutter_app/
   ├── build/web/          ✅ (31 MB - ملفات التطبيق)
   ├── firebase.json       ✅ (إعدادات Hosting)
   ├── .firebaserc         ✅ (معلومات المشروع)
   └── ...
   ```

### الخطوة 2: تسجيل الدخول إلى Firebase

```bash
# افتح Terminal أو Command Prompt
firebase login
```

**ماذا سيحدث؟**
1. سيفتح متصفحك تلقائياً
2. اختر حساب Google الذي أنشأت به مشروع Firebase
3. اضغط "Allow" للسماح بالوصول
4. ستظهر رسالة نجاح في المتصفح
5. ارجع للـ Terminal

### الخطوة 3: الانتقال لمجلد المشروع

```bash
# Windows
cd C:\path\to\flutter_app

# macOS/Linux
cd /path/to/flutter_app
```

**مثال:**
```bash
# Windows
cd C:\Users\YourName\Downloads\flutter_app

# macOS
cd ~/Downloads/flutter_app
```

### الخطوة 4: التحقق من الإعدادات (اختياري)

```bash
# تحقق من أن Firebase يتعرف على المشروع
firebase projects:list

# يجب أن ترى مشروع zahratamal-36602 في القائمة
```

### الخطوة 5: النشر 🚀

```bash
firebase deploy --only hosting
```

**ماذا سيحدث؟**
```
=== Deploying to 'zahratamal-36602'...

i  deploying hosting
i  hosting[zahratamal-36602]: beginning deploy...
i  hosting[zahratamal-36602]: found 50 files in build/web
✔  hosting[zahratamal-36602]: file upload complete
i  hosting[zahratamal-36602]: finalizing version...
✔  hosting[zahratamal-36602]: version finalized
i  hosting[zahratamal-36602]: releasing new version...
✔  hosting[zahratamal-36602]: release complete

✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/zahratamal-36602
Hosting URL: https://zahratamal-36602.web.app
```

### الخطوة 6: اختبار التطبيق

افتح الرابط في المتصفح:
- **https://zahratamal-36602.web.app**
- أو: **https://zahratamal-36602.firebaseapp.com**

### الخطوة 7: تسجيل الدخول للاختبار

**حساب مدير:**
```
البريد: admin@zahrat.sd
كلمة المرور: admin123
```

**حساب مستخدم:**
```
الرقم الفريد: ZA-2025-001234
كلمة المرور: 123456
```

---

## 3️⃣ ربط النطاق المخصص `sd.zahrat.amal`

### المتطلبات الأساسية

1. ✅ يجب أن تملك النطاق `sd.zahrat.amal`
2. ✅ الوصول لإعدادات DNS للنطاق
3. ✅ التطبيق منشور على Firebase

### الخطوة 1: إضافة النطاق في Firebase Console

1. **افتح Firebase Console:**
   https://console.firebase.google.com/project/zahratamal-36602/hosting

2. **اضغط على "Add custom domain"**

3. **أدخل النطاق:**
   ```
   sd.zahrat.amal
   ```

4. **اضغط "Continue"**

### الخطوة 2: إثبات الملكية

Firebase سيطلب منك إثبات ملكية النطاق بإحدى الطريقتين:

#### الطريقة 1: TXT Record (موصى بها)

Firebase سيعطيك سجل TXT مثل:
```
Type: TXT
Name: @
Value: firebase=zahratamal-36602
```

**أضف هذا السجل في إعدادات DNS:**
- اذهب لمزود النطاق (Namecheap, GoDaddy, إلخ)
- افتح DNS Settings
- أضف سجل TXT جديد:
  - Host/Name: `@` أو اترك فارغاً
  - Value: `firebase=zahratamal-36602`
  - TTL: Auto أو 3600

#### الطريقة 2: Meta Tag

أضف Meta Tag في `index.html`:
```html
<meta name="firebase-hosting-site-verification" content="YOUR_CODE_HERE" />
```

### الخطوة 3: إعداد DNS Records

بعد إثبات الملكية، أضف السجلات التالية:

#### A Records (IPv4)

```
Type: A
Name: @ (أو sd)
Value: 151.101.1.195
TTL: 3600

Type: A
Name: @ (أو sd)
Value: 151.101.65.195
TTL: 3600
```

#### AAAA Records (IPv6) - اختياري

```
Type: AAAA
Name: @
Value: 2a04:4e42::347
TTL: 3600

Type: AAAA
Name: @
Value: 2a04:4e42:200::347
TTL: 3600
```

### الخطوة 4: الانتظار

⏱️ **وقت الانتظار:**
- إثبات الملكية: 5-30 دقيقة
- تفعيل النطاق: 24-48 ساعة
- SSL Certificate: يتم تلقائياً بعد التفعيل

### الخطوة 5: التحقق

```bash
# تحقق من DNS Records
nslookup sd.zahrat.amal

# يجب أن ترى عناوين IP:
# 151.101.1.195
# 151.101.65.195
```

### الخطوة 6: الانتهاء ✅

بعد اكتمال الإعداد:
- ✅ النطاق `sd.zahrat.amal` سيوجه للتطبيق
- ✅ SSL Certificate (https) سيتم تفعيله تلقائياً
- ✅ التطبيق متاح على الرابط المخصص

---

## 🔄 تحديث التطبيق مستقبلاً

عند إجراء أي تعديلات على التطبيق:

### 1. بناء التطبيق من جديد

```bash
# في مجلد المشروع
flutter build web --release
```

### 2. النشر

```bash
firebase deploy --only hosting
```

### 3. التحقق

افتح الرابط:
- https://zahratamal-36602.web.app
- أو: https://sd.zahrat.amal (إذا كنت أضفت نطاق مخصص)

---

## 🛠️ استكشاف الأخطاء

### خطأ: "Firebase CLI not found"

```bash
# أعد تثبيت Firebase CLI
npm install -g firebase-tools

# أعد تشغيل Terminal
```

### خطأ: "Not authorized"

```bash
# سجّل خروج ثم دخول من جديد
firebase logout
firebase login
```

### خطأ: "Project not found"

تحقق من:
1. ملف `.firebaserc` موجود
2. يحتوي على: `"default": "zahratamal-36602"`

### خطأ: "DNS not propagating"

```bash
# تحقق من DNS
dig sd.zahrat.amal

# أو
nslookup sd.zahrat.amal

# الحل: انتظر 24-48 ساعة
```

### خطأ: "SSL Certificate pending"

- الحل: انتظر حتى ساعة بعد إعداد DNS
- Firebase يُنشئ SSL تلقائياً
- تحقق من Firebase Console: Hosting → Custom Domain

---

## 📊 معلومات المشروع

**معلومات Firebase:**
- Project ID: `zahratamal-36602`
- Region: Default (us-central1)
- Hosting URL: https://zahratamal-36602.web.app

**معلومات التطبيق:**
- اسم التطبيق: زهرة الأمل - ZahratAmal
- Package Name: sd.zahrat.amal
- Version: 1.0.0
- حجم التطبيق: 31 MB

**الخطة:**
- Spark Plan (مجاني)
- 10 GB Bandwidth/شهرياً
- 10 GB Storage
- SSL مجاني
- Custom Domain مجاني

---

## 🔐 بيانات الاختبار

**مدير النظام:**
```
البريد الإلكتروني: admin@zahrat.sd
كلمة المرور: admin123
```

**مستخدم عادي:**
```
البريد: أي بريد إلكتروني
الهاتف: أي رقم
الرقم الفريد: ZA-2025-001234
كلمة المرور: 123456
```

---

## 📞 الدعم الفني

**روابط مفيدة:**
- Firebase Console: https://console.firebase.google.com/
- Firebase Hosting Docs: https://firebase.google.com/docs/hosting
- Custom Domain Guide: https://firebase.google.com/docs/hosting/custom-domain
- Firebase CLI Reference: https://firebase.google.com/docs/cli

**مشاكل شائعة:**
- Firebase Status: https://status.firebase.google.com/
- Stack Overflow: https://stackoverflow.com/questions/tagged/firebase-hosting

---

## ✅ قائمة التحقق النهائية

قبل النشر:
- [ ] تم تثبيت Firebase CLI
- [ ] تم تسجيل الدخول: `firebase login`
- [ ] تم تحميل المشروع كاملاً
- [ ] ملف `firebase.json` موجود
- [ ] ملف `.firebaserc` يحتوي على project ID
- [ ] مجلد `build/web` موجود وليس فارغاً

بعد النشر:
- [ ] الرابط يعمل: https://zahratamal-36602.web.app
- [ ] تسجيل الدخول يعمل
- [ ] جميع الصفحات تعمل بشكل صحيح
- [ ] الصور والأيقونات تظهر
- [ ] التطبيق يعمل على الموبايل

للنطاق المخصص:
- [ ] تم إضافة النطاق في Firebase Console
- [ ] تم إثبات الملكية (TXT Record)
- [ ] تم إضافة A Records
- [ ] DNS propagation اكتمل (24-48 ساعة)
- [ ] SSL Certificate نشط
- [ ] النطاق المخصص يعمل بشكل كامل

---

**آخر تحديث:** 17 ديسمبر 2025  
**الإصدار:** 1.0.0  
**المشروع:** زهرة الأمل - ZahratAmal
