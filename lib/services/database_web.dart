import '../models/transaction.dart' as models;
import 'database_interface.dart';

class DatabaseWeb implements DatabaseInterface {
  static final List<models.Transaction> _transactions = [];

  @override
  Future<void> insertTransaction(models.Transaction transaction) async {
    _transactions.add(transaction);
  }

  @override
  Future<List<models.Transaction>> getTransactions({String? filter, String? search}) async {
    var transactions = List<models.Transaction>.from(_transactions);
    
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
      
      transactions = transactions.where((t) => t.createdAt.isAfter(startDate)).toList();
    }

    if (search != null && search.isNotEmpty) {
      transactions = transactions.where((t) =>
        (t.contactName?.toLowerCase().contains(search.toLowerCase()) ?? false) ||
        t.phoneNumber.contains(search)
      ).toList();
    }

    return transactions..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Map<String, dynamic>> getReports() async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    
    final monthTransactions = _transactions
        .where((t) => t.createdAt.isAfter(monthStart))
        .toList();

    final totalThisMonth = monthTransactions
        .fold<double>(0, (sum, t) => sum + t.amount);

    final categoryMap = <String, Map<String, dynamic>>{};
    for (final t in monthTransactions) {
      if (categoryMap.containsKey(t.category)) {
        categoryMap[t.category]!['total'] += t.amount;
        categoryMap[t.category]!['count']++;
      } else {
        categoryMap[t.category] = {'total': t.amount, 'count': 1, 'category': t.category};
      }
    }

    final categories = categoryMap.values.toList()
      ..sort((a, b) => b['total'].compareTo(a['total']));

    final contactMap = <String, int>{};
    for (final t in monthTransactions) {
      if (t.contactName != null) {
        contactMap[t.contactName!] = (contactMap[t.contactName!] ?? 0) + 1;
      }
    }

    final topContact = contactMap.isNotEmpty
        ? contactMap.entries.reduce((a, b) => a.value > b.value ? a : b)
        : null;

    return {
      'totalThisMonth': totalThisMonth,
      'categories': categories,
      'topContact': topContact != null ? {
        'contact_name': topContact.key,
        'phone_number': monthTransactions
            .firstWhere((t) => t.contactName == topContact.key)
            .phoneNumber,
        'count': topContact.value,
      } : null,
    };
  }
}
