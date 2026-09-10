import '../../../../core/usecases/usecase.dart';
import '../entities/fasting_session.dart';
import '../repositories/fasting_repository.dart';

class GetFastingHistoryUseCase implements UseCase<List<FastingSessionEntity>, NoParams> {
  final FastingRepository repository;

  GetFastingHistoryUseCase(this.repository);

  @override
  Future<List<FastingSessionEntity>> call(NoParams params) async {
    return await repository.getFastingHistory();
  }
}
