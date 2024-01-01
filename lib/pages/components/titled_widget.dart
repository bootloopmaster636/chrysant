import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class TitledWidget extends StatelessWidget {
  final String title;
  final Widget child;
  const TitledWidget({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const Gap(4),
        child,
      ],
    );
  }
}
