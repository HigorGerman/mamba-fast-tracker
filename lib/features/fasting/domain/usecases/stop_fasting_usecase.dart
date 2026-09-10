import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/fasting_session.dart';
import '../entities/fasting_status.dart';
import '../repositories/fasting_repository.dart';

class StopFastingParams extends Equatable {
  final FastingSessionEntity activeSession;
  final bool isCancelled;

  const StopFastingParams({
    required this.activeSession,
    this.isCancelled = false,
  });

  @override
  List<Object?> get props => [activeSession, isCancelled];
}

class StopFastingUseCase implements UseCase<FastingSessionEntity, StopFastingParams> {
  final FastingRepository repository;

  StopFastingUseCase(this.repository);

  @override
  Future<FastingSessionEntity> call(StopFastingParams params) async {
    final nowUtc = DateTime.now().toUtc();
    final bool goalReached = params.activeSession.isGoalReached(nowUtc);

    final FastingStatus finalStatus;
    if (params.isCancelled) {
      finalStatus = FastingStatus.cancelled;
    } else if (goalReached) {
      finalStatus = FastingStatus.completed;
    } else {
      finalStatus = FastingStatus.endedEarly;
    }

    final finishedSession = params.activeSession.copyWith(
      status: finalStatus,
      endTime: nowUtc,
    );

    // Save to historical logs and clear current active session box
    await repository.saveToHistory(finishedSession);
    await repository.clearActiveSession();

    return finishedSession;
  }
}
