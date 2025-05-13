import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class MyHeatMap extends StatelessWidget {
  final DateTime startDate;
  final Map<DateTime, int> datasets;

  const MyHeatMap({
    super.key,
    required this.startDate,
    required this.datasets,
  });

  @override
  Widget build(BuildContext context) {
    // Determine current month boundaries
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final currentMonthEnd = DateTime(now.year, now.month + 1, 0); // Last day of current month

    // Filter datasets to include only current month's dates
    final filteredDatasets = Map<DateTime, int>.fromEntries(
      datasets.entries.where(
            (entry) =>
        entry.key.isAfter(currentMonthStart.subtract(const Duration(days: 1))) &&
            entry.key.isBefore(currentMonthEnd.add(const Duration(days: 1))),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: HeatMap(
        startDate: currentMonthStart,
        endDate: currentMonthEnd,
        datasets: filteredDatasets,
        colorMode: ColorMode.color,
        defaultColor: Theme.of(context).colorScheme.secondary,
        textColor: Theme.of(context).colorScheme.onSurface,
        showColorTip: false,
        showText: true,
        scrollable: true,
        size: 30,
        margin: const EdgeInsets.all(2),
        colorsets: {
          1: Colors.green.shade200,
          2: Colors.green.shade300,
          3: Colors.green.shade400,
          4: Colors.green.shade500,
          5: Colors.green.shade600,
        },
      ),
    );
  }
}