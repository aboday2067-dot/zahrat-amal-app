# 🌐 دليل ربط النطاق المخصص - sd.zahrat.amal

## 📋 نظرة عامة

هذا الدليل يشرح كيفية ربط النطاق المخصص `sd.zahrat.amal` بتطبيق Firebase Hosting خطوة بخطوة.

---

## ✅ المتطلبات الأساسية

قبل البدء، تأكد من:

1. ✅ **ملكية النطاق:** يجب أن تملك `sd.zahrat.amal` أو يكون لديك صلاحية إدارة DNS
2. ✅ **التطبيق منشور:** التطبيق منشور على Firebase (https://zahratamal-36602.web.app)
3. ✅ **الوصول لـ DNS:** لديك صلاحية تعديل DNS Records للنطاق

---

## 🔍 فهم النطاق

### نطاقك: `sd.zahrat.amal`

هذا نطاق فرعي (subdomain):
- **Domain:** `zahrat.amal`
- **Subdomain:** `sd`
- **Full Domain:** `sd.zahrat.amal`

### نوع الإعداد

حسب نوع النطاق:

#### إذا كنت تريد `sd.zahrat.amal` (نطاق فرعي)
```
في Firebase: أدخل sd.zahrat.amal
في DNS: استخدم @ أو sd حسب مزود الخدمة
```

#### إذا كنت تريد `zahrat.amal` (نطاق رئيسي)
```
في Firebase: أدخل zahrat.amal
في DNS: استخدم @ دائماً
```

---

## 🚀 خطوات الإعداد الكاملة

### المرحلة 1: إضافة النطاق في Firebase

#### الخطوة 1: افتح Firebase Console

اذهب إلى:
```
https://console.firebase.google.com/project/zahratamal-36602/hosting/sites
```

أو:
1. افتح https://console.firebase.google.com/
2. اختر المشروع: `zahratamal-36602`
3. من القائمة الجانبية: **Hosting**
4. اضغط تبويب **Custom domain**

#### الخطوة 2: اضغط "Add custom domain"

ستظهر نافذة منبثقة

#### الخطوة 3: أدخل النطاق

```
sd.zahrat.amal
```

> ⚠️ **تأكد:** لا تضع `http://` أو `https://` أو `/` في النهاية

#### الخطوة 4: اضغط "Continue"

---

### المرحلة 2: إثبات ملكية النطاق

Firebase سيطلب إثبات أنك تملك النطاق.

#### الطريقة 1: TXT Record (موصى بها)

Firebase سيعطيك سجل TXT مثل:

```
Record Type: TXT
Host/Name: @ أو sd أو فارغ
Value: firebase=zahratamal-36602
TTL: 3600 (أو Auto)
```

**خطوات الإضافة:**

1. **افتح DNS Management:**
   - اذهب لموقع مزود النطاق (Namecheap, GoDaddy, Cloudflare, إلخ)
   - ابحث عن "DNS Settings" أو "DNS Management"
   - قد تجدها في: Domain → Manage → DNS

2. **أضف سجل TXT جديد:**
   ```
   Type: TXT
   Host: @ (أو اترك فارغاً)
   Value: firebase=zahratamal-36602
   TTL: Auto أو 3600
   ```

3. **احفظ التغييرات**

4. **ارجع لـ Firebase Console واضغط "Verify"**

⏱️ **وقت الانتظار:** 5-30 دقيقة (أحياناً فوري)

#### الطريقة 2: Meta Tag (بديلة)

إذا لم تتمكن من إضافة TXT Record:

1. **افتح ملف:** `build/web/index.html`

2. **أضف هذا السطر داخل `<head>`:**
   ```html
   <meta name="firebase-hosting-site" content="zahratamal-36602" />
   ```

3. **احفظ وأعد النشر:**
   ```bash
   firebase deploy --only hosting
   ```

4. **ارجع لـ Firebase Console واضغط "Verify"**

---

### المرحلة 3: إعداد DNS Records

بعد إثبات الملكية بنجاح، أضف السجلات التالية:

#### A Records (IPv4) - إلزامي

أضف هذين السجلين:

**السجل الأول:**
```
Type: A
Host/Name: @ (أو sd أو فارغ حسب المزود)
Value/Points to: 151.101.1.195
TTL: 3600 (أو Auto)
```

**السجل الثاني:**
```
Type: A
Host/Name: @ (أو sd أو فارغ حسب المزود)
Value/Points to: 151.101.65.195
TTL: 3600 (أو Auto)
```

> 💡 **ملاحظة عن Host/Name:**
> - إذا كنت تستخدم `sd.zahrat.amal` → ضع `sd` أو `@`
> - إذا كنت تستخدم `zahrat.amal` → ضع `@` أو اترك فارغاً
> - حسب مزود النطاق (اقرأ تعليمات المزود)

#### AAAA Records (IPv6) - اختياري لكن موصى به

**السجل الأول:**
```
Type: AAAA
Host/Name: @ (أو sd)
Value: 2a04:4e42::347
TTL: 3600
```

**السجل الثاني:**
```
Type: AAAA
Host/Name: @ (أو sd)
Value: 2a04:4e42:200::347
TTL: 3600
```

---

### المرحلة 4: الانتظار والتحقق

#### وقت الانتظار ⏱️

- **إثبات الملكية:** 5-30 دقيقة
- **DNS Propagation:** 24-48 ساعة (أحياناً أسرع)
- **SSL Certificate:** يتم تلقائياً بعد تفعيل DNS

#### التحقق من DNS

**Windows:**
```bash
nslookup sd.zahrat.amal
```

**Mac/Linux:**
```bash
dig sd.zahrat.amal
# أو
host sd.zahrat.amal
```

**النتيجة المتوقعة:**
```
Name: sd.zahrat.amal
Address: 151.101.1.195
Address: 151.101.65.195
```

#### التحقق عبر الإنترنت

استخدم أحد المواقع:
- https://www.whatsmydns.net/
- https://dnschecker.org/
- https://mxtoolbox.com/DNSLookup.aspx

أدخل: `sd.zahrat.amal` وتحقق من انتشار DNS عالمياً

---

### المرحلة 5: SSL Certificate (تلقائي)

Firebase ينشئ SSL Certificate تلقائياً بعد تفعيل DNS

#### الحالات

1. **"Pending"** → انتظر حتى ساعة
2. **"Active"** → النطاق جاهز بالكامل! ✅
3. **"Failed"** → تحقق من DNS Records

#### التحقق

```bash
curl -I https://sd.zahrat.amal
```

يجب أن ترى:
```
HTTP/2 200
```

---

## 🎉 الانتهاء

بعد اكتمال جميع الخطوات:

✅ النطاق `sd.zahrat.amal` يوجّه لتطبيقك  
✅ SSL Certificate (https) نشط  
✅ التطبيق متاح على الرابط المخصص

**افتح التطبيق:**
```
https://sd.zahrat.amal
```

---

## 📊 حالة DNS - كيف تقرأها

### في Firebase Console

**Pending:**
```
⏳ Pending verification
```
الحل: انتظر أو تحقق من TXT Record

**Active:**
```
✅ Connected
   Status: Active
   SSL: Active
```
مبروك! النطاق يعمل بشكل كامل

**Failed:**
```
❌ Setup failed
```
الحل: تحقق من A Records

---

## 🛠️ استكشاف الأخطاء الشائعة

### 1. "Verification failed"

**المشكلة:** TXT Record غير صحيح أو لم ينتشر

**الحل:**
```bash
# تحقق من TXT Record
nslookup -type=TXT sd.zahrat.amal
# أو
dig TXT sd.zahrat.amal
```

يجب أن ترى: `firebase=zahratamal-36602`

**إذا لم يظهر:**
- تحقق من أنك أضفت TXT Record بشكل صحيح
- انتظر 15-30 دقيقة
- امسح DNS Cache: `ipconfig /flushdns` (Windows)

---

### 2. "DNS not propagating"

**المشكلة:** A Records غير صحيحة أو لم تنتشر عالمياً

**الحل:**
```bash
nslookup sd.zahrat.amal
```

**النتيجة المتوقعة:**
```
Name: sd.zahrat.amal
Address: 151.101.1.195
Address: 151.101.65.195
```

**إذا لم تظهر:**
- تحقق من أنك أضفت A Records بشكل صحيح
- تأكد من Value: `151.101.1.195` و `151.101.65.195`
- انتظر 24-48 ساعة لانتشار DNS عالمياً

**تحقق من انتشار DNS عالمياً:**
https://www.whatsmydns.net/#A/sd.zahrat.amal

---

### 3. "SSL Certificate pending"

**المشكلة:** شهادة SSL لم يتم إنشاؤها بعد

**الحل:**
- انتظر حتى ساعة بعد تفعيل DNS
- Firebase يُنشئ SSL تلقائياً
- لا تحتاج فعل أي شيء

**تحقق من الحالة:**
Firebase Console → Hosting → Custom Domain → Status

---

### 4. "Too many redirects"

**المشكلة:** إعدادات SSL غير صحيحة في مزود النطاق

**الحل:**
- إذا كنت تستخدم Cloudflare: غيّر SSL Mode إلى "Full (strict)"
- احذف أي Redirect Rules متعارضة
- امسح Cache المتصفح

---

### 5. "Domain already exists"

**المشكلة:** النطاق مستخدم في مشروع Firebase آخر

**الحل:**
- احذف النطاق من المشروع القديم أولاً
- أضفه للمشروع الجديد
- أو استخدم نطاق فرعي مختلف

---

## 📋 قائمة التحقق الكاملة

### قبل الإعداد
- [ ] أملك النطاق `sd.zahrat.amal` أو لدي صلاحية DNS
- [ ] التطبيق منشور على Firebase
- [ ] لدي صلاحية الوصول لإعدادات DNS

### إثبات الملكية
- [ ] أضفت TXT Record في DNS
- [ ] Firebase تحقق من الملكية بنجاح
- [ ] ظهرت رسالة "Verification complete"

### إعداد DNS
- [ ] أضفت A Record الأول: 151.101.1.195
- [ ] أضفت A Record الثاني: 151.101.65.195
- [ ] (اختياري) أضفت AAAA Records
- [ ] حفظت جميع التغييرات

### الانتظار والتحقق
- [ ] انتظرت 24-48 ساعة لانتشار DNS
- [ ] تحققت من DNS باستخدام `nslookup`
- [ ] تحققت من انتشار DNS عالمياً
- [ ] SSL Certificate نشط في Firebase Console

### الاختبار النهائي
- [ ] النطاق يفتح: https://sd.zahrat.amal
- [ ] SSL يعمل (https بدون تحذيرات)
- [ ] التطبيق يعمل بشكل كامل
- [ ] تسجيل الدخول يعمل
- [ ] جميع الصفحات والميزات تعمل

---

## 🌍 الإعدادات لمزودي النطاقات الشائعين

### Namecheap

**DNS Management:**
1. Dashboard → Domain List
2. اضغط "Manage" بجانب النطاق
3. اضغط تبويب "Advanced DNS"

**TXT Record:**
```
Type: TXT Record
Host: @
Value: firebase=zahratamal-36602
TTL: Automatic
```

**A Records:**
```
Type: A Record
Host: @ (أو sd)
Value: 151.101.1.195
TTL: Automatic

Type: A Record
Host: @ (أو sd)
Value: 151.101.65.195
TTL: Automatic
```

---

### GoDaddy

**DNS Management:**
1. My Products → Domains
2. اضغط DNS بجانب النطاق

**TXT Record:**
```
Type: TXT
Name: @ (أو sd)
Value: firebase=zahratamal-36602
TTL: 600
```

**A Records:**
```
Type: A
Name: @
Value: 151.101.1.195
TTL: 600

Type: A
Name: @
Value: 151.101.65.195
TTL: 600
```

---

### Cloudflare

**DNS Management:**
1. Dashboard → Select Domain
2. اضغط تبويب "DNS"

**TXT Record:**
```
Type: TXT
Name: @ (أو sd)
Content: firebase=zahratamal-36602
Proxy status: DNS only (gray cloud)
TTL: Auto
```

**A Records:**
```
Type: A
Name: @ (أو sd)
IPv4 address: 151.101.1.195
Proxy status: DNS only (gray cloud)
TTL: Auto

Type: A
Name: @ (أو sd)
IPv4 address: 151.101.65.195
Proxy status: DNS only (gray cloud)
TTL: Auto
```

> ⚠️ **مهم:** في Cloudflare، تأكد من **DNS only** (gray cloud) وليس **Proxied** (orange cloud)

---

### Google Domains

**DNS Management:**
1. My Domains → اختر النطاق
2. اضغط "DNS"

**TXT Record:**
```
Host name: @ (أو sd)
Type: TXT
TTL: 3600
Data: firebase=zahratamal-36602
```

**A Records:**
```
Host name: @
Type: A
TTL: 3600
Data: 151.101.1.195

Host name: @
Type: A
TTL: 3600
Data: 151.101.65.195
```

---

## 🔄 بعد الإعداد الناجح

### تحديث التطبيق

التحديثات المستقبلية لن تؤثر على النطاق:

```bash
# بناء التطبيق
flutter build web --release

# النشر (النطاق المخصص سيتحدث تلقائياً)
firebase deploy --only hosting
```

### إضافة نطاقات إضافية

يمكنك إضافة أكثر من نطاق:

**مثال:**
- `sd.zahrat.amal` → التطبيق الرئيسي
- `www.sd.zahrat.amal` → نفس التطبيق
- `app.zahrat.amal` → نفس التطبيق

**خطوات:**
1. في Firebase Console اضغط "Add custom domain"
2. أدخل النطاق الجديد
3. اتبع نفس الخطوات السابقة

### حذف نطاق

في Firebase Console:
1. Hosting → Custom domain
2. اضغط على النطاق
3. اختر "Remove domain"
4. (اختياري) احذف DNS Records من مزود النطاق

---

## 📊 معلومات تقنية

**Firebase Hosting IP Addresses:**
```
IPv4 (A Records):
151.101.1.195
151.101.65.195

IPv6 (AAAA Records):
2a04:4e42::347
2a04:4e42:200::347
```

**SSL Certificate:**
- يتم إنشاؤه تلقائياً بواسطة Firebase
- نوع الشهادة: Let's Encrypt
- التجديد: تلقائي (كل 90 يوم)
- الصلاحية: يدعم TLS 1.2 و TLS 1.3

**DNS Propagation:**
- محلياً (ISP الخاص بك): 5-30 دقيقة
- عالمياً: 24-48 ساعة (أحياناً أسرع)
- TTL: يؤثر على سرعة الانتشار

---

## 📞 الدعم والمساعدة

**Firebase Support:**
- Firebase Console: https://console.firebase.google.com/
- Firebase Hosting Docs: https://firebase.google.com/docs/hosting/custom-domain
- Firebase Status: https://status.firebase.google.com/

**DNS Tools:**
- DNS Checker: https://dnschecker.org/
- What's My DNS: https://www.whatsmydns.net/
- MX Toolbox: https://mxtoolbox.com/

**Community:**
- Stack Overflow: https://stackoverflow.com/questions/tagged/firebase-hosting
- Firebase Community: https://firebase.google.com/community

---

## ✅ الخلاصة

**الوقت الإجمالي للإعداد:**
- الإعداد الفعلي: 15-30 دقيقة
- الانتظار (DNS): 24-48 ساعة
- **المجموع:** حوالي يومين

**بعد الانتهاء:**
- ✅ تطبيقك متاح على: `https://sd.zahrat.amal`
- ✅ SSL Certificate نشط ومُجدد تلقائياً
- ✅ رابط احترافي دائم
- ✅ سرعة عالية (Firebase CDN)

**التكلفة:**
- Firebase Hosting: مجاني (Spark Plan)
- SSL Certificate: مجاني (Let's Encrypt)
- النطاق: حسب المزود (سنوي)

---

**آخر تحديث:** 17 ديسمبر 2025  
**المشروع:** زهرة الأمل - ZahratAmal  
**Firebase Project:** zahratamal-36602  
**Package Name:** sd.zahrat.amal
