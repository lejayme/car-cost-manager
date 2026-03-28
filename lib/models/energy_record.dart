/// 能耗记录模型（油价/电价）
class EnergyRecord {
  final int? id;
  final String date;
  final String energyType; // 'fuel' 或 'electricity'
  final double price; // 单价（元/升 或 元/度）
  final double quantity; // 数量（升 或 度）
  final double totalCost; // 总花费

  EnergyRecord({
    this.id,
    required this.date,
    required this.energyType,
    required this.price,
    required this.quantity,
    required this.totalCost,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'energyType': energyType,
      'price': price,
      'quantity': quantity,
      'totalCost': totalCost,
    };
  }

  factory EnergyRecord.fromMap(Map<String, dynamic> map) {
    return EnergyRecord(
      id: map['id'] as int?,
      date: map['date'] as String,
      energyType: map['energyType'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: (map['quantity'] as num).toDouble(),
      totalCost: (map['totalCost'] as num).toDouble(),
    );
  }

  EnergyRecord copyWith({
    int? id,
    String? date,
    String? energyType,
    double? price,
    double? quantity,
    double? totalCost,
  }) {
    return EnergyRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      energyType: energyType ?? this.energyType,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      totalCost: totalCost ?? this.totalCost,
    );
  }

  String get energyTypeLabel {
    switch (energyType) {
      case 'fuel':
        return '燃油';
      case 'electricity':
        return '充电';
      default:
        return energyType;
    }
  }
}