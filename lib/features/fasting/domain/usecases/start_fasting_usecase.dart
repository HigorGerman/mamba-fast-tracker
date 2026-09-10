import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/fasting_protocol.dart';
import '../entities/fasting_session.dart';
import '../entities/fasting_status.dart';
import '../repositories/fasting_repository.dart';

class StartFastingParams extends Equatable {
  final FastingProtocolType protocol;
  final Duration? customDuration;

  const StartFastingParams({
    required this.protocol,
    this.customDuration,
  });

  @override
  List<Object?> get props => [protocol, customDuration];
}

class StartFastingUseCase implements UseCase<FastingSessionEntity, StartFastingParams> {
  final FastingRepository repository;

  StartFastingUseCase(this.repository);

  @override
  Future<FastingSessionEntity> call(StartFastingParams params) async {
    final nowUtc = DateTime.now().toUtc();
    final target = params.protocol == FastingProtocolType.custom && params.customDuration != null
        ? params.customDuration!
        : params.protocol.defaultDuration;

    final session = FastingSessionEntity(
      id: 'session_${nowUtc.millisecondsSinceEpoch}',
      startTime: nowUtc,
      targetDuration: target,
      protocol: params.protocol,
      status: FastingStatus.fasting,
    );

    await repository.saveActiveSession(session);
    return session;
  }
}
