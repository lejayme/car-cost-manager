# 🚗 CarCost - 快速开始指南

## 一、项目初始化

### 1.1 创建 Flutter 项目

```bash
# 创建项目
flutter create --org com.yourname --platforms android,windows car_cost_manager

# 进入项目
cd car_cost_manager

# 添加依赖
flutter pub add:
  - isar: ^3.1.0+1
  - isar_flutter_libs: ^3.1.0+1
  - flutter_riverpod: ^2.4.9
  - fl_chart: ^0.66.0
  - intl: ^0.18.1
  - image_picker: ^1.0.7
  - path_provider: ^2.1.2
  - uuid: ^4.3.3
```

### 1.2 pubspec.yaml 完整依赖

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # 状态管理
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  
  # 数据库
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  
  # 图表
  fl_chart: ^0.66.0
  
  # 工具
  intl: ^0.18.1
  uuid: ^4.3.3
  path_provider: ^2.1.2
  image_picker: ^1.0.7
  
  # UI
  google_fonts: ^6.1.0
  flutter_slidable: ^3.0.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  isar_generator: ^3.1.0+1
  build_runner: ^2.4.8
  riverpod_generator: ^2.3.9
```

---

## 二、数据模型

### 2.1 开销模型 (expense.dart)

```dart
import 'package:isar/isar.dart';

part 'expense.g.dart';

@collection
class Expense {
  Id id = Isar.autoIncrement;
  
  @Index()
  int vehicleId = 0;
  
  @Index()
  int categoryId = 0;
  
  double amount = 0.0;
  double? mileage;
  
  @Index()
  DateTime date = DateTime.now();
  
  String? location;
  String? notes;
  String? receiptImagePath;
  String? paymentMethod;
  
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
```

### 2.2 分类模型 (category.dart)

```dart
import 'package:isar/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  String name = '';
  
  String icon = '📦';
  String color = '#C7CEEA';
  
  bool isDefault = true;
}
```

### 2.3 车辆模型 (vehicle.dart)

```dart
import 'package:isar/isar.dart';

part 'vehicle.g.dart';

@collection
class Vehicle {
  Id id = Isar.autoIncrement;
  
  String name = '我的车';
  String? brand;
  String? model;
  String? licensePlate;
  double currentMileage = 0.0;
  
  DateTime createdAt = DateTime.now();
}
```

---

## 三、数据库服务

### 3.1 数据库初始化 (database.dart)

```dart
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'expense.dart';
import 'category.dart';
import 'vehicle.dart';

class DatabaseService {
  static late Isar isar;
  
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [ExpenseSchema, CategorySchema, VehicleSchema],
      directory: dir.path,
    );
    
    // 初始化默认分类
    await _initDefaultCategories();
  }
  
  static Future<void> _initDefaultCategories() async {
    final count = await isar.categories.count();
    if (count == 0) {
      final defaultCategories = [
        Category(name: '充电费', icon: '⚡', color: '#FFD700'),
        Category(name: '加油费', icon: '⛽', color: '#FF6B6B'),
        Category(name: '停车费', icon: '🅿️', color: '#4ECDC4'),
        Category(name: '过路费', icon: '🛣️', color: '#95E1D3'),
        Category(name: '保险费', icon: '🛡️', color: '#A8E6CF'),
        Category(name: '保养费', icon: '🔧', color: '#DCEDC1'),
        Category(name: '维修费', icon: '🔨', color: '#FFEAA7'),
        Category(name: '洗车费', icon: '🚿', color: '#DDA0DD'),
        Category(name: '违章罚款', icon: '📋', color: '#FF8C94'),
        Category(name: '其他', icon: '📦', color: '#C7CEEA'),
      ];
      await isar.writeTxn(() => isar.categories.putAll(defaultCategories));
    }
  }
}
```

---

## 四、核心功能实现

### 4.1 添加开销 (expense_provider.dart)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database.dart';
import 'expense.dart';

final expenseProvider = StateNotifierProvider<ExpenseNotifier, List<Expense>>((ref) {
  return ExpenseNotifier();
});

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  ExpenseNotifier() : super([]) {
    loadExpenses();
  }
  
  Future<void> loadExpenses() async {
    final expenses = await DatabaseService.isar.expenses
        .filter()
        .dateGreaterThan(DateTime.now().subtract(const Duration(days: 30)))
        .sortByDate()
        .findAll();
    state = expenses;
  }
  
  Future<void> addExpense(Expense expense) async {
    await DatabaseService.isar.writeTxn(() => 
      DatabaseService.isar.expenses.put(expense)
    );
    loadExpenses();
  }
  
  Future<void> deleteExpense(int id) async {
    await DatabaseService.isar.writeTxn(() => 
      DatabaseService.isar.expenses.delete(id)
    );
    loadExpenses();
  }
}
```

