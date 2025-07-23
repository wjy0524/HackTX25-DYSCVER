import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// values: y값 리스트, colors: 막대별 색상 리스트 (values.length == colors.length)
/// height: 차트 높이
class BarChartWithColors extends StatelessWidget {
  final List<double> values;
  final List<Color> colors;
  final double height;

  const BarChartWithColors({
    Key? key,
    required this.values,
    required this.colors,
    this.height = 200,
  })  : assert(values.length == colors.length),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final count = values.length;

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final totalWidth = constraints.maxWidth;
          // 한 막대당 차지할 "세그먼트 폭"
          final segmentWidth = totalWidth / count;
          // 세그먼트의 80%만 실제 막대 폭으로 사용
          final barWidth = segmentWidth * 0.8;

          return BarChart(
            BarChartData(
              maxY: 100,
              minY: 0,
              // 막대들을 "spaceEvenly"로 배치하면
              // 양쪽 끝과 막대 사이가 모두 균등 간격이 됩니다.
              alignment: BarChartAlignment.spaceEvenly,

              // 각 그룹(=각 막대) 데이터
              barGroups: List.generate(count, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: values[i],
                      width: barWidth,
                      color: colors[i],
                      borderRadius: BorderRadius.circular(2),
                      // 검은 테두리
                      borderSide: const BorderSide(color: Colors.black, width: 2),
                    ),
                  ],
                );
              }),

              // y축 레이블만 보여주고 x축 레이블은 숨김
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 10,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}%');
                    },
                  ),
                ),
              ),

              // 격자선
              gridData: FlGridData(show: true),

              // 차트 테두리: 하단만 투명, 나머지 검은 선
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  left: BorderSide(color: Colors.black),
                  top: BorderSide(color: Colors.black),
                  right: BorderSide(color: Colors.black),
                  bottom: BorderSide(color: Colors.transparent),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
