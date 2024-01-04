import 'dart:io';

import 'package:chrysant/constants.dart';
import 'package:chrysant/logic/manage/category.dart';
import 'package:chrysant/logic/manage/menu.dart';
import 'package:chrysant/logic/manage/order.dart';
import 'package:chrysant/pages/components/image_preview.dart';
import 'package:chrysant/pages/components/titled_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:text_scroll/text_scroll.dart';

import '../../data/models/menu.dart';
import '../../data/models/order.dart';

class ModifyOrderPage extends HookWidget {
  final Id? id;

  const ModifyOrderPage({super.key, this.id});

  @override
  Widget build(BuildContext context) {
    final tempOrder = useState(Order());

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletWidth) {
          return MobileLayout(
            id: id,
            order: tempOrder,
          );
        } else {
          return TabletLayout(
            id: id,
            order: tempOrder,
          );
        }
      },
    );
  }
}

class MenuSelector extends ConsumerWidget {
  final ValueNotifier<Order> order;

  const MenuSelector({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final menus = ref.watch(menusProvider);

    return categories.isLoading
        ? const Center(child: LinearProgressIndicator())
        : DefaultTabController(
            length: categories.value!.length,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                categories.when(
                  data: (category) {
                    return TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        labelPadding:
                            const EdgeInsets.symmetric(horizontal: 24),
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: category
                            .map((e) => Tab(
                                  text: e.category,
                                ))
                            .toList());
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text(e.toString())),
                ),
                Expanded(
                  child: TabBarView(
                    children: categories.value!.map((e) {
                      return menus.when(
                          data: (menus) {
                            final filteredMenu = menus
                                .where(
                                    (element) => element.category == e.category)
                                .toList();
                            return filteredMenu.length != 0
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: filteredMenu.map((thisMenu) {
                                        return MenuTile(
                                            menu: thisMenu, order: order);
                                      }).toList(),
                                    ),
                                  )
                                : const Center(
                                    child: Text("No menu on this category"));
                          },
                          error: (e, s) => Text(e.toString()),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()));
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
  }
}

class MenuTile extends HookWidget {
  final Menu menu;
  final ValueNotifier<Order> order;

  const MenuTile({super.key, required this.menu, required this.order});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      if (constraint.maxWidth < tabletWidth) {
        return FractionallySizedBox(
          widthFactor: 0.48,
          child: Container(
            height: 260,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(16),
            child: item(context),
          ),
        );
      } else {
        return Container(
          width: 200,
          height: 260,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16),
          child: item(context),
        );
      }
    });
  }

  Column item(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.secondary,
          ),
          clipBehavior: Clip.antiAlias,
          child: menu.imagePath == ""
              ? Icon(
                  Icons.no_photography_outlined,
                  color: Theme.of(context).colorScheme.onSecondary,
                )
              : GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return ImagePreview(
                          file: File(menu.imagePath),
                          menuName: menu.name,
                        );
                      },
                    ));
                  },
                  child: Hero(
                    tag: menu.name,
                    child: Image.file(File(menu.imagePath), fit: BoxFit.cover),
                  ),
                ),
        ),
        const Gap(8),
        TextScroll(
          menu.name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          delayBefore: const Duration(seconds: 2),
          pauseOnBounce: const Duration(seconds: 2),
          pauseBetween: const Duration(seconds: 2),
          mode: TextScrollMode.bouncing,
          velocity: const Velocity(pixelsPerSecond: Offset(60, 0)),
        ),
        Text(
          "$currency ${menu.price}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const Gap(16),
        const Text("Quantity"),
        const Gap(4),
        ItemQuantity(menu: menu, order: order)
      ],
    );
  }
}

class ItemQuantity extends HookConsumerWidget {
  const ItemQuantity({
    super.key,
    required this.menu,
    required this.order,
  });

