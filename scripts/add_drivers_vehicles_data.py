#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
إضافة بيانات تجريبية للسائقين والمركبات
Add Sample Data for Drivers and Vehicles
"""

import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime, timedelta
import random

# تهيئة Firebase
try:
    cred = credentials.Certificate('/opt/flutter/firebase-admin-sdk.json')
    firebase_admin.initialize_app(cred)
    print("✅ تم تهيئة Firebase بنجاح")
except Exception as e:
    print(f"❌ خطأ في تهيئة Firebase: {e}")
    exit(1)

db = firestore.client()

# أسماء السائقين السودانيين
driver_names = [
    "محمد أحمد علي",
    "عثمان إبراهيم حسن",
    "عبد الله محمود عمر",
    "حسن علي محمد",
    "أحمد عبد الرحمن",
    "إبراهيم حسن علي",
    "عمر محمد أحمد",
    "علي عثمان محمد",
    "يوسف عبد الله",
    "طارق حسن محمد",
    "صالح أحمد إبراهيم",
    "خالد محمود علي",
]

# أنواع وماركات المركبات
vehicle_types = ["دراجة نارية", "سيارة صغيرة", "شاحنة صغيرة"]
vehicle_brands = {
    "دراجة نارية": ["Honda", "Yamaha", "Suzuki", "Bajaj"],
    "سيارة صغيرة": ["Toyota", "Nissan", "Suzuki", "Hyundai"],
    "شاحنة صغيرة": ["Isuzu", "Mitsubishi", "Toyota", "Nissan"],
}
vehicle_models = {
    "Honda": ["CB125", "CG125", "Wave"],
    "Yamaha": ["YBR125", "FZ150", "XTZ125"],
    "Suzuki": ["GS150", "Hayate", "Gixxer"],
    "Bajaj": ["Boxer", "Platina", "Pulsar"],
    "Toyota": ["Corolla", "Yaris", "Hilux"],
    "Nissan": ["Sunny", "Tiida", "Pickup"],
    "Hyundai": ["Accent", "Elantra", "Creta"],
    "Isuzu": ["D-Max", "NQR", "NPR"],
    "Mitsubishi": ["L200", "Canter", "Fuso"],
}

colors = ["أبيض", "أسود", "فضي", "أزرق", "أحمر", "رمادي"]

# سعات المركبات (كجم)
capacities = {
    "دراجة نارية": [50, 75, 100],
    "سيارة صغيرة": [200, 300, 400],
    "شاحنة صغيرة": [500, 750, 1000, 1500],
}

def generate_phone_number():
    """توليد رقم هاتف سوداني"""
    prefixes = ["0912", "0911", "0915", "0916", "0918", "0919"]
    return f"{random.choice(prefixes)}{random.randint(1000000, 9999999)}"

def generate_plate_number():
    """توليد رقم لوحة سودانية"""
    letters = ['أ', 'ب', 'ج', 'د', 'هـ', 'و', 'ز']
    return f"{random.choice(letters)} {random.randint(1000, 9999)} {random.choice(letters)}"

def generate_license_number():
    """توليد رقم رخصة قيادة"""
    return f"SD-{random.randint(100000, 999999)}"

def add_vehicles_data():
    """إضافة بيانات المركبات"""
    print("\n🚗 إضافة بيانات المركبات...")
    
    # الحصول على جميع مكاتب التوصيل
    offices_ref = db.collection('delivery_offices')
    offices = offices_ref.stream()
    
    vehicles_added = 0
    
    for office in offices:
        office_id = office.id
        office_data = office.to_dict()
        office_name = office_data.get('office_name', '')
        
        # إضافة 3-5 مركبات لكل مكتب
        num_vehicles = random.randint(3, 5)
        print(f"   📋 إضافة {num_vehicles} مركبات لمكتب: {office_name}")
        
        for i in range(num_vehicles):
            # اختيار نوع المركبة
            vehicle_type = random.choice(vehicle_types)
            
            # اختيار الماركة بناءً على النوع
            brand = random.choice(vehicle_brands[vehicle_type])
            
            # اختيار الموديل بناءً على الماركة
            model = random.choice(vehicle_models[brand])
            
            # اختيار السعة بناءً على النوع
            capacity = random.choice(capacities[vehicle_type])
            
            # توليد رقم اللوحة
            plate_number = generate_plate_number()
            
            # اختيار اللون
            color = random.choice(colors)
            
            # تاريخ انتهاء التأمين (سنة واحدة من الآن)
            insurance_expiry = (datetime.now() + timedelta(days=random.randint(180, 730))).strftime('%Y-%m-%d')
            
            vehicle_data = {
                'office_id': office_id,
                'type': vehicle_type,
                'brand': brand,
                'model': model,
                'plate_number': plate_number,
                'color': color,
                'capacity': capacity,
                'is_active': True,
                'insurance_expiry': insurance_expiry,
                'created_at': firestore.SERVER_TIMESTAMP,
            }
            
            # إضافة المركبة إلى Firestore
            db.collection('vehicles').add(vehicle_data)
            vehicles_added += 1
            print(f"      ✅ {brand} {model} ({plate_number}) - {capacity} كجم")
    
    print(f"\n✅ تمت إضافة {vehicles_added} مركبة بنجاح")
    return vehicles_added

def add_drivers_data():
    """إضافة بيانات السائقين"""
    print("\n👤 إضافة بيانات السائقين...")
    
    # الحصول على جميع مكاتب التوصيل
    offices_ref = db.collection('delivery_offices')
    offices = offices_ref.stream()
    
    drivers_added = 0
    
    for office in offices:
        office_id = office.id
        office_data = office.to_dict()
        office_name = office_data.get('office_name', '')
        
        # الحصول على مركبات هذا المكتب
        vehicles_ref = db.collection('vehicles').where('office_id', '==', office_id)
        vehicles = list(vehicles_ref.stream())
        
        if not vehicles:
            print(f"   ⚠️ لا توجد مركبات لمكتب: {office_name}")
            continue
        
        # إضافة سائق لكل مركبة + سائقين إضافيين
        num_drivers = len(vehicles) + random.randint(0, 2)
        print(f"   📋 إضافة {num_drivers} سائقين لمكتب: {office_name}")
        
        available_names = driver_names.copy()
        random.shuffle(available_names)
        
        for i in range(min(num_drivers, len(available_names))):
            driver_name = available_names[i]
            
            # اختيار مركبة عشوائية
            vehicle = random.choice(vehicles)
            vehicle_id = vehicle.id
            
            # توليد رقم هاتف
            phone = generate_phone_number()
            emergency_phone = generate_phone_number()
            
            # توليد رقم رخصة
            license_number = generate_license_number()
            
            # تاريخ انتهاء الرخصة (1-3 سنوات من الآن)
            license_expiry = (datetime.now() + timedelta(days=random.randint(365, 1095))).strftime('%Y-%m-%d')
            
            # تقييم عشوائي
            rating = round(random.uniform(4.0, 5.0), 1)
            
            # عدد عمليات التوصيل
            total_deliveries = random.randint(50, 500)
            
            driver_data = {
                'office_id': office_id,
                'full_name': driver_name,
                'phone': phone,
                'emergency_phone': emergency_phone,
                'license_number': license_number,
                'license_expiry': license_expiry,
                'vehicle_id': vehicle_id,
                'is_active': True,
                'rating': rating,
                'total_deliveries': total_deliveries,
                'created_at': firestore.SERVER_TIMESTAMP,
            }
            
            # إضافة السائق إلى Firestore
            db.collection('drivers').add(driver_data)
            drivers_added += 1
            print(f"      ✅ {driver_name} - {phone} (⭐ {rating})")
    
    print(f"\n✅ تمت إضافة {drivers_added} سائق بنجاح")
    return drivers_added

def update_office_driver_counts():
    """تحديث عدد السائقين في كل مكتب"""
    print("\n🔄 تحديث عدد السائقين في مكاتب التوصيل...")
    
    offices_ref = db.collection('delivery_offices')
    offices = offices_ref.stream()
    
    for office in offices:
        office_id = office.id
        
        # عد السائقين النشطين
        drivers_ref = db.collection('drivers').where('office_id', '==', office_id).where('is_active', '==', True)
        driver_count = len(list(drivers_ref.stream()))
        
        # تحديث المكتب
        offices_ref.document(office_id).update({
            'active_drivers': driver_count
        })
        
        print(f"   ✅ تم تحديث عدد السائقين: {driver_count}")
    
    print("✅ تم تحديث جميع المكاتب بنجاح")

def main():
    """الوظيفة الرئيسية"""
    print("=" * 60)
    print("🚀 بدء إضافة بيانات السائقين والمركبات")
    print("=" * 60)
    
    try:
        # إضافة المركبات أولاً
        vehicles_count = add_vehicles_data()
        
        # إضافة السائقين
        drivers_count = add_drivers_data()
        
        # تحديث عدد السائقين في المكاتب
        update_office_driver_counts()
        
        print("\n" + "=" * 60)
        print("✅ تمت العملية بنجاح!")
        print(f"📊 الإحصائيات:")
        print(f"   • المركبات المضافة: {vehicles_count}")
        print(f"   • السائقين المضافون: {drivers_count}")
        print("=" * 60)
        
    except Exception as e:
        print(f"\n❌ حدث خطأ: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()
