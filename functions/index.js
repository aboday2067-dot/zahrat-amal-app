const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// ===== 🤖 AI Developer Functions =====
const aiDeveloper = require('./ai_developer');
exports.processAIDevelopmentRequest = aiDeveloper.processAIDevelopmentRequest;
exports.triggerAIProcessing = aiDeveloper.triggerAIProcessing;

// ===== مثال 1: إرسال رسالة ترحيب عند تسجيل مستخدم جديد =====
exports.sendWelcomeEmail = functions.auth.user().onCreate(async (user) => {
  const email = user.email;
  const displayName = user.displayName || 'عميل جديد';

  console.log(`مستخدم جديد: ${displayName} (${email})`);

  // هنا يمكنك إضافة كود إرسال البريد الإلكتروني
  // مثلاً باستخدام SendGrid أو Nodemailer

  return null;
});

// ===== مثال 2: حفظ بيانات إضافية في Firestore عند التسجيل =====
exports.createUserProfile = functions.auth.user().onCreate(async (user) => {
  const uid = user.uid;
  const email = user.email;
  const displayName = user.displayName || 'مستخدم جديد';

  try {
    await admin.firestore().collection('users').doc(uid).set({
      email: email,
      displayName: displayName,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      userType: 'buyer',
      isActive: true,
    }, { merge: true });

    console.log(`✅ تم إنشاء ملف تعريف للمستخدم: ${uid}`);
  } catch (error) {
    console.error('خطأ في إنشاء الملف التعريفي:', error);
  }

  return null;
});

// ===== مثال 3: تحديث إحصائيات عند إنشاء طلب جديد =====
exports.updateOrderStats = functions.firestore
  .document('orders/{orderId}')
  .onCreate(async (snap, context) => {
    const order = snap.data();
    const merchantId = order.merchantId;

    if (!merchantId) return null;

    try {
      // تحديث عدد الطلبات للتاجر
      const merchantRef = admin.firestore().collection('merchants').doc(merchantId);
      await merchantRef.update({
        totalOrders: admin.firestore.FieldValue.increment(1),
        lastOrderDate: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`✅ تم تحديث إحصائيات التاجر: ${merchantId}`);
    } catch (error) {
      console.error('خطأ في تحديث الإحصائيات:', error);
    }

    return null;
  });

// ===== مثال 4: إرسال إشعار عند تحديث حالة الطلب =====
exports.notifyOrderStatusChange = functions.firestore
  .document('orders/{orderId}')
  .onUpdate(async (change, context) => {
    const oldStatus = change.before.data().status;
    const newStatus = change.after.data().status;

    if (oldStatus === newStatus) return null;

    const orderId = context.params.orderId;
    const userId = change.after.data().userId;

    console.log(`📦 تحديث حالة الطلب ${orderId}: ${oldStatus} → ${newStatus}`);

    // هنا يمكنك إرسال إشعار Push Notification
    // أو إرسال SMS/Email

    return null;
  });

// ===== مثال 5: API Endpoint لحساب الإحصائيات =====
exports.getStatistics = functions.https.onRequest(async (req, res) => {
  try {
    const ordersSnapshot = await admin.firestore().collection('orders').get();
    const usersSnapshot = await admin.firestore().collection('users').get();

    const stats = {
      totalOrders: ordersSnapshot.size,
      totalUsers: usersSnapshot.size,
      timestamp: new Date().toISOString(),
    };

    res.json(stats);
  } catch (error) {
    console.error('خطأ في جلب الإحصائيات:', error);
    res.status(500).json({ error: 'فشل في جلب الإحصائيات' });
  }
});

// ===== مثال 6: Scheduled Function - تشغيل يومي =====
exports.dailyCleanup = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    console.log('🧹 تنظيف يومي...');

    // حذف الطلبات الملغاة القديمة (أكبر من 30 يوم)
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const oldOrdersSnapshot = await admin.firestore()
      .collection('orders')
      .where('status', '==', 'cancelled')
      .where('createdAt', '<', thirtyDaysAgo)
      .get();

    const batch = admin.firestore().batch();
    oldOrdersSnapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    console.log(`✅ تم حذف ${oldOrdersSnapshot.size} طلب قديم`);

    return null;
  });
