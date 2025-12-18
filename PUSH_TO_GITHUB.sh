#!/bin/bash

# 🚀 سكربت رفع المشروع إلى GitHub تلقائياً
# ZahratAmal - Smart Sudan Market

echo "🚀 بدء رفع مشروع ZahratAmal إلى GitHub..."
echo ""

# التأكد من وجود Git
if ! command -v git &> /dev/null; then
    echo "❌ Git غير مثبت! حمّل Git من: https://git-scm.com/"
    exit 1
fi

echo "✅ Git موجود"
echo ""

# الانتقال إلى مجلد المشروع
cd "$(dirname "$0")"
echo "📂 المجلد الحالي: $(pwd)"
echo ""

# تهيئة Git (إذا لزم الأمر)
echo "🔧 تهيئة Git..."
git config user.name "aboday2067-dot"
git config user.email "aboday2067@github.com"
echo ""

# التحقق من حالة Git
echo "📊 حالة Git الحالية:"
git status
echo ""

# إضافة جميع الملفات
echo "📦 إضافة جميع الملفات..."
git add .
echo ""

# عمل Commit
echo "💾 عمل Commit..."
git commit -m "Complete ZahratAmal project: 155 files with documentation, screenshots, and privacy policy"
echo ""

# التحقق من Remote
if ! git remote get-url origin &> /dev/null; then
    echo "🔗 إضافة Remote..."
    git remote add origin https://github.com/aboday2067-dot/zahrat-amal-app.git
else
    echo "✅ Remote موجود مسبقاً"
fi
echo ""

# رفع إلى GitHub
echo "🚀 رفع المشروع إلى GitHub..."
echo "⚠️ سيطلب منك GitHub اسم المستخدم وكلمة المرور أو Personal Access Token"
echo ""

git push -u origin main

# التحقق من نجاح العملية
if [ $? -eq 0 ]; then
    echo ""
    echo "✅✅✅ تم رفع المشروع بنجاح! ✅✅✅"
    echo ""
    echo "🔗 Repository URL:"
    echo "   https://github.com/aboday2067-dot/zahrat-amal-app"
    echo ""
    echo "📋 الخطوة التالية: تفعيل GitHub Pages"
    echo "   1. اذهب إلى: https://github.com/aboday2067-dot/zahrat-amal-app/settings/pages"
    echo "   2. في Source، اختر: Branch = main, Folder = / (root)"
    echo "   3. اضغط Save"
    echo "   4. انتظر 2-3 دقائق"
    echo ""
    echo "🌐 بعد تفعيل GitHub Pages، سيكون لديك:"
    echo "   - رابط التطبيق: https://aboday2067-dot.github.io/zahrat-amal-app/"
    echo "   - رابط سياسة الخصوصية: https://aboday2067-dot.github.io/zahrat-amal-app/privacy-policy.html"
    echo ""
else
    echo ""
    echo "❌ فشل رفع المشروع!"
    echo ""
    echo "💡 الحلول البديلة:"
    echo "   1. استخدم GitHub Desktop: https://desktop.github.com/"
    echo "   2. رفع مباشر عبر Web: https://github.com/aboday2067-dot/zahrat-amal-app"
    echo "   3. استخدم Personal Access Token بدلاً من كلمة المرور"
    echo ""
fi
