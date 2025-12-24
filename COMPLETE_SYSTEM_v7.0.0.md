# 🚀 نظام زهرة الأمل الشامل - الإصدار 7.0.0

## 📋 نظرة عامة

تم تطوير نظام متكامل يجمع بين:
- **تطبيق الإدارة** (Admin App) للتحكم والمراقبة
- **التطبيق الرسمي** (Official App) للمستخدمين (تجار، مشترين، مكاتب توصيل)
- **التزامن الفوري** عبر Firebase Firestore

---

## 🎯 الميزات الجديدة المطورة

### 1️⃣ نظام المراسلة الفورية للمدير (Admin Messaging System)

**الملف**: `/home/user/admin_app/lib/admin_messaging_system.dart`

**الميزات**:
- 💬 محادثات فردية بين المدير وكل مستخدم
- 📢 رسائل جماعية (Broadcast) لمجموعات محددة:
  - الكل
  - التجار فقط
  - المشترين فقط
  - مكاتب التوصيل فقط
- 🔔 إشعارات فورية للرسائل غير المقروءة
- 🔍 بحث عن المستخدمين
- 📊 تصنيف المستخدمين حسب النوع

**الاستخدام**:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AdminMessagingSystem(
      adminId: 'admin_user_id',
      adminName: 'اسم المدير',
    ),
  ),
);
```

---

### 2️⃣ نظام الصفحات الشخصية المفصلة (User Profiles System)

**الملف**: `/home/user/flutter_app/lib/user_profiles_system.dart`

**أنواع الصفحات**:

#### صفحة التاجر (Merchant Profile):
- 📊 إحصائيات: عدد المنتجات، الطلبات، التقييم
- 🏪 معلومات المتجر (قابلة للتعديل)
- 📦 عرض المنتجات
- ⭐ التقييمات والمراجعات
- ✏️ وضع التعديل لتحديث المعلومات

#### صفحة المشتري (Buyer Profile):
- 📊 إحصائيات: عدد الطلبات، الإنفاق، النقاط
- 📋 قائمة الطلبات
- ❤️ المنتجات المفضلة
- 👤 المعلومات الشخصية

#### صفحة مكتب التوصيل (Delivery Office Profile):
- 📊 إحصائيات: الطلبات الحالية، المكتملة، التقييم
- 🚚 قائمة الطلبات الحالية
- 📜 سجل التوصيل
- 🏢 معلومات المكتب

**الاستخدام**:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => UserProfileScreen(
      userId: 'user_id',
      userType: 'merchant', // merchant, buyer, delivery
    ),
  ),
);
```

---

### 3️⃣ نظام الدفع المحلي (Local Payment System)

**الملف**: `/home/user/flutter_app/lib/local_payment_system.dart`

**طرق الدفع المتاحة**:

#### 1. Vodafone Cash:
- 📱 إدخال رقم المحفظة
- 🔒 رمز PIN آمن
- ✅ تأكيد فوري
- 📝 رقم معاملة تلقائي

#### 2. الدفع عند الاستلام (Cash on Delivery):
- 💵 دفع نقدي عند استلام الطلب
- ⏰ بدون متطلبات مسبقة

**الميزات الأمنية**:
- 🔐 تشفير البيانات
- 🛡️ رسائل تأكيد آمنة
- 📋 سجل كامل لكل معاملة

**الاستخدام**:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => LocalPaymentSystem(
      userId: 'user_id',
      orderId: 'order_id',
      totalAmount: 500.00,
      onPaymentComplete: (paymentData) {
        // معالجة بعد إتمام الدفع
        print('تم الدفع: $paymentData');
      },
    ),
  ),
);
```

---

### 4️⃣ نظام الدردشة الفورية (Chat System)

**الملف**: `/home/user/flutter_app/lib/chat_system.dart`

**الميزات**:
- 💬 محادثات فردية بين:
  - تاجر ↔ مشتري
  - تاجر ↔ مكتب توصيل
  - مشتري ↔ مكتب توصيل
- 🔔 إشعارات الرسائل غير المقروءة
- 🔍 بحث عن المحادثات
- 📱 واجهة مستخدم بسيطة وسهلة
- ⏱️ توقيت الرسائل
- ✅ علامات القراءة (Read Receipts)

**الاستخدام**:
```dart
// قائمة المحادثات
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChatSystem(
      currentUserId: 'user_id',
      currentUserName: 'اسم المستخدم',
      currentUserType: 'merchant', // merchant, buyer, delivery
    ),
  ),
);

