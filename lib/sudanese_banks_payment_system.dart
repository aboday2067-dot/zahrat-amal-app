import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// نظام الدفع عبر البنوك السودانية - v8.0.0
/// يدعم البنوك الرئيسية في السودان مع طرق دفع متنوعة

class SudaneseBanksPaymentSystem {
  static final SudaneseBanksPaymentSystem _instance = SudaneseBanksPaymentSystem._internal();
  factory SudaneseBanksPaymentSystem() => _instance;
  SudaneseBanksPaymentSystem._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // قائمة البنوك السودانية
  static const List<Map<String, String>> sudaneseBanks = [
    {
      'id': 'bos',
      'name': 'بنك السودان',
      'nameEn': 'Bank of Sudan',
      'accountNumber': '0123456789',
    },
    {
      'id': 'bk',
      'name': 'بنك الخرطوم',
      'nameEn': 'Bank of Khartoum',
      'accountNumber': '1234567890',
    },
    {
      'id': 'oib',
      'name': 'بنك أمدرمان الوطني',
      'nameEn': 'Omdurman National Bank',
      'accountNumber': '2345678901',
    },
    {
      'id': 'aib',
      'name': 'البنك الزراعي السوداني',
      'nameEn': 'Agricultural Bank of Sudan',
      'accountNumber': '3456789012',
    },
    {
      'id': 'tdb',
      'name': 'بنك التنمية السوداني',
      'nameEn': 'Sudanese Development Bank',
      'accountNumber': '4567890123',
    },
    {
      'id': 'fib',
      'name': 'بنك فيصل الإسلامي السوداني',
      'nameEn': 'Faisal Islamic Bank',
      'accountNumber': '5678901234',
    },
    {
      'id': 'bankak',
      'name': 'بنكك (Bankak)',
      'nameEn': 'Bankak Digital Banking',
      'accountNumber': '+249-123-456-789',
    },
    {
      'id': 'direct_transfer',
      'name': 'تحويل مباشر',
      'nameEn': 'Direct Transfer',
      'accountNumber': 'حدد رقم الحساب',
    },
  ];

  // طرق الدفع المتاحة
  static const List<Map<String, String>> paymentMethods = [
    {
      'id': 'bank_transfer',
      'name': 'تحويل بنكي',
      'nameEn': 'Bank Transfer',
      'icon': 'account_balance',
    },
    {
      'id': 'mobile_money',
      'name': 'المحفظة الإلكترونية',
      'nameEn': 'Mobile Money',
      'icon': 'phone_android',
    },
    {
      'id': 'cash_on_delivery',
      'name': 'الدفع عند الاستلام',
      'nameEn': 'Cash on Delivery',
      'icon': 'local_shipping',
    },
    {
      'id': 'direct_payment',
      'name': 'دفع مباشر (نقداً)',
      'nameEn': 'Direct Cash Payment',
      'icon': 'payments',
    },
  ];

