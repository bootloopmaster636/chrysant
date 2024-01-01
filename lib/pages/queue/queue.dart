import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../components/work_in_progress.dart';

class QueuePage extends HookConsumerWidget {
  const QueuePage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                title: const Text("Manage Queue"),
              ),
              Expanded(
                child: Card(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const Center(
                        child: WIP(),
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
        const Expanded(
          child: Card(
            child: Center(
              child: WIP(),
            ),
          ),
        ),
      ],
    );
  }
}
