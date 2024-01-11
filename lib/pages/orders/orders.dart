import 'package:chrysant/constants.dart';
import 'package:chrysant/data/models/order.dart';
import 'package:chrysant/logic/manage/order.dart';
import 'package:chrysant/pages/components/titled_widget.dart';
import 'package:chrysant/pages/orders/modify_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class OrdersPage extends HookWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<int> selectedOrderId =
        useState(-1); // selectedOrderId -1 is nothing selected

    useEffect(
      () {
        selectedOrderId.value = -1;
        return null;
      },
      <Object?>[selectedOrderId.value],
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < tabletWidth) {
          return OrdersPageMobile(
            selectedOrderId: selectedOrderId,
          );
        } else {
          return OrdersPageTablet(
            selectedOrderId: selectedOrderId,
          );
        }
      },
    );
  }
}

class OrdersPageMobile extends HookConsumerWidget {
  const OrdersPageMobile({
    required this.selectedOrderId,
    super.key,
  });
  final ValueNotifier<int> selectedOrderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: 'Orders'),
              Tab(text: 'Order Details'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            OrderListScreen(selectedOrderId: selectedOrderId),
            OrderDetailsScreen(selectedOrderId: selectedOrderId),
          ],
        ),
      ),
    );
  }
}

class OrdersPageTablet extends HookConsumerWidget {
  const OrdersPageTablet({
    required this.selectedOrderId,
    super.key,
  });
  final ValueNotifier<int> selectedOrderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: 40.w,
          child: Column(
            children: <Widget>[
              AppBar(
                title: const Text('Orders'),
              ),
              Expanded(
                child: OrderListScreen(selectedOrderId: selectedOrderId),
              ),
            ],
          ),
        ),
        const Gap(4),
        Expanded(child: OrderDetailsScreen(selectedOrderId: selectedOrderId)),
      ],
    );
  }
}

class OrderDetailsScreen extends ConsumerWidget {
  const OrderDetailsScreen({
    required this.selectedOrderId,
    super.key,
  });

  final ValueNotifier<int> selectedOrderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ref.watch(ordersProvider).when(
              data: (List<Order> orders) {
                return selectedOrderId.value == -1
                    ? const NoOrderSelectedNotif()
                    : OrderDetails(
                        order: orders
                            .where(
                              (Order order) =>
                                  order.id == selectedOrderId.value,
                            )
                            .first,
                      );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, StackTrace stackTrace) => const Center(
                child: Text('Error fetching orders'),
              ),
            ),
      ),
    );
  }
}

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({
    required this.selectedOrderId,
    super.key,
  });

  final ValueNotifier<int> selectedOrderId;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16),
          child: OrderList(
            selectedOrderId: selectedOrderId,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      const ModifyOrderPage(mode: ManageMode.add),
                ),
              );
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class NoOrderSelectedNotif extends StatelessWidget {
  const NoOrderSelectedNotif({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('(・・ ) ?', style: TextStyle(fontSize: 32)),
        Gap(8),
        Text(
          'No order selected, select an order first to see the details.',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}

class OrderList extends HookConsumerWidget {
  const OrderList({required this.selectedOrderId, super.key});
  final ValueNotifier<Id> selectedOrderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      onRefresh: () async {
        ref.refresh(ordersProvider);
        selectedOrderId.value = -1;
      },
      child: ref.watch(ordersProvider).when(
            data: (List<Order> orders) {
              return orders.isNotEmpty
                  ? ListView(
                      children: orders
                          .map(
                            (Order order) => Material(
                              child: InkWell(
                                onTap: () {
                                  selectedOrderId.value = order.id;
                                },
                                child: OrderTile(
                                  order: order,
                                  isSelected: order.id == selectedOrderId.value,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    )
                  : const Center(child: NoOrderAvailableNotif());
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object error, StackTrace stackTrace) => const Center(
              child: Text('Error fetching orders'),
            ),
          ),
    );
  }
}

class NoOrderAvailableNotif extends StatelessWidget {
  const NoOrderAvailableNotif({super.key});

  @override
  Widget build(BuildContext context) {
    return const Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('(　’ω’)旦~~', style: TextStyle(fontSize: 32)),
          Gap(8),
          Text(
            'No order available, go grab a coffee and relax...',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            'Or... Add an order by clicking the + button below.',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class OrderTile extends HookConsumerWidget {
  const OrderTile({required this.order, required this.isSelected, super.key});
  final Order order;
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 160,
      child: Card(
        color:
            isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (order.isDineIn)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Table',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      order.tableNumber.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              else
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Take',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'away',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              const Gap(16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Total $currency ${order.totalPrice}',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.start,
                  ),
                  const Gap(4),
                  Expanded(
                    child: SizedBox(
                      width: 22.w,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: order.items.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Text(
                            '${order.items[index].name} (x${order.items[index].quantity})',
                            style: const TextStyle(fontSize: 16),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => ModifyOrderPage(
                        mode: ManageMode.edit,
                        currentOrder: order,
                      ),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  elevation: 3,
                  backgroundColor:
                      Theme.of(context).colorScheme.tertiaryContainer,
                  foregroundColor:
                      Theme.of(context).colorScheme.onTertiaryContainer,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Icon(Icons.payments_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderDetails extends HookConsumerWidget {
  const OrderDetails({required this.order, super.key});
  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Text('Order Details', style: TextStyle(fontSize: 28)),
        const Gap(8),
        InfoCard(order: order),
        const Gap(8),
        Expanded(
          child: ListView.builder(
            itemCount: order.items.length,
            itemBuilder: (BuildContext context, int index) {
              return SizedBox(
                height: 80,
                child: ListTile(
                  title: Text(
                    '${order.items[index].name} (x${order.items[index].quantity})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '@ $currency ${order.items[index].price ~/ order.items[index].quantity}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: Text(
                    '$currency ${order.items[index].price}',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              );
            },
          ),
        ),
        const Gap(4),
        const Divider(),
        const Gap(4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Total: $currency ${order.totalPrice}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({required this.order, super.key});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TitledWidget(
                  title: 'Customer Name',
                  child: Text(
                    order.name ?? 'Unknown',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const Gap(12),
                TitledWidget(
                  title: 'Type',
                  child: Text(
                    order.isDineIn ? 'Dining in' : 'Take away',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            const Gap(32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TitledWidget(
                  title: 'Table Number',
                  child: Text(
                    order.tableNumber != null
                        ? order.tableNumber.toString().padLeft(2, '0')
                        : 'Unknown',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const Gap(12),
                TitledWidget(
                  title: 'Ordered At',
                  child: Text(
                    "${order.orderedAt?.day.toString().padLeft(2, "0")}-${order.orderedAt?.month.toString().padLeft(2, "0")}-${order.orderedAt?.year} @ ${order.orderedAt?.hour.toString().padLeft(2, "0")}:${order.orderedAt?.minute.toString().padLeft(2, "0")}",
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
