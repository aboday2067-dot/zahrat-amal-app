# 🔥 دليل Firebase Cloud Functions - تطبيق زهرة الأمل

## ✅ **تم إعداد Cloud Functions بنجاح!**

---

## 📁 **البنية الحالية:**

```
flutter_app/
├── firebase.json          ✅ محدث (Hosting + Functions)
├── functions/
│   ├── package.json       ✅ تم إنشاؤه
│   ├── index.js           ✅ 6 أمثلة جاهزة
│   └── node_modules/      ⏳ سيتم تثبيته
```

---

## 🚀 **الأمثلة الموجودة في index.js:**

### **1️⃣ sendWelcomeEmail**
- **المحفز:** عند تسجيل مستخدم جديد
- **الوظيفة:** إرسال رسالة ترحيب
- **الاستخدام:** تلقائي

### **2️⃣ createUserProfile**
- **المحفز:** عند تسجيل مستخدم جديد
- **الوظيفة:** إنشاء ملف تعريفي في Firestore
- **الاستخدام:** تلقائي

### **3️⃣ updateOrderStats**
- **المحفز:** عند إنشاء طلب جديد
- **الوظيفة:** تحديث إحصائيات التاجر
- **الاستخدام:** تلقائي

### **4️⃣ notifyOrderStatusChange**
- **المحفز:** عند تحديث حالة الطلب
- **الوظيفة:** إرسال إشعارات
- **الاستخدام:** تلقائي

### **5️⃣ getStatistics**
- **المحفز:** HTTP Request
- **الوظيفة:** API لجلب الإحصائيات
- **الاستخدام:** يدوي
- **URL:** `https://us-central1-zahratamal-36602.cloudfunctions.net/getStatistics`

### **6️⃣ dailyCleanup**
- **المحفز:** كل 24 ساعة (مجدول)
- **الوظيفة:** حذف الطلبات القديمة
- **الاستخدام:** تلقائي

---

## 📦 **خطوات التثبيت والنشر:**

### **الخطوة 1: تثبيت Dependencies**

```bash
cd /home/user/flutter_app/functions
npm install
```

**سيتم تثبيت:**
- `firebase-functions` (^5.0.0)
- `firebase-admin` (^12.0.0)
- `firebase-functions-test` (^3.1.0)

---

### **الخطوة 2: تسجيل الدخول إلى Firebase**

```bash
cd /home/user/flutter_app
firebase login
```

**أو إذا كنت في بيئة CI/CD:**
```bash
firebase login --no-localhost
```

---

### **الخطوة 3: ربط المشروع**

```bash
cd /home/user/flutter_app
firebase use zahratamal-36602
```

---

### **الخطوة 4: نشر Functions**

```bash
cd /home/user/flutter_app
firebase deploy --only functions
```

**أو نشر function واحدة:**
```bash
firebase deploy --only functions:sendWelcomeEmail
```

---

## 🧪 **الاختبار المحلي:**

### **تشغيل Functions محلياً:**

```bash
cd /home/user/flutter_app/functions
npm run serve
```

**النتيجة:**
- Functions Emulator سيعمل على: `http://localhost:5001`
- يمكنك اختبار HTTP Functions مباشرة

---

### **اختبار HTTP Function:**

```bash
curl http://localhost:5001/zahratamal-36602/us-central1/getStatistics
```

---

## 📊 **بعد النشر:**

### **رؤية Logs:**

```bash
firebase functions:log
```

**أو عبر Firebase Console:**
```
Functions → Logs
```

---

### **استخدام HTTP Function في Flutter:**

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> getStatistics() async {
  final url = Uri.parse(
    'https://us-central1-zahratamal-36602.cloudfunctions.net/getStatistics'
  );
  
  final response = await http.get(url);
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('فشل في جلب الإحصائيات');
  }
}
```

---

## ⚙️ **إعدادات متقدمة:**

### **تحديد Region:**

```javascript
exports.myFunction = functions.region('europe-west1').https.onRequest(...);
```

---

### **إضافة Environment Variables:**

```bash
firebase functions:config:set sendgrid.key="YOUR_API_KEY"
```

**استخدامها في الكود:**
```javascript
const sendgridKey = functions.config().sendgrid.key;
```

---

### **تحديد Memory وTimeout:**

```javascript
exports.heavyFunction = functions
  .runWith({
    timeoutSeconds: 300,
    memory: '1GB'
  })
  .https.onRequest(...);
```

---

## 💰 **التكلفة:**

### **Free Tier (Spark Plan):**
- ✅ 125,000 استدعاء/شهر
- ✅ 40,000 GB-ثانية/شهر
- ✅ 40,000 CPU-ثانية/شهر
- ✅ 5GB نقل بيانات خارجية/شهر

### **Blaze Plan (الدفع حسب الاستخدام):**
- الأسعار تبدأ بعد Free Tier
- مناسب للتطبيقات الكبيرة

---

## 🚨 **ملاحظات مهمة:**

### **1. Firebase Admin SDK في Functions:**
```javascript
const admin = require('firebase-admin');
admin.initializeApp(); // تلقائي في Functions
```

### **2. Firestore في Functions:**
```javascript
const db = admin.firestore();
await db.collection('users').doc(uid).set(data);
```

### **3. Authentication في Functions:**
```javascript
const user = await admin.auth().getUser(uid);
```

---

## 🎯 **متى تستخدم Cloud Functions:**

### ✅ **يُنصح بها لـ:**
- إرسال إشعارات تلقائية
- معالجة الطلبات في الخلفية
- تحديث البيانات المعقدة
- APIs خارجية (SendGrid, Twilio, etc.)
- مهام مجدولة (Daily/Weekly tasks)

### ⚠️ **غير ضرورية لـ:**
- عمليات CRUD بسيطة (استخدم Firestore مباشرة)
- UI Logic (يتم في Flutter)
- Authentication الأساسية (Firebase Auth كافي)

---

## 📞 **الدعم والموارد:**

### **التوثيق الرسمي:**
- https://firebase.google.com/docs/functions

### **أمثلة Functions:**
- https://github.com/firebase/functions-samples

### **الأسعار:**
- https://firebase.google.com/pricing

---

## 🎉 **الخلاصة:**

### ✅ **ما تم إعداده:**
1. ✅ مجلد `functions/` مع `package.json`
2. ✅ ملف `index.js` مع 6 أمثلة جاهزة
3. ✅ `firebase.json` محدث

### ⏳ **الخطوات التالية:**
1. ⏳ `cd /home/user/flutter_app/functions && npm install`
2. ⏳ `firebase login`
3. ⏳ `firebase use zahratamal-36602`
4. ⏳ `firebase deploy --only functions`

---

**💡 هل تحتاج Cloud Functions الآن؟**
- **لا:** يمكنك تجاهل هذا الملف والاستمرار مع Firestore + Auth فقط
- **نعم:** اتبع الخطوات أعلاه لنشر Functions

**🚀 التطبيق يعمل بدون Functions! هذا إضافة اختيارية للميزات المتقدمة.**
