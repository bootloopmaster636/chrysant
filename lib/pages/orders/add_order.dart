import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';

class ModifyOrderPage extends StatelessWidget {
  final Id? id;
  const ModifyOrderPage({super.key, this.id});

  @override
  Widget build(BuildContext context) {
    return const TabletLayout();
  }
}

class TabletLayout extends HookConsumerWidget {
  const TabletLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Order'),
      ),
    );
  }
}
