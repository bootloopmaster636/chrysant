import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../components/workInProgress.dart';

class AnalyticPage extends HookConsumerWidget {
  const AnalyticPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
      child: WIP(),
    );
  }
}
