import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 🤖 شاشة AI Developer - تطوير تلقائي بالذكاء الاصطناعي
class AIDeveloperScreen extends StatefulWidget {
  const AIDeveloperScreen({super.key});

  @override
  State<AIDeveloperScreen> createState() => _AIDeveloperScreenState();
}

class _AIDeveloperScreenState extends State<AIDeveloperScreen> {
  final _formKey = GlobalKey<FormState>();
  final _featureController = TextEditingController();
  final _detailsController = TextEditingController();
  
  String _selectedType = 'feature';
  String _selectedPriority = 'medium';
  bool _isProcessing = false;
  
  final List<Map<String, dynamic>> _requestTypes = [
    {'value': 'feature', 'label': '✨ ميزة جديدة', 'icon': Icons.add_circle},
    {'value': 'improvement', 'label': '🔧 تحسين', 'icon': Icons.build},
    {'value': 'fix', 'label': '🐛 إصلاح', 'icon': Icons.bug_report},
    {'value': 'ui', 'label': '🎨 تحسين واجهة', 'icon': Icons.palette},
    {'value': 'performance', 'label': '⚡ تحسين أداء', 'icon': Icons.speed},
  ];
  
  final List<Map<String, dynamic>> _priorities = [
    {'value': 'low', 'label': '🟢 منخفض', 'color': Colors.green},
    {'value': 'medium', 'label': '🟡 متوسط', 'color': Colors.orange},
    {'value': 'high', 'label': '🔴 عالي', 'color': Colors.red},
    {'value': 'urgent', 'label': '🚨 عاجل', 'color': Colors.deepOrange},
  ];

  @override
  void dispose() {
    _featureController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isProcessing = true);
    
