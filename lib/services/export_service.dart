import '../models/transaction.dart';

class ExportService {
  static Future<String?> exportToCsv(List<Transaction> transactions) async {
    return 'Export not available in minimal version';
  }

  static Future<String?> exportToPdf(
    List<Transaction> transactions,
    Map<String, dynamic> reports,
  ) async {
    return 'Export not available in minimal version';
  }
}
