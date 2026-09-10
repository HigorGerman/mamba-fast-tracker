import 'package:equatable/equatable.dart';

class Meal extends Equatable {
  final String id;
  final String name;
  final int calories;
  final DateTime createdAt;

  const Meal({
    required this.id,
    required this.name,
    required this.calories,
    required this.createdAt,
  });

  Meal copyWith({
    String? id,
    String? name,
    int? calories,
    DateTime? createdAt,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, calories, createdAt];
}
