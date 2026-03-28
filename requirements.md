# 🚗 用车成本管理软件 - 需求方案设计

## 1. 项目概述

### 1.1 产品名称
**CarCost** - 智能用车成本管家

### 1.2 产品定位
跨平台（Android + Windows）个人用车成本记录与分析工具，帮助用户清晰掌握车辆使用开销，优化用车决策。

### 1.3 目标用户
- 私家车主
- 网约车/出租车司机
- 车队管理员
- 需要报销用车费用的商务人士

### 1.4 核心价值
- 📊 **透明化**：每一笔开销清晰可查
- 📈 **数据化**：用数据驱动用车决策
- 💰 **省钱**：发现不必要的开支，优化成本
- 🔄 **同步**：多端数据实时同步（规划中）

---

## 2. 功能需求

### 2.1 核心功能模块

```
┌─────────────────────────────────────────────────────────────┐
│                      CarCost 系统架构                        │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  记录模块   │  │  分析模块   │  │    设置与管理       │  │
│  │  ✅ 已实现  │  │  ✅ 已实现  │  │    ✅ 已实现        │  │
│  │             │  │             │  │                     │  │
│  │ ✅ 添加开销 │  │ ✅ 日/月统计│  │ ✅ 车辆信息管理    │  │
│  │ ✅ 编辑删除 │  │ ✅ 图表分析 │  │ ✅ 数据导出导入    │  │
│  │ ⏳ 拍照上传 │  │ ✅ 趋势图表 │  │ ⏳ 多车支持        │  │
│  │ ⏳ 快速记账 │  │ ✅ 分类占比 │  │ ⏳ 云端同步        │  │
│  │ ⏳ 定期开销 │  │ ⏳ 成本排行 │  │ ⏳ 预算设置        │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
│  ✅ = 已实现    ⏳ = 规划中                                  │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 详细功能清单

#### 📝 模块一：开销记录

| 功能 | 描述 | 优先级 | 状态 |
|------|------|--------|------|
| 添加开销 | 记录金额、类型、日期、里程数 | P0 | ✅ 已实现 |
| 开销分类 | 充电费、停车费、加油费、保险、保养、维修、洗车、过路费、违章罚款、其他 | P0 | ✅ 已实现 |
| 编辑/删除 | 修改或移除已有记录 | P0 | ✅ 已实现 |
| 快速记账 | 一键记录常用开销（预设模板） | P1 | ⏳ 规划中 |
| 拍照上传 | 拍摄发票/收据，OCR 自动识别金额 | P1 | ⏳ 规划中 |
| 定期开销 | 设置周期性自动记录（如月保、保险） | P2 | ⏳ 规划中 |
| 批量导入 | Excel/CSV 导入历史数据 | P2 | ⏳ 规划中 |

#### 📊 模块二：数据分析

| 功能 | 描述 | 优先级 | 状态 |
|------|------|--------|------|
| 总成本统计 | 显示累计总开销 | P0 | ✅ 已实现 |
| 日均成本 | 平均每日用车成本 | P0 | ✅ 已实现 |
| 每公里成本 | 平均每公里开销 | P0 | ✅ 已实现 |
| 趋势图表 | 日/周/月/年视图，成本累积曲线 | P1 | ✅ 已实现 |
| 分类占比 | 饼图展示各类开销比例 | P1 | ✅ 已实现 |
| 能耗分析 | 燃油/充电费用、每公里能耗成本 | P1 | ✅ 已实现 |
| 成本排行 | 按金额/频次排序开销项目 | P1 | ⏳ 规划中 |
| 年度对比 | 同比/环比数据分析 | P2 | ⏳ 规划中 |

#### ⚙️ 模块三：设置与管理

| 功能 | 描述 | 优先级 | 状态 |
|------|------|--------|------|
| 车辆信息管理 | 设置车辆名称、起始日期、购车价格 | P1 | ✅ 已实现 |
| 数据导出 | 导出 JSON 格式数据文件 | P1 | ✅ 已实现 |
| 数据导入 | 导入 JSON 数据，兼容旧版格式 | P1 | ✅ 已实现 |
| 清空数据 | 重置所有记录 | P1 | ✅ 已实现 |
| 多车支持 | 支持多辆车，切换查看 | P1 | ⏳ 规划中 |
| 云端同步 | 云端备份与同步（账号登录） | P1 | ⏳ 规划中 |
| 预算设置 | 设置月度/年度预算，超支提醒 | P2 | ⏳ 规划中 |
| 提醒功能 | 保险到期、保养提醒 | P2 | ⏳ 规划中 |

---

## 3. 数据结构设计

### 3.1 当前数据模型（v1.0.0 已实现）

#### Expense（开销记录）
```dart
class Expense {
  int? id;
  String date;        // 日期 (yyyy-MM-dd)
  String type;        // 费用类型
  double amount;      // 金额
  double mileage;     // 里程
}
```

#### CarInfo（车辆信息）
```dart
class CarInfo {
  int? id;
  String name;            // 车辆名称
  String startDate;       // 用车起始日期
  double? purchasePrice;  // 购车价格
}
```

#### EnergyRecord（能耗记录）
```dart
class EnergyRecord {
  int? id;
  String date;        // 日期
  String energyType;  // fuel / electricity
  double price;       // 单价
  double quantity;    // 数量（升/度）
  double totalCost;   // 总花费
}
```

### 3.2 规划数据模型（v2.0 目标）

```sql
-- 车辆表（多车支持）
CREATE TABLE vehicles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    brand TEXT,
    model TEXT,
    license_plate TEXT,
    purchase_date DATE,
    purchase_price REAL,
    current_mileage REAL
);

