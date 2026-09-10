import '../../../../core/usecases/usecase.dart';
import '../repositories/meal_repository.dart';

class DeleteMealUseCase implements UseCase<void, String> {
  final MealRepository repository;

  DeleteMealUseCase(this.repository);

  @override
  Future<void> call(String mealId) async {
    return await repository.deleteMeal(mealId);
  }
}