  final Menu menu;
  final ValueNotifier<Order> order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemQuantity = useState(
        order.value.items.where((element) => element.name == menu.name).isEmpty
            ? 0
            : order.value.items
                .where((element) => element.name == menu.name)
                .first
                .quantity);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            padding: EdgeInsets.zero,
          ),
          onPressed: itemQuantity.value != 0
              ? () {
                  itemQuantity.value--;
                  if (itemQuantity.value > 0) {
                    final newOrderMenu = OrderMenu()
                      ..name = menu.name
                      ..quantity = itemQuantity.value
                      ..price = menu.price * itemQuantity.value;
                    var newOrderList = order.value.items;

                    // TODO refactor this AI generated code XD
                    // if this menu is not on order list
                    if (order.value.items
                        .where((element) => element.name == menu.name)
                        .isEmpty) {
                      //add this menu to order list
                      newOrderList.add(newOrderMenu);
                      final newOrder = Order()
                        ..items = newOrderList
                        ..totalPrice = order.value.totalPrice + menu.price;
                      order.value = newOrder;
                    } else {
                      //else just change the quantity value
                      final index = order.value.items
                          .indexWhere((element) => element.name == menu.name);
                      newOrderList[index].quantity = itemQuantity.value;
                      newOrderList[index].price =
                          menu.price * itemQuantity.value;
                      final newOrder = Order()
                        ..items = newOrderList
                        ..totalPrice = order.value.totalPrice - menu.price;
                      order.value = newOrder;
                    }
                  } else {
                    final newOrderList = order.value.items;
                    final index = order.value.items
                        .indexWhere((element) => element.name == menu.name);
                    newOrderList.removeAt(index);
                    final newOrder = Order()
                      ..items = newOrderList
                      ..totalPrice = order.value.totalPrice - menu.price;
                    order.value = newOrder;
                  }
                }
              : null,
          child: const Icon(Icons.remove),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            itemQuantity.value.toString(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            padding: EdgeInsets.zero,
          ),
          onPressed: itemQuantity.value < 99
              ? () {
                  if (itemQuantity.value < 99) {
                    itemQuantity.value++;
                    final newOrderMenu = OrderMenu()
                      ..name = menu.name
                      ..quantity = itemQuantity.value
                      ..price = menu.price * itemQuantity.value;
                    var newOrderList = order.value.items;

                    // if this menu is not on order list
                    if (order.value.items
                        .where((element) => element.name == menu.name)
                        .isEmpty) {
                      //add this menu to order list
                      newOrderList.add(newOrderMenu);
                      final newOrder = Order()
                        ..items = newOrderList
                        ..totalPrice = order.value.totalPrice + menu.price;
                      order.value = newOrder;
                    } else {
                      //else just change the quantity value
                      final index = order.value.items
                          .indexWhere((element) => element.name == menu.name);
                      newOrderList[index].quantity = itemQuantity.value;
                      newOrderList[index].price =
                          menu.price * itemQuantity.value;
                      final newOrder = Order()
                        ..items = newOrderList
                        ..totalPrice = order.value.totalPrice + menu.price;
                      order.value = newOrder;
                    }
                  }
                }
              : null,
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}

class OrderDetails extends HookConsumerWidget {
  final ValueNotifier<Order> order;
  final bool enableDragHandle;

