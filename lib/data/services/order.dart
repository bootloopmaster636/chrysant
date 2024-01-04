import 'package:isar/isar.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import '../models/category.dart';
import '../models/menu.dart';
import '../models/order.dart';

class OrderService {
  late Future<Isar> db;

  OrderService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    final dir = await getApplicationSupportDirectory();
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [CategorySchema, MenuSchema, OrderSchema],
        directory: dir.path,
        inspector: true,
      );
    }

    return Future.value(Isar.getInstance());
  }

  Future<List<Order>> getAllOrder() async {
    try {
      final isar = await db;
      final orders = isar.orders;
      final orderItems = await orders.where().findAll();
      return orderItems;
    } catch (e) {
      Logger().e(e.toString());
      return [];
    }
  }

  Future<void> putOrder(
      {Id? id,
      required String name,
      int? tableNumber,
      bool isDineIn = false,
      String? note,
      DateTime? orderedAt,
      DateTime? paidAt,
      required List<OrderMenu> items}) async {
    try {
      final isar = await db;
      var order = Order()
        ..name = name
        ..tableNumber = tableNumber
        ..isDineIn = isDineIn
        ..note = note
        ..orderedAt = orderedAt
        ..paidAt = paidAt
        ..items = items;

      if (id != null) {
        order.id = id;
      }

      isar.writeTxn(() => isar.orders.put(order));
    } catch (e) {
      Logger().e(e.toString());
    }
  }

  Future<void> deleteOrder(Id id) async {
    try {
      final isar = await db;
      await isar.writeTxn(() => isar.orders.delete(id));
    } catch (e) {
      Logger().e(e.toString());
    }
  }
}
