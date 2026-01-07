const functions = require('firebase-functions');
const admin = require('firebase-admin');
const bcrypt = require('bcrypt');

admin.initializeApp();

// ============================================
// 🔐 Twilio Configuration
// ============================================
const TWILIO_ACCOUNT_SID = 'AC5e42a6c203c0310632a44713e0018a7'; // ✅ Test Credentials
const TWILIO_AUTH_TOKEN = '46e18850a5bdb2c3d492879558dae77f';   // ✅ Test Credentials
const TWILIO_WHATSAPP_NUMBER = 'whatsapp:+14155238886'; // Twilio Sandbox Number

// Initialize Twilio Client
const twilio = require('twilio')(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN);

// ============================================
// 📞 Function 1: Send WhatsApp OTP (Twilio)
// ============================================
exports.sendWhatsAppOTP = functions.https.onCall(async (data, context) => {
  try {
    const { phoneNumber } = data;

    if (!phoneNumber) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'رقم الهاتف مطلوب'
      );
    }

    // تنظيف رقم الهاتف وتحويله للصيغة الدولية
    let formattedPhone = phoneNumber;
    if (phoneNumber.startsWith('0')) {
      formattedPhone = '+249' + phoneNumber.substring(1);
    } else if (!phoneNumber.startsWith('+')) {
      formattedPhone = '+249' + phoneNumber;
    }

    console.log('📞 Sending OTP to:', formattedPhone);

    // 1️⃣ التحقق من معدل الطلبات (Rate Limiting)
    const now = Date.now();
    const otpRef = admin.firestore().collection('otp').doc(formattedPhone);
    const otpDoc = await otpRef.get();

    if (otpDoc.exists) {
      const lastRequestTime = otpDoc.data().createdAt.toMillis();
      const timeSinceLastRequest = now - lastRequestTime;

      // يجب الانتظار 3 دقائق بين الطلبات
      if (timeSinceLastRequest < 3 * 60 * 1000) {
        throw new functions.https.HttpsError(
          'resource-exhausted',
          'يرجى الانتظار 3 دقائق قبل إعادة الطلب'
        );
      }
    }

    // 2️⃣ توليد OTP عشوائي (6 أرقام)
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    console.log('🔑 Generated OTP:', otp);

    // 3️⃣ تشفير OTP
    const hashedOTP = await bcrypt.hash(otp, 10);

    // 4️⃣ حفظ OTP في Firestore
    const expiresAt = admin.firestore.Timestamp.fromMillis(
      now + 2 * 60 * 1000 // صلاحية دقيقتين
    );

    await otpRef.set({
      otp: hashedOTP,
      createdAt: admin.firestore.Timestamp.now(),
      expiresAt: expiresAt,
      attempts: 0,
      phoneNumber: formattedPhone,
    });

    // 5️⃣ إرسال OTP عبر Twilio WhatsApp
    const message = await twilio.messages.create({
      from: TWILIO_WHATSAPP_NUMBER,
      to: `whatsapp:${formattedPhone}`,
      body: `🌸 زهرة الأمل - Zahrat Amal\n\nرمز التحقق الخاص بك:\n${otp}\n\nصالح لمدة دقيقتين فقط.\n\n⚠️ لا تشارك هذا الرمز مع أي شخص.`
    });

    console.log('✅ WhatsApp message sent:', message.sid);

    return {
      success: true,
      message: 'تم إرسال رمز التحقق عبر WhatsApp',
      messageSid: message.sid,
    };

  } catch (error) {
    console.error('❌ Error sending OTP:', error);
    
    if (error.code === 21608) {
      throw new functions.https.HttpsError(
        'failed-precondition',
        'رقم WhatsApp غير مُفعّل في Sandbox. يرجى إرسال "join <code>" إلى الرقم +1 415 523 8886'
      );
    }
    
    throw new functions.https.HttpsError(
      'internal',
      `فشل إرسال رمز التحقق: ${error.message}`
    );
  }
});

// ============================================
// ✅ Function 2: Verify WhatsApp OTP
// ============================================
exports.verifyWhatsAppOTP = functions.https.onCall(async (data, context) => {
  try {
    const { phoneNumber, otp } = data;

    if (!phoneNumber || !otp) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'رقم الهاتف ورمز التحقق مطلوبان'
      );
    }

    // تنظيف رقم الهاتف
    let formattedPhone = phoneNumber;
    if (phoneNumber.startsWith('0')) {
      formattedPhone = '+249' + phoneNumber.substring(1);
    } else if (!phoneNumber.startsWith('+')) {
      formattedPhone = '+249' + phoneNumber;
    }

    console.log('🔐 Verifying OTP for:', formattedPhone);

    // 1️⃣ البحث عن OTP في Firestore
    const otpRef = admin.firestore().collection('otp').doc(formattedPhone);
    const otpDoc = await otpRef.get();

    if (!otpDoc.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        'رمز التحقق غير موجود أو منتهي الصلاحية'
      );
    }

    const otpData = otpDoc.data();

    // 2️⃣ التحقق من الصلاحية
    const now = Date.now();
    const expiresAt = otpData.expiresAt.toMillis();

    if (now > expiresAt) {
      await otpRef.delete();
      throw new functions.https.HttpsError(
        'deadline-exceeded',
        'رمز التحقق منتهي الصلاحية'
      );
    }

    // 3️⃣ التحقق من عدد المحاولات
    if (otpData.attempts >= 3) {
      await otpRef.delete();
      throw new functions.https.HttpsError(
        'resource-exhausted',
        'تم تجاوز عدد المحاولات المسموحة'
      );
    }

    // 4️⃣ التحقق من OTP
    const isValid = await bcrypt.compare(otp, otpData.otp);

    if (!isValid) {
      // زيادة عدد المحاولات
      await otpRef.update({
        attempts: admin.firestore.FieldValue.increment(1),
      });

      throw new functions.https.HttpsError(
        'invalid-argument',
        'رمز التحقق غير صحيح'
      );
    }

    // 5️⃣ OTP صحيح - حذف OTP
    await otpRef.delete();

    // 6️⃣ إنشاء Custom Token لـ Firebase Auth
    const uid = formattedPhone.replace('+', '');
    const customToken = await admin.auth().createCustomToken(uid);

    console.log('✅ OTP verified successfully');

    return {
      success: true,
      message: 'تم التحقق بنجاح',
      token: customToken,
    };

  } catch (error) {
    console.error('❌ Error verifying OTP:', error);
    throw error;
  }
});

// ============================================
// 🔄 Function 3: Resend WhatsApp OTP
// ============================================
exports.resendWhatsAppOTP = functions.https.onCall(async (data, context) => {
  // نفس منطق sendWhatsAppOTP
  return exports.sendWhatsAppOTP(data, context);
});

// ============================================
// 🧹 Function 4: Cleanup Expired OTPs
// ============================================
exports.cleanupExpiredOTPs = functions.pubsub
  .schedule('every 1 hours')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const expiredOTPs = await admin
      .firestore()
      .collection('otp')
      .where('expiresAt', '<', now)
      .get();

    const batch = admin.firestore().batch();
    expiredOTPs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    console.log(`🧹 Cleaned up ${expiredOTPs.size} expired OTPs`);
    return null;
  });
