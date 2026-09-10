import '../../../../core/usecases/usecase.dart';
import '../entities/meal.dart';
import '../repositories/meal_repository.dart';

class AddMealUseCase implements UseCase<void, Meal> {
  final MealRepository repository;

  AddMealUseCase(this.repository);

  @override
  Future<void> call(Meal meal) async {
    return await repository.addMeal(meal);
  }
}
