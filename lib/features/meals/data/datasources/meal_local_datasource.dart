import 'package:hive_flutter/hive_flutter.dart';
import '../models/meal_model.dart';

abstract class MealLocalDataSource {
  Future<List<MealModel>> getMealsByDate(DateTime date);
  Future<void> addMeal(MealModel mealModel);
  Future<void> updateMeal(MealModel mealModel);
  Future<void> deleteMeal(String mealId);
}

class MealLocalDataSourceImpl implements MealLocalDataSource {
  static const String mealsBoxName = 'mamba_meals_box';

  final Box mealsBox;

  MealLocalDataSourceImpl({required this.mealsBox});

  @override
  Future<List<MealModel>> getMealsByDate(DateTime date) async {
    final meals = <MealModel>[];
    final localTargetDate = date.toLocal();

    for (var key in mealsBox.keys) {
      final rawData = mealsBox.get(key);
      if (rawData != null) {
        final jsonMap = Map<String, dynamic>.from(rawData as Map);
        final model = MealModel.fromJson(jsonMap);
        final modelLocalDate = model.createdAt.toLocal();

        if (modelLocalDate.year == localTargetDate.year &&
            modelLocalDate.month == localTargetDate.month &&
            modelLocalDate.day == localTargetDate.day) {
          meals.add(model);
        }
      }
    }

    // Sort descending by time
    meals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return meals;
  }

  @override
  Future<void> addMeal(MealModel mealModel) async {
    await mealsBox.put(mealModel.id, mealModel.toJson());
  }

  @override
  Future<void> updateMeal(MealModel mealModel) async {
    await mealsBox.put(mealModel.id, mealModel.toJson());
  }

  @override
  Future<void> deleteMeal(String mealId) async {
    await mealsBox.delete(mealId);
  }
}
