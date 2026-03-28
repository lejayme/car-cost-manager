import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

/// 能耗分析页面
class EnergyAnalysisScreen extends StatefulWidget {
  const EnergyAnalysisScreen({super.key});

  @override
  State<EnergyAnalysisScreen> createState() => _EnergyAnalysisScreenState();
}

class _EnergyAnalysisScreenState extends State<EnergyAnalysisScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();

    // 计算能耗相关数据
    final fuelExpenses = provider.expenses
        .where((e) => e.type.contains('燃油') || e.type.contains('油'))
        .toList();
    final electricExpenses = provider.expenses
        .where((e) => e.type.contains('电'))
        .toList();

    final totalFuelCost = fuelExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final totalElectricCost = electricExpenses.fold(0.0, (sum, e) => sum + e.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '能耗成本分析',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // 能耗统计卡片
          Row(
            children: [
              Expanded(
                child: _buildEnergyCard(
                  context,
                  '燃油费用',
                  totalFuelCost,
                  Icons.local_gas_station,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildEnergyCard(
                  context,
                  '充电费用',
                  totalElectricCost,
                  Icons.ev_station,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 能耗效率
          if (provider.totalMileage > 0) ...[
            const Text(
              '能耗效率',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('燃油每公里成本'),
                        Text(
                          '¥${(totalFuelCost / provider.totalMileage).toStringAsFixed(3)}/km',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('充电每公里成本'),
                        Text(
                          '¥${(totalElectricCost / provider.totalMileage).toStringAsFixed(3)}/km',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('总能耗每公里成本'),
                        Text(
                          '¥${((totalFuelCost + totalElectricCost) / provider.totalMileage).toStringAsFixed(3)}/km',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // 能耗记录列表
          const Text(
            '能耗记录',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // 显示燃油相关记录
          if (fuelExpenses.isNotEmpty) ...[
            const Text('燃油记录', style: TextStyle(fontSize: 14, color: Colors.grey)),
            ...fuelExpenses.map((e) => ListTile(
              leading: const Icon(Icons.local_gas_station, color: Colors.orange),
              title: Text(e.type),
              subtitle: Text('${e.date} | ${e.mileage} km'),
              trailing: Text('¥${e.amount.toStringAsFixed(2)}'),
            )),
          ],

          // 显示充电相关记录
          if (electricExpenses.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('充电记录', style: TextStyle(fontSize: 14, color: Colors.grey)),
            ...electricExpenses.map((e) => ListTile(
              leading: const Icon(Icons.ev_station, color: Colors.green),
              title: Text(e.type),
              subtitle: Text('${e.date} | ${e.mileage} km'),
              trailing: Text('¥${e.amount.toStringAsFixed(2)}'),
            )),
          ],

          if (fuelExpenses.isEmpty && electricExpenses.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('暂无能耗记录，请在记录列表中添加燃油或电费相关支出'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEnergyCard(
    BuildContext context,
    String title,
    double cost,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              '¥${cost.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}