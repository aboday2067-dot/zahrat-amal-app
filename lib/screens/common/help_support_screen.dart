import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: const Text(
            'المساعدة والدعم',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // بطاقة الاتصال
            _buildContactCard(context),
            
            const SizedBox(height: 24),
            
            // الأسئلة الشائعة
            _buildSectionTitle('الأسئلة الشائعة'),
            _buildFAQItem(
              question: 'كيف يمكنني إنشاء حساب؟',
              answer: 'يمكنك إنشاء حساب بالضغط على "إنشاء حساب جديد" من صفحة تسجيل الدخول وإدخال بياناتك الشخصية.',
            ),
            _buildFAQItem(
              question: 'كيف يمكنني إضافة منتج للسلة؟',
              answer: 'اضغط على المنتج المطلوب ثم اضغط "إضافة إلى السلة" من صفحة تفاصيل المنتج.',
            ),
            _buildFAQItem(
              question: 'ما هي طرق الدفع المتاحة؟',
              answer: 'نوفر الدفع عند الاستلام، MOMO، وبطاقة الفيزا.',
            ),
            _buildFAQItem(
              question: 'كيف يمكنني تتبع طلبي؟',
              answer: 'يمكنك تتبع طلباتك من قسم "طلباتي" في القائمة الرئيسية.',
            ),
            _buildFAQItem(
              question: 'كيف يمكنني تغيير كلمة المرور؟',
              answer: 'اذهب إلى الإعدادات > الحساب > تغيير كلمة المرور.',
            ),
            
            const SizedBox(height: 24),
            
            // دليل الاستخدام
            _buildSectionTitle('دليل الاستخدام'),
            _buildGuideCard([
              _buildGuideTile(
                icon: Icons.shopping_cart,
                title: 'التسوق والشراء',
                subtitle: 'تعلم كيفية استخدام التطبيق للتسوق',
                onTap: () {
                  _showGuideDialog(
                    context,
                    'التسوق والشراء',
                    '1. تصفح المنتجات من الصفحة الرئيسية\n2. اختر المنتج المطلوب\n3. أضفه للسلة\n4. اذهب للسلة وأكمل عملية الشراء',
                  );
                },
              ),
              _buildDivider(),
              _buildGuideTile(
                icon: Icons.store,
                title: 'للتجار',
                subtitle: 'دليل استخدام لوحة التاجر',
                onTap: () {
                  _showGuideDialog(
                    context,
                    'دليل التجار',
                    '1. أنشئ حساب تاجر\n2. أضف منتجاتك من لوحة التحكم\n3. أدِر طلباتك ومخزونك\n4. تابع مبيعاتك وإحصائياتك',
                  );
                },
              ),
              _buildDivider(),
              _buildGuideTile(
                icon: Icons.delivery_dining,
                title: 'لمكاتب التوصيل',
                subtitle: 'دليل استخدام نظام التوصيل',
                onTap: () {
                  _showGuideDialog(
                    context,
                    'دليل مكاتب التوصيل',
                    '1. سجّل مكتب التوصيل\n2. أضف المناطق التي تخدمها\n3. أدِر عمال التوصيل\n4. تابع حالة الطلبات والمبيعات',
                  );
                },
              ),
            ]),
            
            const SizedBox(height: 24),
            
            // الإبلاغ عن مشكلة
            _buildSectionTitle('الإبلاغ عن مشكلة'),
            _buildGuideCard([
              _buildGuideTile(
                icon: Icons.bug_report,
                title: 'الإبلاغ عن خطأ',
                subtitle: 'أبلغنا عن أي مشكلة تقنية',
                onTap: () {
                  _showReportDialog(context);
                },
              ),
              _buildDivider(),
              _buildGuideTile(
                icon: Icons.feedback,
                title: 'إرسال ملاحظات',
                subtitle: 'شاركنا آرائك واقتراحاتك',
                onTap: () {
                  _showFeedbackDialog(context);
                },
              ),
            ]),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.teal[400]!, Colors.teal[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.headset_mic,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            const Text(
              'تواصل معنا',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'نحن هنا لمساعدتك على مدار الساعة',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildContactButton(
                  icon: Icons.email,
                  label: 'البريد',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('support@zahrat.sd'),
                      ),
                    );
                  },
                ),
                _buildContactButton(
                  icon: Icons.phone,
                  label: 'الهاتف',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('+249 911 234 567'),
                      ),
                    );
                  },
                ),
                _buildContactButton(
                  icon: Icons.chat,
                  label: 'واتساب',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('+249 911 234 567'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                answer,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: children),
    );
  }

  Widget _buildGuideTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal[600]),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey[300]);
  }

  void _showGuideDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('الإبلاغ عن مشكلة'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'اشرح المشكلة التي واجهتك...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('شكراً لك! تم إرسال البلاغ بنجاح'),
                  ),
                );
              },
              child: const Text('إرسال'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('إرسال ملاحظات'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'شاركنا آرائك واقتراحاتك...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('شكراً لك! تم إرسال ملاحظاتك بنجاح'),
                  ),
                );
              },
              child: const Text('إرسال'),
            ),
          ],
        ),
      ),
    );
  }
}
