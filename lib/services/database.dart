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
        Category(name: '装饰改装', icon: '🎨', color: '#B5EAD7'),
        Category(name: '其他', icon: '📦', color: '#C7CEEA'),
      ];
      await isar.writeTxn(() => isar.categories.putAll(defaultCategories));
    }
  }
}
