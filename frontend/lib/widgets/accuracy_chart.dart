// lib/widgets/accuracy_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AccuracyChart extends StatelessWidget {
  /// x축: 타임스탬프, y축: 정확도(0.0~1.0)
  final List<FlSpot> spots;

  const AccuracyChart({super.key, required this.spots});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 0.2,
              getTitlesWidget: (value, ctx) => Text('${(value*100).toInt()}%'),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (spots.length>1) ? (spots.last.x - spots.first.x)/4 : 1,
              getTitlesWidget: (value, ctx) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Text('${date.month}/${date.day}');
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}