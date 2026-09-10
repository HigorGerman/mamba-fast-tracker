import '../../domain/entities/fasting_session.dart';
import '../../domain/repositories/fasting_repository.dart';
import '../datasources/fasting_local_datasource.dart';
import '../models/fasting_session_model.dart';

class FastingRepositoryImpl implements FastingRepository {
  final FastingLocalDataSource localDataSource;

  FastingRepositoryImpl({required this.localDataSource});

  @override
  Future<void> saveActiveSession(FastingSessionEntity session) async {
    final model = FastingSessionModel.fromEntity(session);
    await localDataSource.saveActiveSession(model);
  }

  @override
  Future<FastingSessionEntity?> getActiveSession() async {
    final model = await localDataSource.getActiveSession();
    return model?.toEntity();
  }

  @override
  Future<void> clearActiveSession() async {
    await localDataSource.clearActiveSession();
  }

  @override
  Future<void> saveToHistory(FastingSessionEntity session) async {
    final model = FastingSessionModel.fromEntity(session);
    await localDataSource.saveToHistory(model);
  }

  @override
  Future<List<FastingSessionEntity>> getFastingHistory() async {
    final models = await localDataSource.getFastingHistory();
    return models.map((m) => m.toEntity()).toList();
  }
}
