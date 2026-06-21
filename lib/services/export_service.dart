import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/invoice_model.dart';
import '../models/customer_model.dart';

class ExportService {
  Future<void> exportInvoicePdf(Invoice invoice) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Invoice #${invoice.invoiceNumber}',
                style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 8),
          if (invoice.customerName != null && invoice.customerName!.isNotEmpty)
            pw.Text('Customer: ${invoice.customerName}'),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: ['Description', 'Qty', 'Rate', 'Amount'],
            data: invoice.items.map((item) => [
                  item.description,
                  item.quantity.toStringAsFixed(0),
                  'Rs. ${item.rate.toStringAsFixed(0)}',
                  'Rs. ${item.amount.toStringAsFixed(0)}',
                ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey50),
            cellAlignment: pw.Alignment.centerLeft,
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text('Total: Rs. ${invoice.totalAmount.toStringAsFixed(0)}',
                  style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue)),
            ],
          ),
        ],
      ),
    );

    await _shareFile(doc, 'invoice_${invoice.invoiceNumber}.pdf');
  }

  Future<void> exportCustomersCsv(List<Customer> customers) async {
    final csvData = <List<String>>[
      ['Name', 'Phone', 'Address', 'Total Udhaar'],
      ...customers.map((c) => [
            c.name,
            c.phone,
            c.address,
            c.totalUdhaar.toStringAsFixed(0),
          ]),
    ];

    final csv = const ListToCsvConverter().convert(csvData);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/customers_export.csv');
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], text: 'Customers Export');
  }

  Future<void> _shareFile(pw.Document doc, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(await doc.save());
    await Share.shareXFiles([XFile(file.path)], text: filename);
  }
}