    try {
      // إنشاء طلب AI جديد
      final request = {
        'type': _selectedType,
        'title': _featureController.text.trim(),
        'details': _detailsController.text.trim(),
        'priority': _selectedPriority,
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
        'created_by': 'admin@zahratamal.com',
        'processed': false,
        'result': null,
        'error': null,
      };
      
      // حفظ في Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('ai_development_requests')
          .add(request);
      
      if (!mounted) return;
      
      // إرسال إلى Cloud Function للمعالجة
      await _triggerAIProcessing(docRef.id);
      
      // إظهار رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم إرسال الطلب! سيتم المعالجة خلال دقائق'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );
      
      // مسح النموذج
      _featureController.clear();
      _detailsController.clear();
      setState(() {
        _selectedType = 'feature';
        _selectedPriority = 'medium';
      });
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
  
  Future<void> _triggerAIProcessing(String requestId) async {
    // في الإصدار المستقبلي: استدعاء Cloud Function
    // الآن: علامة للمعالجة
    await FirebaseFirestore.instance
        .collection('ai_development_requests')
        .doc(requestId)
        .update({'trigger_processing': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI Developer'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purple.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.auto_awesome, size: 64, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'مطور ذكاء اصطناعي',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اطلب أي ميزة أو تحسين وسيقوم الذكاء الاصطناعي بتطويره تلقائياً',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            // النموذج
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // نوع الطلب
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '📋 نوع الطلب',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _requestTypes.map((type) {
                                final isSelected = _selectedType == type['value'];
                                return ChoiceChip(
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        type['icon'] as IconData,
                                        size: 18,
                                        color: isSelected ? Colors.white : Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(type['label'] as String),
                                    ],
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() => _selectedType = type['value'] as String);
                                    }
                                  },
                                  selectedColor: Colors.deepPurple,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // العنوان
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '📝 عنوان الميزة',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _featureController,
                              decoration: const InputDecoration(
                                hintText: 'مثال: إضافة نظام تقييم المنتجات',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.title),
                              ),
                              maxLength: 100,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'الرجاء إدخال عنوان الميزة';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // التفاصيل
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '📄 التفاصيل والمتطلبات',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _detailsController,
                              decoration: const InputDecoration(
                                hintText: 'اشرح بالتفصيل ما تريد إضافته أو تحسينه...\n\nمثال:\n- إضافة نجوم تقييم (1-5)\n- إمكانية كتابة تعليق\n- عرض متوسط التقييم\n- فلترة حسب التقييم',
                                border: OutlineInputBorder(),
                                alignLabelWithHint: true,
                              ),
                              maxLines: 8,
                              maxLength: 1000,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'الرجاء إدخال تفاصيل الطلب';
                                }
                                if (value.trim().length < 20) {
                                  return 'الرجاء كتابة تفاصيل أكثر (20 حرف على الأقل)';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // الأولوية
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '⚡ الأولوية',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _priorities.map((priority) {
                                final isSelected = _selectedPriority == priority['value'];
                                return ChoiceChip(
                                  label: Text(priority['label'] as String),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() => _selectedPriority = priority['value'] as String);
                                    }
                                  },
                                  selectedColor: priority['color'] as Color,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // زر الإرسال
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _submitRequest,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.rocket_launch),
                      label: Text(
                        _isProcessing ? 'جاري الإرسال...' : '🚀 إرسال للذكاء الاصطناعي',
                        style: const TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // سجل الطلبات
                    _buildRequestsHistory(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRequestsHistory() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  'سجل الطلبات',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('ai_development_requests')
                  .orderBy('created_at', descending: true)
                  .limit(10)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('خطأ: ${snapshot.error}');
                }
                
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'لا توجد طلبات بعد\nابدأ بإضافة أول طلب!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
                
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    
                    return _buildRequestItem(doc.id, data);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRequestItem(String id, Map<String, dynamic> data) {
    final status = data['status'] ?? 'pending';
    final type = data['type'] ?? 'feature';
    final title = data['title'] ?? 'بدون عنوان';
    final priority = data['priority'] ?? 'medium';
    
    final statusInfo = _getStatusInfo(status);
    final typeInfo = _requestTypes.firstWhere(
      (t) => t['value'] == type,
      orElse: () => _requestTypes.first,
    );
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: statusInfo['color'] as Color,
        child: Icon(
          statusInfo['icon'] as IconData,
          color: Colors.white,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(typeInfo['icon'] as IconData, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                typeInfo['label'] as String,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 12),
              Text(
                _getPriorityLabel(priority),
                style: TextStyle(
                  fontSize: 12,
                  color: _getPriorityColor(priority),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            statusInfo['label'] as String,
            style: TextStyle(
              fontSize: 12,
              color: statusInfo['color'] as Color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.info_outline),
        onPressed: () => _showRequestDetails(id, data),
      ),
    );
  }
  
  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'pending':
        return {
          'label': '⏳ قيد الانتظار',
          'color': Colors.orange,
          'icon': Icons.hourglass_empty,
        };
      case 'processing':
        return {
          'label': '🔄 جاري المعالجة',
          'color': Colors.blue,
          'icon': Icons.sync,
        };
      case 'completed':
        return {
          'label': '✅ مكتمل',
          'color': Colors.green,
          'icon': Icons.check_circle,
        };
      case 'failed':
        return {
          'label': '❌ فشل',
          'color': Colors.red,
          'icon': Icons.error,
        };
      default:
        return {
          'label': status,
          'color': Colors.grey,
          'icon': Icons.help,
        };
    }
  }
  
  String _getPriorityLabel(String priority) {
    return _priorities.firstWhere(
      (p) => p['value'] == priority,
      orElse: () => _priorities[1],
    )['label'] as String;
  }
  
  Color _getPriorityColor(String priority) {
    return _priorities.firstWhere(
      (p) => p['value'] == priority,
      orElse: () => _priorities[1],
    )['color'] as Color;
  }
  
  void _showRequestDetails(String id, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['title'] ?? 'تفاصيل الطلب'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('📋 التفاصيل:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(data['details'] ?? 'لا توجد تفاصيل'),
              SizedBox(height: 16),
              if (data['result'] != null) ...[
                Text('✅ النتيجة:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(data['result']),
              ],
              if (data['error'] != null) ...[
                Text('❌ الخطأ:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                SizedBox(height: 8),
                Text(data['error'], style: TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
