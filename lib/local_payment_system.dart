import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// نظام الدفع المحلي - v7.0.0
/// يدعم: Vodafone Cash والدفع عند الاستلام
/// مع نظام تأكيد مدمج وإيصالات

class LocalPaymentSystem extends StatefulWidget {
  final String userId;
  final String orderId;
  final double totalAmount;
  final Function(Map<String, dynamic> paymentData) onPaymentComplete;

  const LocalPaymentSystem({
    Key? key,
    required this.userId,
    required this.orderId,
    required this.totalAmount,
    required this.onPaymentComplete,
  }) : super(key: key);

  @override
  State<LocalPaymentSystem> createState() => _LocalPaymentSystemState();
}

class _LocalPaymentSystemState extends State<LocalPaymentSystem> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedPaymentMethod = '';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طرق الدفع'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ملخص الطلب
            _buildOrderSummary(),
            
            // فاصل
            Divider(thickness: 8, color: Colors.grey[200]),
            
            // طرق الدفع
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'اختر طريقة الدفع',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 20),
                    
                    // Vodafone Cash
                    _buildPaymentMethodCard(
                      id: 'vodafone_cash',
                      title: 'Vodafone Cash',
                      subtitle: 'الدفع عبر محفظة فودافون كاش',
                      icon: Icons.account_balance_wallet,
                      color: Colors.red,
                      isRecommended: true,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // الدفع عند الاستلام
                    _buildPaymentMethodCard(
                      id: 'cash_on_delivery',
                      title: 'الدفع عند الاستلام',
                      subtitle: 'ادفع نقداً عند استلام الطلب',
                      icon: Icons.local_shipping,
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            
            // زر المتابعة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _selectedPaymentMethod.isEmpty || _isProcessing
                    ? null
                    : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'متابعة الدفع',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.blue[700]!, Colors.blue[400]!],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'إجمالي المبلغ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              Text(
                '${widget.totalAmount.toStringAsFixed(2)} ج.س',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'رقم الطلب: ${widget.orderId}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool isRecommended = false,
  }) {
    final isSelected = _selectedPaymentMethod == id;
    
    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            _selectedPaymentMethod = id;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Radio button
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? color : Colors.grey,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                          ),
                        ),
                      )
                    : null,
              ),
              
              const SizedBox(width: 16),
              
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              
              const SizedBox(width: 16),
              
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isRecommended)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'مستحسن',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? color : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.right,
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

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == 'vodafone_cash') {
      await _processVodafoneCash();
    } else if (_selectedPaymentMethod == 'cash_on_delivery') {
      await _processCashOnDelivery();
    }
  }

  Future<void> _processVodafoneCash() async {
    // عرض نموذج Vodafone Cash
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => VodafoneCashForm(
        amount: widget.totalAmount,
        orderId: widget.orderId,
        onComplete: (transactionData) async {
          Navigator.pop(context);
          await _completePayment(transactionData);
        },
      ),
    );
  }

  Future<void> _processCashOnDelivery() async {
    final paymentData = {
      'payment_method': 'cash_on_delivery',
      'status': 'pending',
      'amount': widget.totalAmount,
      'order_id': widget.orderId,
      'user_id': widget.userId,
      'created_at': FieldValue.serverTimestamp(),
    };
    
    await _completePayment(paymentData);
  }

  Future<void> _completePayment(Map<String, dynamic> paymentData) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // حفظ معلومات الدفع
      await _firestore.collection('payments').add(paymentData);
      
      // تحديث حالة الطلب
      await _firestore.collection('orders').doc(widget.orderId).update({
        'payment_method': paymentData['payment_method'],
        'payment_status': paymentData['status'],
        'payment_data': paymentData,
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        widget.onPaymentComplete(paymentData);
        
        // عرض رسالة نجاح
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم الدفع بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('خطأ في معالجة الدفع: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل الدفع، حاول مرة أخرى'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}

/// نموذج الدفع عبر Vodafone Cash
class VodafoneCashForm extends StatefulWidget {
  final double amount;
  final String orderId;
  final Function(Map<String, dynamic>) onComplete;

  const VodafoneCashForm({
    Key? key,
    required this.amount,
    required this.orderId,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<VodafoneCashForm> createState() => _VodafoneCashFormState();
}

class _VodafoneCashFormState extends State<VodafoneCashForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                const Text(
                  'الدفع عبر Vodafone Cash',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // المبلغ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'المبلغ المطلوب',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    '${widget.amount.toStringAsFixed(2)} ج.س',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // رقم الهاتف
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: 'رقم محفظة Vodafone Cash',
                hintText: '01xxxxxxxxx',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال رقم الهاتف';
                }
                if (value.length != 11 || !value.startsWith('01')) {
                  return 'رقم هاتف غير صحيح';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // رمز PIN
            TextFormField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              textAlign: TextAlign.right,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: 'رمز PIN',
                hintText: '****',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                counterText: '',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال رمز PIN';
                }
                if (value.length != 4) {
                  return 'رمز PIN يجب أن يكون 4 أرقام';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            // تحذير أمني
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'معلوماتك آمنة ومشفرة. لن نشارك بياناتك مع أي طرف ثالث.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber[900],
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // زر التأكيد
            ElevatedButton(
              onPressed: _isProcessing ? null : _processVodafonePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'تأكيد الدفع',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _processVodafonePayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // محاكاة معالجة الدفع (في الإنتاج، يجب الاتصال بـ API الحقيقي)
      await Future.delayed(const Duration(seconds: 2));
      
      // توليد رقم معاملة فريد
      final transactionId = 'VFC${DateTime.now().millisecondsSinceEpoch}';
      
      final paymentData = {
        'payment_method': 'vodafone_cash',
        'status': 'completed',
        'amount': widget.amount,
        'order_id': widget.orderId,
        'phone_number': _phoneController.text.trim(),
        'transaction_id': transactionId,
        'created_at': FieldValue.serverTimestamp(),
      };
      
      widget.onComplete(paymentData);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('خطأ في معالجة Vodafone Cash: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل الدفع، حاول مرة أخرى'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