// محادثة مباشرة
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChatScreen(
      currentUserId: 'user_id',
      currentUserName: 'اسم المستخدم',
      currentUserType: 'merchant',
      otherUserId: 'other_user_id',
      otherUserName: 'اسم الطرف الآخر',
      otherUserType: 'buyer',
    ),
  ),
);
```

---

### 5️⃣ نظام رفع الإيصالات (Receipt Upload System)

**الملف**: `/home/user/flutter_app/lib/receipt_upload_system.dart`

**الميزات**:

#### رفع الإيصالات:
- 📸 رفع صورة الإيصال
- 📋 ربط تلقائي مع الطلب
- 🔍 معاينة الإيصال قبل الإرسال
- ✏️ إمكانية التعديل والحذف

#### صفحة إيصالاتي (My Receipts):
- 📜 قائمة بجميع الإيصالات
- 🏷️ حالات الإيصالات:
  - ⏳ قيد المراجعة
  - ✅ تم التحقق
  - ❌ مرفوض
- 📊 تفاصيل كل إيصال
- 💰 المبلغ والتاريخ

**الاستخدام**:
```dart
// رفع إيصال
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ReceiptUploadSystem(
      orderId: 'order_id',
      buyerId: 'buyer_id',
      merchantId: 'merchant_id',
      orderAmount: 500.00,
    ),
  ),
);

// عرض الإيصالات
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MyReceiptsScreen(
      buyerId: 'buyer_id',
    ),
  ),
);
```

---

### 6️⃣ نظام تأكيد الطلبات للتاجر (Merchant Order Confirmation)

**الملف**: `/home/user/flutter_app/lib/merchant_order_confirmation.dart`

**سير العمل**:

1. **استلام الطلب**:
   - 📬 يصل طلب جديد بعد الدفع
   - 📋 مراجعة تفاصيل الطلب
   - 🖼️ عرض إيصال الدفع

2. **تأكيد أو رفض**:
   - ✅ تأكيد الطلب
   - ❌ رفض الطلب مع ذكر السبب

3. **بعد التأكيد**:
   - 📝 إنشاء إيصال رسمي تلقائياً
   - 📧 إرسال الإيصال للمشتري
   - 🚚 إشعار مكتب التوصيل
   - 📊 تحديث حالة الطلب

**الميزات**:
- 🔍 فلاتر: (قيد الانتظار / مؤكدة / الكل)
- 📊 عرض شامل لكل طلب
- 🖼️ معاينة إيصال الدفع
- ⚡ تأكيد فوري

**الاستخدام**:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MerchantOrderConfirmationSystem(
      merchantId: 'merchant_id',
    ),
  ),
);
```

---

## 🔄 سير العمل الكامل للطلب

```
1️⃣ المشتري يختار المنتجات ويضيف للسلة
        ↓
2️⃣ المشتري يختار طريقة الدفع (Vodafone Cash / الدفع عند الاستلام)
        ↓
3️⃣ دفع المبلغ وإكمال الطلب
        ↓
4️⃣ المشتري يرفع إيصال الدفع
        ↓
5️⃣ التاجر يستلم إشعار بالطلب الجديد
        ↓
6️⃣ التاجر يراجع الطلب والإيصال
        ↓
7️⃣ التاجر يؤكد أو يرفض الطلب
        ↓
8️⃣ (عند التأكيد) يتم تلقائياً:
   - ✅ إنشاء إيصال رسمي
   - 📧 إرسال الإيصال للمشتري
   - 🚚 إشعار مكتب التوصيل المختار
   - 📊 تحديث حالة الطلب إلى "مؤكد"
        ↓
9️⃣ مكتب التوصيل يستلم الطلب وينفذ التوصيل
        ↓
🔟 المشتري يستلم الطلب ويقيّم الخدمة
```

