#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
إضافة بيانات الملفات الشخصية إلى Firebase
Add Profile Data to Firebase Firestore
"""

import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime
import sys

def initialize_firebase():
    """تهيئة Firebase"""
    try:
        # البحث عن ملف Firebase Admin SDK
        import os
        import glob
        
        # البحث في /opt/flutter/
        firebase_files = glob.glob('/opt/flutter/*adminsdk*.json')
        if not firebase_files:
            firebase_files = glob.glob('/opt/flutter/firebase-*.json')
        
        if not firebase_files:
            print("❌ لم يتم العثور على ملف Firebase Admin SDK")
            return None
        
        firebase_key_path = firebase_files[0]
        print(f"✅ تم العثور على ملف Firebase: {firebase_key_path}")
        
        # تهيئة Firebase
        cred = credentials.Certificate(firebase_key_path)
        
        # التحقق من عدم تهيئة Firebase مسبقاً
        try:
            firebase_admin.get_app()
            print("✅ Firebase مهيأ مسبقاً")
        except ValueError:
            firebase_admin.initialize_app(cred)
            print("✅ تم تهيئة Firebase بنجاح")
        
        return firestore.client()
    
    except Exception as e:
        print(f"❌ خطأ في تهيئة Firebase: {e}")
        return None

def add_merchant_profiles(db):
    """إضافة ملفات التجار"""
    print("\n📦 جاري إضافة ملفات التجار...")
    
    merchants = [
        {
            'merchant_name': 'متجر الفاخر للإلكترونيات',
            'owner_name': 'محمد أحمد الحسن',
            'email': 'alfakher@electronics.sd',
            'phone': '+249 91 234 5678',
            'business_license': 'TRD-2024-001234',
            'address': 'شارع الجامعة، مربع 15، محل رقم 23',
            'city': 'الخرطوم',
            'district': 'الخرطوم 2',
            'profile_image': 'https://via.placeholder.com/200',
            'store_logo': 'https://via.placeholder.com/150',
            'rating': 4.8,
            'total_sales': 125000,
            'total_products': 150,
            'total_orders': 342,
            'join_date': '2024-01-15',
            'is_verified': True,
            'categories': ['إلكترونيات', 'هواتف', 'حواسيب', 'ملحقات']
        },
        {
            'merchant_name': 'معرض الأناقة للأزياء',
            'owner_name': 'فاطمة علي محمد',
            'email': 'elegance@fashion.sd',
            'phone': '+249 92 345 6789',
            'business_license': 'TRD-2024-002345',
            'address': 'سوق العربي، الطابق الثاني، محل 45',
            'city': 'الخرطوم',
            'district': 'الخرطوم',
            'profile_image': 'https://via.placeholder.com/200',
            'store_logo': 'https://via.placeholder.com/150',
            'rating': 4.6,
            'total_sales': 89000,
            'total_products': 220,
            'total_orders': 278,
            'join_date': '2024-02-20',
            'is_verified': True,
            'categories': ['ملابس', 'أزياء', 'إكسسوارات', 'أحذية']
        },
        {
            'merchant_name': 'مكتبة النور للأدوات المكتبية',
            'owner_name': 'عبدالله إبراهيم',
            'email': 'alnoor@stationary.sd',
            'phone': '+249 93 456 7890',
            'business_license': 'TRD-2024-003456',
            'address': 'شارع القصر، بجوار جامعة الخرطوم',
            'city': 'الخرطوم',
            'district': 'الخرطوم',
            'profile_image': 'https://via.placeholder.com/200',
            'store_logo': 'https://via.placeholder.com/150',
            'rating': 4.9,
            'total_sales': 67000,
            'total_products': 180,
            'total_orders': 195,
            'join_date': '2024-03-10',
            'is_verified': True,
            'categories': ['أدوات مكتبية', 'كتب', 'قرطاسية', 'مطبوعات']
        },
        {
            'merchant_name': 'سوبر ماركت الخير',
            'owner_name': 'خالد محمود أحمد',
            'email': 'alkheir@supermarket.sd',
            'phone': '+249 94 567 8901',
            'business_license': 'TRD-2024-004567',
            'address': 'حي الرياض، شارع 15',
            'city': 'أم درمان',
            'district': 'أم درمان الغربية',
            'profile_image': 'https://via.placeholder.com/200',
            'store_logo': 'https://via.placeholder.com/150',
            'rating': 4.5,
            'total_sales': 245000,
            'total_products': 450,
            'total_orders': 567,
            'join_date': '2024-01-05',
            'is_verified': True,
            'categories': ['مواد غذائية', 'خضروات', 'فواكه', 'منتجات منزلية']
        },
    ]
    
    for merchant in merchants:
        try:
            doc_ref = db.collection('merchants').add(merchant)
            print(f"✅ تمت إضافة التاجر: {merchant['merchant_name']}")
        except Exception as e:
            print(f"❌ خطأ في إضافة {merchant['merchant_name']}: {e}")
    
    print(f"✅ تمت إضافة {len(merchants)} تاجر بنجاح")

def add_buyer_profiles(db):
    """إضافة ملفات المشترين"""
    print("\n🛒 جاري إضافة ملفات المشترين...")
    
    buyers = [
        {
            'full_name': 'أحمد محمد علي',
            'email': 'ahmed.mohamed@email.com',
            'phone': '+249 91 234 5678',
            'city': 'الخرطوم',
            'district': 'الخرطوم 2',
            'profile_image': 'https://via.placeholder.com/200',
            'total_orders': 15,
            'total_spent': 12500.0,
            'loyalty_points': 1250,
            'join_date': '2024-01-15',
            'favorite_categories': ['إلكترونيات', 'هواتف', 'ملحقات'],
            'membership_level': 'Gold'
        },
        {
            'full_name': 'فاطمة حسن محمود',
            'email': 'fatima.hassan@email.com',
            'phone': '+249 92 345 6789',
            'city': 'الخرطوم',
            'district': 'الخرطوم',
            'profile_image': 'https://via.placeholder.com/200',
            'total_orders': 28,
            'total_spent': 23400.0,
            'loyalty_points': 2340,
            'join_date': '2024-02-01',
            'favorite_categories': ['ملابس', 'أزياء', 'إكسسوارات'],
            'membership_level': 'Platinum'
        },
        {
            'full_name': 'عمر عبدالله إبراهيم',
            'email': 'omar.abdullah@email.com',
            'phone': '+249 93 456 7890',
            'city': 'أم درمان',
            'district': 'أم درمان الشرقية',
            'profile_image': 'https://via.placeholder.com/200',
            'total_orders': 8,
            'total_spent': 6700.0,
            'loyalty_points': 670,
            'join_date': '2024-03-15',
            'favorite_categories': ['كتب', 'قرطاسية', 'أدوات مكتبية'],
            'membership_level': 'Silver'
        },
        {
            'full_name': 'سارة خالد محمد',
            'email': 'sara.khaled@email.com',
            'phone': '+249 94 567 8901',
            'city': 'بحري',
            'district': 'بحري الشمالية',
            'profile_image': 'https://via.placeholder.com/200',
            'total_orders': 4,
            'total_spent': 2300.0,
            'loyalty_points': 230,
            'join_date': '2024-05-20',
            'favorite_categories': ['مواد غذائية', 'خضروات'],
            'membership_level': 'Bronze'
        },
        {
            'full_name': 'يوسف محمود أحمد',
            'email': 'youssef.mahmoud@email.com',
            'phone': '+249 95 678 9012',
            'city': 'الخرطوم',
            'district': 'الخرطوم 3',
            'profile_image': 'https://via.placeholder.com/200',
            'total_orders': 19,
            'total_spent': 18900.0,
            'loyalty_points': 1890,
            'join_date': '2024-02-28',
            'favorite_categories': ['إلكترونيات', 'حواسيب', 'ألعاب'],
            'membership_level': 'Gold'
        },
    ]
    
    for buyer in buyers:
        try:
            doc_ref = db.collection('buyers').add(buyer)
            print(f"✅ تمت إضافة المشتري: {buyer['full_name']}")
        except Exception as e:
            print(f"❌ خطأ في إضافة {buyer['full_name']}: {e}")
    
    print(f"✅ تمت إضافة {len(buyers)} مشتري بنجاح")

def add_delivery_office_profiles(db):
    """إضافة ملفات مكاتب التوصيل"""
    print("\n🚚 جاري إضافة ملفات مكاتب التوصيل...")
    
    delivery_offices = [
        {
            'office_name': 'سريع للتوصيل السريع',
            'manager_name': 'إبراهيم محمد الأمين',
            'email': 'saree@delivery.sd',
            'phone': '+249 91 111 2222',
            'address': 'شارع الجامعة، مبنى رقم 50',
            'city': 'الخرطوم',
            'coverage_areas': ['الخرطوم', 'الخرطوم 2', 'الخرطوم 3', 'أركويت'],
            'profile_image': 'https://via.placeholder.com/200',
            'rating': 4.7,
            'total_deliveries': 1250,
            'active_drivers': 15,
            'delivery_prices': {
                'الخرطوم': 30.0,
                'الخرطوم 2': 35.0,
                'الخرطوم 3': 40.0,
                'أركويت': 50.0,
            },
            'join_date': '2024-01-10',
            'is_active': True,
            'working_hours': '8:00 صباحاً - 10:00 مساءً'
        },
        {
            'office_name': 'البرق للشحن والتوصيل',
            'manager_name': 'عثمان صالح أحمد',
            'email': 'albarq@shipping.sd',
            'phone': '+249 92 222 3333',
            'address': 'سوق العربي، الطابق الأرضي',
            'city': 'الخرطوم',
            'coverage_areas': ['الخرطوم', 'أم درمان', 'بحري', 'الديوم'],
            'profile_image': 'https://via.placeholder.com/200',
            'rating': 4.5,
            'total_deliveries': 980,
            'active_drivers': 12,
            'delivery_prices': {
                'الخرطوم': 25.0,
                'أم درمان': 30.0,
                'بحري': 35.0,
                'الديوم': 40.0,
            },
            'join_date': '2024-02-01',
            'is_active': True,
            'working_hours': '7:00 صباحاً - 11:00 مساءً'
        },
        {
            'office_name': 'النجم الساطع للخدمات اللوجستية',
            'manager_name': 'محمد الفاتح عبدالله',
            'email': 'alnajm@logistics.sd',
            'phone': '+249 93 333 4444',
            'address': 'حي الرياض، شارع 12',
            'city': 'أم درمان',
            'coverage_areas': ['أم درمان', 'أم درمان الشرقية', 'أم درمان الغربية', 'الموردة'],
            'profile_image': 'https://via.placeholder.com/200',
            'rating': 4.8,
            'total_deliveries': 1450,
            'active_drivers': 18,
            'delivery_prices': {
                'أم درمان': 28.0,
                'أم درمان الشرقية': 32.0,
                'أم درمان الغربية': 35.0,
                'الموردة': 45.0,
            },
            'join_date': '2024-01-20',
            'is_active': True,
            'working_hours': '8:00 صباحاً - 9:00 مساءً'
        },
        {
            'office_name': 'الأمانة للتوصيل المضمون',
            'manager_name': 'حسن علي محمود',
            'email': 'alamana@delivery.sd',
            'phone': '+249 94 444 5555',
            'address': 'شارع القصر، مبنى المركز التجاري',
            'city': 'بحري',
            'coverage_areas': ['بحري', 'بحري الشمالية', 'بحري الجنوبية', 'الخرطوم الشمالية'],
            'profile_image': 'https://via.placeholder.com/200',
            'rating': 4.6,
            'total_deliveries': 875,
            'active_drivers': 10,
            'delivery_prices': {
                'بحري': 30.0,
                'بحري الشمالية': 35.0,
                'بحري الجنوبية': 38.0,
                'الخرطوم الشمالية': 42.0,
            },
            'join_date': '2024-03-01',
            'is_active': True,
            'working_hours': '9:00 صباحاً - 8:00 مساءً'
        },
    ]
    
    for office in delivery_offices:
        try:
            doc_ref = db.collection('delivery_offices').add(office)
            print(f"✅ تمت إضافة مكتب التوصيل: {office['office_name']}")
        except Exception as e:
            print(f"❌ خطأ في إضافة {office['office_name']}: {e}")
    
    print(f"✅ تمت إضافة {len(delivery_offices)} مكتب توصيل بنجاح")

def main():
    """الوظيفة الرئيسية"""
    print("=" * 60)
    print("🔥 إضافة بيانات الملفات الشخصية إلى Firebase")
    print("=" * 60)
    
    # تهيئة Firebase
    db = initialize_firebase()
    if not db:
        print("❌ فشل تهيئة Firebase. الخروج...")
        sys.exit(1)
    
    # إضافة البيانات
    add_merchant_profiles(db)
    add_buyer_profiles(db)
    add_delivery_office_profiles(db)
    
    print("\n" + "=" * 60)
    print("✅ تمت إضافة جميع البيانات بنجاح!")
    print("=" * 60)
    print("\n📊 الملخص:")
    print("  - 4 تجار")
    print("  - 5 مشترين")
    print("  - 4 مكاتب توصيل")
    print("\n🎉 التطبيق جاهز الآن مع جميع البيانات!")

if __name__ == '__main__':
    main()
