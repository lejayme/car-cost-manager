import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';

/// 图表分析页面 - 成本趋势
class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  String _viewType = 'daily';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();

    if (provider.expenses.isEmpty) {
      return const Center(child: Text('暂无数据，请先添加记录'));
    }

    return Column(
      children: [
        // 视图切换按钮
        Padding(
          padding: const EdgeInsets.all(16),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'daily', label: Text('日')),
              ButtonSegment(value: 'weekly', label: Text('周')),
              ButtonSegment(value: 'monthly', label: Text('月')),
              ButtonSegment(value: 'yearly', label: Text('年')),
            ],
            selected: {_viewType},
            onSelectionChanged: (selection) {
              setState(() => _viewType = selection.first);
            },
          ),
        ),

        // 统计摘要
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('总成本', '¥${provider.totalCost.toStringAsFixed(2)}'),
              _buildStatItem('日均', '¥${provider.dailyCost.toStringAsFixed(2)}'),
              _buildStatItem('每公里', '¥${provider.perKmCost.toStringAsFixed(2)}'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 图表
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildChart(provider),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildChart(ExpenseProvider provider) {
    final chartData = _generateChartData(provider);

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= chartData.labels.length) {
                  return const Text('');
                }
                final label = chartData.labels[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  '¥${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          // 总成本曲线
          LineChartBarData(
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            spots: chartData.totalCosts.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value);
            }).toList(),
          ),
        ],
      ),
    );
  }

  _ChartData _generateChartData(ExpenseProvider provider) {
    switch (_viewType) {
      case 'daily':
        return _generateDailyData(provider);
      case 'weekly':
        return _generateWeeklyData(provider);
      case 'monthly':
        return _generateMonthlyData(provider);
      case 'yearly':
        return _generateYearlyData(provider);
      default:
        return _generateDailyData(provider);
    }
  }

  _ChartData _generateDailyData(ExpenseProvider provider) {
    final expenses = provider.expenses;
    if (expenses.isEmpty) return _ChartData(labels: [], totalCosts: []);

    final startDate = DateTime.parse(provider.carInfo!.startDate);
    final now = DateTime.now();
    final labels = <String>[];
    final totalCosts = <double>[];
    double cumulativeCost = 0;

    // 计算起始日期之前的费用
    for (var exp in expenses) {
      if (DateTime.parse(exp.date).isBefore(startDate)) {
        cumulativeCost += exp.amount;
      }
    }

    // 按日累积
    for (int i = 0; i <= now.difference(startDate).inDays && i < 30; i++) {
      final date = startDate.add(Duration(days: i));
      final dateStr = DateFormat('MM-dd').format(date);
      labels.add(dateStr);

      for (var exp in expenses) {
        if (DateFormat('yyyy-MM-dd').format(DateTime.parse(exp.date)) ==
            DateFormat('yyyy-MM-dd').format(date)) {
          cumulativeCost += exp.amount;
        }
      }
      totalCosts.add(cumulativeCost);
    }

    return _ChartData(labels: labels, totalCosts: totalCosts);
  }

  _ChartData _generateWeeklyData(ExpenseProvider provider) {
    final expenses = provider.expenses;
    if (expenses.isEmpty) return _ChartData(labels: [], totalCosts: []);

    final startDate = DateTime.parse(provider.carInfo!.startDate);
    final now = DateTime.now();
    final labels = <String>[];
    final totalCosts = <double>[];
    double cumulativeCost = 0;

    int weekNum = 1;
    DateTime current = startDate;

    while (current.isBefore(now) && weekNum <= 12) {
      labels.add('W$weekNum');

      for (var exp in expenses) {
        final expDate = DateTime.parse(exp.date);
        if (expDate.isBefore(current.add(const Duration(days: 7))) &&
            !expDate.isBefore(current)) {
          cumulativeCost += exp.amount;
        }
      }
      totalCosts.add(cumulativeCost);

      current = current.add(const Duration(days: 7));
      weekNum++;
    }

    return _ChartData(labels: labels, totalCosts: totalCosts);
  }

  _ChartData _generateMonthlyData(ExpenseProvider provider) {
    final expenses = provider.expenses;
    if (expenses.isEmpty) return _ChartData(labels: [], totalCosts: []);

    final startDate = DateTime.parse(provider.carInfo!.startDate);
    final now = DateTime.now();
    final labels = <String>[];
    final totalCosts = <double>[];
    double cumulativeCost = 0;

    DateTime current = DateTime(startDate.year, startDate.month, 1);

    while (current.isBefore(now) || current.month == now.month) {
      labels.add('${current.month}月');

      for (var exp in expenses) {
        final expDate = DateTime.parse(exp.date);
        if (expDate.year == current.year && expDate.month == current.month) {
          cumulativeCost += exp.amount;
        }
      }
      totalCosts.add(cumulativeCost);

      current = DateTime(current.year, current.month + 1, 1);
      if (current.year > now.year) break;
    }

    return _ChartData(labels: labels, totalCosts: totalCosts);
  }

  _ChartData _generateYearlyData(ExpenseProvider provider) {
    final expenses = provider.expenses;
    if (expenses.isEmpty) return _ChartData(labels: [], totalCosts: []);

    final startDate = DateTime.parse(provider.carInfo!.startDate);
    final now = DateTime.now();
    final labels = <String>[];
    final totalCosts = <double>[];
    double cumulativeCost = 0;

    for (int year = startDate.year; year <= now.year; year++) {
      labels.add('$year年');

      for (var exp in expenses) {
        if (DateTime.parse(exp.date).year == year) {
          cumulativeCost += exp.amount;
        }
      }
      totalCosts.add(cumulativeCost);
    }

    return _ChartData(labels: labels, totalCosts: totalCosts);
  }
}

class _ChartData {
  final List<String> labels;
  final List<double> totalCosts;

  _ChartData({required this.labels, required this.totalCosts});
}