import '../../domain/entities/meal.dart';

class MealModel extends Meal {
  const MealModel({
    required super.id,
    required super.name,
    required super.calories,
    required super.createdAt,
  });

  factory MealModel.fromEntity(Meal entity) {
    return MealModel(
      id: entity.id,
      name: entity.name,
      calories: entity.calories,
      createdAt: entity.createdAt,
    );
  }

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'] as String,
      name: json['name'] as String,
      calories: json['calories'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Meal toEntity() {
    return Meal(
      id: id,
      name: name,
      calories: calories,
      createdAt: createdAt,
    );
  }
}
