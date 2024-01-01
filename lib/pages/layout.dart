import 'package:chrysant/pages/menu/menu.dart';
import 'package:chrysant/pages/orders/orders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'analytic/analytics.dart';
import 'home/home.dart';

const contentMain = <Widget>[
  HomePage(),
  OrdersPage(),
  MenuPage(),
  AnalyticPage(),
];

class AppLayout extends HookConsumerWidget {
  const AppLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = useState(1);
    final navExpanded = useState(false);

    return SafeArea(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Row(
          children: [
            //nav
            Nav(navExpanded: navExpanded, selectedIndex: selectedIndex),

            //content main
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: contentMain[selectedIndex.value],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Nav extends StatelessWidget {
  const Nav({
    super.key,
    required this.navExpanded,
    required this.selectedIndex,
  });

  final ValueNotifier<bool> navExpanded;
  final ValueNotifier<int> selectedIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: navExpanded.value,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      indicatorColor: Theme.of(context).colorScheme.inversePrimary,
      selectedIndex: selectedIndex.value,
      onDestinationSelected: (int index) {
        selectedIndex.value = index;
      },
      labelType: navExpanded.value
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.selected,
      destinations: const [
        NavigationRailDestination(
            icon: Icon(Icons.home_outlined), label: Text('Home')),
        NavigationRailDestination(
            icon: Icon(Icons.library_books_outlined), label: Text('Orders')),
        NavigationRailDestination(
            icon: Icon(Icons.menu_book), label: Text('Menu')),
        NavigationRailDestination(
            icon: Icon(Icons.show_chart), label: Text('Analytics')),
      ],
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          navExpanded.value = !navExpanded.value;
        },
      ),
    );
  }
}
