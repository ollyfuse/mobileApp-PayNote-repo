import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../utils/fee_calculator.dart';
import '../widgets/category_chart.dart';

final historyFilterProvider = StateProvider<String>((ref) => 'all');
final historySearchProvider = StateProvider<String>((ref) => '');

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    
    final filter = ref.read(historyFilterProvider);
    final search = ref.read(historySearchProvider);
    
    final transactions = await DatabaseService.getTransactions(
      filter: filter == 'all' ? null : filter,
      search: search.isEmpty ? null : search,
    );
    
    setState(() {
      _transactions = transactions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(historyFilterProvider, (_, __) => _loadTransactions());
    ref.listen(historySearchProvider, (_, __) => _loadTransactions());

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1A1C).withOpacity(0.8),
                  const Color(0xFF2A2A2C).withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00FF88)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              onChanged: (value) {
                ref.read(historySearchProvider.notifier).state = value;
              },
            ),
          ),

          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Today', 'today'),
                const SizedBox(width: 8),
                _buildFilterChip('Week', 'week'),
                const SizedBox(width: 8),
                _buildFilterChip('Month', 'month'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Analytics Chart
          if (_transactions.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Category Performance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CategoryChart(categories: _getCategoryData()),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Fee Summary
          if (_transactions.isNotEmpty) _buildFeeSummary(),

          // Transactions List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00FF88)))
                : _transactions.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = _transactions[index];
                          return _buildTransactionCard(transaction);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = ref.watch(historyFilterProvider) == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        ref.read(historyFilterProvider.notifier).state = value;
      },
      backgroundColor: const Color(0xFF1A1A1C),
      selectedColor: const Color(0xFF00FF88).withOpacity(0.2),
      checkmarkColor: const Color(0xFF00FF88),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF00FF88) : Colors.white,
      ),
    );
  }

  Widget _buildFeeSummary() {
    final totalFees = _transactions.fold<double>(0, (sum, transaction) {
        // Use stored fee if available, otherwise calculate with merchant detection
        return sum + (transaction.fee ?? FeeCalculator.calculateFeeWithNumber(
        transaction.amount, 
        transaction.phoneNumber, 
        transaction.network
        ));
    });

    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
            const Color(0xFF1A1A1C).withOpacity(0.8),
            const Color(0xFF2A2A2C).withOpacity(0.6),
            ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
        ),
        child: Row(
        children: [
            Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: const Color(0xFF00FF88).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.receipt, color: Color(0xFF00FF88), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                const Text(
                    'Total Transaction Fees',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                    '${totalFees.toInt()} RWF',
                    style: const TextStyle(
                    color: Color(0xFF00FF88),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    ),
                ),
                ],
            ),
            ),
        ],
        ),
    );
    }

  Widget _buildTransactionCard(Transaction transaction) {
    // Use stored fee if available, otherwise calculate with merchant detection
    final fee = transaction.fee ?? FeeCalculator.calculateFeeWithNumber(
        transaction.amount, 
        transaction.phoneNumber, 
        transaction.network
    );
    
    return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
            const Color(0xFF1A1A1C).withOpacity(0.8),
            const Color(0xFF2A2A2C).withOpacity(0.6),
            ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
        ),
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
            children: [
            // Category Icon
            Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                color: const Color(0xFF00FF88).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                child: Text(
                    _getCategoryIcon(transaction.category),
                    style: const TextStyle(fontSize: 20),
                ),
                ),
            ),
            
            const SizedBox(width: 16),
            
            // Transaction Details
            Expanded(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                    transaction.contactName ?? transaction.phoneNumber,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                    ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                    transaction.category,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                    ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                    _formatDate(transaction.createdAt),
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                    ),
                    ),
                    if (fee > 0) ...[ 
                    const SizedBox(height: 4),
                    Text(
                        'Fee: ${fee.toInt()} RWF',
                        style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF00FF88),
                        ),
                    ),
                    ] else if (FeeCalculator.isMerchantCode(transaction.phoneNumber)) ...[
                    const SizedBox(height: 4),
                    Text(
                        'Merchant Payment - No Fee',
                        style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF00FF88),
                        ),
                    ),
                    ],
                ],
                ),
            ),
            
            // Amount
            Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                Text(
                    '${transaction.amount.toInt()}',
                    style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    ),
                ),
                Text(
                    'RWF',
                    style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    ),
                ),
                const SizedBox(height: 4),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                    color: transaction.network == 'MTN' 
                        ? const Color(0xFFFFC107).withOpacity(0.2)
                        : const Color(0xFFFF3B30).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                    transaction.network,
                    style: TextStyle(
                        fontSize: 10,
                        color: transaction.network == 'MTN' 
                            ? const Color(0xFFFFC107)
                            : const Color(0xFFFF3B30),
                    ),
                    ),
                ),
                ],
            ),
            ],
        ),
        ),
    );
    }
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1C),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your payment history will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getCategoryData() {
    final categoryMap = <String, Map<String, dynamic>>{};
    
    for (final transaction in _transactions) {
      if (categoryMap.containsKey(transaction.category)) {
        categoryMap[transaction.category]!['total'] += transaction.amount;
        categoryMap[transaction.category]!['count']++;
      } else {
        categoryMap[transaction.category] = {
          'category': transaction.category,
          'total': transaction.amount,
          'count': 1,
        };
      }
    }
    
    final categories = categoryMap.values.toList();
    categories.sort((a, b) => b['total'].compareTo(a['total']));
    return categories;
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'Transport': return '🚗';
      case 'Food': return '🍽️';
      case 'Rent': return '🏠';
      case 'Family': return '👨👩👧👦';
      case 'Business': return '💼';
      case 'Entertainment': return '🍻';
      case 'Health': return '⚕️';
      case 'Shopping': return '🛍️';
      default: return '💰';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
