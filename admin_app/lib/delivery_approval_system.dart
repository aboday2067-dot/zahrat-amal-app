import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// ========== نظام الموافقة على مكاتب التوصيل ==========

class DeliveryOfficesApprovalScreen extends StatefulWidget {
  const DeliveryOfficesApprovalScreen({super.key});

  @override
  State<DeliveryOfficesApprovalScreen> createState() => _DeliveryOfficesApprovalScreenState();
}

class _DeliveryOfficesApprovalScreenState extends State<DeliveryOfficesApprovalScreen> {
  String _selectedTab = 'pending'; // pending, approved, rejected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة مكاتب التوصيل'),
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
                  .where('role', isEqualTo: 'delivery')
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
                    final office = doc.data() as Map<String, dynamic>;
                    return _buildDeliveryOfficeCard(doc.id, office);
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

  Widget _buildDeliveryOfficeCard(String officeId, Map<String, dynamic> office) {
    final createdAt = office['createdAt'] as String?;
    final formattedDate = createdAt != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(createdAt))
        : 'غير محدد';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showOfficeDetails(officeId, office),
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
                    child: const Icon(Icons.local_shipping, size: 30, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          office['officeName'] ?? office['name'] ?? 'مكتب غير محدد',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '📧 ${office['email'] ?? 'غير محدد'}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Text(
                          '📱 ${office['phone'] ?? 'غير محدد'}',
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
                    child: _buildInfoChip('📍 ${office['city'] ?? 'غير محدد'}'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip('📅 $formattedDate'),
                  ),
                ],
              ),
              if (office['coverageAreas'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _buildInfoChip(
                    '🗺️ مناطق التغطية: ${(office['coverageAreas'] as List).length}',
                    color: Colors.blue,
                  ),
                ),
              if (_selectedTab == 'approved' && office['approvedAt'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _buildInfoChip(
                    '✅ تمت الموافقة: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(office['approvedAt']))}',
                    color: Colors.green,
                  ),
                ),
              if (_selectedTab == 'rejected' && office['rejectionReason'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _buildInfoChip(
                    '❌ سبب الرفض: ${office['rejectionReason']}',
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
                          onPressed: () => _approveOffice(officeId, office),
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
                          onPressed: () => _rejectOffice(officeId, office),
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

  void _showOfficeDetails(String officeId, Map<String, dynamic> office) {
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
          return DeliveryOfficeDetailsSheet(
            officeId: officeId,
            office: office,
            scrollController: scrollController,
            onApprove: () {
              Navigator.pop(context);
              _approveOffice(officeId, office);
            },
            onReject: () {
              Navigator.pop(context);
              _rejectOffice(officeId, office);
            },
          );
        },
      ),
    );
  }

  Future<void> _approveOffice(String officeId, Map<String, dynamic> office) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(officeId).update({
        'approvalStatus': 'approved',
        'approvedAt': DateTime.now().toIso8601String(),
        'approvedBy': 'admin',
      });

      // إرسال إشعار لمكتب التوصيل
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': officeId,
        'title': '🎉 تمت الموافقة على مكتبكم!',
        'message': 'مرحباً ${office['officeName'] ?? office['name']}! تمت الموافقة على تسجيل مكتبكم. يمكنكم الآن استقبال طلبات التوصيل.',
        'type': 'delivery_approval',
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تمت الموافقة على مكتب: ${office['officeName'] ?? office['name']}'),
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

  Future<void> _rejectOffice(String officeId, Map<String, dynamic> office) async {
    final reasonController = TextEditingController();

    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض الطلب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل أنت متأكد من رفض طلب: ${office['officeName'] ?? office['name']}؟'),
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
      await FirebaseFirestore.instance.collection('users').doc(officeId).update({
        'approvalStatus': 'rejected',
        'rejectedAt': DateTime.now().toIso8601String(),
        'rejectionReason': reason,
        'rejectedBy': 'admin',
      });

      // إرسال إشعار لمكتب التوصيل
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': officeId,
        'title': '❌ تم رفض طلبكم',
        'message': 'عذراً ${office['officeName'] ?? office['name']}، تم رفض طلب التسجيل. السبب: $reason',
        'type': 'delivery_rejection',
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم رفض طلب المكتب: ${office['officeName'] ?? office['name']}'),
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

// ===== ورقة تفاصيل مكتب التوصيل =====

class DeliveryOfficeDetailsSheet extends StatelessWidget {
  final String officeId;
  final Map<String, dynamic> office;
  final ScrollController scrollController;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const DeliveryOfficeDetailsSheet({
    super.key,
    required this.officeId,
    required this.office,
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
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B9AC4),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(Icons.local_shipping, size: 50, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        office['officeName'] ?? office['name'] ?? 'مكتب غير محدد',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      _buildStatusChip(office['approvalStatus']),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Contact Information
                _buildSectionTitle('معلومات الاتصال'),
                _buildInfoRow(Icons.email, 'البريد الإلكتروني', office['email'] ?? 'غير محدد'),
                _buildInfoRow(Icons.phone, 'رقم الهاتف', office['phone'] ?? 'غير محدد'),
                _buildInfoRow(Icons.location_city, 'المدينة', office['city'] ?? 'غير محدد'),
                _buildInfoRow(Icons.home, 'العنوان', office['address'] ?? 'غير محدد'),
                _buildInfoRow(Icons.calendar_today, 'تاريخ التسجيل',
                  office['createdAt'] != null
                    ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(office['createdAt']))
                    : 'غير محدد'),
                const SizedBox(height: 24),
                // Coverage Areas
                _buildSectionTitle('مناطق التغطية'),
                if (office['coverageAreas'] != null && (office['coverageAreas'] as List).isNotEmpty)
                  ...( office['coverageAreas'] as List).map((area) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Color(0xFF6B9AC4)),
                            const SizedBox(width: 8),
                            Text(area.toString()),
                          ],
                        ),
                      ))
                else
                  const Text('لا توجد مناطق تغطية محددة'),
                const SizedBox(height: 24),
                // Delivery Prices
                if (office['deliveryPrices'] != null) ...[
                  _buildSectionTitle('أسعار التوصيل'),
                  ...(office['deliveryPrices'] as Map<String, dynamic>).entries.map(
                    (entry) => _buildInfoRow(
                      Icons.attach_money,
                      entry.key,
                      '${entry.value} جنيه',
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                // Approval Actions
                if (office['approvalStatus'] == 'pending') ...[
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
                if (office['approvalStatus'] == 'approved') ...[
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.check_circle, 'تمت الموافقة في',
                    office['approvedAt'] != null
                      ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(office['approvedAt']))
                      : 'غير محدد'),
                ],
                if (office['approvalStatus'] == 'rejected') ...[
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.cancel, 'سبب الرفض', office['rejectionReason'] ?? 'غير محدد'),
                  _buildInfoRow(Icons.access_time, 'تاريخ الرفض',
                    office['rejectedAt'] != null
                      ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(office['rejectedAt']))
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
