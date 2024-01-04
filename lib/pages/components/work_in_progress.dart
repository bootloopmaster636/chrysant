import 'package:flutter/material.dart';

class WIP extends StatelessWidget {
  const WIP({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 380,
      height: 160,
      child: Card(
        elevation: 2,
        child: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("(⌒_⌒;)", style: TextStyle(fontSize: 24)),
            Text("Work in progress, check back in a bit..."),
          ],
        )),
      ),
    );
  }
}
