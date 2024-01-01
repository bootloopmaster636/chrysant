import 'package:isar/isar.dart';

part 'menu.g.dart';

@collection
class Menu {
  Id id = Isar.autoIncrement;
  String imagePath = "";
  String name = "";
  String? description = "";
  int price = 0;
  String category = "";
}
