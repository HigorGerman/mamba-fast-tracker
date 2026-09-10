import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/mamba_theme.dart';
import '../../domain/entities/weekly_summary.dart';

class WeeklyBarChartWidget extends StatelessWidget {
  final List<DailyMetric> dailyMetrics;

  const WeeklyBarChartWidget({
    super.key,
    required this.dailyMetrics,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.6,
      child: Container(
        padding: const EdgeInsets.only(top: 20, bottom: 12, left: 16, right: 16),
        decoration: BoxDecoration(
          color: MambaTheme.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: MambaTheme.neonGold.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 24,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => MambaTheme.surface,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final metric = dailyMetrics[groupIndex];
                  return BarTooltipItem(
                    '${metric.dayLabel}\n',
                    const TextStyle(
                      color: MambaTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(
                        text: '${rod.toY.toStringAsFixed(1)} h de jejum\n',
                        style: const TextStyle(
                          color: MambaTheme.neonGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      TextSpan(
                        text: '${metric.totalCalories} kcal',
                        style: const TextStyle(
                          color: MambaTheme.neonGreen,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 6,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}h',
                      style: const TextStyle(
                        color: MambaTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < dailyMetrics.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          dailyMetrics[index].dayLabel,
                          style: const TextStyle(
                            color: MambaTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 6,
              getDrawingHorizontalLine: (value) {
                return const FlLine(
                  color: MambaTheme.surface,
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            barGroups: dailyMetrics.asMap().entries.map((entry) {
              final index = entry.key;
              final metric = entry.value;
              final hours = metric.fastingHours > 24 ? 24.0 : metric.fastingHours;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: hours > 0 ? hours : 0.5,
                    gradient: LinearGradient(
                      colors: hours >= 16
                          ? [MambaTheme.neonGreen, MambaTheme.neonCyan]
                          : [MambaTheme.neonGold, MambaTheme.neonGreen],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    width: 18,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: 24,
                      color: MambaTheme.surface,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
