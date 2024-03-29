import 'package:isar/isar.dart';

part 'order.g.dart';

@collection
class Order {
  Id id = Isar.autoIncrement;
  String? name = '';
  int? tableNumber;
  bool isDineIn = false;
  DateTime? orderedAt;
  DateTime? paidAt;
  int totalPrice = 0;
  String? note = '';
  List<OrderMenu> items = <OrderMenu>[];
}

@embedded
class OrderMenu {
  String name = '';
  int price = 0;
  int quantity = 0;
}
