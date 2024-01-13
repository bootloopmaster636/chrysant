import 'package:chrysant/logic/analytic/analytic.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MenuPopularityWidget extends HookConsumerWidget {
  const MenuPopularityWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Future<List<(String, int)>> count = getMenuPopularity(
      DateTime.now().subtract(const Duration(days: 90)),
      DateTime.now(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Menu popularity',
          style: TextStyle(fontSize: 16),
        ),
        const Gap(16),
        FutureBuilder(
          future: count,
          builder: (
            BuildContext context,
            AsyncSnapshot<List<(String, int)>> snapshot,
          ) {
            if (snapshot.hasData) {
              return Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    barGroups: snapshot.data?.map(((String, int) element) {
                      return BarChartGroupData(
                        x: snapshot.data!.indexOf((element.$1, element.$2)),
                        barRods: <BarChartRodData>[
                          BarChartRodData(
                            toY: element.$2.toDouble(),
                            width: 20,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ],
                      );
                    }).toList(),
                    minY: 0,
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              snapshot.data?[value.toInt()].$1 ?? '',
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ],
    );
  }
}
