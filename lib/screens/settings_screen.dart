import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/car_info.dart';
import '../services/export_service.dart';
import '../services/import_service.dart';

/// 设置页面 - 车辆信息和数据导入导出
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _startDateController;
  late TextEditingController _purchasePriceController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ExpenseProvider>();
    final carInfo = provider.carInfo;

    _nameController = TextEditingController(text: carInfo?.name ?? '我的车');
    _startDateController = TextEditingController(
      text: carInfo?.startDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    _purchasePriceController = TextEditingController(
      text: carInfo?.purchasePrice?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startDateController.dispose();
    _purchasePriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 车辆信息设置
            const Text(
              '车辆信息',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '车辆名称',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pickStartDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '用车起始日期',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(_startDateController.text),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _purchasePriceController,
                    decoration: const InputDecoration(
                      labelText: '购车价格（可选）',
                      border: OutlineInputBorder(),
                      prefixText: '¥',
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveCarInfo,
                    child: const Text('保存车辆信息'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // 数据导入导出
            const Text(
              '数据管理',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 导出按钮
            Card(
              child: ListTile(
                leading: const Icon(Icons.upload_file, color: Colors.blue),
                title: const Text('导出数据'),
                subtitle: const Text('导出为JSON文件，可用于备份或迁移到其他设备'),
                onTap: _exportData,
              ),
            ),
            const SizedBox(height: 8),

            // 导入按钮
            Card(
              child: ListTile(
                leading: const Icon(Icons.download, color: Colors.green),
                title: const Text('导入数据'),
                subtitle: const Text('从JSON文件导入数据（支持旧版格式）'),
                onTap: _importData,
              ),
            ),
            const SizedBox(height: 8),

            // 清空数据
            Card(
              child: ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('清空所有数据'),
                subtitle: const Text('删除所有记录，此操作不可恢复'),
                onTap: _confirmClearData,
              ),
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // 关于
            const Text(
              '关于',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('用车成本分析 v1.0.0'),
            const Text('支持 Windows 和 Android 平台'),
            const SizedBox(height: 8),
            const Text(
              '数据存储在本地SQLite数据库中，\n'
              '可通过导出功能在不同设备间迁移数据。',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_startDateController.text),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _saveCarInfo() {
    final carInfo = CarInfo(
      name: _nameController.text,
      startDate: _startDateController.text,
      purchasePrice: _purchasePriceController.text.isNotEmpty
          ? double.parse(_purchasePriceController.text)
          : null,
    );
    context.read<ExpenseProvider>().setCarInfo(carInfo);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('车辆信息已保存')),
    );
  }

  void _exportData() async {
    try {
      final exportService = ExportService.instance;
      final file = await exportService.saveJsonToFile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('数据已导出到: ${file.path}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导出失败: $e')),
      );
    }
  }

  void _importData() async {
    final importService = ImportService.instance;

    try {
      final jsonString = await importService.pickJsonFile();
      if (jsonString == null) return;
      if (!mounted) return;

      // 显示导入选项对话框
      final strategy = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('导入数据'),
          content: const Text('发现已有数据，请选择导入方式：'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'overwrite'),
              child: const Text('覆盖现有数据'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'merge'),
              child: const Text('合并数据'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
          ],
        ),
      );

      if (strategy == null) return;

      final result = await importService.importData(jsonString, strategy);
      if (!mounted) return;

      await context.read<ExpenseProvider>().loadData();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导入失败: $e')),
      );
    }
  }

  void _confirmClearData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认清空'),
        content: const Text('确定要清空所有数据吗？此操作不可恢复！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              // 先导出备份
              await ExportService.instance.saveJsonToFile();
              if (!mounted) return;
              // 再清空
              context.read<ExpenseProvider>().loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('数据已清空，备份文件已保存')),
              );
            },
            child: const Text('确认清空'),
          ),
        ],
      ),
    );
  }
}