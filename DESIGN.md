# 用车成本管理应用 - 设计文档

## 项目概述

跨平台用车成本记录及分析软件，支持 Windows 和 Android 平台。

## 技术栈

| 技术 | 说明 |
|------|------|
| Flutter | 跨平台 UI 框架 |
| Dart | 编程语言 |
| SQLite (sqflite) | 本地数据库 |
| Provider | 状态管理 |
| fl_chart | 图表可视化 |
| sqflite_common_ffi | Windows 桌面 SQLite 支持 |

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── models/                   # 数据模型
│   ├── expense.dart          # 开销记录
│   ├── expense_category.dart # 费用分类
│   ├── energy_record.dart    # 能耗记录
│   └── car_info.dart         # 车辆信息
├── providers/                # 状态管理
│   └── expense_provider.dart
├── screens/                  # 页面
│   ├── home_screen.dart      # 主页概览
│   ├── expense_list_screen.dart # 记录列表
│   ├── chart_screen.dart     # 趋势图表
│   ├── category_stats_screen.dart # 分类统计
│   ├── energy_analysis_screen.dart # 能耗分析
│   └── settings_screen.dart  # 设置页面
├── widgets/                  # UI组件
│   ├── stat_card.dart        # 统计卡片
│   └── expense_form.dart     # 记录表单
├── services/                 # 服务层
│   ├── database_service.dart # 数据库操作
│   ├── export_service.dart   # 导出服务
│   └── import_service.dart   # 导入服务
└── utils/                    # 工具类
```

## 功能模块

### 1. 主页概览
- 统计卡片：总成本、总里程、日均成本、每公里成本、用车天数、日均里程
- 最近记录列表
- 快捷设置入口

### 2. 记录管理
- 添加/编辑/删除开销记录
- 支持自定义费用类型
- 日期选择器

### 3. 趋势图表
- 日/周/月/年视图切换
- 成本累积曲线

### 4. 分类统计
- 饼图展示各类型费用占比
- 分类明细列表

### 5. 能耗分析
- 燃油费用统计
- 充电费用统计
- 每公里能耗成本

### 6. 设置
- 车辆信息管理
- 数据导出（JSON格式）
- 数据导入（兼容旧版格式）
- 清空数据

## 数据模型

### Expense (开销记录)
```dart
{
  int? id,
  String date,        // 日期
  String type,        // 费用类型
  double amount,      // 金额
  double mileage,     // 里程
}
```

### CarInfo (车辆信息)
```dart
{
  int? id,
  String name,        // 车辆名称
  String startDate,   // 用车起始日期
  double? purchasePrice, // 购车价格
}
```

### EnergyRecord (能耗记录)
```dart
{
  int? id,
  String date,        // 日期
  String energyType,  // fuel/electricity
  double price,       // 单价
  double quantity,    // 数量
  double totalCost,   // 总花费
}
```

## 跨平台数据迁移

### 导出格式
```json
{
  "version": "2.0",
  "exportTime": "2026-03-28T10:00:00Z",
  "appVersion": "1.0.0",
  "data": {
    "carInfo": {...},
    "expenses": [...],
    "energyRecords": [...]
  }
}
```

### 兼容性
- 支持导入旧版 HTML 应用的 JSON 数据
- 自动转换格式

## 构建命令

### 开发运行
```bash
# Windows
flutter run -d windows

# Android
flutter run -d android
```

### 发布构建
```bash
# Windows
flutter build windows --release

# Android
flutter build apk --release
```

## 依赖包

```yaml
dependencies:
  flutter: sdk
  sqflite: ^2.3.0
  sqflite_common_ffi: ^2.3.0
  path_provider: ^2.1.0
  fl_chart: ^0.66.0
  provider: ^6.1.0
  intl: ^0.18.0
  share_plus: ^7.2.0
  file_picker: ^6.1.0
  excel: ^4.0.0
```

## 版本历史

### v1.0.0 (2026-03-28)
- 初始版本
- 支持 Windows 和 Android 平台
- 基础功能实现：记录管理、统计分析、数据导入导出