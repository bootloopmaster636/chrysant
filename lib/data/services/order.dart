import 'package:chrysant/data/models/order.dart';
import 'package:chrysant/data/services/utils.dart';
import 'package:isar/isar.dart';
import 'package:logger/logger.dart';

class OrderService {
  OrderService() {
    db = openDB();
  }
  late Future<Isar> db;

  Future<List<Order>> getAllOrder() async {
    try {
      final Isar isar = await db;
      final IsarCollection<Order> orders = isar.orders;
      final List<Order> orderItems = await orders.where().findAll();
      return orderItems;
    } catch (e) {
      Logger().e(e.toString());
      return <Order>[];
    }
  }

  Future<Order> getOrderById(Id id) async {
    try {
      final Isar isar = await db;
      final IsarCollection<Order> orders = isar.orders;
      final Order? order = await orders.get(id);
      return order!;
    } catch (e) {
      Logger().e(e.toString());
      return Order();
    }
  }

  Future<void> putOrder({
    required String name,
    required List<OrderMenu> items,
    required int totalPrice,
    Id? id,
    int? tableNumber,
    bool isDineIn = false,
    String? note,
    DateTime? orderedAt,
    DateTime? paidAt,
  }) async {
    try {
      final Isar isar = await db;
      final Order order = Order()
        ..name = name
        ..tableNumber = tableNumber
        ..isDineIn = isDineIn
        ..note = note
        ..orderedAt = orderedAt
        ..paidAt = paidAt
        ..totalPrice = totalPrice
        ..items = items;

      if (id != null) {
        order.id = id;
      }

      await isar.writeTxn(() => isar.orders.put(order));
    } catch (e) {
      Logger().e(e.toString());
    }
  }

  Future<void> deleteOrder(Id id) async {
    try {
      final Isar isar = await db;
      await isar.writeTxn(() => isar.orders.delete(id));
    } catch (e) {
      Logger().e(e.toString());
    }
  }
}
