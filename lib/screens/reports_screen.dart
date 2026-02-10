import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/database_service.dart';
import '../utils/fee_calculator.dart';
import '../widgets/category_chart.dart';
import '../services/export_service.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  Map<String, dynamic>? _reports;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    
    final reports = await DatabaseService.getReports();
    
    setState(() {
      _reports = reports;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _loadReports,
            icon: const Icon(Icons.refresh, color: Color(0xFF00FF88)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00FF88)))
          : _reports == null
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadReports,
                  color: const Color(0xFF00FF88),
                  backgroundColor: const Color(0xFF1A1A1C),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOverviewCards(),
                        const SizedBox(height: 24),
                        _buildCategoryAnalytics(),
                        const SizedBox(height: 24),
                        _buildTopContactCard(),
                        const SizedBox(height: 24),
                        _buildMonthlyTrend(),
                        const SizedBox(height: 24),
                        _buildExportCard(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildOverviewCards() {
    final total = _reports!['totalThisMonth'] as double;
    
    return FutureBuilder<double>(
        future: _calculateActualFees(),
        builder: (context, snapshot) {
        final totalFees = snapshot.data ?? 0.0;
        
        return Row(
            children: [
            Expanded(
                child: _buildMetricCard(
                title: 'Total Sent',
                value: '${total.toInt()}',
                subtitle: 'RWF',
                icon: Icons.trending_up,
                color: const Color(0xFF00FF88),
                ),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: _buildMetricCard(
                title: 'Total Fees',
                value: '${totalFees.toInt()}',
                subtitle: 'RWF',
                icon: Icons.receipt,
                color: const Color(0xFF007AFF),
                ),
            ),
            ],
        );
        },
    );
    }

    Future<double> _calculateActualFees() async {
    final transactions = await DatabaseService.getTransactions();
    final thisMonth = DateTime.now();
    final monthStart = DateTime(thisMonth.year, thisMonth.month, 1);
    
    final thisMonthTransactions = transactions.where((t) => 
        t.createdAt.isAfter(monthStart) && 
        t.createdAt.isBefore(thisMonth.add(const Duration(days: 1)))
    ).toList();
    
    return thisMonthTransactions.fold<double>(0, (sum, transaction) {
        return sum + (transaction.fee ?? FeeCalculator.calculateFeeWithNumber(
        transaction.amount, 
        transaction.phoneNumber, 
        transaction.network
        ));
    });
    }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A1C).withOpacity(0.8),
            const Color(0xFF2A2A2C).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryAnalytics() {
    final categories = _reports!['categories'] as List<Map<String, dynamic>>;
    
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category Analytics',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        CategoryChart(categories: categories),
        const SizedBox(height: 16),
        _buildCategoryList(categories),
      ],
    );
  }

  Widget _buildCategoryList(List<Map<String, dynamic>> categories) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A1C).withOpacity(0.8),
            const Color(0xFF2A2A2C).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
      ),
      child: Column(
        children: categories.map((category) => _buildCategoryItem(category)).toList(),
      ),
    );
  }

    Widget _buildCategoryItem(Map<String, dynamic> category) {
        final name = category['category'] as String;
        final total = category['total'] as double;
        final count = category['count'] as int;
        final avgAmount = total / count;
        final totalFees = FeeCalculator.calculateMTNFee(avgAmount) * count;
        
        return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
            children: [
                Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: _getCategoryColor(name).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                    child: Text(
                    _getCategoryIcon(name),
                    style: const TextStyle(fontSize: 18),
                    ),
                ),
                ),
                const SizedBox(width: 16),
                Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(
                        name,
                        style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        ),
                    ),
                    Text(
                        '$count transactions •',
                        style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        ),
                    ),
                    ],
                ),
                ),
                Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                    Text(
                    '${total.toInt()} RWF',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                    ),
                    ),
                   
                ],
                ),
            ],
            ),
        );
        }

        Widget _buildTopContactCard() {
        final topContact = _reports!['topContact'] as Map<String, dynamic>?;
        
        return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                const Color(0xFF1A1A1C).withOpacity(0.8),
                const Color(0xFF2A2A2C).withOpacity(0.6),
                ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                const Text(
                'Most Frequent Contact',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                ),
                ),
                const SizedBox(height: 16),
                if (topContact == null)
                const Text(
                    'No contacts this month',
                    style: TextStyle(color: Colors.grey),
                )
                else
                Row(
                    children: [
                    Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                            const Color(0xFF00FF88).withOpacity(0.3),
                            const Color(0xFF00CC6A).withOpacity(0.3),
                            ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                        child: Text(
                            (topContact['contact_name'] as String)[0].toUpperCase(),
                            style: const TextStyle(
                            color: Color(0xFF00FF88),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            ),
                        ),
                        ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(
                            topContact['contact_name'] as String,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                            ),
                            ),
                            Text(
                            topContact['phone_number'] as String,
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                            ),
                            ),
                        ],
                        ),
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                        color: const Color(0xFF00FF88).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                        '${topContact['count']} times',
                        style: const TextStyle(
                            color: Color(0xFF00FF88),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                        ),
                        ),
                    ),
                    ],
                ),
            ],
            ),
        );
        }

        Widget _buildMonthlyTrend() {
        return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                const Color(0xFF1A1A1C).withOpacity(0.8),
                const Color(0xFF2A2A2C).withOpacity(0.6),
                ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                const Text(
                'Monthly Trend',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                height: 120,
                child: LineChart(
                    LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                        LineChartBarData(
                        spots: _generateMockTrendData(),
                        isCurved: true,
                        color: const Color(0xFF00FF88),
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                                const Color(0xFF00FF88).withOpacity(0.3),
                                const Color(0xFF00FF88).withOpacity(0.0),
                            ],
                            ),
                        ),
                        ),
                    ],
                    ),
                ),
                ),
            ],
            ),
        );
        }

        Widget _buildExportCard() {
        return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                const Color(0xFF1A1A1C).withOpacity(0.8),
                const Color(0xFF2A2A2C).withOpacity(0.6),
                ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                const Text(
                'Export Data',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                ),
                ),
                const SizedBox(height: 8),
                const Text(
                'Export your transaction history and reports',
                style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Row(
                children: [
                    Expanded(
                    child: _buildExportButton(
                        icon: Icons.picture_as_pdf,
                        label: 'PDF Report',
                        onPressed: _exportPdf,
                    ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                    child: _buildExportButton(
                        icon: Icons.table_chart,
                        label: 'CSV Data',
                        onPressed: _exportCsv,
                    ),
                    ),
                ],
                ),
            ],
            ),
        );
        }

        Widget _buildExportButton({
        required IconData icon,
        required String label,
        required VoidCallback onPressed,
        }) {
        return Container(
            decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    children: [
                    Icon(icon, color: const Color(0xFF00FF88), size: 24),
                    const SizedBox(height: 8),
                    Text(
                        label,
                        style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        ),
                    ),
                    ],
                ),
                ),
            ),
            ),
        );
        }

        Future<void> _exportCsv() async {
        try {
            final transactions = await DatabaseService.getTransactions();
            final result = await ExportService.exportToCsv(transactions);
            
            if (result != null) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                content: Text('CSV exported: $result'),
                backgroundColor: const Color(0xFF1A1A1C),
                behavior: SnackBarBehavior.floating,
                ),
            );
            } else {
            _showError('Failed to export CSV');
            }
        } catch (e) {
            _showError('Export error: $e');
        }
        }

        Future<void> _exportPdf() async {
        try {
            final transactions = await DatabaseService.getTransactions();
            final result = await ExportService.exportToPdf(transactions, _reports!);
            
            if (result != null) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                content: Text('PDF exported: $result'),
                backgroundColor: const Color(0xFF1A1A1C),
                behavior: SnackBarBehavior.floating,
                ),
            );
            } else {
            _showError('Failed to export PDF');
            }
        } catch (e) {
            _showError('Export error: $e');
        }
        }

        void _showError(String message) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFFFF3B30),
            behavior: SnackBarBehavior.floating,
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
                    Icons.analytics_outlined,
                    size: 40,
                    color: Colors.grey,
                ),
                ),
                const SizedBox(height: 16),
                const Text(
                'No data available',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                ),
                ),
                const SizedBox(height: 8),
                const Text(
                'Make some transactions to see reports',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                ),
                ),
            ],
            ),
        );
        }

        List<FlSpot> _generateMockTrendData() {
        return [
            const FlSpot(0, 1),
            const FlSpot(1, 3),
            const FlSpot(2, 2),
            const FlSpot(3, 5),
            const FlSpot(4, 4),
            const FlSpot(5, 6),
            const FlSpot(6, 5),
        ];
        }

        Color _getCategoryColor(String category) {
        switch (category) {
            case 'Transport': return const Color(0xFF00FF88);
            case 'Food': return const Color(0xFF007AFF);
            case 'Rent': return const Color(0xFFFF9500);
            case 'Family': return const Color(0xFFFF2D92);
            case 'Business': return const Color(0xFF5856D6);
            case 'Entertainment': return const Color(0xFFFF3B30);
            case 'Health': return const Color(0xFFFFCC00);
            case 'Shopping': return const Color(0xFFAF52DE);
            default: return const Color(0xFF8E8E93);
        }
        }

        String _getCategoryIcon(String category) {
        switch (category) {
            case 'Transport': return '🚗';
            case 'Food': return '🍽️';
            case 'Rent': return '🏠';
            case 'Family': return '👨👩👧👦';
            case 'Business': return '💼';
            default: return '💰';
        }
        }

}
