import 'package:flutter/material.dart';

/// 默认费用类型列表
const List<String> defaultExpenseTypes = [
  '燃油费',
  '电费',
  '保养费',
  '停车费',
  '高速费',
  '保险费',
  '车价',
  '车位费',
  '充电桩',
  '维修费',
  '违章罚款',
  '洗车费',
  '装饰费',
  '其他',
];

/// 费用类型颜色映射
Map<String, Color> expenseTypeColors = {
  '燃油费': Colors.orange,
  '电费': Colors.green,
  '保养费': Colors.blue,
  '停车费': Colors.purple,
  '高速费': Colors.teal,
  '保险费': Colors.red,
  '车价': Colors.indigo,
  '车位费': Colors.brown,
  '充电桩': Colors.cyan,
  '维修费': Colors.grey,
  '违章罚款': Colors.deepOrange,
  '洗车费': Colors.lightBlue,
  '装饰费': Colors.pink,
  '其他': Colors.blueGrey,
};

Color getTypeColor(String type) {
  return expenseTypeColors[type] ?? Colors.blueGrey;
}