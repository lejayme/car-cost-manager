import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import '../models/expense.dart';
import '../models/energy_record.dart';
import '../models/car_info.dart';
import 'database_service.dart';
import 'export_service.dart';

/// 导入服务 - 数据校验和冲突处理
class ImportService {
  static final ImportService instance = ImportService._internal();
  ImportService._internal();

  final DatabaseService _db = DatabaseService.instance;
  final ExportService _export = ExportService.instance;

  /// 从文件选择器选择JSON文件
  Future<String?> pickJsonFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final bytes = result.files.first.bytes;
      if (bytes != null) {
        return utf8.decode(bytes);
      }
    }
    return null;
  }

  /// 验证导入数据格式
  bool validateImportData(Map<String, dynamic> data) {
    final dataSection = data['data'] as Map<String, dynamic>?;
    if (dataSection == null) return false;

    // 检查必要字段
    if (!dataSection.containsKey('expenses')) return false;

    // 验证expenses格式
    final expenses = dataSection['expenses'] as List?;
    if (expenses == null) return false;

    for (var exp in expenses) {
      if (exp['date'] == null || exp['amount'] == null || exp['mileage'] == null) {
        return false;
      }
    }

    return true;
  }

  /// 导入数据到数据库
  /// conflictStrategy: 'overwrite' | 'merge' | 'skip'
  Future<ImportResult> importData(
    String jsonString,
    String conflictStrategy,
  ) async {
    final data = _export.parseJsonData(jsonString);

    if (!validateImportData(data)) {
      return ImportResult(success: false, message: '数据格式无效');
    }

    final dataSection = data['data'] as Map<String, dynamic>;

    // 导入前备份现有数据
    if (conflictStrategy == 'overwrite') {
      await _db.clearAllData();
    }

    int expenseCount = 0;
    int energyCount = 0;

    // 导入车辆信息
    final carInfoData = dataSection['carInfo'] as Map<String, dynamic>?;
    if (carInfoData != null && carInfoData['startDate'] != null) {
      final existingCarInfo = await _db.getCarInfo();
      if (existingCarInfo != null) {
        await _db.updateCarInfo(CarInfo(
          id: existingCarInfo.id,
          name: carInfoData['name'] as String? ?? existingCarInfo.name,
          startDate: carInfoData['startDate'] as String,
          purchasePrice: carInfoData['purchasePrice'] as double?,
        ));
      } else {
        await _db.insertCarInfo(CarInfo(
          name: carInfoData['name'] as String? ?? '我的车',
          startDate: carInfoData['startDate'] as String,
          purchasePrice: carInfoData['purchasePrice'] as double?,
        ));
      }
    }

    // 导入开销记录
    final expensesData = dataSection['expenses'] as List;
    for (var expData in expensesData) {
      final expense = Expense(
        date: expData['date'] as String,
        type: expData['type'] as String? ?? '其他',
        amount: (expData['amount'] as num).toDouble(),
        mileage: (expData['mileage'] as num).toDouble(),
      );

      if (conflictStrategy == 'merge') {
        // 检查是否已存在相同日期和类型的记录
        final existing = await _db.getAllExpenses();
        final duplicate = existing.any((e) =>
            e.date == expense.date &&
            e.type == expense.type &&
            e.amount == expense.amount);

        if (duplicate) continue;
      }

      await _db.insertExpense(expense);
      expenseCount++;
    }

    // 导入能耗记录
    final energyData = dataSection['energyRecords'] as List?;
    if (energyData != null) {
      for (var recordData in energyData) {
        final record = EnergyRecord(
          date: recordData['date'] as String,
          energyType: recordData['energyType'] as String,
          price: (recordData['price'] as num).toDouble(),
          quantity: (recordData['quantity'] as num).toDouble(),
          totalCost: (recordData['totalCost'] as num).toDouble(),
        );
        await _db.insertEnergyRecord(record);
        energyCount++;
      }
    }

    return ImportResult(
      success: true,
      message: '导入成功：${expenseCount}条开销记录，${energyCount}条能耗记录',
      expenseCount: expenseCount,
      energyCount: energyCount,
    );
  }
}

/// 导入结果
class ImportResult {
  final bool success;
  final String message;
  final int expenseCount;
  final int energyCount;

  ImportResult({
    required this.success,
    required this.message,
    this.expenseCount = 0,
    this.energyCount = 0,
  });
}