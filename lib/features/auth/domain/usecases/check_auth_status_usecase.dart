import '../../../../core/usecases/usecase.dart';
import '../entities/user_session.dart';
import '../repositories/auth_repository.dart';

class CheckAuthStatusUseCase implements UseCase<UserSession?, NoParams> {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  @override
  Future<UserSession?> call(NoParams params) async {
    return await repository.checkAuthStatus();
  }
}