  const OrderDetails(
      {super.key, required this.order, required this.enableDragHandle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerNameCtl = useTextEditingController();
    final tableNumberCtl = useTextEditingController();
    final isDiningInCtl = useState(true);
    final noteCtl = useTextEditingController();

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (enableDragHandle)
              Center(
                child: Icon(Icons.drag_handle_outlined,
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer
                        .withOpacity(0.8)),
              ),
            const Text(
              "Order Details",
              style: TextStyle(fontSize: 20),
            ),
            const Gap(8),
            InfoCard(
              order: order,
              customerNameCtl: customerNameCtl,
              tableNumberCtl: tableNumberCtl,
              isDiningInCtl: isDiningInCtl,
              noteCtl: noteCtl,
            ),
            const Gap(16),
            const Text(
              "Selected Menu",
              style: TextStyle(fontSize: 20),
            ),
            Expanded(
              child: ListView(
                children: order.value.items
                    .map((e) => OrderedMenuTile(orderMenu: e))
                    .toList(),
              ),
            ),
            FilledButton(
              onPressed: () {
                ref.read(ordersProvider.notifier).addOrder(
                      Order()
                        ..name = customerNameCtl.text
                        ..tableNumber = tableNumberCtl.text == ""
                            ? null
                            : int.parse(tableNumberCtl.text)
                        ..isDineIn = isDiningInCtl.value
                        ..note = noteCtl.text
                        ..items = order.value.items
                        ..totalPrice = order.value.totalPrice
                        ..orderedAt = DateTime.now(),
                    );
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    const Text("Add Order"),
                    const Spacer(),
                    Text("Total $currency ${order.value.totalPrice}"),
                    const Icon(Icons.chevron_right)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class OrderedMenuTile extends StatelessWidget {
  final OrderMenu orderMenu;

  const OrderedMenuTile({super.key, required this.orderMenu});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Card(
        elevation: 4,
        child: ListTile(
          title: Text("${orderMenu.name} (x${orderMenu.quantity})"),
          subtitle:
              Text("@ $currency ${orderMenu.price ~/ orderMenu.quantity}"),
          trailing: Text(
            "$currency ${orderMenu.price}",
            style: TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }
}

class InfoCard extends HookConsumerWidget {
  final ValueNotifier<Order> order;
  final TextEditingController customerNameCtl;
  final TextEditingController tableNumberCtl;
  final ValueNotifier<bool> isDiningInCtl;
  final TextEditingController noteCtl;

  const InfoCard(
      {super.key,
      required this.order,
      required this.customerNameCtl,
      required this.tableNumberCtl,
      required this.isDiningInCtl,
      required this.noteCtl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: SizedBox(
            width: double.infinity,
            child: Wrap(
              runSpacing: 8,
              spacing: 8,
              children: [
                FractionallySizedBox(
                  widthFactor: 0.48,
                  child: TitledWidget(
                    title: "Customer Name",
                    child: TextFormField(
                      controller: customerNameCtl,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.all(8),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: 0.32,
                  child: TitledWidget(
                    title: "Table Number",
                    child: TextFormField(
                      controller: tableNumberCtl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.all(8),
                        border: OutlineInputBorder(),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: 0.4,
                  child: TitledWidget(
                    title: "Order Notes",
                    child: TextFormField(
                      controller: noteCtl,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.all(8),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                TitledWidget(
                  title: "Order Type",
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio(
                        value: true,
                        groupValue: isDiningInCtl.value,
                        onChanged: (value) {
                          isDiningInCtl.value = value as bool;
                        },
                      ),
                      const Text("Dine In"),
                      const Gap(8),
                      Radio(
                        value: false,
                        groupValue: isDiningInCtl.value,
                        onChanged: (value) {
                          isDiningInCtl.value = value as bool;
                        },
                      ),
                      const Text("Take Away"),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TabletLayout extends HookConsumerWidget {
  final int? id;
  final ValueNotifier<Order> order;

  const TabletLayout({super.key, required this.id, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(id == null ? 'Add Order' : 'Modify Order'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: MenuSelector(
                order: order,
              ),
            ),
            const Gap(8),
            Expanded(
              flex: 1,
              child: OrderDetails(
                order: order,
                enableDragHandle: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MobileLayout extends HookConsumerWidget {
  final int? id;
  final ValueNotifier<Order> order;

  const MobileLayout({super.key, required this.id, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sheetCtl = useState(DraggableScrollableController());
    return Scaffold(
      appBar: AppBar(
        title: Text(id == null ? 'Add Order' : 'Modify Order'),
      ),
      // body: const MenuList(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MenuSelector(
              order: order,
            ),
          ),
          DraggableScrollableSheet(
            controller: sheetCtl.value,
            initialChildSize: 0.2,
            minChildSize: 0.2,
            maxChildSize: 0.8,
            snap: true,
            snapAnimationDuration: const Duration(milliseconds: 200),
            builder: (context, controller) {
              return SingleChildScrollView(
                clipBehavior: Clip.none,
                controller: controller,
                child: Container(
                  height: 100.h,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .inverseSurface
                            .withOpacity(0.2),
                        blurRadius: 4,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: OrderDetails(
                    order: order,
                    enableDragHandle: true,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
