import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class TitledWidget extends StatelessWidget {
  const TitledWidget({required this.title, required this.child, super.key});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title),
        const Gap(4),
        child,
      ],
    );
  }
}
