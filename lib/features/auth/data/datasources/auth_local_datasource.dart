import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_session_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUserSession(UserSessionModel sessionModel);
  Future<UserSessionModel?> getUserSession();
  Future<void> clearUserSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String authBoxName = 'mamba_auth_box';
  static const String userSessionKey = 'current_user_session';

  final Box authBox;

  AuthLocalDataSourceImpl({required this.authBox});

  @override
  Future<void> saveUserSession(UserSessionModel sessionModel) async {
    await authBox.put(userSessionKey, sessionModel.toJson());
  }

  @override
  Future<UserSessionModel?> getUserSession() async {
    final rawData = authBox.get(userSessionKey);
    if (rawData == null) return null;
    final jsonMap = Map<String, dynamic>.from(rawData as Map);
    return UserSessionModel.fromJson(jsonMap);
  }

  @override
  Future<void> clearUserSession() async {
    await authBox.delete(userSessionKey);
  }
}