### 4.2 统计服务 (stats_service.dart)

```dart
import 'database.dart';
import 'expense.dart';

class StatsService {
  // 今日总支出
  static Future<double> getTodayTotal() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final expenses = await DatabaseService.isar.expenses
        .filter()
        .dateGreaterOrEqual(start)
        .findAll();
    return expenses.fold(0.0, (sum, e) => sum + e.amount);
  }
  
  // 本月总支出
  static Future<double> getMonthTotal() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final expenses = await DatabaseService.isar.expenses
        .filter()
        .dateGreaterOrEqual(start)
        .findAll();
    return expenses.fold(0.0, (sum, e) => sum + e.amount);
  }
  
  // 日均成本
  static Future<double> getDailyAverage({int days = 30}) async {
    final start = DateTime.now().subtract(Duration(days: days));
    final expenses = await DatabaseService.isar.expenses
        .filter()
        .dateGreaterOrEqual(start)
        .findAll();
    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
    return total / days;
  }
  
  // 分类统计
  static Future<Map<int, double>> getCategoryStats({int days = 30}) async {
    final start = DateTime.now().subtract(Duration(days: days));
    final expenses = await DatabaseService.isar.expenses
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
```

---

## 五、UI 组件

### 5.1 首页 (home_screen.dart)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'expense_provider.dart';
import 'stats_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  double todayTotal = 0.0;
  double monthTotal = 0.0;
  
  @override
  void initState() {
    super.initState();
    _loadStats();
  }
  
  Future<void> _loadStats() async {
    final today = await StatsService.getTodayTotal();
    final month = await StatsService.getMonthTotal();
    setState(() {
      todayTotal = today;
      monthTotal = month;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚗 CarCost'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          IconButton(icon: const Icon(Icons.person), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 今日支出卡片
            _buildCard(
              title: '今日支出',
              amount: todayTotal,
              subtitle: '共 ${ref.watch(expenseProvider).length} 笔',
            ),
            const SizedBox(height: 16),
            
            // 本月支出卡片
            _buildCard(
              title: '本月支出',
              amount: monthTotal,
              subtitle: '日均 ¥${(monthTotal / DateTime.now().day).toStringAsFixed(1)}',
            ),
            const SizedBox(height: 24),
            
            const Text('最近记录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // 开销列表
            ...ref.watch(expenseProvider).take(5).map((expense) => 
              _buildExpenseTile(expense)
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('记账'),
      ),
    );
  }
  
  Widget _buildCard({required String title, required double amount, required String subtitle}) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade700],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 8),
            Text(
              '¥ ${amount.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildExpenseTile(Expense expense) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: const Text('⚡'),
      ),
      title: Text('充电费'),
      subtitle: Text(expense.notes ?? ''),
      trailing: Text(
        '-¥${expense.amount.toStringAsFixed(2)}',
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
    );
  }
  
  void _showAddExpenseDialog(BuildContext context) {
    // TODO: 实现添加开销对话框
  }
}
```

---

## 六、运行项目

```bash
# 生成代码
flutter pub run build_runner build --delete-conflicting-outputs

# 运行 Android
flutter run -d android

# 运行 Windows
flutter run -d windows

# 打包 Android
flutter build apk --release

# 打包 Windows
flutter build windows --release
```

---

## 七、下一步

1. ✅ 完成数据模型和数据库
2. ⬜ 实现添加/编辑/删除开销
3. ⬜ 实现统计图表
4. ⬜ 添加数据导出功能
5. ⬜ 实现云端同步

---

*创建日期：2026-02-28*
