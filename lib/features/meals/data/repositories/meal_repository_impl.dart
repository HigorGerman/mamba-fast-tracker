import '../../domain/entities/meal.dart';
import '../../domain/repositories/meal_repository.dart';
import '../datasources/meal_local_datasource.dart';
import '../models/meal_model.dart';

class MealRepositoryImpl implements MealRepository {
  final MealLocalDataSource localDataSource;

  MealRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Meal>> getMealsByDate(DateTime date) async {
    final models = await localDataSource.getMealsByDate(date);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addMeal(Meal meal) async {
    final model = MealModel.fromEntity(meal);
    await localDataSource.addMeal(model);
  }

  @override
  Future<void> updateMeal(Meal meal) async {
    final model = MealModel.fromEntity(meal);
    await localDataSource.updateMeal(model);
  }

  @override
  Future<void> deleteMeal(String mealId) async {
    await localDataSource.deleteMeal(mealId);
  }
}
