/// 车辆信息模型
class CarInfo {
  final int? id;
  final String name;
  final String startDate;
  final double? purchasePrice;

  CarInfo({
    this.id,
    required this.name,
    required this.startDate,
    this.purchasePrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate,
      'purchasePrice': purchasePrice,
    };
  }

  factory CarInfo.fromMap(Map<String, dynamic> map) {
    return CarInfo(
      id: map['id'] as int?,
      name: map['name'] as String,
      startDate: map['startDate'] as String,
      purchasePrice: map['purchasePrice'] != null
          ? (map['purchasePrice'] as num).toDouble()
          : null,
    );
  }

  CarInfo copyWith({
    int? id,
    String? name,
    String? startDate,
    double? purchasePrice,
  }) {
    return CarInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
    );
  }
}