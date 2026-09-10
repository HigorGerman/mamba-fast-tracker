import 'package:equatable/equatable.dart';
import '../../domain/entities/meal.dart';

abstract class MealsState extends Equatable {
  final DateTime selectedDate;
  final List<Meal> meals;
  final int totalCalories;
  final int dailyGoal;

  const MealsState({
    required this.selectedDate,
    this.meals = const [],
    this.totalCalories = 0,
    this.dailyGoal = 2000,
  });

  double get calorieProgress {
    if (dailyGoal <= 0) return 0.0;
    final progress = totalCalories / dailyGoal;
    return progress > 1.0 ? 1.0 : progress;
  }

  int get remainingCalories {
    final rem = dailyGoal - totalCalories;
    return rem < 0 ? 0 : rem;
  }

  @override
  List<Object?> get props => [selectedDate, meals, totalCalories, dailyGoal];
}

class MealsInitial extends MealsState {
  MealsInitial({DateTime? date}) : super(selectedDate: date ?? DateTime.now());
}

class MealsLoading extends MealsState {
  const MealsLoading({
    required super.selectedDate,
    super.meals,
    super.totalCalories,
    super.dailyGoal,
  });
}

class MealsLoaded extends MealsState {
  const MealsLoaded({
    required super.selectedDate,
    required super.meals,
    required super.totalCalories,
    super.dailyGoal,
  });
}

class MealsError extends MealsState {
  final String message;

  const MealsError({
    required this.message,
    required super.selectedDate,
    super.meals,
    super.totalCalories,
    super.dailyGoal,
  });

  @override
  List<Object?> get props => [message, selectedDate, meals, totalCalories, dailyGoal];
}
