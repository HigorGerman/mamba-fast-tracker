import '../../domain/entities/user_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_session_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<UserSession> login(String email, String password) async {
    // Validate credentials
    if (!email.contains('@') || password.length < 4) {
      throw Exception('Invalid email address or password too short (min 4 characters)');
    }

    // Generate authenticated session
    final username = email.split('@').first;
    final sessionModel = UserSessionModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: username.toUpperCase(),
      token: 'jwt_token_${DateTime.now().millisecondsSinceEpoch}',
    );

    await localDataSource.saveUserSession(sessionModel);
    return sessionModel.toEntity();
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearUserSession();
  }

  @override
  Future<UserSession?> checkAuthStatus() async {
    final model = await localDataSource.getUserSession();
    return model?.toEntity();
  }
}
