import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../components/workInProgress.dart';
import 'manageCategories.dart';

class MenuPage extends HookConsumerWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryOverlayIsVisible = useState(false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu"),
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () {
              categoryOverlayIsVisible.value = !categoryOverlayIsVisible.value;
            },
            child: const Text(
              "Manage Categories",
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Center(
            child: WIP(),
          ),
          Positioned(
            right: 0,
            child: AnimatedContainer(
              height: categoryOverlayIsVisible.value ? 60.h : 0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: const CategoryOverlay(),
            ),
          ),
        ],
      ),
    );
  }
}
