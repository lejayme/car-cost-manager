/// 开销记录模型
class Expense {
  final int? id;
  final String date;
  final String type;
  final double amount;
  final double mileage;

  Expense({
    this.id,
    required this.date,
    required this.type,
    required this.amount,
    required this.mileage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'type': type,
      'amount': amount,
      'mileage': mileage,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      date: map['date'] as String,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      mileage: (map['mileage'] as num).toDouble(),
    );
  }

  Expense copyWith({
    int? id,
    String? date,
    String? type,
    double? amount,
    double? mileage,
  }) {
    return Expense(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      mileage: mileage ?? this.mileage,
    );
  }

  @override
  String toString() {
    return 'Expense(id: $id, date: $date, type: $type, amount: $amount, mileage: $mileage)';
  }
}