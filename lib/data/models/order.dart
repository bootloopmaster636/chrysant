import 'package:isar/isar.dart';

part 'order.g.dart';

@collection
class Order {
  Id id = Isar.autoIncrement;
  String name = "";
  int? tableNumber;
  bool isDineIn = false;
  DateTime? orderedAt;
  DateTime? paidAt;
  List<OrderMenu> items = [];
}

@embedded
class OrderMenu {
  String name = "";
  String? description = "";
  int price = 0;
  int quantity = 0;
  String category = "";
}
