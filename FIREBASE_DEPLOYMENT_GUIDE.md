# 🚀 دليل النشر على Firebase Hosting

## 📋 **ما تم إعداده:**

✅ **ملفات التكوين:**
- `/home/user/flutter_app/.firebaserc` - تكوين المشروع
- `/home/user/flutter_app/firebase.json` - إعدادات Hosting للتطبيق الرسمي
- `/home/user/admin_app/.firebaserc` - تكوين المشروع
- `/home/user/admin_app/firebase.json` - إعدادات Hosting لتطبيق الإدارة

✅ **سكربتات النشر:**
- `/home/user/scripts/deploy_to_firebase.sh` - نشر كامل (أول مرة)
- `/home/user/scripts/quick_update.sh` - تحديث سريع

---

## 🔐 **الخطوة الأولى: الحصول على Firebase Token**

### **الطريقة 1: من المتصفح (الأسهل)**

1. **افتح متصفحك** وشغل الأمر التالي في terminal خارجي:
   ```bash
   firebase login:ci
   ```

2. **سيفتح المتصفح تلقائياً**
   - سجل دخول بحساب Google المرتبط بـ Firebase
   - اختر مشروع `zahratamal-36602`
   - وافق على الأذونات

3. **انسخ الـ Token** من Terminal
   - سيظهر شيء مثل: `1//0abcdefgh...`

4. **احفظ الـ Token** في متغير بيئة:
   ```bash
   export FIREBASE_TOKEN='1//0abcdefgh...'
   ```

### **الطريقة 2: باستخدام Service Account (للأتمتة)**

إذا كنت تريد أتمتة كاملة:

1. **افتح Firebase Console:**
   ```
   https://console.firebase.google.com/project/zahratamal-36602/settings/serviceaccounts/adminsdk
   ```

2. **اضغط "Generate new private key"**

3. **حمّل الملف** وضعه في:
   ```
   /home/user/firebase-deployment-key.json
   ```

4. **استخدمه:**
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="/home/user/firebase-deployment-key.json"
   ```

---

## 🚀 **الخطوة الثانية: النشر الأول**

### **الطريقة 1: باستخدام Token**

```bash
# 1. تعيين Token
export FIREBASE_TOKEN='your-token-here'

# 2. تشغيل سكربت النشر
/home/user/scripts/deploy_to_firebase.sh
```

### **الطريقة 2: تسجيل دخول تفاعلي**

```bash
# إذا لم يكن لديك Token، السكربت سيطلب تسجيل الدخول
/home/user/scripts/deploy_to_firebase.sh
```

---

## 🔄 **التحديثات اليومية (Automated Updates)**

### **للتحديث السريع:**

```bash
# تشغيل سكربت التحديث السريع
/home/user/scripts/quick_update.sh
```

**سيسألك:**
```
اختر التطبيق للتحديث:
  1) التطبيق الرسمي
  2) تطبيق الإدارة
  3) كلاهما
```

### **أتمتة التحديثات:**

يمكنك إعداد Cron Job للتحديث التلقائي:

```bash
# فتح crontab
crontab -e

# إضافة سطر للتحديث اليومي الساعة 2 صباحاً
0 2 * * * /home/user/scripts/deploy_to_firebase.sh
```

---

## 🔗 **الروابط الثابتة (بعد النشر):**

### **التطبيق الرسمي:**
```
https://zahratamal-36602.web.app
https://zahratamal-36602.firebaseapp.com
```

### **تطبيق الإدارة:**
```
https://zahratamal-admin.web.app
https://zahratamal-admin.firebaseapp.com
```

**ملاحظة:** الروابط ستكون متاحة فقط **بعد النشر الأول**.

---

## 📊 **إدارة المواقع:**

### **عرض جميع المواقع:**
```bash
firebase hosting:sites:list
```

### **إنشاء موقع جديد:**
```bash
firebase hosting:sites:create site-name
```

### **حذف موقع:**
```bash
firebase hosting:sites:delete site-name
```

---

## 🌐 **ربط دومين مخصص:**

### **الخطوات:**

1. **افتح Firebase Console:**
   ```
   https://console.firebase.google.com/project/zahratamal-36602/hosting/sites
   ```

2. **اختر الموقع** (التطبيق الرسمي أو الإدارة)

3. **اضغط "Add custom domain"**

4. **أدخل الدومين:**
   - للتطبيق الرسمي: `app.your-domain.com`
   - لتطبيق الإدارة: `admin.your-domain.com`

5. **أضف سجلات DNS** عند مزود الدومين:
   ```
   Type: A
   Name: app (أو admin)
   Value: [IP من Firebase]
   ```

6. **انتظر التفعيل** (قد يستغرق حتى 24 ساعة)

---

## 🔍 **استكشاف الأخطاء:**

### **خطأ: "Permission denied"**
```bash
# الحل: تأكد من Token أو سجل دخول
firebase login
```

### **خطأ: "Site not found"**
```bash
# الحل: أنشئ الموقع أولاً
firebase hosting:sites:create zahratamal-admin
```

### **خطأ: "Build failed"**
```bash
# الحل: تأكد من بناء Flutter أولاً
cd /home/user/flutter_app
flutter build web --release
```

### **خطأ: "No Firebase token"**
```bash
# الحل: احصل على Token
firebase login:ci
export FIREBASE_TOKEN='your-token'
```

---

## 💡 **نصائح للتحديثات:**

### **تحديث بدون توقف (Zero-downtime):**
Firebase Hosting يدعم التحديث بدون توقف تلقائياً.

### **التراجع عن نشر (Rollback):**
```bash
# عرض آخر النشرات
firebase hosting:clone SOURCE_SITE_ID:SOURCE_CHANNEL TARGET_SITE_ID:live

# أو من Firebase Console
# Hosting → Release History → Restore
```

### **معاينة قبل النشر:**
```bash
# معاينة محلية
firebase serve --only hosting

# معاينة على قناة مؤقتة
firebase hosting:channel:deploy preview
```

---

## 📊 **مراقبة الأداء:**

### **عرض إحصائيات الاستخدام:**
```
https://console.firebase.google.com/project/zahratamal-36602/analytics
```

### **عرض أخطاء التطبيق:**
```
https://console.firebase.google.com/project/zahratamal-36602/crashlytics
```

---

## 🎯 **الأوامر السريعة:**

```bash
# نشر كامل (أول مرة)
/home/user/scripts/deploy_to_firebase.sh

# تحديث سريع
/home/user/scripts/quick_update.sh

# نشر التطبيق الرسمي فقط
cd /home/user/flutter_app && firebase deploy --only hosting

# نشر تطبيق الإدارة فقط
cd /home/user/admin_app && firebase deploy --only hosting

# معاينة محلية
cd /home/user/flutter_app && firebase serve --only hosting
```

---

## 📞 **الدعم:**

- Firebase Documentation: https://firebase.google.com/docs/hosting
- Firebase Console: https://console.firebase.google.com/project/zahratamal-36602
- Support: https://firebase.google.com/support

---

## ✅ **قائمة التحقق:**

قبل النشر الأول:
- [ ] حصلت على Firebase Token
- [ ] بنيت التطبيقات (`flutter build web --release`)
- [ ] اختبرت التطبيقات محلياً
- [ ] راجعت ملفات التكوين

بعد النشر:
- [ ] اختبرت الروابط الجديدة
- [ ] تأكدت من عمل جميع المميزات
- [ ] أضفت الروابط للمفضلة
- [ ] أعددت نظام التحديثات التلقائية

---

**تم إعداد كل شيء! جاهز للنشر الآن** 🚀
