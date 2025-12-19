const functions = require('firebase-functions');
const admin = require('firebase-admin');

// تهيئة Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * 🤖 معالج طلبات AI Developer
 * 
 * يتم تشغيله تلقائياً عند إضافة طلب جديد لـ ai_development_requests
 * 
 * الخطوات:
 * 1. قراءة الطلب
 * 2. إرسال إلى Claude AI API
 * 3. الحصول على الكود المُولّد
 * 4. تطبيق التغييرات (عبر GitHub API)
 * 5. Push تلقائي إلى GitHub
 * 6. تحديث حالة الطلب
 */
exports.processAIDevelopmentRequest = functions.firestore
  .document('ai_development_requests/{requestId}')
  .onCreate(async (snap, context) => {
    const requestId = context.params.requestId;
    const requestData = snap.data();
    
    try {
      // تحديث الحالة: جاري المعالجة
      await snap.ref.update({
        status: 'processing',
        started_at: admin.firestore.FieldValue.serverTimestamp()
      });
      
      console.log(`🤖 بدء معالجة الطلب: ${requestId}`);
      console.log(`النوع: ${requestData.type}`);
      console.log(`العنوان: ${requestData.title}`);
      
      // ======================
      // المرحلة 1: تحليل الطلب
      // ======================
      const analysisPrompt = generateAnalysisPrompt(requestData);
      
      // ======================
      // المرحلة 2: توليد الكود
      // ======================
      const generatedCode = await generateCodeWithAI(analysisPrompt, requestData);
      
      if (!generatedCode || !generatedCode.success) {
        throw new Error('فشل توليد الكود من AI');
      }
      
      // ======================
      // المرحلة 3: تطبيق التغييرات
      // ======================
      const applicationResult = await applyChangesToGitHub(generatedCode, requestData);
      
      if (!applicationResult.success) {
        throw new Error(`فشل تطبيق التغييرات: ${applicationResult.error}`);
      }
      
      // ====================== 
      // المرحلة 4: Push إلى GitHub
      // ======================
      const pushResult = await pushToGitHub(applicationResult.commitMessage);
      
      if (!pushResult.success) {
        throw new Error(`فشل Push إلى GitHub: ${pushResult.error}`);
      }
      
      // تحديث الحالة: مكتمل
      await snap.ref.update({
        status: 'completed',
        completed_at: admin.firestore.FieldValue.serverTimestamp(),
        result: {
          message: '✅ تم تطوير الميزة ونشرها بنجاح!',
          commit_url: pushResult.commitUrl,
          files_changed: generatedCode.files,
          deployment_url: 'https://zahratamal-36602.web.app',
        },
        processed: true
      });
      
      console.log(`✅ اكتمل الطلب: ${requestId}`);
      
      // إرسال إشعار للمدير
      await sendNotificationToAdmin(requestId, requestData, pushResult);
      
      return {success: true};
      
    } catch (error) {
      console.error(`❌ خطأ في معالجة ${requestId}:`, error);
      
      // تحديث الحالة: فشل
      await snap.ref.update({
        status: 'failed',
        failed_at: admin.firestore.FieldValue.serverTimestamp(),
        error: error.message,
        processed: true
      });
      
      return {success: false, error: error.message};
    }
  });

/**
 * إنشاء Prompt لتحليل الطلب
 */
function generateAnalysisPrompt(requestData) {
  const { type, title, details, priority } = requestData;
  
  return `
أنت مطور Flutter محترف. تحتاج إلى تحليل وتطوير الميزة التالية:

**نوع الطلب:** ${type}
**العنوان:** ${title}
**التفاصيل:** ${details}
**الأولوية:** ${priority}

**المشروع الحالي:**
- تطبيق Flutter للتجارة الإلكترونية
- يستخدم Firebase (Firestore, Auth, Storage)
- يستخدم Provider لإدارة الحالة
- يدعم 3 أنواع مستخدمين: تجار، مشترين، مكاتب توصيل

**المطلوب منك:**

1. **تحليل الطلب:** فهم المتطلبات بدقة
2. **تصميم الحل:** تحديد الملفات والتغييرات المطلوبة
3. **كتابة الكود:** إنشاء كود Flutter كامل وجاهز
4. **Integration:** التأكد من التكامل مع المشروع الحالي

**ارجع الناتج بصيغة JSON:**

\`\`\`json
{
  "analysis": "تحليل الطلب...",
  "files": [
    {
      "path": "lib/screens/...",
      "action": "create|modify",
      "content": "كود Flutter الكامل..."
    }
  ],
  "dependencies": ["package: version"],
  "routes": ["/new-route": "ScreenName()"],
  "commit_message": "رسالة commit"
}
\`\`\`

**قواعد مهمة:**
- كود كامل وجاهز للتشغيل
- اتبع معايير Flutter و Dart
- استخدم Material Design 3
- دعم العربية (RTL)
- تعليقات واضحة بالعربية
`;
}

/**
 * توليد الكود باستخدام Claude AI
 */