  // حفظ معلومات الدفع
  Future<PaymentResult> savePaymentInfo({
    required String orderId,
    required String paymentMethod,
    required String? bankId,
    required String? accountNumber,
    required String? referenceNumber,
    required double amount,
    required String userId,
    String? receiptImageUrl,
  }) async {
    try {
      debugPrint('💰 حفظ معلومات الدفع للطلب: $orderId');

      final paymentId = 'PAY-${DateTime.now().millisecondsSinceEpoch}';

      await _firestore.collection('payments').doc(paymentId).set({
        'paymentId': paymentId,
        'orderId': orderId,
        'userId': userId,
        'paymentMethod': paymentMethod,
        'bankId': bankId,
        'accountNumber': accountNumber,
        'referenceNumber': referenceNumber,
        'amount': amount,
        'receiptImageUrl': receiptImageUrl,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // تحديث حالة الطلب
      await _firestore.collection('orders').doc(orderId).update({
        'paymentStatus': 'pending',
        'paymentMethod': paymentMethod,
        'paymentId': paymentId,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ تم حفظ معلومات الدفع بنجاح');

      return PaymentResult(
        success: true,
        message: 'تم حفظ معلومات الدفع بنجاح',
        paymentId: paymentId,
      );
    } catch (e) {
      debugPrint('❌ خطأ في حفظ معلومات الدفع: $e');
      return PaymentResult(
        success: false,
        message: 'حدث خطأ أثناء حفظ معلومات الدفع: $e',
      );
    }
  }

  // فتح دردشة تلقائية بعد الدفع
  Future<void> createAutoChat({
    required String orderId,
    required String buyerId,
    required String buyerName,
    required String merchantId,
    required String merchantName,
  }) async {
    try {
      debugPrint('💬 إنشاء دردشة تلقائية للطلب: $orderId');

      // إنشاء معرف فريد للدردشة
      final chatId = 'CHAT-${buyerId}_${merchantId}_$orderId';

      // التحقق من عدم وجود الدردشة مسبقاً
      final existingChat = await _firestore.collection('chats').doc(chatId).get();

      if (!existingChat.exists) {
        // إنشاء دردشة جديدة
        await _firestore.collection('chats').doc(chatId).set({
          'chatId': chatId,
          'orderId': orderId,
          'participants': [buyerId, merchantId],
          'participantNames': {
            buyerId: buyerName,
            merchantId: merchantName,
          },
          'participantRoles': {
            buyerId: 'buyer',
            merchantId: 'merchant',
          },
          'last_message': 'تم إنشاء الدردشة بنجاح',
          'last_message_time': DateTime.now().toIso8601String(),
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });

        // إرسال رسالة ترحيبية تلقائية
        await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .add({
          'senderId': 'system',
          'senderName': 'النظام',
          'message': '🎉 مرحباً! تم إنشاء هذه الدردشة بنجاح بعد إتمام طلبك. يمكنك الآن التواصل مع التاجر.',
          'created_at': DateTime.now().toIso8601String(),
          'is_read': false,
        });

        debugPrint('✅ تم إنشاء الدردشة التلقائية بنجاح');
      } else {
        debugPrint('ℹ️ الدردشة موجودة بالفعل');
      }
    } catch (e) {
      debugPrint('❌ خطأ في إنشاء الدردشة التلقائية: $e');
    }
  }
}

// نتيجة عملية الدفع
class PaymentResult {
  final bool success;
  final String message;
  final String? paymentId;

  PaymentResult({
    required this.success,
    required this.message,
    this.paymentId,
  });
}

// صفحة اختيار طريقة الدفع
class SudanesePaymentScreen extends StatefulWidget {
  final String orderId;
  final double totalAmount;
  final String merchantId;
  final String merchantName;

  const SudanesePaymentScreen({
    Key? key,
    required this.orderId,
    required this.totalAmount,
    required this.merchantId,
    required this.merchantName,
  }) : super(key: key);

  @override
  State<SudanesePaymentScreen> createState() => _SudanesePaymentScreenState();
}

class _SudanesePaymentScreenState extends State<SudanesePaymentScreen> {
  String? _selectedPaymentMethod;
  String? _selectedBank;
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _referenceNumberController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _accountNumberController.dispose();
    _referenceNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر طريقة الدفع'),
        backgroundColor: const Color(0xFF6B9AC4),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات الطلب
            Card(
              color: const Color(0xFF6B9AC4).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تفاصيل الطلب',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('رقم الطلب:'),
                        Text(widget.orderId, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('المبلغ الإجمالي:'),
                        Text(
                          '${widget.totalAmount.toStringAsFixed(2)} ج',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // اختيار طريقة الدفع
            const Text(
              'اختر طريقة الدفع:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ...SudaneseBanksPaymentSystem.paymentMethods.map((method) {
              return _buildPaymentMethodCard(method);
            }).toList(),

            // عرض خيارات البنوك إذا تم اختيار تحويل بنكي
            if (_selectedPaymentMethod == 'bank_transfer' ||
                _selectedPaymentMethod == 'mobile_money') ...[
              const SizedBox(height: 24),
              const Text(
                'اختر البنك:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...SudaneseBanksPaymentSystem.sudaneseBanks.map((bank) {
                return _buildBankCard(bank);
              }).toList(),
            ],

            // حقول إدخال معلومات الدفع
            if (_selectedBank != null) ...[
              const SizedBox(height: 24),
              const Text(
                'أدخل معلومات الدفع:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _accountNumberController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'رقم الحساب / رقم الهاتف',
                  hintText: 'أدخل رقم الحساب',
                  prefixIcon: const Icon(Icons.account_balance),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _referenceNumberController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'رقم المرجع / رقم العملية',
                  hintText: 'أدخل رقم المرجع',
                  prefixIcon: const Icon(Icons.numbers),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],

            // زر تأكيد الدفع
            if (_selectedPaymentMethod != null) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B9AC4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'تأكيد الدفع',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(Map<String, String> method) {
    final isSelected = _selectedPaymentMethod == method['id'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? const Color(0xFF6B9AC4).withOpacity(0.1) : null,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPaymentMethod = method['id'];
            _selectedBank = null;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                _getPaymentIcon(method['icon']!),
                size: 32,
                color: isSelected ? const Color(0xFF6B9AC4) : Colors.grey,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method['name']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    Text(
                      method['nameEn']!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: Color(0xFF6B9AC4)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankCard(Map<String, String> bank) {
    final isSelected = _selectedBank == bank['id'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? const Color(0xFF6B9AC4).withOpacity(0.1) : null,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedBank = bank['id'];
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.account_balance, size: 32, color: Color(0xFF6B9AC4)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bank['name']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    Text(
                      bank['nameEn']!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'رقم الحساب: ${bank['accountNumber']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: Color(0xFF6B9AC4)),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String iconName) {
    switch (iconName) {
      case 'account_balance':
        return Icons.account_balance;
      case 'phone_android':
        return Icons.phone_android;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'payments':
        return Icons.payments;
      default:
        return Icons.payment;
    }
  }

  Future<void> _handlePayment() async {
    if (_selectedPaymentMethod == null) {
      _showError('الرجاء اختيار طريقة الدفع');
      return;
    }

    if ((_selectedPaymentMethod == 'bank_transfer' ||
            _selectedPaymentMethod == 'mobile_money') &&
        _selectedBank == null) {
      _showError('الرجاء اختيار البنك');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // الحصول على معلومات المستخدم الحالي
      final userId = 'USER-${DateTime.now().millisecondsSinceEpoch}'; // يجب استبداله بمعرف المستخدم الحقيقي
      final userName = 'المستخدم'; // يجب استبداله بالاسم الحقيقي

      // حفظ معلومات الدفع
      final result = await SudaneseBanksPaymentSystem().savePaymentInfo(
        orderId: widget.orderId,
        paymentMethod: _selectedPaymentMethod!,
        bankId: _selectedBank,
        accountNumber: _accountNumberController.text.trim(),
        referenceNumber: _referenceNumberController.text.trim(),
        amount: widget.totalAmount,
        userId: userId,
      );

      if (result.success) {
        // إنشاء دردشة تلقائية مع التاجر
        await SudaneseBanksPaymentSystem().createAutoChat(
          orderId: widget.orderId,
          buyerId: userId,
          buyerName: userName,
          merchantId: widget.merchantId,
          merchantName: widget.merchantName,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${result.message}\n💬 تم فتح دردشة مع التاجر'),
              backgroundColor: Colors.green,
            ),
          );

          // العودة إلى الصفحة السابقة
          Navigator.of(context).pop(true);
        }
      } else {
        _showError(result.message);
      }
    } catch (e) {
      _showError('حدث خطأ: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ $message'), backgroundColor: Colors.red),
    );
  }
}
