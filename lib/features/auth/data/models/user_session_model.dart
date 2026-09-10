import '../../domain/entities/user_session.dart';

class UserSessionModel extends UserSession {
  const UserSessionModel({
    required super.id,
    required super.email,
    required super.name,
    required super.token,
  });

  factory UserSessionModel.fromEntity(UserSession entity) {
    return UserSessionModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      token: entity.token,
    );
  }

  factory UserSessionModel.fromJson(Map<String, dynamic> json) {
    return UserSessionModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'token': token,
    };
  }

  UserSession toEntity() {
    return UserSession(
      id: id,
      email: email,
      name: name,
      token: token,
    );
  }
}
