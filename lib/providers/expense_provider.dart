import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/energy_record.dart';
import '../models/car_info.dart';
import '../services/database_service.dart';

/// 开销数据状态管理
class ExpenseProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  List<Expense> _expenses = [];
  List<EnergyRecord> _energyRecords = [];
  CarInfo? _carInfo;
  bool _isLoading = false;

  List<Expense> get expenses => _expenses;
  List<EnergyRecord> get energyRecords => _energyRecords;
  CarInfo? get carInfo => _carInfo;
  bool get isLoading => _isLoading;

  // 统计数据
  double get totalCost => _expenses.fold(0, (sum, e) => sum + e.amount);
  double get totalMileage => _expenses.fold(0, (sum, e) => sum + e.mileage);

  int get usageDays {
    if (_carInfo == null) return 0;
    final start = DateTime.parse(_carInfo!.startDate);
    final now = DateTime.now();
    return (now.difference(start).inDays) + 1;
  }

  double get dailyCost {
    if (usageDays == 0) return 0;
    return totalCost / usageDays;
  }

  double get perKmCost {
    if (totalMileage == 0) return 0;
    return totalCost / totalMileage;
  }

  double get dailyMileage {
    if (usageDays == 0) return 0;
    return totalMileage / usageDays;
  }

  Map<String, double> get costByCategory {
    Map<String, double> result = {};
    for (var expense in _expenses) {
      result[expense.type] = (result[expense.type] ?? 0) + expense.amount;
    }
    return result;
  }

  /// 加载所有数据
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _expenses = await _db.getAllExpenses();
      _energyRecords = await _db.getAllEnergyRecords();
      _carInfo = await _db.getCarInfo();
    } catch (e) {
      debugPrint('加载数据失败: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 添加开销记录
  Future<void> addExpense(Expense expense) async {
    await _db.insertExpense(expense);
    await loadData();
  }

  /// 更新开销记录
  Future<void> updateExpense(Expense expense) async {
    await _db.updateExpense(expense);
    await loadData();
  }

  /// 删除开销记录
  Future<void> deleteExpense(int id) async {
    await _db.deleteExpense(id);
    await loadData();
  }

  /// 添加能耗记录
  Future<void> addEnergyRecord(EnergyRecord record) async {
    await _db.insertEnergyRecord(record);
    await loadData();
  }

  /// 更新能耗记录
  Future<void> updateEnergyRecord(EnergyRecord record) async {
    await _db.updateEnergyRecord(record);
    await loadData();
  }

  /// 删除能耗记录
  Future<void> deleteEnergyRecord(int id) async {
    await _db.deleteEnergyRecord(id);
    await loadData();
  }

  /// 设置车辆信息
  Future<void> setCarInfo(CarInfo carInfo) async {
    final existing = await _db.getCarInfo();
    if (existing != null) {
      await _db.updateCarInfo(carInfo.copyWith(id: existing.id));
    } else {
      await _db.insertCarInfo(carInfo);
    }
    await loadData();
  }
}