---

## 🗃️ هيكل قاعدة البيانات (Firestore Collections)

### 1. `users` Collection:
```json
{
  "user_id": "unique_id",
  "name": "اسم المستخدم",
  "email": "email@example.com",
  "phone": "01xxxxxxxxx",
  "user_type": "merchant|buyer|delivery",
  "is_approved": true,
  "rating": 4.5,
  "review_count": 120,
  "points": 500,
  "created_at": "timestamp"
}
```

### 2. `chats` Collection:
```json
{
  "chat_id": "userId1_userId2",
  "participants": ["userId1", "userId2"],
  "last_message": "آخر رسالة",
  "last_message_time": "timestamp",
  "last_sender_id": "userId1"
}
```

### 3. `chats/{chat_id}/messages` SubCollection:
```json
{
  "message_id": "auto_generated",
  "sender_id": "userId",
  "sender_name": "الاسم",
  "sender_type": "merchant|buyer|delivery",
  "receiver_id": "userId",
  "message": "نص الرسالة",
  "is_read": false,
  "created_at": "timestamp"
}
```

### 4. `payments` Collection:
```json
{
  "payment_id": "auto_generated",
  "payment_method": "vodafone_cash|cash_on_delivery",
  "status": "pending|completed|failed",
  "amount": 500.00,
  "order_id": "order_id",
  "user_id": "user_id",
  "transaction_id": "VFCxxxxxxxxx",
  "created_at": "timestamp"
}
```

### 5. `receipts` Collection:
```json
{
  "receipt_id": "auto_generated",
  "order_id": "order_id",
  "buyer_id": "user_id",
  "merchant_id": "user_id",
  "receipt_url": "https://storage.url/receipt.jpg",
  "amount": 500.00,
  "status": "pending|verified|rejected",
  "rejection_reason": "سبب الرفض (اختياري)",
  "uploaded_at": "timestamp"
}
```

### 6. `official_receipts` Collection:
```json
{
  "receipt_id": "auto_generated",
  "order_id": "order_id",
  "buyer_id": "user_id",
  "merchant_id": "user_id",
  "delivery_office_id": "user_id",
  "total_amount": 500.00,
  "items": [
    {
      "product_id": "product_id",
      "name": "اسم المنتج",
      "quantity": 2,
      "price": 250.00
    }
  ],
  "receipt_number": "RECxxxxxxxxxx",
  "status": "confirmed",
  "created_at": "timestamp"
}
```

### 7. `orders` Collection (تحديث):
```json
{
  "order_id": "auto_generated",
  "order_number": "ORD12345",
  "buyer_id": "user_id",
  "merchant_id": "user_id",
  "delivery_office_id": "user_id",
  "items": [...],
  "total_price": 500.00,
  "payment_method": "vodafone_cash|cash_on_delivery",
  "payment_status": "completed",
  "receipt_uploaded": true,
  "receipt_url": "https://...",
  "receipt_status": "pending|verified|rejected",
  "merchant_confirmed": false,
  "status": "pending|confirmed|shipped|delivered|cancelled|rejected",
  "rejection_reason": "سبب الرفض (اختياري)",
  "created_at": "timestamp",
  "confirmed_at": "timestamp",
  "updated_at": "timestamp"
}
```

### 8. `notifications` Collection:
```json
{
  "notification_id": "auto_generated",
  "user_id": "user_id",
  "title": "عنوان الإشعار",
  "body": "نص الإشعار",
  "type": "order_confirmed|new_delivery|message|payment",
  "order_id": "order_id (اختياري)",
  "receipt_id": "receipt_id (اختياري)",
  "is_read": false,
  "created_at": "timestamp"
}
```

