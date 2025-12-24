#!/usr/bin/env python3
"""
خادم HTTP بدون تخزين مؤقت - يجبر المتصفح على تحميل أحدث نسخة
HTTP Server with no-cache headers - forces browser to load latest version
"""

import http.server
import socketserver
from datetime import datetime

PORT = 5060

class NoCacheHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """معالج طلبات HTTP مع headers لمنع التخزين المؤقت"""
    
    def end_headers(self):
        # منع التخزين المؤقت تماماً
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        
        # CORS headers
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        
        # Frame headers
        self.send_header('X-Frame-Options', 'ALLOWALL')
        self.send_header('Content-Security-Policy', "frame-ancestors *")
        
        super().end_headers()
    
    def log_message(self, format, *args):
        """تسجيل الطلبات مع الوقت"""
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        print(f"[{timestamp}] {format % args}")

if __name__ == '__main__':
    with socketserver.TCPServer(("0.0.0.0", PORT), NoCacheHTTPRequestHandler) as httpd:
        print(f"🚀 خادم بدون تخزين مؤقت يعمل على المنفذ {PORT}")
        print(f"🚀 No-cache server running on port {PORT}")
        print(f"⏰ بدأ في: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"⏰ Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("="*60)
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n🛑 إيقاف الخادم...")
            print("🛑 Stopping server...")
