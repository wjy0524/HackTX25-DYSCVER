// lib/widgets/accuracy_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';



class AccuracyChart extends StatelessWidget {
  final List<FlSpot> spots;
  const AccuracyChart({required this.spots, super.key});

  @override
  Widget build(BuildContext context) {
    final count = spots.length;
    // 최대 5개 레이블만 찍도록: (0, 간격, 2*간격, ...)
    final step = (count / 5).ceil().clamp(1, count);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: count > 1 ? count - 1 : 1,
        minY: 0,
        maxY: 100,
         // ─── ① 차트 영역 밖 데이터는 절단 ───
        clipData: FlClipData.all(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (spots.length / 5).ceil().clamp(1, spots.length).toDouble(),
              reservedSize: 24, // 공간 확보
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= spots.length) return const SizedBox();
                return Text('${idx + 1}');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 10,
              reservedSize: 40, // y축 레이블 너비
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}%');
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}