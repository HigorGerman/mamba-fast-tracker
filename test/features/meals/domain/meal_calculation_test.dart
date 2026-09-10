import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/features/meals/domain/entities/meal.dart';

void main() {
  group('Meal & Calorie Calculation Unit Tests', () {
    final date = DateTime.utc(2026, 9, 10, 12, 0, 0);

    final mealsList = [
      Meal(
        id: 'meal_1',
        name: 'Omelete com Espinafre',
        calories: 350,
        createdAt: date,
      ),
      Meal(
        id: 'meal_2',
        name: 'Frango Grelhado com Salada e Arroz',
        calories: 650,
        createdAt: date.add(const Duration(hours: 4)),
      ),
      Meal(
        id: 'meal_3',
        name: 'Shake de Proteína com Banana',
        calories: 400,
        createdAt: date.add(const Duration(hours: 8)),
      ),
    ];

    test('should calculate exact total cumulative calories for a daily meal list', () {
      final totalCalories = mealsList.fold<int>(0, (sum, meal) => sum + meal.calories);

      expect(totalCalories, equals(1400));
    });

    test('should calculate correct calorie goal progress ratio', () {
      const dailyGoal = 2000;
      final totalCalories = mealsList.fold<int>(0, (sum, meal) => sum + meal.calories);
      final progress = totalCalories / dailyGoal;

      expect(progress, equals(0.70));
    });

    test('should compute remaining calories to hit daily target', () {
      const dailyGoal = 2000;
      final totalCalories = mealsList.fold<int>(0, (sum, meal) => sum + meal.calories);
      final remaining = dailyGoal - totalCalories;

      expect(remaining, equals(600));
    });

    test('should clamp remaining calories to zero when daily goal is exceeded', () {
      const dailyGoal = 1200;
      final totalCalories = mealsList.fold<int>(0, (sum, meal) => sum + meal.calories); // 1400 kcal
      final remaining = dailyGoal - totalCalories;
      final clampedRemaining = remaining < 0 ? 0 : remaining;

      expect(clampedRemaining, equals(0));
    });
  });
}
