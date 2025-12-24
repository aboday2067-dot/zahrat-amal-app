import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// ========== نظام الموافقة على التجار ومكاتب التوصيل ==========

// ===== 1. شاشة الموافقة على التجار =====

class MerchantsApprovalScreen extends StatefulWidget {
  const MerchantsApprovalScreen({super.key});

  @override
  State<MerchantsApprovalScreen> createState() => _MerchantsApprovalScreenState();
}

class _MerchantsApprovalScreenState extends State<MerchantsApprovalScreen> {
  String _selectedTab = 'pending'; // pending, approved, rejected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة التجار'),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('pending', 'المعلقة', Icons.pending_actions),
                ),
                Expanded(
                  child: _buildTabButton('approved', 'المقبولة', Icons.check_circle),
                ),
                Expanded(
                  child: _buildTabButton('rejected', 'المرفوضة', Icons.cancel),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'merchant')
                  .where('approvalStatus', isEqualTo: _selectedTab)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedTab == 'pending' ? Icons.inbox : 
                          _selectedTab == 'approved' ? Icons.check_circle_outline : Icons.cancel_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _selectedTab == 'pending' ? 'لا توجد طلبات معلقة' :
                          _selectedTab == 'approved' ? 'لا توجد طلبات مقبولة' : 'لا توجد طلبات مرفوضة',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final merchant = doc.data() as Map<String, dynamic>;
                    return _buildMerchantCard(doc.id, merchant);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String value, String label, IconData icon) {
    final isSelected = _selectedTab == value;
    return InkWell(
      onTap: () => setState(() => _selectedTab = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF6B9AC4) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF6B9AC4) : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF6B9AC4) : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMerchantCard(String merchantId, Map<String, dynamic> merchant) {
    final createdAt = merchant['createdAt'] as String?;
    final formattedDate = createdAt != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(createdAt))
        : 'غير محدد';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showMerchantDetails(merchantId, merchant),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF6B9AC4),
                    child: Text(
                      merchant['name']?.substring(0, 1) ?? 'T',
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          merchant['name'] ?? 'تاجر غير محدد',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '📧 ${merchant['email'] ?? 'غير محدد'}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          '📱 ${merchant['phone'] ?? 'غير محدد'}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  if (_selectedTab == 'pending')
                    const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip('📍 ${merchant['city'] ?? 'غير محدد'}'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip('📅 $formattedDate'),
                  ),
                ],
              ),
              if (_selectedTab == 'approved' && merchant['approvedAt'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _buildInfoChip(
                    '✅ تمت الموافقة: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(merchant['approvedAt']))}',
                    color: Colors.green,
                  ),
                ),
              if (_selectedTab == 'rejected' && merchant['rejectionReason'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _buildInfoChip(
                    '❌ سبب الرفض: ${merchant['rejectionReason']}',
                    color: Colors.red,
                  ),
                ),
              if (_selectedTab == 'pending')
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _approveMerchant(merchantId, merchant),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.check),
                          label: const Text('موافقة'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _rejectMerchant(merchantId, merchant),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.close),
                          label: const Text('رفض'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey[200])!.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color ?? Colors.grey[300]!),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: color ?? Colors.grey[800]),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _showMerchantDetails(String merchantId, Map<String, dynamic> merchant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return MerchantDetailsSheet(
            merchantId: merchantId,
            merchant: merchant,
            scrollController: scrollController,
            onApprove: () {
              Navigator.pop(context);
              _approveMerchant(merchantId, merchant);
            },
            onReject: () {
              Navigator.pop(context);
              _rejectMerchant(merchantId, merchant);
            },
          );
        },
      ),
    );
  }

  Future<void> _approveMerchant(String merchantId, Map<String, dynamic> merchant) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(merchantId).update({
        'approvalStatus': 'approved',
        'approvedAt': DateTime.now().toIso8601String(),
        'approvedBy': 'admin', // TODO: استخدام ID المدير الفعلي
      });

      // إرسال إشعار للتاجر
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': merchantId,
        'title': '🎉 تمت الموافقة على حسابك!',
        'message': 'مرحباً ${merchant['name']}! تمت الموافقة على حسابك كتاجر. يمكنك الآن البدء بإضافة منتجاتك والبيع عبر المنصة.',
        'type': 'merchant_approval',
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تمت الموافقة على التاجر: ${merchant['name']}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _rejectMerchant(String merchantId, Map<String, dynamic> merchant) async {
    final reasonController = TextEditingController();

    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض الطلب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل أنت متأكد من رفض طلب: ${merchant['name']}؟'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'سبب الرفض',
                hintText: 'اكتب سبب الرفض...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, reasonController.text),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('رفض'),
          ),
        ],
      ),
    );

    if (reason == null || reason.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(merchantId).update({
        'approvalStatus': 'rejected',
        'rejectedAt': DateTime.now().toIso8601String(),
        'rejectionReason': reason,
        'rejectedBy': 'admin', // TODO: استخدام ID المدير الفعلي
      });

      // إرسال إشعار للتاجر
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': merchantId,
        'title': '❌ تم رفض طلبك',
        'message': 'عذراً ${merchant['name']}، تم رفض طلب التسجيل كتاجر. السبب: $reason',
        'type': 'merchant_rejection',
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم رفض طلب التاجر: ${merchant['name']}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

// ===== 2. ورقة تفاصيل التاجر =====

class MerchantDetailsSheet extends StatelessWidget {
  final String merchantId;
  final Map<String, dynamic> merchant;
  final ScrollController scrollController;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const MerchantDetailsSheet({
    super.key,
    required this.merchantId,
    required this.merchant,
    required this.scrollController,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFF6B9AC4),
                        child: Text(
                          merchant['name']?.substring(0, 1) ?? 'T',
                          style: const TextStyle(fontSize: 36, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        merchant['name'] ?? 'تاجر غير محدد',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusChip(merchant['approvalStatus']),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Personal Information
                _buildSectionTitle('المعلومات الشخصية'),
                _buildInfoRow(Icons.email, 'البريد الإلكتروني', merchant['email'] ?? 'غير محدد'),
                _buildInfoRow(Icons.phone, 'رقم الهاتف', merchant['phone'] ?? 'غير محدد'),
                _buildInfoRow(Icons.location_city, 'المدينة', merchant['city'] ?? 'غير محدد'),
                _buildInfoRow(Icons.home, 'الحي', merchant['district'] ?? 'غير محدد'),
                _buildInfoRow(Icons.calendar_today, 'تاريخ التسجيل', 
                  merchant['createdAt'] != null 
                    ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(merchant['createdAt']))
                    : 'غير محدد'),
                const SizedBox(height: 24),
                // Business Information
                _buildSectionTitle('معلومات المتجر'),
                _buildInfoRow(Icons.store, 'نوع النشاط', merchant['businessType'] ?? 'غير محدد'),
                _buildInfoRow(Icons.description, 'الوصف', merchant['businessDescription'] ?? 'لا يوجد وصف'),
                const SizedBox(height: 24),
                // Approval Actions
                if (merchant['approvalStatus'] == 'pending') ...[
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onApprove,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('الموافقة على الطلب'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onReject,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: const Icon(Icons.cancel),
                          label: const Text('رفض الطلب'),
                        ),
                      ),
                    ],
                  ),
                ],
                if (merchant['approvalStatus'] == 'approved') ...[
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.check_circle, 'تمت الموافقة في', 
                    merchant['approvedAt'] != null
                      ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(merchant['approvedAt']))
                      : 'غير محدد'),
                ],
                if (merchant['approvalStatus'] == 'rejected') ...[
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.cancel, 'سبب الرفض', merchant['rejectionReason'] ?? 'غير محدد'),
                  _buildInfoRow(Icons.access_time, 'تاريخ الرفض',
                    merchant['rejectedAt'] != null
                      ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(merchant['rejectedAt']))
                      : 'غير محدد'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'approved':
        color = Colors.green;
        text = 'مقبول';
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = Colors.red;
        text = 'مرفوض';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.orange;
        text = 'معلق';
        icon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6B9AC4)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
