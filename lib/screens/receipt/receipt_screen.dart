import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/receipt.dart';
import '../../services/receipt_service.dart';

/// 🧾 شاشة عرض الإيصال
class ReceiptScreen extends StatelessWidget {
  final Receipt receipt;

  const ReceiptScreen({
    super.key,
    required this.receipt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإيصال'),
        backgroundColor: Colors.purple,
        actions: [
          // زر المشاركة
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _showShareOptions(context),
            tooltip: 'مشاركة',
          ),
          // زر الطباعة
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printReceipt(context),
            tooltip: 'طباعة',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // الترويسة
                  _buildHeader(),
                  const Divider(height: 32, thickness: 2),
                  
                  // معلومات التاجر والمشتري
                  _buildContactInfo(),
                  const SizedBox(height: 24),
                  
                  // المنتجات
                  _buildItemsSection(),
                  const SizedBox(height: 24),
                  
                  // المجاميع
                  _buildTotalsSection(),
                  const SizedBox(height: 24),
                  
                  // الملاحظات
                  if (receipt.notes != null && receipt.notes!.isNotEmpty)
                    _buildNotesSection(),
                  
                  const SizedBox(height: 24),
                  
                  // التذييل
                  _buildFooter(),
                  
                  const SizedBox(height: 24),
                  
                  // أزرار الإجراءات
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// الترويسة
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade100, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.purple,
          ),
          const SizedBox(height: 12),
          const Text(
            'إيصال',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              receipt.receiptNumber,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'زهرة الأمل - منصة التجارة الإلكترونية',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// معلومات التاجر والمشتري
  Widget _buildContactInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // معلومات التاجر
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.store, color: Colors.purple.shade700, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'من (التاجر):',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Text(
                  receipt.merchantName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(receipt.merchantPhone),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        receipt.merchantAddress,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // معلومات المشتري
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'إلى (المشتري):',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Text(
                  receipt.buyerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(receipt.buyerPhone),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        receipt.buyerAddress,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// قسم المنتجات
  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'المنتجات:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // العناوين
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'المنتج',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'الكمية',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'السعر',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'المجموع',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              
              // المنتجات
              ...receipt.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isLast = index == receipt.items.length - 1;
                
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: index.isEven ? Colors.white : Colors.grey.shade50,
                    borderRadius: isLast
                        ? const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(item.productName),
                      ),
                      Expanded(
                        child: Text(
                          '${item.quantity}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${item.price.toStringAsFixed(2)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${item.total.toStringAsFixed(2)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  /// قسم المجاميع
  Widget _buildTotalsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          _buildTotalRow('المجموع الفرعي:', receipt.subtotal),
          _buildTotalRow('رسوم التوصيل:', receipt.deliveryFee),
          if (receipt.tax > 0)
            _buildTotalRow('الضريبة:', receipt.tax),
          if (receipt.discount > 0)
            _buildTotalRow(
              'الخصم:',
              -receipt.discount,
              color: Colors.green,
            ),
          const Divider(thickness: 2, height: 24),
          _buildTotalRow(
            'المجموع الكلي:',
            receipt.total,
            isTotal: true,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'طريقة الدفع: ${_getPaymentMethodName(receipt.paymentMethod)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// صف المجموع
  Widget _buildTotalRow(
    String label,
    double amount, {
    bool isTotal = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)} د.س',
            style: TextStyle(
              fontSize: isTotal ? 20 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: color ?? (isTotal ? Colors.purple : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  /// قسم الملاحظات
  Widget _buildNotesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note, color: Colors.amber.shade700),
              const SizedBox(width: 8),
              const Text(
                'ملاحظات:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(receipt.notes!),
        ],
      ),
    );
  }

  /// التذييل
  Widget _buildFooter() {
    final dateStr = '${receipt.date.day}/${receipt.date.month}/${receipt.date.year}';
    final timeStr = '${receipt.date.hour}:${receipt.date.minute.toString().padLeft(2, '0')}';
    
    return Column(
      children: [
        const Text(
          '🌸 شكراً لتعاملكم معنا 🌸',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'التاريخ: $dateStr  |  الوقت: $timeStr',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          'تم الإنشاء بواسطة منصة زهرة الأمل',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  /// أزرار الإجراءات
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // معاينة وطباعة
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _previewReceipt(context),
                icon: const Icon(Icons.visibility),
                label: const Text('معاينة PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _printReceipt(context),
                icon: const Icon(Icons.print),
                label: const Text('طباعة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // مشاركة
        ElevatedButton.icon(
          onPressed: () => _showShareOptions(context),
          icon: const Icon(Icons.share),
          label: const Text('مشاركة الإيصال'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(16),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }

  /// معاينة الإيصال
  Future<void> _previewReceipt(BuildContext context) async {
    try {
      await ReceiptService.previewReceipt(receipt);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في المعاينة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// طباعة الإيصال
  Future<void> _printReceipt(BuildContext context) async {
    try {
      await ReceiptService.printReceipt(receipt);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الطباعة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// عرض خيارات المشاركة
  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'مشاركة الإيصال',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // WhatsApp
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: const Icon(Icons.whatsapp, color: Colors.green),
                ),
                title: const Text('مشاركة عبر WhatsApp'),
                onTap: () {
                  Navigator.pop(context);
                  _shareViaWhatsApp(context);
                },
              ),
              
              // البريد الإلكتروني
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(Icons.email, color: Colors.blue),
                ),
                title: const Text('مشاركة عبر البريد الإلكتروني'),
                onTap: () {
                  Navigator.pop(context);
                  _shareViaEmail(context);
                },
              ),
              
              // مشاركة عامة
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.shade100,
                  child: const Icon(Icons.share, color: Colors.purple),
                ),
                title: const Text('مشاركة'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await ReceiptService.previewReceipt(receipt);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('خطأ: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// مشاركة عبر WhatsApp
  Future<void> _shareViaWhatsApp(BuildContext context) async {
    try {
      await ReceiptService.shareViaWhatsApp(receipt, receipt.buyerPhone);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// مشاركة عبر البريد
  Future<void> _shareViaEmail(BuildContext context) async {
    try {
      await ReceiptService.shareViaEmail(receipt, '');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// الحصول على اسم طريقة الدفع
  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'cash':
        return 'نقداً';
      case 'card':
        return 'بطاقة ائتمان';
      case 'transfer':
        return 'تحويل بنكي';
      default:
        return method;
    }
  }
}
