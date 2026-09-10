import 'package:equatable/equatable.dart';

class UserSession extends Equatable {
  final String id;
  final String email;
  final String name;
  final String token;

  const UserSession({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
  });

  @override
  List<Object?> get props => [id, email, name, token];
}
