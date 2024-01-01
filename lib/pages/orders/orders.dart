import 'package:chrysant/constants.dart';
import 'package:chrysant/pages/components/titled_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../data/models/order.dart';

// TODO temp data for testing purposes only
final Order example1 = Order()
  ..id = 1
  ..name = "John Doe"
  ..tableNumber = 1
  ..isDineIn = true
  ..orderedAt = DateTime.now()
  ..totalPrice = 12
  ..items = [
    OrderMenu()
      ..name = "Chicken Chop"
      ..price = 10
      ..quantity = 1,
    OrderMenu()
      ..name = "Coke"
      ..price = 2
      ..quantity = 1
  ];
final Order example2 = Order()
  ..id = 2
  ..name = "Chto"
  ..isDineIn = false
  ..orderedAt = DateTime.now()
  ..totalPrice = 10000
  ..items = [
    OrderMenu()
      ..name = "Soto Ayam"
      ..price = 10000
      ..quantity = 1,
  ];

final List<Order> orders = [example1, example2];

class OrdersPage extends HookConsumerWidget {
  const OrdersPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedOrderId =
        useState(-1); // selectedOrderId -1 is nothing selected

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        //main screen
        SizedBox(
          width: 40.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                title: const Text("Manage Orders"),
              ),
              Expanded(
                child: Card(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: OrderList(
                          selectedOrderId: selectedOrderId,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: FloatingActionButton(
                          onPressed: () {},
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          child: const Icon(Icons.add),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        //second screen
        const Gap(4),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: selectedOrderId.value == -1
                  ? const NoOrderSelectedNotif()
                  : OrderDetails(
                      order: orders
                          .where((order) => order.id == selectedOrderId.value)
                          .first),
            ),
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
      children: [
        Text("(・・ ) ?", style: TextStyle(fontSize: 32)),
        Gap(8),
        Text("No order selected, select an order first to see the details.",
            style: TextStyle(fontSize: 16)),
      ],
    );
  }
}

class OrderList extends HookConsumerWidget {
  final ValueNotifier<Id> selectedOrderId;

  const OrderList({super.key, required this.selectedOrderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: orders
          .map(
            (order) => InkWell(
              onTap: () {
                selectedOrderId.value = order.id;
              },
              child: OrderTile(
                  order: order,
                  isSelected: order.id == selectedOrderId.value ? true : false),
            ),
          )
          .toList(),
    );
  }
}

class OrderTile extends HookConsumerWidget {
  final Order order;
  final bool isSelected;

  const OrderTile({super.key, required this.order, required this.isSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 160,
      child: Card(
        color:
            isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              order.isDineIn
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Table",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          order.tableNumber.toString().padLeft(2, "0"),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )
                      ],
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Take",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "away",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
              const Gap(16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total $currency ${order.totalPrice}",
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
                        itemBuilder: (context, index) {
                          return Text(
                            "${order.items[index].name} (x${order.items[index].quantity})",
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
                onPressed: () {},
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
  final Order order;

  const OrderDetails({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Order Details", style: TextStyle(fontSize: 28)),
        const Gap(8),
        InfoCard(order: order),
        const Gap(8),
        Expanded(
          child: ListView.builder(
            itemCount: order.items.length,
            itemBuilder: (context, index) {
              return SizedBox(
                height: 80,
                child: ListTile(
                  title: Text(
                    "${order.items[index].name} (x${order.items[index].quantity})",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "@ $currency ${order.items[index].price}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: Text(
                      "$currency ${order.items[index].quantity * order.items[index].price}",
                      style: const TextStyle(fontSize: 20)),
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
            "Total: $currency ${order.totalPrice}",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  final Order order;

  const InfoCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitledWidget(
                  title: "Customer Name",
                  child: Text(
                    order.name ?? "Unknown",
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const Gap(12),
                TitledWidget(
                  title: "Type",
                  child: Text(
                    order.isDineIn ? "Dining in" : "Take away",
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            const Gap(32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitledWidget(
                  title: "Table Number",
                  child: Text(
                    order.tableNumber != null
                        ? order.tableNumber.toString().padLeft(2, "0")
                        : "Unknown",
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const Gap(12),
                TitledWidget(
                  title: "Ordered At",
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
