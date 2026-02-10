import '../models/transaction.dart' as models;
import '../utils/platform_helper.dart';
import 'database_interface.dart';
import 'database_web.dart';
import 'database_mobile.dart' if (dart.library.io) 'database_mobile.dart';

class DatabaseService {
  static DatabaseInterface? _instance;

  static DatabaseInterface get _database {
    if (_instance != null) return _instance!;
    
    if (PlatformHelper.isWeb) {
      _instance = DatabaseWeb();
    } else {
      _instance = DatabaseMobile();
    }
    
    return _instance!;
  }

  static Future<void> insertTransaction(models.Transaction transaction) async {
    await _database.insertTransaction(transaction);
  }

  static Future<List<models.Transaction>> getTransactions({
    String? filter,
    String? search,
  }) async {
    return await _database.getTransactions(filter: filter, search: search);
  }

  static Future<Map<String, dynamic>> getReports() async {
    return await _database.getReports();
  }
}
