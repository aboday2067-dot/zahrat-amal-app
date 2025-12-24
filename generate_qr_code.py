#!/usr/bin/env python3
"""
إنشاء QR Code لرابط تحميل التطبيق
Generate QR Code for app download link
"""

try:
    import qrcode
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("⚠️  جاري تثبيت المكتبات المطلوبة...")
    import subprocess
    subprocess.run(['pip', 'install', 'qrcode[pil]', '-q'])
    import qrcode
    from PIL import Image, ImageDraw, ImageFont

# رابط تحميل التطبيق
download_url = "https://www.genspark.ai/api/code_sandbox/download_file_stream?project_id=052749b7-ebc7-41d0-b451-a85adb835e96&file_path=%2Fhome%2Fuser%2Fflutter_app%2Fbuild%2Fapp%2Foutputs%2Fflutter-apk%2Fapp-release.apk&file_name=ZahratAmal-v6.2.0.apk"

# إنشاء QR Code
qr = qrcode.QRCode(
    version=1,
    error_correction=qrcode.constants.ERROR_CORRECT_H,
    box_size=10,
    border=4,
)

qr.add_data(download_url)
qr.make(fit=True)

# إنشاء الصورة
img = qr.make_image(fill_color="#6B9AC4", back_color="white")

# حفظ الصورة
output_path = '/home/user/flutter_app/ZahratAmal_QRCode.png'
img.save(output_path)

print("✅ تم إنشاء QR Code بنجاح!")
print(f"📍 الموقع: {output_path}")
print("\n📱 استخدم هذا الـ QR Code لتحميل التطبيق مباشرة!")
print("🔗 رابط التحميل:", download_url[:100] + "...")
