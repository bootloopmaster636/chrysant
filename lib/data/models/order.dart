import 'package:isar/isar.dart';

import 'menu.dart';

part 'order.g.dart';

@collection
class Order {
  Id id = Isar.autoIncrement;
  String? name;
  int? tableNumber;
  bool isDineIn = false;
  DateTime? orderedAt;
  DateTime? paidAt;
  final items = IsarLinks<Menu>();
}
