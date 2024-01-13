import 'package:chrysant/constants.dart';
import 'package:chrysant/logic/manage/settings.dart';
import 'package:chrysant/pages/dashboard/analyticWidgets/menuPopularity.dart';
import 'package:chrysant/pages/dashboard/analyticWidgets/todaysOrder.dart';
import 'package:chrysant/pages/dashboard/settings.dart';
import 'package:chrysant/pages/utils/greeter.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DashboardPage extends HookConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${timeGreeter()}, ${ref.read(settingsManagerProvider).value?.name ?? 'User'}!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              greeter(),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const SettingsPage(),
                  ),
                );
              },
              icon: const Icon(Icons.settings_outlined),
            ),
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: <Widget>[
              SmallWidgetContainer(child: TodaysOrderCounter()),
              WideWidgetContainer(child: MenuPopularityWidget()),
            ],
          ),
        ),
      ),
    );
  }
}

class SmallWidgetContainer extends StatelessWidget {
  const SmallWidgetContainer({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth < tabletWidth) {
            return FractionallySizedBox(
              widthFactor: 1,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: child,
                ),
              ),
            );
          } else if (constraints.maxWidth > tabletWidth &&
              constraints.maxWidth < extendedWidth) {
            return FractionallySizedBox(
              widthFactor: 0.5,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: child,
                ),
              ),
            );
          } else {
            return FractionallySizedBox(
              widthFactor: 0.333,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: child,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class WideWidgetContainer extends StatelessWidget {
  const WideWidgetContainer({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
