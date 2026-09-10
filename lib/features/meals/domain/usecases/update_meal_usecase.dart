import '../../../../core/usecases/usecase.dart';
import '../entities/meal.dart';
import '../repositories/meal_repository.dart';

class UpdateMealUseCase implements UseCase<void, Meal> {
  final MealRepository repository;

  UpdateMealUseCase(this.repository);

  @override
  Future<void> call(Meal meal) async {
    return await repository.updateMeal(meal);
  }
}
