import 'package:chrysant/data/models/order.dart';
import 'package:chrysant/data/services/order.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'order.g.dart';

@riverpod
class Orders extends _$Orders {
  Future<List<Order>> fetchOrders() async {
    final OrderService service = OrderService();
    final List<Order> orders = await service.getAllOrder();
    return orders;
  }

  @override
  FutureOr<List<Order>> build() async {
    return fetchOrders();
  }

  Future<void> putOrder(Order order) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final OrderService service = OrderService();
      final Order newOrder = Order();
      await service.putOrder(
        id: order.id,
        name: order.name ?? '',
        tableNumber: order.tableNumber,
        isDineIn: order.isDineIn,
        note: order.note ?? '',
        orderedAt: order.orderedAt,
        paidAt: order.paidAt,
        totalPrice: order.totalPrice,
        items: order.items,
      );
      return fetchOrders();
    });
  }

  Future<void> finishOrder(Id id) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final OrderService service = OrderService();
      await service.deleteOrder(id);
      return fetchOrders();
    });
  }

  Future<void> deleteCategory(Id id) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final OrderService service = OrderService();
      await service.deleteOrder(id);
      return fetchOrders();
    });
  }
}

class OrderUtils {
  static Future<Order> getOrder(Id id) async {
    final OrderService service = OrderService();
    final Order order = await service.getOrderById(id);
    return order;
  }
}
