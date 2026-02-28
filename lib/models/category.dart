import 'package:isar/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String name = '';

  String icon = '📦';
  String color = '#C7CEEA';

  bool isDefault = true;
}
