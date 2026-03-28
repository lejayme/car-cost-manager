# CarCost - 用车成本管理应用

[![Flutter](https://img.shields.io/badge/Flutter-3.11+-blue.svg)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Android-green.svg)](https://flutter.dev)
[![Version](https://img.shields.io/badge/Version-1.0.0-orange.svg)](https://github.com)

一款跨平台用车成本记录与分析工具，帮助用户清晰掌握车辆使用开销，优化用车决策。

## 功能特性

- **开销记录管理** - 添加/编辑/删除开销记录，支持自定义费用类型
- **统计概览** - 总成本、日均成本、每公里成本、用车天数等统计卡片
- **趋势图表** - 日/周/月/年视图的成本累积曲线
- **分类统计** - 饼图展示各类型费用占比
- **能耗分析** - 燃油费用、充电费用、每公里能耗成本统计
- **数据导入导出** - JSON格式导出，支持导入旧版数据
- **跨平台支持** - Windows 桌面 + Android 移动端

## 支持的费用类型

| 类型 | 说明 |
|------|------|
| 充电费 | 电动汽车充电支出 |
| 加油费 | 燃油车加油支出 |
| 停车费 | 停车场费用 |
| 过路费 | 高速公路通行费 |
| 保险费 | 车辆保险支出 |
| 保养费 | 定期保养维护 |
| 维修费 | 车辆维修支出 |
| 洗车费 | 洗车服务费用 |
| 违章罚款 | 交通违章处罚 |
| 其他 | 其他杂项支出 |

## 技术栈

| 技术 | 说明 |
|------|------|
| Flutter | 跨平台 UI 框架 |
| SQLite (sqflite) | 本地数据存储 |
| Provider | 状态管理 |
| fl_chart | 图表可视化 |
| sqflite_common_ffi | Windows 桌面 SQLite 支持 |

## 环境要求

- Flutter SDK 3.11.4 或更高版本
- Dart SDK 3.11.4 或更高版本

**Windows 构建：**
- Visual Studio 2022 或更高版本（包含 C++ 桌面开发工具）

**Android 构建：**
- Android SDK
- Android Studio 或 VS Code + Flutter 扩展

## 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/your-username/car-cost-manager.git
cd car-cost-manager
```

### 2. 安装依赖

```bash
flutter pub get
```

### 3. 运行应用

**Windows：**
```bash
flutter run -d windows
```

**Android（连接设备或模拟器）：**
```bash
flutter run -d android
```

## 构建发布

### Windows 发布版

```bash
flutter build windows --release
```

构建产物位于：`build/windows/x64/runner/Release/`

### Android APK

```bash
flutter build apk --release
```

构建产物位于：`build/app/outputs/flutter-apk/app-release.apk`

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
│   └ expense_provider.dart
├── screens/                  # 页面
│   ├── home_screen.dart      # 主页概览
│   ├── expense_list_screen.dart # 记录列表
│   ├── chart_screen.dart     # 趋势图表
│   ├── category_stats_screen.dart # 分类统计
│   ├── energy_analysis_screen.dart # 能耗分析
│   └ settings_screen.dart    # 设置页面
├── widgets/                  # UI组件
│   ├── stat_card.dart        # 统计卡片
│   └ expense_form.dart       # 记录表单
├── services/                 # 服务层
│   ├── database_service.dart # 数据库操作
│   ├── export_service.dart   # 导出服务
│   └ import_service.dart     # 导入服务
└── utils/                    # 工具类
```

## 数据格式

### 导出格式 (JSON)

```json
{
  "version": "2.0",
  "exportTime": "2026-03-28T10:00:00Z",
  "appVersion": "1.0.0",
  "data": {
    "carInfo": {
      "name": "我的车",
      "startDate": "2026-01-01",
      "purchasePrice": 150000
    },
    "expenses": [
      {
        "date": "2026-03-28",
        "type": "加油费",
        "amount": 350.0,
        "mileage": 12345.0
      }
    ],
    "energyRecords": [...]
  }
}
```

### 兼容性

支持导入旧版 HTML 应用的 JSON 数据格式，自动转换为新版结构。

## 开发计划

| 版本 | 目标 |
|------|------|
| v1.0 | 基础记账 + 本地统计（已完成） |
| v1.5 | 多车支持 + 快速记账模板 |
| v2.0 | 云端同步 + OCR发票识别 |

详细需求参见 [requirements.md](requirements.md)

## 贡献指南

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送分支 (`git push origin feature/amazing-feature`)
5. 提交 Pull Request

## 许可证

本项目采用 MIT 许可证 - 详情见 [LICENSE](LICENSE) 文件