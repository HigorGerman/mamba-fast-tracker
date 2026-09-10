import '../../../../core/usecases/usecase.dart';
import '../entities/meal.dart';
import '../repositories/meal_repository.dart';

class GetMealsByDateUseCase implements UseCase<List<Meal>, DateTime> {
  final MealRepository repository;

  GetMealsByDateUseCase(this.repository);

  @override
  Future<List<Meal>> call(DateTime date) async {
    return await repository.getMealsByDate(date);
  }
}
