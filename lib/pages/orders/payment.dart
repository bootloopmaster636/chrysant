import 'package:chrysant/constants.dart';
import 'package:chrysant/pages/components/titled_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/models/order.dart';
import '../../logic/manage/order.dart';

class PaymentPage extends HookConsumerWidget {
  const PaymentPage({required this.order, super.key});
  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<int> money = useState<int>(0);
    final TextEditingController moneyInputCtl = useTextEditingController();

    useEffect(
      () {
        moneyInputCtl.text = money.value.toString();
        return null;
      },
      <Object?>[money.value],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
      ),
      body: Center(
        heightFactor: 1,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            maxWidth: 600,
          ),
          alignment: Alignment.topCenter,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text(
                        'Order ID: ${order.id}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Table Number: ${order.tableNumber}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const Gap(16),
                  SingleChildScrollView(
                    child: Column(
                      children: order.items.map((OrderMenu element) {
                        return Card(
                          elevation: 3,
                          child: ListTile(
                            title:
                                Text('${element.name} (x${element.quantity})'),
                            subtitle: Text(
                                '@ $currency ${element.price ~/ element.quantity}'),
                            trailing: Text(
                              '$currency ${element.price}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: MoneyPresets(money: money),
            ),
            const Gap(16),
            Row(
              children: <Widget>[
                Expanded(
                  child: TitledWidget(
                    title: 'Enter Money:',
                    child: TextField(
                      controller: moneyInputCtl,
                      decoration: const InputDecoration(
                        prefix: Text('$currency '),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (String value) {
                        money.value = int.parse(value);
                      },
                    ),
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: TitledWidget(
                    title: 'Change:',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        '$currency ${money.value - order.totalPrice}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(16),
            FilledButton(
              onPressed: ((money.value - order.totalPrice) >= 0)
                  ? () {
                      ref.read(ordersProvider.notifier).finishOrder(order.id);
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  : null,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Text('Finish Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MoneyPresets extends StatelessWidget {
  const MoneyPresets({required this.money, super.key});
  final ValueNotifier<int> money;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: bankNotesPreset
          .map(
            (int element) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: InputChip(
                label: Text('$currency $element'),
                onPressed: () {
                  money.value += element;
                },
              ),
            ),
          )
          .toList(),
    );
  }
}
