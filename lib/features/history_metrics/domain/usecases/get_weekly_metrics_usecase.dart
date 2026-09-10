import '../../../../core/usecases/usecase.dart';
import '../../../fasting/domain/entities/fasting_status.dart';
import '../../../fasting/domain/repositories/fasting_repository.dart';
import '../../../meals/domain/repositories/meal_repository.dart';
import '../entities/weekly_summary.dart';

class GetWeeklyMetricsUseCase implements UseCase<WeeklySummary, NoParams> {
  final FastingRepository fastingRepository;
  final MealRepository mealRepository;

  GetWeeklyMetricsUseCase({
    required this.fastingRepository,
    required this.mealRepository,
  });

  @override
  Future<WeeklySummary> call(NoParams params) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final fastingHistory = await fastingRepository.getFastingHistory();

    final dailyMetrics = <DailyMetric>[];
    double totalFastingHoursWeek = 0;
    int totalCaloriesWeek = 0;
    int totalTargetFasts = 0;
    int completedFastsCount = 0;

    const ptDays = ['', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

    // Compile metrics for the last 7 days (index 6 down to 0)
    for (int i = 6; i >= 0; i--) {
      final targetDate = today.subtract(Duration(days: i));
      final dayLabel = ptDays[targetDate.weekday];

      // Fetch meals for target date
      final meals = await mealRepository.getMealsByDate(targetDate);
      final dayCalories = meals.fold<int>(0, (sum, m) => sum + m.calories);

      // Calculate fasting hours on this target date
      double dayFastingHours = 0;
      int dayCompletedFasts = 0;

      for (var session in fastingHistory) {
        final sessionDate = session.startTime.toLocal();
        if (sessionDate.year == targetDate.year &&
            sessionDate.month == targetDate.month &&
            sessionDate.day == targetDate.day) {
          totalTargetFasts++;
          final elapsed = session.getElapsedDuration();
          dayFastingHours += elapsed.inMinutes / 60.0;

          if (session.status == FastingStatus.completed) {
            dayCompletedFasts++;
            completedFastsCount++;
          }
        }
      }

      totalFastingHoursWeek += dayFastingHours;
      totalCaloriesWeek += dayCalories;

      dailyMetrics.add(DailyMetric(
        date: targetDate,
        dayLabel: dayLabel,
        fastingHours: double.parse(dayFastingHours.toStringAsFixed(1)),
        totalCalories: dayCalories,
        completedFastsCount: dayCompletedFasts,
      ));
    }

    final avgFastingHours = totalFastingHoursWeek / 7.0;
    final completionRate = totalTargetFasts > 0 ? (completedFastsCount / totalTargetFasts) : 1.0;

    return WeeklySummary(
      dailyMetrics: dailyMetrics,
      avgFastingHours: double.parse(avgFastingHours.toStringAsFixed(1)),
      totalCaloriesWeek: totalCaloriesWeek,
      completionRate: double.parse(completionRate.toStringAsFixed(2)),
    );
  }
}
