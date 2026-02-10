import '../models/transaction.dart' as models;

abstract class DatabaseInterface {
  Future<void> insertTransaction(models.Transaction transaction);
  Future<List<models.Transaction>> getTransactions({String? filter, String? search});
  Future<Map<String, dynamic>> getReports();
}