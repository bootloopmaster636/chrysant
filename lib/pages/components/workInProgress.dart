import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class WIP extends StatelessWidget {
  const WIP({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.w,
      height: 20.h,
      child: const Card(
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
