#!/usr/bin/env python3
"""
حذف جميع البيانات التجريبية من Firebase
Delete all test data from Firebase
"""

import firebase_admin
from firebase_admin import credentials, firestore

# تهيئة Firebase
try:
    cred = credentials.Certificate('/opt/flutter/firebase-admin-sdk.json')
    firebase_admin.initialize_app(cred)
    print("✅ تم الاتصال بـ Firebase بنجاح")
except Exception as e:
    print(f"❌ خطأ في الاتصال بـ Firebase: {e}")
    exit(1)

db = firestore.client()

print("\n🗑️  جاري حذف جميع البيانات التجريبية...")
print("="*60)

# قائمة المجموعات التي تحتوي على بيانات تجريبية
collections_to_clean = [
    'users',
    'user_credentials',
    'receipts',
    'orders',
    'products',
    'categories',
    'merchants',
    'delivery_offices',
    'notifications',
    'messages',
    'reviews',
    'coupons',
    'cart_items',
    'favorites',
    'addresses',
]

deleted_count = 0

for collection_name in collections_to_clean:
    try:
        # جلب جميع المستندات
        docs = db.collection(collection_name).stream()
        
        collection_deleted = 0
        for doc in docs:
            doc.reference.delete()
            collection_deleted += 1
            deleted_count += 1
        
        if collection_deleted > 0:
            print(f"✅ حذف {collection_deleted} مستند من '{collection_name}'")
        else:
            print(f"ℹ️  لا توجد بيانات في '{collection_name}'")
            
    except Exception as e:
        print(f"⚠️  خطأ في حذف '{collection_name}': {e}")

print("="*60)
print(f"\n✅ تم حذف {deleted_count} مستند بنجاح!")
print("\n🎉 التطبيق الآن نظيف وجاهز للإطلاق العام!")
print("="*60)
