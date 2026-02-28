import 'package:isar/isar.dart';

part 'vehicle.g.dart';

@collection
class Vehicle {
  Id id = Isar.autoIncrement;

  String name = '我的车';
  String? brand;
  String? model;
  String? licensePlate;
  double currentMileage = 0.0;

  DateTime createdAt = DateTime.now();
}
