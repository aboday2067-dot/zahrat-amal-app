import 'package:intl/intl.dart';
import 'notification_service.dart';

/// نموذج الإيصال
class Receipt {
  final String id;
  final String orderId;
  final String buyerId;
  final String buyerName;
  final String buyerEmail;
  final String buyerPhone;
  final String merchantId;
  final String merchantName;
  final List<ReceiptItem> items;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double total;
  final String paymentMethod;
  final DateTime issuedDate;
  final String status; // paid, pending, cancelled

  Receipt({
    required this.id,
    required this.orderId,
    required this.buyerId,
    required this.buyerName,
    required this.buyerEmail,
    required this.buyerPhone,
    required this.merchantId,
    required this.merchantName,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.total,
    required this.paymentMethod,
    required this.issuedDate,
    this.status = 'paid',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerEmail': buyerEmail,
      'buyerPhone': buyerPhone,
      'merchantId': merchantId,
      'merchantName': merchantName,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'deliveryFee': deliveryFee,
      'total': total,
      'paymentMethod': paymentMethod,
      'issuedDate': issuedDate.toIso8601String(),
      'status': status,
    };
  }
}

/// عنصر في الإيصال
class ReceiptItem {
  final String name;
  final int quantity;
  final double unitPrice;
  final double total;

  ReceiptItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'total': total,
    };
  }
}

/// خدمة إدارة الإيصالات
class ReceiptService {
  /// إنشاء إيصال جديد
  static Receipt generateReceipt({
    required String orderId,
    required String buyerId,
    required String buyerName,
    required String buyerEmail,
    required String buyerPhone,
    required String merchantId,
    required String merchantName,
    required List<ReceiptItem> items,
    required String paymentMethod,
    double taxRate = 0.15, // ضريبة 15%
    double deliveryFee = 50.0,
  }) {
    final subtotal = items.fold(0.0, (sum, item) => sum + item.total);
    final tax = subtotal * taxRate;
    final total = subtotal + tax + deliveryFee;

    return Receipt(
      id: 'REC-${DateTime.now().millisecondsSinceEpoch}',
      orderId: orderId,
      buyerId: buyerId,
      buyerName: buyerName,
      buyerEmail: buyerEmail,
      buyerPhone: buyerPhone,
      merchantId: merchantId,
      merchantName: merchantName,
      items: items,
      subtotal: subtotal,
      tax: tax,
      deliveryFee: deliveryFee,
      total: total,
      paymentMethod: paymentMethod,
      issuedDate: DateTime.now(),
    );
  }

  /// تحويل الإيصال إلى نص منسق
  static String formatReceiptAsText(Receipt receipt) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final currencyFormat = NumberFormat('#,##0.00');

    final buffer = StringBuffer();
    
    // رأس الإيصال
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('           🧾 إيصال شراء');
    buffer.writeln('         زهرة الأمل - ZahratAmal');
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln();
    
    // معلومات الإيصال
    buffer.writeln('رقم الإيصال: ${receipt.id}');
    buffer.writeln('رقم الطلب: ${receipt.orderId}');
    buffer.writeln('التاريخ: ${dateFormat.format(receipt.issuedDate)}');
    buffer.writeln('الحالة: ${_getStatusText(receipt.status)}');
    buffer.writeln();
    
    // معلومات العميل
    buffer.writeln('───────────────────────────────────────');
    buffer.writeln('معلومات العميل:');
    buffer.writeln('───────────────────────────────────────');
    buffer.writeln('الاسم: ${receipt.buyerName}');
    buffer.writeln('البريد: ${receipt.buyerEmail}');
    buffer.writeln('الهاتف: ${receipt.buyerPhone}');
    buffer.writeln();
    
    // معلومات التاجر
    buffer.writeln('───────────────────────────────────────');
    buffer.writeln('معلومات التاجر:');
    buffer.writeln('───────────────────────────────────────');
    buffer.writeln('المتجر: ${receipt.merchantName}');
    buffer.writeln();
    
    // المنتجات
    buffer.writeln('───────────────────────────────────────');
    buffer.writeln('المنتجات:');
    buffer.writeln('───────────────────────────────────────');
    
    for (final item in receipt.items) {
      buffer.writeln('${item.name}');
      buffer.writeln('  ${item.quantity} × ${currencyFormat.format(item.unitPrice)} = ${currencyFormat.format(item.total)} SDG');
    }
    
