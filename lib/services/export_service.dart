import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'database_service.dart';

/// 导出服务 - JSON和Excel导出
class ExportService {
  static final ExportService instance = ExportService._internal();
  ExportService._internal();

  final DatabaseService _db = DatabaseService.instance;

  /// 导出数据为JSON格式
  Future<String> exportToJson() async {
    final expenses = await _db.getAllExpenses();
    final energyRecords = await _db.getAllEnergyRecords();
    final carInfo = await _db.getCarInfo();

    final exportData = {
      'version': '2.0',
      'exportTime': DateTime.now().toIso8601String(),
      'appVersion': '1.0.0',
      'data': {
        'carInfo': carInfo?.toMap(),
        'expenses': expenses.map((e) => e.toMap()).toList(),
        'energyRecords': energyRecords.map((e) => e.toMap()).toList(),
      },
    };

    return jsonEncode(exportData);
  }

  /// 保存JSON文件到本地
  Future<File> saveJsonToFile() async {
    final jsonData = await exportToJson();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'car_cost_backup_$timestamp.json';

    // 获取保存目录
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');

    await file.writeAsString(jsonData);
    return file;
  }

  /// 分享JSON文件（用于Android）
  Future<void> shareJsonFile() async {
    final file = await saveJsonToFile();
    await Share.shareXFiles([XFile(file.path)], text: '用车成本数据备份');
  }

  /// 兼容旧版数据格式导入
  Map<String, dynamic> parseJsonData(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    // 检查是否为旧版格式（无version字段）
    if (data.containsKey('expenses') && !data.containsKey('version')) {
      // 转换旧版格式为新版格式
      return {
        'version': '1.0',
        'exportTime': DateTime.now().toIso8601String(),
        'appVersion': 'legacy',
        'data': {
          'carInfo': {'name': '我的车', 'startDate': data['startDate'] ?? ''},
          'expenses': data['expenses'] ?? [],
          'energyRecords': [],
        },
      };
    }

    return data;
  }
}