import 'package:isar/isar.dart';

import 'category.dart';

part 'menu.g.dart';

@collection
class Menu {
  Id id = Isar.autoIncrement;
  String name = "";
  String? description = "";
  int price = 0;
  final category = IsarLink<Category>();
}
