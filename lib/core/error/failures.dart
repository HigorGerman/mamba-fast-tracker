import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local Storage Failure']);
}

class FastingFailure extends Failure {
  const FastingFailure([super.message = 'Fasting Operation Failure']);
}