    buffer.writeln();
    
    // الإجمالي
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('المجموع الفرعي: ${currencyFormat.format(receipt.subtotal)} SDG');
    buffer.writeln('الضريبة (15%): ${currencyFormat.format(receipt.tax)} SDG');
    buffer.writeln('رسوم التوصيل: ${currencyFormat.format(receipt.deliveryFee)} SDG');
    buffer.writeln('───────────────────────────────────────');
    buffer.writeln('الإجمالي النهائي: ${currencyFormat.format(receipt.total)} SDG');
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln();
    
    // طريقة الدفع
    buffer.writeln('طريقة الدفع: ${_getPaymentMethodText(receipt.paymentMethod)}');
    buffer.writeln();
    
    // تذييل الإيصال
    buffer.writeln('───────────────────────────────────────');
    buffer.writeln('       شكراً لتسوقكم معنا! 🌸');
    buffer.writeln('   للدعم: support@zahrat.sd');
    buffer.writeln('═══════════════════════════════════════');

    return buffer.toString();
  }

  /// تحويل الإيصال إلى HTML
  static String formatReceiptAsHtml(Receipt receipt) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final currencyFormat = NumberFormat('#,##0.00');

    return '''
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>إيصال ${receipt.id}</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .receipt {
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .header {
            text-align: center;
            border-bottom: 2px solid #009688;
            padding-bottom: 20px;
            margin-bottom: 20px;
        }
        .header h1 {
            color: #009688;
            margin: 0;
            font-size: 28px;
        }
        .header p {
            color: #666;
            margin: 5px 0;
        }
        .info-section {
            margin: 20px 0;
            padding: 15px;
            background-color: #f9f9f9;
            border-radius: 5px;
        }
        .info-section h3 {
            color: #009688;
            margin-top: 0;
            border-bottom: 1px solid #ddd;
            padding-bottom: 10px;
        }
        .info-row {
            display: flex;
            justify-content: space-between;
            margin: 8px 0;
        }
        .label {
            font-weight: bold;
            color: #333;
        }
        .value {
            color: #666;
        }
        .items-table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        .items-table th {
            background-color: #009688;
            color: white;
            padding: 12px;
            text-align: right;
        }
        .items-table td {
            padding: 10px 12px;
            border-bottom: 1px solid #ddd;
        }
        .items-table tr:hover {
            background-color: #f5f5f5;
        }
        .totals {
            margin-top: 20px;
            padding: 20px;
            background-color: #f0f9f8;
            border-radius: 5px;
        }
        .total-row {
            display: flex;
            justify-content: space-between;
            margin: 10px 0;
            font-size: 16px;
        }
        .total-row.grand-total {
            font-size: 20px;
            font-weight: bold;
            color: #009688;
            border-top: 2px solid #009688;
            padding-top: 10px;
            margin-top: 10px;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 2px solid #009688;
            color: #666;
        }
        .status {
            display: inline-block;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: bold;
        }
        .status.paid {
            background-color: #4caf50;
            color: white;
        }
        .status.pending {
            background-color: #ff9800;
            color: white;
        }
    </style>
</head>
<body>
    <div class="receipt">
        <div class="header">
            <h1>🌸 زهرة الأمل</h1>
            <p>منصة السودان للتجارة الإلكترونية</p>
            <p style="font-size: 18px; margin-top: 15px;">إيصال شراء</p>
        </div>

        <div class="info-section">
            <div class="info-row">
                <span class="label">رقم الإيصال:</span>
                <span class="value">${receipt.id}</span>
            </div>
            <div class="info-row">
                <span class="label">رقم الطلب:</span>
                <span class="value">${receipt.orderId}</span>
            </div>
            <div class="info-row">
                <span class="label">التاريخ:</span>
                <span class="value">${dateFormat.format(receipt.issuedDate)}</span>
            </div>
            <div class="info-row">
                <span class="label">الحالة:</span>
                <span class="status ${receipt.status}">${_getStatusText(receipt.status)}</span>
            </div>
        </div>

        <div class="info-section">
            <h3>معلومات العميل</h3>
            <div class="info-row">
                <span class="label">الاسم:</span>
                <span class="value">${receipt.buyerName}</span>
            </div>
            <div class="info-row">
                <span class="label">البريد الإلكتروني:</span>
                <span class="value">${receipt.buyerEmail}</span>
            </div>
            <div class="info-row">
                <span class="label">رقم الهاتف:</span>
                <span class="value">${receipt.buyerPhone}</span>
            </div>
        </div>

        <div class="info-section">
            <h3>معلومات التاجر</h3>
            <div class="info-row">
                <span class="label">اسم المتجر:</span>
                <span class="value">${receipt.merchantName}</span>
            </div>
        </div>

        <table class="items-table">
            <thead>
                <tr>
                    <th>المنتج</th>
                    <th style="text-align: center;">الكمية</th>
                    <th style="text-align: center;">السعر</th>
                    <th style="text-align: center;">الإجمالي</th>
                </tr>
            </thead>
            <tbody>
                ${receipt.items.map((item) => '''
                <tr>
                    <td>${item.name}</td>
                    <td style="text-align: center;">${item.quantity}</td>
                    <td style="text-align: center;">${currencyFormat.format(item.unitPrice)} SDG</td>
                    <td style="text-align: center;">${currencyFormat.format(item.total)} SDG</td>
                </tr>
                ''').join()}
            </tbody>
        </table>

        <div class="totals">
            <div class="total-row">
                <span>المجموع الفرعي:</span>
                <span>${currencyFormat.format(receipt.subtotal)} SDG</span>
            </div>
            <div class="total-row">
                <span>الضريبة (15%):</span>
                <span>${currencyFormat.format(receipt.tax)} SDG</span>
            </div>
            <div class="total-row">
                <span>رسوم التوصيل:</span>
                <span>${currencyFormat.format(receipt.deliveryFee)} SDG</span>
            </div>
            <div class="total-row grand-total">
                <span>الإجمالي النهائي:</span>
                <span>${currencyFormat.format(receipt.total)} SDG</span>
            </div>
        </div>

        <div class="info-section">
            <div class="info-row">
                <span class="label">طريقة الدفع:</span>
                <span class="value">${_getPaymentMethodText(receipt.paymentMethod)}</span>
            </div>
        </div>

        <div class="footer">
            <p style="font-size: 18px; margin-bottom: 10px;">شكراً لتسوقكم معنا! 🌸</p>
            <p>للدعم والاستفسارات: support@zahrat.sd</p>
            <p style="margin-top: 15px; font-size: 12px; color: #999;">
                هذا إيصال إلكتروني تم إنشاؤه تلقائياً
            </p>
        </div>
    </div>
</body>
</html>
    ''';
  }

  /// إرسال الإيصال عبر البريد الإلكتروني
  static Future<bool> sendReceiptByEmail(Receipt receipt) async {
    final emailBody = formatReceiptAsHtml(receipt);
    
    return await NotificationService.sendEmailNotification(
      email: receipt.buyerEmail,
      subject: 'إيصال طلبك #${receipt.orderId} - زهرة الأمل',
      message: emailBody,
    );
  }

  /// إرسال الإيصال عبر SMS (ملخص مختصر)
  static Future<bool> sendReceiptBySMS(Receipt receipt) async {
    final currencyFormat = NumberFormat('#,##0.00');
    
    final smsMessage = '''
زهرة الأمل 🌸
إيصال: ${receipt.id}
الطلب: ${receipt.orderId}
الإجمالي: ${currencyFormat.format(receipt.total)} SDG
شكراً لثقتكم!
    ''';
    
    return await NotificationService.sendSmsNotification(
      phone: receipt.buyerPhone,
      message: smsMessage,
    );
  }

  /// إرسال الإيصال عبر القنوات المتعددة
  static Future<Map<String, bool>> sendReceiptMultiChannel(Receipt receipt) async {
    final results = await Future.wait([
      sendReceiptByEmail(receipt),
      sendReceiptBySMS(receipt),
    ]);

    return {
      'email': results[0],
      'sms': results[1],
    };
  }

  /// نص حالة الإيصال
  static String _getStatusText(String status) {
    switch (status) {
      case 'paid':
        return 'مدفوع ✓';
      case 'pending':
        return 'قيد الانتظار';
      case 'cancelled':
        return 'ملغى';
      default:
        return status;
    }
  }

  /// نص طريقة الدفع
  static String _getPaymentMethodText(String method) {
    switch (method) {
      case 'cash':
        return 'الدفع عند الاستلام';
      case 'card':
        return 'بطاقة ائتمان';
      case 'bank':
        return 'تحويل بنكي';
      case 'mobile':
        return 'محفظة إلكترونية';
      default:
        return method;
    }
  }
}