-- 开销分类表（自定义分类）
CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    icon TEXT,
    color TEXT,
    is_default BOOLEAN DEFAULT 1
);

-- 用户表（云端同步）
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    email TEXT,
    phone TEXT
);
```

### 3.3 默认费用分类

| 分类 | 图标 | 说明 |
|------|------|------|
| 充电费 | ⚡ | 电动汽车充电支出 |
| 加油费 | ⛽ | 燃油车加油支出 |
| 停车费 | 🅿️ | 停车场费用 |
| 过路费 | 🛣️ | 高速公路通行费 |
| 保险费 | 🛡️ | 车辆保险支出 |
| 保养费 | 🔧 | 定期保养维护 |
| 维修费 | 🔨 | 车辆维修支出 |
| 洗车费 | 🚿 | 洗车服务费用 |
| 违章罚款 | 📋 | 交通违章处罚 |
| 其他 | 📦 | 其他杂项支出 |

---

## 4. 技术选型

### 4.1 已采用技术栈（v1.0.0）

| 技术 | 版本 | 说明 |
|------|------|------|
| Flutter | 3.11+ | 跨平台 UI 框架 |
| Dart | 3.11+ | 编程语言 |
| SQLite (sqflite) | 2.3.0 | 本地数据存储 |
| Provider | 6.1.0 | 状态管理 |
| fl_chart | 0.66.0 | 图表可视化 |
| sqflite_common_ffi | 2.3.0 | Windows SQLite 支持 |
| intl | 0.18.0 | 国际化与日期格式化 |
| file_picker | 6.1.0 | 文件选择 |
| share_plus | 7.2.0 | 文件分享 |
| excel | 4.0.0 | Excel 导出支持 |

### 4.2 技术架构

```
┌─────────────────────────────────────────────────────────────┐
│                    技术架构                                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  前端框架：Flutter 3.11+                                    │
│  ├─ Windows: Flutter Windows Desktop                        │
│  └─ Android: 原生编译                                       │
│                                                             │
│  状态管理：Provider                                         │
│                                                             │
│  本地数据库：SQLite (sqflite)                               │
│  ├─ Android: sqflite                                        │
│  └─ Windows: sqflite_common_ffi                             │
│                                                             │
│  图表可视化：fl_chart                                       │
│                                                             │
│  数据导出：JSON / Excel                                     │
│                                                             │
│  云端同步（规划）：Firebase / Supabase                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 4.3 项目结构

