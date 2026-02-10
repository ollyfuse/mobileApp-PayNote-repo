import '../models/transaction.dart' as models;
import 'database_interface.dart';

class DatabaseMobile implements DatabaseInterface {
  static final List<models.Transaction> _transactions = [];

  @override
  Future<void> insertTransaction(models.Transaction transaction) async {
    _transactions.add(transaction);
  }

  @override
  Future<List<models.Transaction>> getTransactions({String? filter, String? search}) async {
    return _transactions;
  }

  @override
  Future<Map<String, dynamic>> getReports() async {
    return {'totalThisMonth': 0.0, 'categories': []};
  }
}
