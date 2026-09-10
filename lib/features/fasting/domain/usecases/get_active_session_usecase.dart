import '../../../../core/usecases/usecase.dart';
import '../entities/fasting_session.dart';
import '../repositories/fasting_repository.dart';

class GetActiveSessionUseCase implements UseCase<FastingSessionEntity?, NoParams> {
  final FastingRepository repository;

  GetActiveSessionUseCase(this.repository);

  @override
  Future<FastingSessionEntity?> call(NoParams params) async {
    return await repository.getActiveSession();
  }
}
