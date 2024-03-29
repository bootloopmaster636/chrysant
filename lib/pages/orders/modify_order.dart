import 'dart:io';

import 'package:chrysant/constants.dart';
import 'package:chrysant/data/models/category.dart';
import 'package:chrysant/data/models/menu.dart';
import 'package:chrysant/data/models/order.dart';
import 'package:chrysant/logic/manage/category.dart';
import 'package:chrysant/logic/manage/menu.dart';
import 'package:chrysant/logic/manage/order.dart';
import 'package:chrysant/pages/components/image_preview.dart';
import 'package:chrysant/pages/components/titled_widget.dart';
import 'package:chrysant/pages/orders/payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:text_scroll/text_scroll.dart';

class ModifyOrderPage extends HookConsumerWidget {
  const ModifyOrderPage({required this.mode, super.key, this.currentOrder});
  final ManageMode mode;
  final Order? currentOrder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<Order> tempOrder =
        useState(mode == ManageMode.add ? Order() : currentOrder!);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < tabletWidth) {
          return MobileLayout(
            mode: mode,
            tempOrder: tempOrder,
          );
        } else {
          return TabletLayout(
            mode: mode,
            tempOrder: tempOrder,
          );
        }
      },
    );
  }
}

class MenuSelector extends ConsumerWidget {
  const MenuSelector({
    required this.tempOrder,
    required this.mode,
    super.key,
  });
  final ValueNotifier<Order> tempOrder;
  final ManageMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Category>> categories = ref.watch(categoriesProvider);
    final AsyncValue<List<Menu>> menus = ref.watch(menusProvider);

    return categories.isLoading
        ? const Center(child: LinearProgressIndicator())
        : DefaultTabController(
            length: categories.value!.length,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                categories.when(
                  data: (List<Category> category) {
                    return TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 24),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: category
                          .map(
                            (Category e) => Tab(
                              text: e.category,
                            ),
                          )
                          .toList(),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (Object e, StackTrace s) =>
                      Center(child: Text(e.toString())),
                ),
                Expanded(
                  child: TabBarView(
                    children: categories.value!.map((Category e) {
                      return menus.when(
                        data: (List<Menu> menus) {
                          final List<Menu> filteredMenu = menus
                              .where(
                                (Menu element) =>
                                    element.category == e.category,
                              )
                              .toList();
                          return filteredMenu.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: filteredMenu.map((Menu thisMenu) {
                                      return MenuTile(
                                        menu: thisMenu,
                                        tempOrder: tempOrder,
                                        mode: mode,
                                      );
                                    }).toList(),
                                  ),
                                )
                              : const Center(
                                  child: Text('No menu on this category'),
                                );
                        },
                        error: (Object e, StackTrace s) => Text(e.toString()),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
  }
}

class MenuTile extends HookWidget {
  const MenuTile({
    required this.menu,
    required this.tempOrder,
    required this.mode,
    super.key,
  });
  final Menu menu;
  final ValueNotifier<Order> tempOrder;
  final ManageMode mode;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraint) {
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
      },
    );
  }

  Column item(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.secondary,
          ),
          clipBehavior: Clip.antiAlias,
          child: menu.imagePath == ''
              ? Icon(
                  Icons.no_photography_outlined,
                  color: Theme.of(context).colorScheme.onSecondary,
                )
              : GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return ImagePreview(
                            file: File(menu.imagePath),
                            menuName: menu.name,
                          );
                        },
                      ),
                    );
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
          '$currency ${menu.price}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const Gap(16),
        const Text('Quantity'),
        const Gap(4),
        ItemQuantity(
          menu: menu,
          tempOrder: tempOrder,
          mode: mode,
        ),
      ],
    );
  }
}

class ItemQuantity extends HookConsumerWidget {
  const ItemQuantity({
    required this.menu,
    required this.tempOrder,
    required this.mode,
    super.key,
  });

