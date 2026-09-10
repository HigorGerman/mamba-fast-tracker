import 'package:equatable/equatable.dart';

class DailyMetric extends Equatable {
  final DateTime date;
  final String dayLabel; // e.g. 'Mon', 'Tue'
  final double fastingHours;
  final int totalCalories;
  final int completedFastsCount;

  const DailyMetric({
    required this.date,
    required this.dayLabel,
    required this.fastingHours,
    required this.totalCalories,
    required this.completedFastsCount,
  });

  @override
  List<Object?> get props => [
        date,
        dayLabel,
        fastingHours,
        totalCalories,
        completedFastsCount,
      ];
}

class WeeklySummary extends Equatable {
  final List<DailyMetric> dailyMetrics;
  final double avgFastingHours;
  final int totalCaloriesWeek;
  final double completionRate;

  const WeeklySummary({
    required this.dailyMetrics,
    required this.avgFastingHours,
    required this.totalCaloriesWeek,
    required this.completionRate,
  });

  @override
  List<Object?> get props => [
        dailyMetrics,
        avgFastingHours,
        totalCaloriesWeek,
        completionRate,
      ];
}
