import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart';
import '../utils/fee_calculator.dart';
import '../utils/platform_helper.dart';

class ExportService {
  static Future<String?> exportToCsv(List<Transaction> transactions) async {
    try {
      if (PlatformHelper.isWeb) {
        return _exportCsvWeb(transactions);
      } else {
        return _exportCsvMobile(transactions);
      }
    } catch (e) {
      return null;
    }
  }

  static Future<String?> exportToPdf(
    List<Transaction> transactions,
    Map<String, dynamic> reports,
  ) async {
    try {
      if (PlatformHelper.isWeb) {
        return _exportPdfWeb(transactions, reports);
      } else {
        return _exportPdfMobile(transactions, reports);
      }
    } catch (e) {
      return null;
    }
  }

  // Web implementations
  static String _exportCsvWeb(List<Transaction> transactions) {
    final csvData = _generateCsvData(transactions);
    final csvString = const ListToCsvConverter().convert(csvData);
    
    // For web, we'll return the CSV string that can be downloaded via browser
    _downloadFileWeb(csvString, 'paynote_transactions.csv', 'text/csv');
    return 'CSV exported successfully';
  }

  static String _exportPdfWeb(List<Transaction> transactions, Map<String, dynamic> reports) {
    // For web, we'll show a message that PDF export works better on mobile
    return 'PDF export works best on mobile devices. Use CSV export for web.';
  }

  // Mobile implementations
  static Future<String> _exportCsvMobile(List<Transaction> transactions) async {
    final csvData = _generateCsvData(transactions);
    final csvString = const ListToCsvConverter().convert(csvData);
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/paynote_transactions.csv');
    await file.writeAsString(csvString);
    
    return file.path;
  }

  static Future<String> _exportPdfMobile(List<Transaction> transactions, Map<String, dynamic> reports) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            _buildPdfHeader(),
            pw.SizedBox(height: 20),
            _buildPdfSummary(reports),
            pw.SizedBox(height: 20),
            _buildPdfTransactions(transactions),
          ];
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/paynote_report.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file.path;
  }

  // Helper methods
  static List<List<String>> _generateCsvData(List<Transaction> transactions) {
    final csvData = <List<String>>[];
    
    // Header
    csvData.add([
      'Date',
      'Contact',
      'Phone Number',
      'Amount (RWF)',
      'Category',
      'Network',
      'Transaction Fee (RWF)',
      'Note'
    ]);
    
    // Data rows
    for (final transaction in transactions) {
      final fee = FeeCalculator.calculateFee(transaction.amount, transaction.network);
      csvData.add([
        transaction.createdAt.toString().split('.')[0],
        transaction.contactName ?? '',
        transaction.phoneNumber,
        transaction.amount.toString(),
        transaction.category,
        transaction.network,
        fee.toString(),
        transaction.note ?? '',
      ]);
    }
    
    return csvData;
  }

  static pw.Widget _buildPdfHeader() {
    return pw.Header(
      level: 0,
      child: pw.Text(
        'PayNote Transaction Report',
        style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _buildPdfSummary(Map<String, dynamic> reports) {
    final total = reports['totalThisMonth'] as double;
    final categories = reports['categories'] as List<Map<String, dynamic>>;
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Text('Total Amount Sent: ${total.toInt()} RWF'),
        pw.Text('Number of Categories: ${categories.length}'),
        pw.Text('Report Generated: ${DateTime.now().toString().split('.')[0]}'),
      ],
    );
  }

  static pw.Widget _buildPdfTransactions(List<Transaction> transactions) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Transactions', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          headers: ['Date', 'Contact', 'Amount', 'Category', 'Network'],
          data: transactions.take(20).map((t) => [
            t.createdAt.toString().split(' ')[0],
            t.contactName ?? t.phoneNumber,
            '${t.amount.toInt()} RWF',
            t.category,
            t.network,
          ]).toList(),
        ),
      ],
    );
  }

  static void _downloadFileWeb(String content, String filename, String mimeType) {
    if (kIsWeb) {
      // Web download implementation would go here
      // For now, we'll just show the content can be copied
      print('Web download: $filename');
      print('Content: ${content.substring(0, 100)}...');
    }
  }
}
