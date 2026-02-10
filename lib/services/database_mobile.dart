import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart' as models;
import 'database_interface.dart';

class DatabaseMobile implements DatabaseInterface {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'paynote.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL NOT NULL,
            phone_number TEXT NOT NULL,
            contact_name TEXT,
            network TEXT NOT NULL,
            category TEXT NOT NULL,
            note TEXT,
            is_successful INTEGER NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<void> insertTransaction(models.Transaction transaction) async {
    final db = await database;
    await db.insert('transactions', transaction.toMap());
  }

  @override
  Future<List<models.Transaction>> getTransactions({String? filter, String? search}) async {
    final db = await database;
    String query = 'SELECT * FROM transactions WHERE is_successful = 1';
    List<dynamic> args = [];

    if (filter != null) {
      final now = DateTime.now();
      DateTime startDate;
      
      switch (filter) {
        case 'today':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'week':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        default:
          startDate = DateTime(2020);
      }
      
      query += ' AND created_at >= ?';
      args.add(startDate.millisecondsSinceEpoch);
    }

    if (search != null && search.isNotEmpty) {
      query += ' AND (contact_name LIKE ? OR phone_number LIKE ?)';
      args.addAll(['%$search%', '%$search%']);
    }

    query += ' ORDER BY created_at DESC';

    final maps = await db.rawQuery(query, args);
    return maps.map((map) => models.Transaction.fromMap(map)).toList();
  }

  @override
  Future<Map<String, dynamic>> getReports() async {
    final db = await database;
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    final totalResult = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions 
      WHERE is_successful = 1 AND created_at >= ?
    ''', [monthStart.millisecondsSinceEpoch]);

    final categoryResult = await db.rawQuery('''
      SELECT category, SUM(amount) as total, COUNT(*) as count 
      FROM transactions 
      WHERE is_successful = 1 AND created_at >= ?
      GROUP BY category 
      ORDER BY total DESC
    ''', [monthStart.millisecondsSinceEpoch]);

    final contactResult = await db.rawQuery('''
      SELECT contact_name, phone_number, COUNT(*) as count 
      FROM transactions 
      WHERE is_successful = 1 AND created_at >= ? AND contact_name IS NOT NULL
      GROUP BY contact_name, phone_number 
      ORDER BY count DESC 
      LIMIT 1
    ''', [monthStart.millisecondsSinceEpoch]);

    return {
      'totalThisMonth': totalResult.first['total'] ?? 0.0,
      'categories': categoryResult,
      'topContact': contactResult.isNotEmpty ? contactResult.first : null,
    };
  }
}
