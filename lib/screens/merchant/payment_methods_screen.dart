import 'package:flutter/material.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final Map<String, bool> _paymentMethods = {
    'SADAD': true,
    'MOMO': true,
    'Cash': true,
    'Bank Transfer': false,
  };

  final Map<String, Map<String, dynamic>> _paymentDetails = {
    'SADAD': {
      'accountNumber': '1234567890',
      'accountName': 'محمد أحمد',
      'isConfigured': true,
    },
    'MOMO': {
      'phoneNumber': '0912345678',
      'accountName': 'محمد أحمد',
      'isConfigured': true,
    },
    'Cash': {
      'isConfigured': true,
    },
    'Bank Transfer': {
      'bankName': '',
      'accountNumber': '',
      'accountName': '',
      'isConfigured': false,
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('طرق الدفع'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildPaymentMethodsList(),
            const SizedBox(height: 20),
            _buildAddNewPaymentButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.teal, Colors.tealAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.payment, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'طرق الدفع المفعّلة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_paymentMethods.values.where((v) => v).length} من ${_paymentMethods.length} طرق',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'طرق الدفع المتاحة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._paymentMethods.keys.map((method) => _buildPaymentMethodCard(method)),
      ],
    );
  }

  Widget _buildPaymentMethodCard(String method) {
    final isEnabled = _paymentMethods[method]!;
    final details = _paymentDetails[method]!;
    final isConfigured = details['isConfigured'] as bool;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled ? Colors.teal.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: isEnabled ? Colors.teal.withValues(alpha: 0.1) : Colors.grey[200],
                child: Icon(
                  _getPaymentIcon(method),
                  color: isEnabled ? Colors.teal : Colors.grey,
                ),
              ),
              title: Row(
                children: [
                  Text(
                    method,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isEnabled ? Colors.black87 : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isConfigured)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 12, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            'مُعدّ',
                            style: TextStyle(fontSize: 10, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              subtitle: Text(
                _getPaymentDescription(method),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              trailing: Switch(
                value: isEnabled,
                onChanged: isConfigured
                    ? (value) {
                        setState(() {
                          _paymentMethods[method] = value;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value ? 'تم تفعيل $method' : 'تم إيقاف $method',
                            ),
                            backgroundColor: value ? Colors.green : Colors.orange,
                          ),
                        );
                      }
                    : null,
                activeTrackColor: Colors.teal,
              ),
            ),
            if (isEnabled && isConfigured) ...[
              Divider(height: 1, color: Colors.grey[300]),
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildPaymentDetails(method, details),
              ),
            ],
            if (!isConfigured) ...[
              Divider(height: 1, color: Colors.grey[300]),
              Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton.icon(
                  onPressed: () => _configurePaymentMethod(method),
                  icon: const Icon(Icons.settings),
                  label: const Text('إعداد طريقة الدفع'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.teal,
                    side: const BorderSide(color: Colors.teal),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetails(String method, Map<String, dynamic> details) {
    switch (method) {
      case 'SADAD':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('رقم الحساب', details['accountNumber']),
            const SizedBox(height: 8),
            _buildDetailRow('اسم الحساب', details['accountName']),
            const SizedBox(height: 12),
            _buildActionButton('تعديل البيانات', Icons.edit, () => _editPaymentMethod(method)),
          ],
        );
      case 'MOMO':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('رقم الهاتف', details['phoneNumber']),
            const SizedBox(height: 8),
            _buildDetailRow('اسم الحساب', details['accountName']),
            const SizedBox(height: 12),
            _buildActionButton('تعديل البيانات', Icons.edit, () => _editPaymentMethod(method)),
          ],
        );
      case 'Cash':
        return Column(
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'الدفع عند الاستلام - لا يتطلب إعدادات إضافية',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ],
        );
      case 'Bank Transfer':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('البنك', details['bankName'] ?? 'غير محدد'),
            const SizedBox(height: 8),
            _buildDetailRow('رقم الحساب', details['accountNumber'] ?? 'غير محدد'),
            const SizedBox(height: 8),
            _buildDetailRow('اسم الحساب', details['accountName'] ?? 'غير محدد'),
            const SizedBox(height: 12),
            _buildActionButton('تعديل البيانات', Icons.edit, () => _editPaymentMethod(method)),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.teal,
          side: const BorderSide(color: Colors.teal),
        ),
      ),
    );
  }

  Widget _buildAddNewPaymentButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('إضافة طريقة دفع جديدة'),
              content: const Text('هذه الميزة ستكون متاحة قريباً'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('حسناً'),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('إضافة طريقة دفع جديدة'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'SADAD':
        return Icons.credit_card;
      case 'MOMO':
        return Icons.phone_android;
      case 'Cash':
        return Icons.money;
      case 'Bank Transfer':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentDescription(String method) {
    switch (method) {
      case 'SADAD':
        return 'الدفع عبر نظام سداد الإلكتروني';
      case 'MOMO':
        return 'الدفع عبر المحفظة الإلكترونية MOMO';
      case 'Cash':
        return 'الدفع نقداً عند الاستلام';
      case 'Bank Transfer':
        return 'التحويل البنكي المباشر';
      default:
        return '';
    }
  }

  void _configurePaymentMethod(String method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إعداد $method'),
        content: const Text('سيتم فتح نموذج الإعداد...'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _paymentDetails[method]!['isConfigured'] = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم إعداد $method بنجاح')),
              );
            },
            child: const Text('حفظ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _editPaymentMethod(String method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل بيانات $method'),
        content: const Text('سيتم فتح نموذج التعديل...'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حفظ التعديلات')),
              );
            },
            child: const Text('حفظ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }
}
