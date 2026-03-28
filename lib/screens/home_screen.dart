import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/stat_card.dart';
import 'expense_list_screen.dart';
import 'chart_screen.dart';
import 'category_stats_screen.dart';
import 'energy_analysis_screen.dart';
import 'settings_screen.dart';

/// 主页 - 统计概览
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _OverviewTab(),
    const ExpenseListScreen(),
    const ChartScreen(),
    const CategoryStatsScreen(),
    const EnergyAnalysisScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用车成本分析'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: '概览'),
          NavigationDestination(icon: Icon(Icons.list), label: '记录'),
          NavigationDestination(icon: Icon(Icons.show_chart), label: '趋势'),
          NavigationDestination(icon: Icon(Icons.pie_chart), label: '分类'),
          NavigationDestination(icon: Icon(Icons.bolt), label: '能耗'),
        ],
      ),
    );
  }
}

/// 概览标签页
class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 始终显示统计概览，即使没有车辆信息
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 如果没有车辆信息，显示引导卡片
          if (provider.carInfo == null)
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('欢迎使用！请先设置车辆信息开始记录'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        );
                      },
                      child: const Text('去设置'),
                    ),
                  ],
                ),
              ),
            ),
          if (provider.carInfo == null) const SizedBox(height: 16),

          Text(
            '统计概览',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              StatCard(
                title: '总成本',
                value: '¥${provider.totalCost.toStringAsFixed(2)}',
                icon: Icons.account_balance_wallet,
                color: Colors.blue,
              ),
              StatCard(
                title: '总里程',
                value: '${provider.totalMileage.toStringAsFixed(1)} km',
                icon: Icons.route,
                color: Colors.green,
              ),
              StatCard(
                title: '日均成本',
                value: provider.usageDays > 0 ? '¥${provider.dailyCost.toStringAsFixed(2)}' : '--',
                icon: Icons.calendar_today,
                color: Colors.orange,
              ),
              StatCard(
                title: '每公里成本',
                value: provider.totalMileage > 0 ? '¥${provider.perKmCost.toStringAsFixed(2)}' : '--',
                icon: Icons.speed,
                color: Colors.purple,
              ),
              StatCard(
                title: '用车天数',
                value: '${provider.usageDays} 天',
                icon: Icons.date_range,
                color: Colors.teal,
              ),
              StatCard(
                title: '日均里程',
                value: provider.usageDays > 0 ? '${provider.dailyMileage.toStringAsFixed(1)} km' : '--',
                icon: Icons.timeline,
                color: Colors.indigo,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '最近记录',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (provider.expenses.isNotEmpty)
                TextButton(
                  onPressed: () {
                    // 切换到记录页面
                  },
                  child: const Text('查看全部'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _buildRecentExpenses(provider),
        ],
      ),
    );
  }

  Widget _buildRecentExpenses(ExpenseProvider provider) {
    final recentExpenses = provider.expenses.reversed.take(5).toList();

    if (recentExpenses.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('暂无记录'),
        ),
      );
    }

    return Card(
      child: Column(
        children: recentExpenses.map((expense) {
          return ListTile(
            leading: CircleAvatar(
              child: Text(expense.type.substring(0, 1)),
            ),
            title: Text(expense.type),
            subtitle: Text(expense.date),
            trailing: Text(
              '¥${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
      ),
    );
  }
}