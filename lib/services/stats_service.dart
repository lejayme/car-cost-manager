import 'database.dart';
import '../models/expense.dart';

class StatsService {
  // 今日总支出
  static Future<double> getTodayTotal() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final expenses = await isar.expenses
        .filter()
        .dateGreaterOrEqual(start)
        .findAll();
    return expenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  // 本月总支出
  static Future<double> getMonthTotal() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final expenses = await isar.expenses
        .filter()
        .dateGreaterOrEqual(start)
        .findAll();
    return expenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  // 日均成本
  static Future<double> getDailyAverage({int days = 30}) async {
    final start = DateTime.now().subtract(Duration(days: days));
    final expenses = await isar.expenses
        .filter()
        .dateGreaterOrEqual(start)
        .findAll();
    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
    return total / days;
  }

  // 分类统计
  static Future<Map<int, double>> getCategoryStats({int days = 30}) async {
    final start = DateTime.now().subtract(Duration(days: days));
    final expenses = await isar.expenses
        .filter()
        .dateGreaterOrEqual(start)
        .findAll();

    final Map<int, double> stats = {};
    for (final expense in expenses) {
      stats[expense.categoryId] = (stats[expense.categoryId] ?? 0) + expense.amount;
    }
    return stats;
  }
}