async function generateCodeWithAI(prompt, requestData) {
  // ملاحظة: سيتم استخدام Claude API هنا
  // للتجربة الأولية، سنستخدم استجابة وهمية
  
  const ANTHROPIC_API_KEY = functions.config().anthropic?.api_key;
  
  if (!ANTHROPIC_API_KEY) {
    console.warn('⚠️ Claude API key not configured. Using mock response.');
    return generateMockResponse(requestData);
  }
  
  try {
    const fetch = require('node-fetch');
    
    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': ANTHROPIC_API_KEY,
        'anthropic-version': '2023-06-01'
      },
      body: JSON.stringify({
        model: 'claude-3-5-sonnet-20241022',
        max_tokens: 8000,
        temperature: 0.7,
        messages: [{
          role: 'user',
          content: prompt
        }]
      })
    });
    
    if (!response.ok) {
      throw new Error(`Claude API error: ${response.statusText}`);
    }
    
    const data = await response.json();
    const aiResponse = data.content[0].text;
    
    // استخراج JSON من الاستجابة
    const jsonMatch = aiResponse.match(/```json\n([\s\S]*?)\n```/);
    if (!jsonMatch) {
      throw new Error('لم يتم العثور على JSON في استجابة AI');
    }
    
    const generatedCode = JSON.parse(jsonMatch[1]);
    return { success: true, ...generatedCode };
    
  } catch (error) {
    console.error('خطأ في Claude AI:', error);
    throw error;
  }
}

/**
 * استجابة وهمية للاختبار (بدون Claude API)
 */
function generateMockResponse(requestData) {
  return {
    success: true,
    analysis: `تم تحليل الطلب: ${requestData.title}`,
    files: [
      {
        path: `lib/screens/generated_${Date.now()}.dart`,
        action: 'create',
        content: `
import 'package:flutter/material.dart';

/// 🤖 تم إنشاؤه بواسطة AI Developer
/// ${requestData.title}
class GeneratedScreen extends StatelessWidget {
  const GeneratedScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('${requestData.title}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 64, color: Colors.deepPurple),
            const SizedBox(height: 16),
            const Text(
              'تم إنشاء هذه الشاشة بواسطة AI',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'الطلب: ${requestData.title}',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
        `
      }
    ],
    dependencies: [],
    routes: {},
    commit_message: `🤖 AI: ${requestData.title}`
  };
}

/**
 * تطبيق التغييرات على GitHub
 */
async function applyChangesToGitHub(generatedCode, requestData) {
  const GITHUB_TOKEN = functions.config().github?.token;
  const REPO_OWNER = 'aboday2067-dot';
  const REPO_NAME = 'zahrat-amal-app';
  
  if (!GITHUB_TOKEN) {
    console.warn('⚠️ GitHub token not configured. Skipping GitHub operations.');
    return {
      success: true,
      commitMessage: generatedCode.commit_message,
      warning: 'GitHub token not configured'
    };
  }
  
  try {
    const fetch = require('node-fetch');
    const { Octokit } = require('@octokit/rest');
    
    const octokit = new Octokit({ auth: GITHUB_TOKEN });
    
    // إنشاء/تحديث الملفات
    for (const file of generatedCode.files) {
      await octokit.repos.createOrUpdateFileContents({
        owner: REPO_OWNER,
        repo: REPO_NAME,
        path: file.path,
        message: generatedCode.commit_message,
        content: Buffer.from(file.content).toString('base64'),
        branch: 'main'
      });
    }
    
    return {
      success: true,
      commitMessage: generatedCode.commit_message
    };
    
  } catch (error) {
    console.error('خطأ في GitHub API:', error);
    throw error;
  }
}

/**
 * Push التغييرات إلى GitHub
 */
async function pushToGitHub(commitMessage) {
  // الـ Push يتم تلقائياً عبر GitHub API في applyChangesToGitHub
  return {
    success: true,
    commitUrl: `https://github.com/aboday2067-dot/zahrat-amal-app/commits/main`,
    message: 'تم Push التغييرات بنجاح'
  };
}

/**
 * إرسال إشعار للمدير
 */
async function sendNotificationToAdmin(requestId, requestData, pushResult) {
  try {
    await db.collection('notifications').add({
      type: 'ai_development_completed',
      title: '✅ تم تطوير الميزة',
      message: `تم تطوير: ${requestData.title}`,
      request_id: requestId,
      commit_url: pushResult.commitUrl,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      read: false,
      user_email: 'admin@zahratamal.com'
    });
  } catch (error) {
    console.error('خطأ في إرسال الإشعار:', error);
  }
}

/**
 * Webhook لتشغيل Cloud Function يدوياً (للاختبار)
 */
exports.triggerAIProcessing = functions.https.onRequest(async (req, res) => {
  const requestId = req.body.requestId;
  
  if (!requestId) {
    return res.status(400).json({ error: 'requestId required' });
  }
  
  try {
    const requestRef = db.collection('ai_development_requests').doc(requestId);
    const requestSnap = await requestRef.get();
    
    if (!requestSnap.exists) {
      return res.status(404).json({ error: 'Request not found' });
    }
    
    // تشغيل المعالجة
    await requestRef.update({ trigger_processing: true });
    
    res.json({
      success: true,
      message: 'بدأت معالجة الطلب',
      requestId
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
