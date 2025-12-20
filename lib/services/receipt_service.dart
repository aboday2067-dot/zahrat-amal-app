import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/receipt.dart';

/// 🧾 خدمة توليد ومشاركة الإيصالات
class ReceiptService {
  
  /// توليد PDF للإيصال
  static Future<pw.Document> generateReceiptPDF(Receipt receipt) async {
    final pdf = pw.Document();

    // تحميل خط عربي
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicFontBold = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(
          base: arabicFont,
          bold: arabicFontBold,
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // الترويسة
              _buildHeader(receipt),
              pw.SizedBox(height: 20),
              
              // معلومات التاجر والمشتري
              _buildContactInfo(receipt),
              pw.SizedBox(height: 20),
              
              // جدول المنتجات
              _buildItemsTable(receipt),
              pw.SizedBox(height: 20),
              
              // المجاميع
              _buildTotals(receipt),
              pw.SizedBox(height: 20),
              
              // الملاحظات
              if (receipt.notes != null && receipt.notes!.isNotEmpty)
                _buildNotes(receipt.notes!),
              
              pw.Spacer(),
              
              // التذييل
              _buildFooter(receipt),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  /// ترويسة الإيصال
  static pw.Widget _buildHeader(Receipt receipt) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.purple50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'إيصال',
                style: pw.TextStyle(
                  fontSize: 32,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.purple900,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'رقم الإيصال: ${receipt.receiptNumber}',
                style: const pw.TextStyle(fontSize: 14),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'زهرة الأمل',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.purple900,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'منصة التجارة الإلكترونية',
                style: const pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// معلومات التاجر والمشتري
  static pw.Widget _buildContactInfo(Receipt receipt) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // معلومات التاجر
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'من (التاجر):',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.purple900,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(receipt.merchantName, style: const pw.TextStyle(fontSize: 12)),
                pw.Text('📞 ${receipt.merchantPhone}', style: const pw.TextStyle(fontSize: 10)),
                pw.Text('📍 ${receipt.merchantAddress}', style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ),
        
        pw.SizedBox(width: 20),
        
        // معلومات المشتري
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'إلى (المشتري):',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.purple900,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(receipt.buyerName, style: const pw.TextStyle(fontSize: 12)),
                pw.Text('📞 ${receipt.buyerPhone}', style: const pw.TextStyle(fontSize: 10)),
                pw.Text('📍 ${receipt.buyerAddress}', style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// جدول المنتجات
  static pw.Widget _buildItemsTable(Receipt receipt) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // العناوين
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.purple100),
          children: [
            _buildTableCell('المنتج', isHeader: true),
            _buildTableCell('الكمية', isHeader: true),
            _buildTableCell('السعر', isHeader: true),
            _buildTableCell('المجموع', isHeader: true),
          ],
        ),
        
        // المنتجات
        ...receipt.items.map((item) {
          return pw.TableRow(
            children: [
              _buildTableCell(item.productName),
              _buildTableCell('${item.quantity}'),
              _buildTableCell('${item.price.toStringAsFixed(2)} د.س'),
              _buildTableCell('${item.total.toStringAsFixed(2)} د.س'),
            ],
          );
        }),
      ],
    );
  }

  /// خلية الجدول
  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  /// المجاميع
  static pw.Widget _buildTotals(Receipt receipt) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          _buildTotalRow('المجموع الفرعي:', receipt.subtotal),
          _buildTotalRow('رسوم التوصيل:', receipt.deliveryFee),
          if (receipt.tax > 0) _buildTotalRow('الضريبة:', receipt.tax),
          if (receipt.discount > 0) _buildTotalRow('الخصم:', -receipt.discount, color: PdfColors.green),
          pw.Divider(thickness: 2),
          _buildTotalRow(
            'المجموع الكلي:',
            receipt.total,
            isTotal: true,
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'طريقة الدفع: ${_getPaymentMethodName(receipt.paymentMethod)}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  /// صف المجموع
  static pw.Widget _buildTotalRow(
    String label,
    double amount, {
    bool isTotal = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isTotal ? 14 : 11,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            '${amount.toStringAsFixed(2)} د.س',
            style: pw.TextStyle(
              fontSize: isTotal ? 14 : 11,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color ?? (isTotal ? PdfColors.purple900 : PdfColors.black),
            ),
          ),
        ],
      ),
    );
  }

  /// الملاحظات
  static pw.Widget _buildNotes(String notes) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.yellow50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.yellow200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ملاحظات:',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(notes, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  /// التذييل
  static pw.Widget _buildFooter(Receipt receipt) {
    final dateStr = '${receipt.date.day}/${receipt.date.month}/${receipt.date.year}';
    final timeStr = '${receipt.date.hour}:${receipt.date.minute.toString().padLeft(2, '0')}';
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'شكراً لتعاملكم معنا',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.purple900,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'التاريخ: $dateStr | الوقت: $timeStr',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
          pw.Text(
            'تم الإنشاء بواسطة زهرة الأمل - منصة التجارة الإلكترونية',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  /// الحصول على اسم طريقة الدفع
  static String _getPaymentMethodName(String method) {
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

  /// طباعة الإيصال
  static Future<void> printReceipt(Receipt receipt) async {
    final pdf = await generateReceiptPDF(receipt);
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  /// معاينة الإيصال
  static Future<void> previewReceipt(Receipt receipt) async {
    final pdf = await generateReceiptPDF(receipt);
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${receipt.receiptNumber}.pdf',
    );
  }

  /// مشاركة عبر WhatsApp
  static Future<void> shareViaWhatsApp(Receipt receipt, String phoneNumber) async {
    // حفظ PDF
    final pdf = await generateReceiptPDF(receipt);
    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${receipt.receiptNumber}.pdf');
    await file.writeAsBytes(bytes);

    // مشاركة
    final message = '''
مرحباً! 👋

إليك إيصال طلبك من زهرة الأمل:

📄 رقم الإيصال: ${receipt.receiptNumber}
💰 المبلغ الإجمالي: ${receipt.total.toStringAsFixed(2)} د.س
📅 التاريخ: ${receipt.date.day}/${receipt.date.month}/${receipt.date.year}

شكراً لتعاملك معنا! 🌸
    ''';

    await Share.shareXFiles(
      [XFile(file.path)],
      text: message,
    );
  }

  /// مشاركة عبر البريد
  static Future<void> shareViaEmail(Receipt receipt, String email) async {
    final pdf = await generateReceiptPDF(receipt);
    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${receipt.receiptNumber}.pdf');
    await file.writeAsBytes(bytes);

    final subject = 'إيصال ${receipt.receiptNumber} - زهرة الأمل';
    final body = '''
مرحباً ${receipt.buyerName},

نشكرك على تعاملك مع منصة زهرة الأمل.

تجد مرفق إيصال طلبك رقم ${receipt.receiptNumber}.

التفاصيل:
- المبلغ الإجمالي: ${receipt.total.toStringAsFixed(2)} د.س
- التاريخ: ${receipt.date.day}/${receipt.date.month}/${receipt.date.year}

مع تحيات فريق زهرة الأمل 🌸
    ''';

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: subject,
      text: body,
    );
  }

  /// حفظ PDF محلياً
  static Future<String> saveReceiptPDF(Receipt receipt) async {
    final pdf = await generateReceiptPDF(receipt);
    final bytes = await pdf.save();
    
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/receipts/${receipt.receiptNumber}.pdf');
    
    // إنشاء المجلد إذا لم يكن موجوداً
    await file.parent.create(recursive: true);
    
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