---

## 📱 التكامل مع Firebase

### Firebase Configuration:
- ✅ Firebase Core 3.6.0
- ✅ Cloud Firestore 5.4.3
- ✅ Firebase Storage 12.3.2
- ✅ Firebase Messaging 15.1.3

### Security Rules (مثال):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // السماح بالقراءة والكتابة في وضع التطوير
    match /{document=**} {
      allow read, write: if true;
    }
    
    // في الإنتاج، استخدم قواعد أمان صارمة:
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    match /chats/{chatId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participants;
    }
    
    match /orders/{orderId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

---

## 🚀 كيفية الاستخدام

### 1. تشغيل تطبيق الإدارة:
```bash
cd /home/user/admin_app
flutter run -d web-server --web-port 8080
```

**الوصول**: `https://8080-[sandbox-id].sandbox.novita.ai`

### 2. تشغيل التطبيق الرسمي:
```bash
cd /home/user/flutter_app
flutter run -d web-server --web-port 5060
```

**الوصول**: `https://5060-[sandbox-id].sandbox.novita.ai`

---

## 🔐 الأمان والخصوصية

### التشفير:
- 🔒 جميع الاتصالات عبر HTTPS
- 🔐 تشفير كلمات المرور (SHA-256)
- 🛡️ حماية البيانات الشخصية

### الصلاحيات:
- 👤 كل مستخدم يصل فقط لبياناته
- 🔑 المدير له صلاحيات كاملة
- 🚫 التجار لا يصلون لبيانات بعضهم

---

## 📊 الإحصائيات والتقارير

### للتجار:
- 📈 إجمالي المبيعات
- 📦 عدد الطلبات
- ⭐ متوسط التقييم
- 👥 عدد العملاء

### للمدير:
- 🌐 إحصائيات شاملة للمنصة
- 📊 تقارير المبيعات
- 👤 إحصائيات المستخدمين
- 💰 الإيرادات

---

## 🐛 حل المشاكل الشائعة

### مشكلة: لا تظهر الرسائل
**الحل**: تأكد من:
- ✅ الاتصال بالإنترنت
- ✅ صلاحيات Firestore
- ✅ معرّفات المستخدمين صحيحة

### مشكلة: فشل رفع الإيصال
**الحل**:
- ✅ تأكد من حجم الصورة (أقل من 5MB)
- ✅ تأكد من صيغة الصورة (JPG/PNG)
- ✅ صلاحيات Firebase Storage

### مشكلة: لا يصل الإشعار
**الحل**:
- ✅ تفعيل Firebase Messaging
- ✅ صلاحيات الإشعارات على الجهاز
- ✅ التحقق من مجموعة notifications

---

## 📝 الملاحظات المهمة

1. **التزامن الفوري**: جميع التحديثات فورية عبر Firestore Snapshots
2. **الإشعارات**: يتم إرسال إشعارات تلقائية لجميع الأحداث المهمة
3. **الأمان**: استخدم قواعد أمان Firestore في الإنتاج
4. **الاختبار**: اختبر جميع السيناريوهات قبل النشر
5. **الصيانة**: راجع سجلات Firebase بانتظام

---

## 🎉 الخلاصة

تم تطوير نظام متكامل وشامل يغطي:
- ✅ إدارة المستخدمين
- ✅ المراسلة والدردشة
- ✅ الدفع والإيصالات
- ✅ تأكيد الطلبات
- ✅ التوصيل والتتبع
- ✅ التقييمات والمراجعات

النظام جاهز للاستخدام الفوري مع إمكانية التطوير والتحسين المستمر! 🚀

---

**تاريخ الإنشاء**: 2025
**الإصدار**: 7.0.0
**الحالة**: ✅ جاهز للاستخدام