  final Menu menu;
  final ValueNotifier<Order> tempOrder;
  final ManageMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 0 when this menu is not on the list tempOrderMenu, else use the quantity from the list tempOrderMenu
    final ValueNotifier<int> itemQuantity = useState(
      tempOrder.value.items
              .where((OrderMenu element) => element.name == menu.name)
              .isEmpty
          ? 0
          : tempOrder.value.items
              .where((OrderMenu element) => element.name == menu.name)
              .first
              .quantity,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            padding: EdgeInsets.zero,
          ),
          onPressed: itemQuantity.value != 0
              ? () {
                  itemQuantity.value--;

                  if (itemQuantity.value == 0) {
                    if (mode == ManageMode.add) {
                      tempOrder.value.items.removeWhere(
                        (OrderMenu element) => element.name == menu.name,
                      );
                    } else {
                      final List<OrderMenu> newList = <OrderMenu>[];
                      newList.addAll(tempOrder.value.items);
                      newList.removeWhere(
                        (OrderMenu element) => element.name == menu.name,
                      );
                      tempOrder.value.items = newList;
                    }
                    tempOrder.notifyListeners();
                    tempOrder.value.totalPrice -= menu.price;
                  } else {
                    OrderMenu editItem = tempOrder.value.items
                        .where((OrderMenu element) => element.name == menu.name)
                        .first;
                    editItem
                      ..quantity = itemQuantity.value
                      ..price = menu.price * itemQuantity.value;
                    tempOrder.value.totalPrice -= menu.price;
                  }
                  tempOrder.notifyListeners();
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
                  itemQuantity.value++;
                  if (itemQuantity.value == 1) {
                    if (mode == ManageMode.add) {
                      tempOrder.value.items.add(
                        OrderMenu()
                          ..name = menu.name
                          ..price = menu.price * itemQuantity.value
                          ..quantity = itemQuantity.value,
                      );
                    } else {
                      final List<OrderMenu> newList = <OrderMenu>[];
                      newList.addAll(tempOrder.value.items);
                      newList.add(
                        OrderMenu()
                          ..name = menu.name
                          ..price = menu.price * itemQuantity.value
                          ..quantity = itemQuantity.value,
                      );
                      tempOrder.value.items = newList;
                    }
                    tempOrder.value.totalPrice += menu.price;
                  } else {
                    OrderMenu editOrder = tempOrder.value.items
                        .where((OrderMenu element) => element.name == menu.name)
                        .first;
                    editOrder
                      ..quantity = itemQuantity.value
                      ..price = menu.price * itemQuantity.value;
                    tempOrder.value.totalPrice += menu.price;
                  }
                  tempOrder.notifyListeners();
                }
              : null,
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}

class OrderDetails extends HookConsumerWidget {
  const OrderDetails({
    required this.tempOrder,
    required this.mode,
    super.key,
  });
  final ValueNotifier<Order> tempOrder;
  final ManageMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController customerNameCtl = useTextEditingController(
      text: mode == ManageMode.add ? '' : tempOrder.value.name,
    );
    final TextEditingController tableNumberCtl = useTextEditingController(
      text:
          mode == ManageMode.add ? '0' : tempOrder.value.tableNumber.toString(),
    );
    final ValueNotifier<bool> isDiningInCtl =
        useState(mode == ManageMode.add ? true : tempOrder.value.isDineIn);
    final TextEditingController noteCtl = useTextEditingController(
      text: mode == ManageMode.add ? '' : tempOrder.value.note,
    );

    final ValueNotifier<String> orderName = useState(customerNameCtl.text);
    final ValueNotifier<String> orderTableNumber =
        useState(tableNumberCtl.text);
    final ValueNotifier<String> orderNote = useState(noteCtl.text);

    final Order finalOrder = useValueListenable(tempOrder);

    useEffect(
      () {
        void listener() {
          orderName.value = customerNameCtl.text;
          orderTableNumber.value = tableNumberCtl.text;
          orderNote.value = noteCtl.text;
        }

        customerNameCtl.addListener(listener);
        tableNumberCtl.addListener(listener);
        noteCtl.addListener(listener);

        return () {
          customerNameCtl.removeListener(listener);
          tableNumberCtl.removeListener(listener);
          noteCtl.removeListener(listener);
        };
      },
      <Object?>[],
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            'Order Details',
            style: TextStyle(fontSize: 20),
          ),
          const Gap(8),
          InfoCard(
            customerNameCtl: customerNameCtl,
            tableNumberCtl: tableNumberCtl,
            isDiningInCtl: isDiningInCtl,
            noteCtl: noteCtl,
          ),
          const Gap(16),
          const Text(
            'Selected Menu',
            style: TextStyle(fontSize: 20),
          ),
          Expanded(
            child: finalOrder.items.isNotEmpty
                ? ListView(
                    children: finalOrder.items
                        .map((OrderMenu e) => OrderedMenuTile(orderMenu: e))
                        .toList(),
                  )
                : const Center(
                    child: Text('No menu selected'),
                  ),
          ),
          const Gap(16),
          ConfirmButton(
            name: orderName.value,
            tableNumber: orderTableNumber.value == ''
                ? 0
                : int.parse(orderTableNumber.value),
            isDineIn: isDiningInCtl.value,
            note: orderNote.value,
            tempOrder: finalOrder,
            mode: mode,
          ),
        ],
      ),
    );
  }
}

