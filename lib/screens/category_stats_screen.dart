import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/expense_category.dart';

/// 分类统计页面 - 饼图展示
class CategoryStatsScreen extends StatelessWidget {
  const CategoryStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();

    if (provider.expenses.isEmpty) {
      return const Center(child: Text('暂无数据，请先添加记录'));
    }

    final costByCategory = provider.costByCategory;
    final sortedCategories = costByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 饼图
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: sortedCategories.map((entry) {
                  final percentage = (entry.value / provider.totalCost) * 100;
                  return PieChartSectionData(
                    value: entry.value,
                    title: '${percentage.toStringAsFixed(1)}%',
                    color: getTypeColor(entry.key),
                    radius: 100,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 分类列表
          const Text(
            '费用分类明细',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...sortedCategories.map((entry) {
            final percentage = (entry.value / provider.totalCost) * 100;
            return Card(
              child: ListTile(
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: getTypeColor(entry.key),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                title: Text(entry.key),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '¥${entry.value.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}