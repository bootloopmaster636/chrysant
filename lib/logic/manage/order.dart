import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/order.dart';
import '../../data/services/order.dart';

part 'order.g.dart';

@riverpod
class Orders extends _$Orders {
  Future<List<Order>> _fetchOrders() async {
    final service = OrderService();
    final List<Order> orders = await service.getAllOrder();
    return orders;
  }

  @override
  FutureOr<List<Order>> build() async {
    return _fetchOrders();
  }

  Future<void> addOrder(Order order) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final service = OrderService();
      await service.putOrder(
        id: order.id,
        name: order.name ?? '',
        tableNumber: order.tableNumber,
        isDineIn: order.isDineIn,
        note: order.note ?? '',
        orderedAt: order.orderedAt,
        paidAt: order.paidAt,
        items: order.items,
      );
      return await _fetchOrders();
    });
  }

  Future<void> deleteCategory(Id id) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final service = OrderService();
      await service.deleteOrder(id);
      return await _fetchOrders();
    });
  }
}