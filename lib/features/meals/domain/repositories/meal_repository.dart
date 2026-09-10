import '../entities/meal.dart';

abstract class MealRepository {
  Future<List<Meal>> getMealsByDate(DateTime date);
  Future<void> addMeal(Meal meal);
  Future<void> updateMeal(Meal meal);
  Future<void> deleteMeal(String mealId);
}