```
car_cost_manager/
├── lib/
│   ├── main.dart                 # 应用入口
│   ├── models/                   # 数据模型
│   │   ├── expense.dart          # 开销记录 ✅
│   │   ├── expense_category.dart # 费用分类 ✅
│   │   ├── energy_record.dart    # 能耗记录 ✅
│   │   └── car_info.dart         # 车辆信息 ✅
│   ├── providers/                # 状态管理
│   │   └── expense_provider.dart # ✅
│   ├── screens/                  # 页面
│   │   ├── home_screen.dart      # 主页概览 ✅
│   │   ├── expense_list_screen.dart # 记录列表 ✅
│   │   ├── chart_screen.dart     # 趋势图表 ✅
│   │   ├── category_stats_screen.dart # 分类统计 ✅
│   │   ├── energy_analysis_screen.dart # 能耗分析 ✅
│   │   └ settings_screen.dart    # 设置页面 ✅
│   ├── widgets/                  # UI组件
│   │   ├── stat_card.dart        # 统计卡片 ✅
│   │   └ expense_form.dart       # 记录表单 ✅
│   ├── services/                 # 服务层
│   │   ├── database_service.dart # 数据库操作 ✅
│   │   ├── export_service.dart   # 导出服务 ✅
│   │   └ import_service.dart     # 导入服务 ✅
│   └── utils/                    # 工具类
├── android/                      # Android 平台配置
├── windows/                      # Windows 平台配置
└── test/                         # 测试目录
```

---

## 5. 数据导出导入

### 5.1 导出格式（v2.0）

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

### 5.2 兼容性

- ✅ 支持导入旧版 HTML 应用的 JSON 数据格式
- ✅ 自动转换为新版数据结构

---

## 6. 开发计划

### 6.1 版本里程碑

| 版本 | 日期 | 状态 | 目标 |
|------|------|------|------|
| **v1.0.0** | 2026-03-28 | ✅ 已完成 | 基础记账 + 本地统计 + 数据导入导出 |
| **v1.5.0** | 规划中 | ⏳ | 多车支持 + 快速记账模板 + 分类自定义 |
| **v2.0.0** | 规划中 | ⏳ | 云端同步 + OCR 发票识别 + 预算提醒 |

### 6.2 v1.0.0 已完成功能

- ✅ Flutter 项目搭建
- ✅ SQLite 数据库设计与实现
- ✅ 开销记录管理（添加/编辑/删除）
- ✅ 主页统计概览
- ✅ 趋势图表（日/周/月/年视图）
- ✅ 分类统计（饼图）
- ✅ 能耗分析
- ✅ 车辆信息管理
- ✅ 数据导入导出（JSON）
- ✅ Windows + Android 双平台支持

### 6.3 v1.5.0 规划功能

- ⏳ 多车支持
- ⏳ 快速记账模板
- ⏳ 自定义费用分类
- ⏳ 成本排行榜
- ⏳ Excel 导出增强

### 6.4 v2.0.0 规划功能

- ⏳ 云端同步（Firebase / Supabase）
- ⏳ OCR 发票识别
- ⏳ 预算设置与超支提醒
- ⏳ 保险/保养到期提醒
- ⏳ 年度对比分析

---

## 7. 构建与运行

### 7.1 环境要求

- Flutter SDK 3.11.4+
- Dart SDK 3.11.4+
- Windows: Visual Studio 2022（C++ 桌面开发工具）
- Android: Android SDK + Android Studio

### 7.2 开发运行

```bash
# 安装依赖
flutter pub get

# Windows 开发
flutter run -d windows

# Android 开发
flutter run -d android
```

### 7.3 发布构建

```bash
# Windows 发布版
flutter build windows --release

# Android APK
flutter build apk --release
```

---

## 8. 风险与挑战

| 风险 | 影响 | 应对措施 |
|------|------|----------|
| 跨平台 UI 一致性 | 中 | ✅ 使用 Flutter 统一组件库 |
| 数据同步冲突 | 高 | 规划版本控制与冲突解决策略 |
| OCR 识别准确率 | 中 | 支持手动修正，不依赖 OCR |
| 用户数据隐私 | 高 | 本地存储，云端传输加密 |
| 电量/性能消耗 | 低 | 优化数据库查询，懒加载 |

---

## 9. 附录

### 9.1 竞品参考
- 小熊油耗
- 加油记账
- Car Care
- 汽车记账本

### 9.2 设计资源
- Flutter 组件库：https://flutter.dev
- 图标：Material Icons
- 配色：Material Design Color System

---

*文档版本：v2.0*
*更新日期：2026-03-28*
*当前版本：v1.0.0*