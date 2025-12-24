#!/usr/bin/env python3
"""
إنشاء مستخدمين تجريبيين في Firebase لاختبار نظام المصادقة
"""

import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime
import hashlib

# تهيئة Firebase
try:
    cred = credentials.Certificate('/opt/flutter/firebase-admin-sdk.json')
    firebase_admin.initialize_app(cred)
    print("✅ تم الاتصال بـ Firebase بنجاح")
except Exception as e:
    print(f"❌ خطأ في الاتصال بـ Firebase: {e}")
    exit(1)

db = firestore.client()

def hash_password(password):
    """تشفير كلمة المرور بـ SHA-256"""
    return hashlib.sha256(password.encode()).hexdigest()

# مستخدمين تجريبيين
test_users = [
    {
        'userId': 'USR-TEST-BUYER-001',
        'name': 'أحمد محمد علي',
        'email': 'buyer@test.com',
        'password': '12345678',
        'phone': '+249 91 234 5678',
        'city': 'الخرطوم',
        'district': 'الخرطوم 2',
        'role': 'buyer',
    },
    {
        'userId': 'USR-TEST-MERCHANT-001',
        'name': 'محمد التاجر',
        'email': 'merchant@test.com',
        'password': '12345678',
        'phone': '+249 91 345 6789',
        'city': 'الخرطوم',
        'district': 'الخرطوم',
        'role': 'merchant',
    },
    {
        'userId': 'USR-TEST-DELIVERY-001',
        'name': 'مكتب التوصيل السريع',
        'email': 'delivery@test.com',
        'password': '12345678',
        'phone': '+249 91 456 7890',
        'city': 'الخرطوم',
        'district': 'أم درمان',
        'role': 'delivery_office',
    },
]

print("\n🔄 جاري إنشاء المستخدمين التجريبيين...")
print("="*60)

for user_data in test_users:
    try:
        userId = user_data['userId']
        password = user_data.pop('password')
        
        # إضافة بيانات إضافية
        user_data['createdAt'] = datetime.now().isoformat()
        user_data['isEmailVerified'] = True
        user_data['isActive'] = True
        
        # حفظ المستخدم
        db.collection('users').document(userId).set(user_data)
        
        # حفظ كلمة المرور المشفرة
        db.collection('user_credentials').document(userId).set({
            'userId': userId,
            'passwordHash': hash_password(password),
            'createdAt': datetime.now().isoformat(),
        })
        
        print(f"\n✅ تم إنشاء المستخدم: {user_data['name']}")
        print(f"   📧 البريد: {user_data['email']}")
        print(f"   🔑 كلمة المرور: 12345678")
        print(f"   👤 النوع: {user_data['role']}")
        
    except Exception as e:
        print(f"\n❌ خطأ في إنشاء المستخدم {user_data.get('name', 'Unknown')}: {e}")

print("\n" + "="*60)
print("✅ تم إنشاء جميع المستخدمين التجريبيين بنجاح!")
print("\n📋 معلومات تسجيل الدخول:")
print("-"*60)
print("1️⃣  مشتري:")
print("   البريد: buyer@test.com")
print("   كلمة المرور: 12345678")
print("\n2️⃣  تاجر:")
print("   البريد: merchant@test.com")
print("   كلمة المرور: 12345678")
print("\n3️⃣  مكتب توصيل:")
print("   البريد: delivery@test.com")
print("   كلمة المرور: 12345678")
print("="*60)
