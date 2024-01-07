import 'package:chrysant/constants.dart';
import 'package:chrysant/pages/analytic/analytics.dart';
import 'package:chrysant/pages/home/home.dart';
import 'package:chrysant/pages/menu/menu.dart';
import 'package:chrysant/pages/orders/orders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const List<Widget> contentMain = <Widget>[
  HomePage(),
  OrdersPage(),
  MenuPage(),
  AnalyticPage(),
];

class AppLayout extends HookWidget {
  const AppLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<int> selectedIndex = useState(1);
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxWidth < tabletWidth) {
        return MobileAppLayout(
          selectedIndex: selectedIndex,
        );
      } else {
        return TabletAppLayout(
          selectedIndex: selectedIndex,
        );
      }
    },);
  }
}

class MobileAppLayout extends HookConsumerWidget {
  const MobileAppLayout({required this.selectedIndex, super.key});
  final ValueNotifier<int> selectedIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: contentMain[selectedIndex.value],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        onDestinationSelected: (int index) {
          selectedIndex.value = index;
        },
        selectedIndex: selectedIndex.value,
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.library_books_outlined), label: 'Orders',),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Menu'),
          NavigationDestination(
              icon: Icon(Icons.show_chart), label: 'Analytics',),
        ],
      ),
    );
  }
}

class TabletAppLayout extends HookConsumerWidget {
  const TabletAppLayout({required this.selectedIndex, super.key});
  final ValueNotifier<int> selectedIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<bool> navExpanded = useState(false);

    return SafeArea(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).colorScheme.background,
        child: Row(
          children: <Widget>[
            //nav
            Nav(navExpanded: navExpanded, selectedIndex: selectedIndex),

            //content main
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
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
    required this.navExpanded, required this.selectedIndex, super.key,
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
      destinations: const <NavigationRailDestination>[
        NavigationRailDestination(
            icon: Icon(Icons.home_outlined), label: Text('Home'),),
        NavigationRailDestination(
            icon: Icon(Icons.library_books_outlined), label: Text('Orders'),),
        NavigationRailDestination(
            icon: Icon(Icons.menu_book), label: Text('Menu'),),
        NavigationRailDestination(
            icon: Icon(Icons.show_chart), label: Text('Analytics'),),
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
