import 'package:isar/isar.dart';

part 'expense.g.dart';

@collection
class Expense {
  Id id = Isar.autoIncrement;

  @Index()
  int vehicleId = 0;

  @Index()
  int categoryId = 0;

  double amount = 0.0;
  double? mileage;

  @Index()
  DateTime date = DateTime.now();

  String? location;
  String? notes;
  String? receiptImagePath;
  String? paymentMethod;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  Expense() {
    updatedAt = DateTime.now();
  }
}
