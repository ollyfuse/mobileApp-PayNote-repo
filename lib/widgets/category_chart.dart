import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CategoryChart extends StatelessWidget {
  final List<Map<String, dynamic>> categories;

  const CategoryChart({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Container(
        height: 200,
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
        child: const Center(
          child: Text(
            'No data available',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    final total = categories.fold<double>(0, (sum, cat) => sum + cat['total']);

    return Container(
      height: 200,
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
      ),
      child: Row(
        children: [
          // Pie Chart
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sections: _buildPieChartSections(categories, total),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
                startDegreeOffset: -90,
              ),
            ),
          ),
          
          // Legend
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: categories.take(4).map((category) {
                final percentage = ((category['total'] / total) * 100).round();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getCategoryColor(category['category']),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category['category'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '$percentage%',
                              style: const TextStyle(
                                color: Color(0xFF00FF88),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(List<Map<String, dynamic>> categories, double total) {
    return categories.map((category) {
      final percentage = (category['total'] / total) * 100;
      return PieChartSectionData(
        color: _getCategoryColor(category['category']),
        value: percentage,
        title: '${percentage.round()}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
        case 'Transport':
            return const Color(0xFF00FF88);
        case 'Food':
            return const Color(0xFF007AFF);
        case 'Rent':
            return const Color(0xFFFF9500);
        case 'Family':
            return const Color(0xFFFF2D92);
        case 'Business':
            return const Color(0xFF5856D6);
        case 'Entertainment':
            return const Color(0xFFAF52DE);
        case 'Health':
            return const Color(0xFF5AC8FA);
        case 'Shopping':
            return const Color(0xFFFF3B30);
        default:
            return const Color(0xFF8E8E93);
    }
  }
}