class OrderedMenuTile extends StatelessWidget {
  const OrderedMenuTile({required this.orderMenu, super.key});
  final OrderMenu orderMenu;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Card(
        elevation: 4,
        child: ListTile(
          title: Text('${orderMenu.name} (x${orderMenu.quantity})'),
          subtitle:
              Text('@ $currency ${orderMenu.price ~/ orderMenu.quantity}'),
          trailing: Text(
            '$currency ${orderMenu.price}',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }
}

class InfoCard extends HookConsumerWidget {
  const InfoCard({
    required this.customerNameCtl,
    required this.tableNumberCtl,
    required this.isDiningInCtl,
    required this.noteCtl,
    super.key,
  });
  final TextEditingController customerNameCtl;
  final TextEditingController tableNumberCtl;
  final ValueNotifier<bool> isDiningInCtl;
  final TextEditingController noteCtl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: Wrap(
          runSpacing: 8,
          spacing: 8,
          children: <Widget>[
            FractionallySizedBox(
              widthFactor: 0.48,
              child: TitledWidget(
                title: 'Customer Name',
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
                title: 'Table Number',
                child: TextFormField(
                  controller: tableNumberCtl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.all(8),
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
            ),
            FractionallySizedBox(
              widthFactor: 0.4,
              child: TitledWidget(
                title: 'Order Notes',
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
              title: 'Order Type',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Radio<bool>(
                    value: true,
                    groupValue: isDiningInCtl.value,
                    onChanged: (bool? value) {
                      isDiningInCtl.value = value!;
                    },
                  ),
                  const Text('Dine In'),
                  const Gap(8),
                  Radio<bool>(
                    value: false,
                    groupValue: isDiningInCtl.value,
                    onChanged: (bool? value) {
                      isDiningInCtl.value = value!;
                    },
                  ),
                  const Text('Take Away'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmButton extends ConsumerWidget {
  const ConfirmButton({
    required this.name,
    required this.tableNumber,
    required this.isDineIn,
    required this.note,
    required this.tempOrder,
    required this.mode,
    super.key,
  });

  final String name;
  final int tableNumber;
  final bool isDineIn;
  final String note;
  final Order tempOrder;
  final ManageMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: mode == ManageMode.add
          ? addOrder(context, ref)
          : editOrder(context, ref),
    );
  }

  Widget addOrder(BuildContext context, WidgetRef ref) {
    return FilledButton(
      onPressed: () {
        Logger().i(
          'Saving order with name: $name, table number $tableNumber, total price ${tempOrder.totalPrice}',
        );
        final Order inputOrder = Order()
          ..name = name
          ..tableNumber = tableNumber
          ..isDineIn = isDineIn
          ..note = note
          ..orderedAt = DateTime.now()
          ..totalPrice = tempOrder.totalPrice
          ..items = tempOrder.items;
        ref.read(ordersProvider.notifier).putOrder(inputOrder);
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Row(
        children: <Widget>[
          const Text('Add Order'),
          const Spacer(),
          Text('Total: $currency ${tempOrder.totalPrice}'),
          const Gap(8),
          const Icon(Icons.arrow_forward_ios_rounded),
        ],
      ),
    );
  }

  Widget editOrder(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Logger().i(
                'Editing order id: ${tempOrder.id}, with name: $name, table number $tableNumber, total price ${tempOrder.totalPrice}',
              );
              final Order inputOrder = Order()
                ..id = tempOrder.id
                ..items = tempOrder.items
                ..name = name
                ..tableNumber = tableNumber
                ..isDineIn = isDineIn
                ..note = note
                ..orderedAt = DateTime.now()
                ..totalPrice = tempOrder.totalPrice;
              ref.read(ordersProvider.notifier).putOrder(inputOrder);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Edit Order'),
          ),
        ),
        const Gap(8),
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: () {
              final Order inputOrder = Order()
                ..id = tempOrder.id
                ..items = tempOrder.items
                ..name = name
                ..tableNumber = tableNumber
                ..isDineIn = isDineIn
                ..note = note
                ..orderedAt = DateTime.now()
                ..totalPrice = tempOrder.totalPrice;
              ref.read(ordersProvider.notifier).putOrder(inputOrder);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      PaymentPage(order: inputOrder),
                ),
              );
            },
            child: SizedBox(
              child: Row(
                children: <Widget>[
                  const Text('Pay'),
                  const Spacer(),
                  Text('Total: $currency ${tempOrder.totalPrice}'),
                  const Gap(8),
                  const Icon(Icons.payments_outlined),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TabletLayout extends HookConsumerWidget {
  const TabletLayout({
    required this.mode,
    required this.tempOrder,
  });
  final ManageMode mode;
  final ValueNotifier<Order> tempOrder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mode == ManageMode.add ? 'Add Order' : 'Edit Order'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: MenuSelector(
                tempOrder: tempOrder,
                mode: mode,
              ),
            ),
            const Gap(8),
            Expanded(
              child: Card(
                child: OrderDetails(
                  mode: mode,
                  tempOrder: tempOrder,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MobileLayout extends HookConsumerWidget {
  const MobileLayout({
    required this.mode,
    required this.tempOrder,
    super.key,
  });
  final ManageMode mode;
  final ValueNotifier<Order> tempOrder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mode == ManageMode.add ? 'Add Order' : 'Edit Order'),
      ),
      // body: const MenuList(),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: MenuSelector(
          tempOrder: tempOrder,
          mode: mode,
        ),
      ),
      bottomSheet: Ink(
        height: 72,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        child: InkWell(
          onTap: () {
            showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: OrderDetails(
                    mode: mode,
                    tempOrder: tempOrder,
                  ),
                );
              },
            );
          },
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.keyboard_double_arrow_up_rounded),
                Gap(4),
                Text('ORDER DETAILS', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
