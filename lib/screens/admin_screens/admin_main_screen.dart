import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../widgets/admin_bottom_navigation_bar.dart';

class AppColors {
  static const Color primary = contentColorCyan;
  static const Color menuBackground = Color(0xFF090912);
  static const Color itemsBackground = Color(0xFF1B2339);
  static const Color pageBackground = Color(0xFF282E45);
  static const Color mainTextColor1 = Colors.white;
  static const Color mainTextColor2 = Colors.white70;
  static const Color mainTextColor3 = Colors.white38;
  static const Color mainGridLineColor = Colors.white10;
  static const Color borderColor = Colors.white54;
  static const Color gridLinesColor = Color(0x11FFFFFF);

  static const Color contentColorBlack = Colors.black;
  static const Color contentColorWhite = Colors.white;
  static const Color contentColorBlue = Color(0xFF2196F3);
  static const Color contentColorYellow = Color(0xFFFFC300);
  static const Color contentColorOrange = Color(0xFFFF683B);
  static const Color contentColorGreen = Color(0xFF3BFF49);
  static const Color contentColorPurple = Color(0xFF6E1BFF);
  static const Color contentColorPink = Color(0xFFFF3AF2);
  static const Color contentColorRed = Color(0xFFE80054);
  static const Color contentColorCyan = Color(0xFF50E4FF);
  static const Color shadowColor = Color(0xFFCCCCCC); // 그림자 색상 추가
}

class _BarData {
  const _BarData(this.color, this.value, this.shadowValue, this.label);
  final Color color;
  final double value;
  final double shadowValue;
  final String label;
}

class AdminMainScreen extends StatefulWidget {
  AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _BarChartSample7State();
}

// 바 차트 상태
class _BarChartSample7State extends State<AdminMainScreen> {
  final List<_BarData> dataList = [
    const _BarData(AppColors.contentColorYellow, 18, 17, "게시글 수"),
    const _BarData(AppColors.contentColorGreen, 17, 16, "댓글 수"),
    const _BarData(AppColors.contentColorOrange, 15, 10, "회원 수"),
    const _BarData(AppColors.contentColorPink, 5, 4, "게시글 신고 수"),
    const _BarData(AppColors.contentColorBlue, 2.5, 2, "댓글 신고 수"),
    const _BarData(AppColors.contentColorRed, 2, 1, "사용자 신고 수"),
  ];
  int touchedGroupIndex = -1;

  BarChartGroupData generateBarGroup(
      int x, Color color, double value, double shadowValue) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          color: color,
          width: 6,
        ),
        BarChartRodData(
          toY: shadowValue,
          color: AppColors.shadowColor,
          width: 6,
        ),
      ],
      showingTooltipIndicators: touchedGroupIndex == x ? [0] : [],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AspectRatio(
            aspectRatio: 1.4,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                borderData: FlBorderData(
                  show: true,
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: AppColors.borderColor.withOpacity(0.2),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 4.0), // 오른쪽 패딩 추가
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: 10), // 글씨 크기 조정
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        final label = dataList[index].label;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: dataList[index].color,
                              fontSize: 10, // 글씨 크기 조정
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.gridLinesColor,
                    strokeWidth: 1,
                  ),
                ),
                barGroups: dataList.asMap().entries.map((e) {
                  final index = e.key;
                  final data = e.value;
                  return generateBarGroup(
                    index,
                    data.color,
                    data.value,
                    data.shadowValue,
                  );
                }).toList(),
                maxY: 20,
                barTouchData: BarTouchData(
                  enabled: true,
                  handleBuiltInTouches: false,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.transparent,
                    tooltipMargin: 0,
                    getTooltipItem: (
                        BarChartGroupData group,
                        int groupIndex,
                        BarChartRodData rod,
                        int rodIndex,
                        ) {
                      return BarTooltipItem(
                        rod.toY.toString(),
                        TextStyle(
                          fontWeight: FontWeight.bold,
                          color: rod.color,
                          fontSize: 18,
                          shadows: const [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  touchCallback: (event, response) {
                    if (event.isInterestedForInteractions &&
                        response != null &&
                        response.spot != null) {
                      setState(() {
                        touchedGroupIndex = response.spot!.touchedBarGroupIndex;
                      });
                    } else {
                      setState(() {
                        touchedGroupIndex = -1;
                      });
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AdminCustomBottomNavigationBar(selectedIndex: 0), // 예시 인덱스
    );
  }
}