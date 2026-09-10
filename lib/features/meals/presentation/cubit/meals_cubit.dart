import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/meal.dart';
import '../../domain/usecases/add_meal_usecase.dart';
import '../../domain/usecases/delete_meal_usecase.dart';
import '../../domain/usecases/get_meals_by_date_usecase.dart';
import '../../domain/usecases/update_meal_usecase.dart';
import 'meals_state.dart';

class MealsCubit extends Cubit<MealsState> {
  final GetMealsByDateUseCase getMealsByDateUseCase;
  final AddMealUseCase addMealUseCase;
  final UpdateMealUseCase updateMealUseCase;
  final DeleteMealUseCase deleteMealUseCase;

  MealsCubit({
    required this.getMealsByDateUseCase,
    required this.addMealUseCase,
    required this.updateMealUseCase,
    required this.deleteMealUseCase,
  }) : super(MealsInitial());

  /// Load meals for a specific date and compute total calories
  Future<void> loadMealsForDate(DateTime date) async {
    emit(MealsLoading(
      selectedDate: date,
      meals: state.meals,
      totalCalories: state.totalCalories,
      dailyGoal: state.dailyGoal,
    ));

    try {
      final meals = await getMealsByDateUseCase(date);
      final total = meals.fold<int>(0, (sum, meal) => sum + meal.calories);

      emit(MealsLoaded(
        selectedDate: date,
        meals: meals,
        totalCalories: total,
        dailyGoal: state.dailyGoal,
      ));
    } catch (e) {
      emit(MealsError(
        message: 'Failed to load meals: ${e.toString()}',
        selectedDate: date,
        meals: state.meals,
        totalCalories: state.totalCalories,
        dailyGoal: state.dailyGoal,
      ));
    }
  }

  /// Change selected date and load meals
  void changeDate(DateTime newDate) {
    loadMealsForDate(newDate);
  }

  /// Add a new meal and refresh daily total
  Future<void> addMeal({
    required String name,
    required int calories,
    DateTime? createdAt,
  }) async {
    final nowUtc = (createdAt ?? DateTime.now()).toUtc();
    final newMeal = Meal(
      id: 'meal_${nowUtc.millisecondsSinceEpoch}',
      name: name,
      calories: calories,
      createdAt: nowUtc,
    );

    try {
      await addMealUseCase(newMeal);
      await loadMealsForDate(state.selectedDate);
    } catch (e) {
      emit(MealsError(
        message: 'Failed to add meal: ${e.toString()}',
        selectedDate: state.selectedDate,
        meals: state.meals,
        totalCalories: state.totalCalories,
        dailyGoal: state.dailyGoal,
      ));
    }
  }

  /// Edit an existing meal and refresh daily total
  Future<void> updateMeal(Meal meal) async {
    try {
      await updateMealUseCase(meal);
      await loadMealsForDate(state.selectedDate);
    } catch (e) {
      emit(MealsError(
        message: 'Failed to update meal: ${e.toString()}',
        selectedDate: state.selectedDate,
        meals: state.meals,
        totalCalories: state.totalCalories,
        dailyGoal: state.dailyGoal,
      ));
    }
  }

  /// Delete a meal by ID and refresh daily total
  Future<void> deleteMeal(String mealId) async {
    try {
      await deleteMealUseCase(mealId);
      await loadMealsForDate(state.selectedDate);
    } catch (e) {
      emit(MealsError(
        message: 'Failed to delete meal: ${e.toString()}',
        selectedDate: state.selectedDate,
        meals: state.meals,
        totalCalories: state.totalCalories,
        dailyGoal: state.dailyGoal,
      ));
    }
  }

  /// Update user daily calorie target goal
  void updateDailyGoal(int newGoal) {
    if (newGoal <= 0) return;
    emit(MealsLoaded(
      selectedDate: state.selectedDate,
      meals: state.meals,
      totalCalories: state.totalCalories,
      dailyGoal: newGoal,
    ));
  }
}
