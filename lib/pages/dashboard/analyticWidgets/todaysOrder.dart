import 'package:chrysant/logic/manage/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class TodaysOrderCounter extends ConsumerWidget {
  const TodaysOrderCounter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Future<int> noOfOrders =
        ArchiveUtils.countArchivesOnDate(DateTime.now());
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          "Today you've served...",
          style: TextStyle(fontSize: 16),
        ),
        FutureBuilder<int>(
          future: noOfOrders,
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            if (snapshot.hasData) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Text(
                    snapshot.data.toString(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(4),
                  const Text(
                    'orders',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
        const Gap(4),
        FutureBuilder<int>(
          future: noOfOrders,
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            if (snapshot.hasData) {
              return Text(
                getMotivationalMessage(snapshot.data ?? 0),
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ],
    );
  }

  String getMotivationalMessage(int noOfOrders) {
    if (noOfOrders == 0) {
      return "Don't worry, things will get better soon";
    } else if (noOfOrders < 10) {
      return 'Never give up!';
    } else if (noOfOrders < 30) {
      return "That's impressive!";
    } else {
      return 'Looking pretty good!';
    }
  }
}
