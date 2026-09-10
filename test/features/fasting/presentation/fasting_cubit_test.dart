import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/core/notifications/notification_service.dart';
import 'package:mamba_fast_tracker/features/fasting/data/datasources/fasting_local_datasource.dart';
import 'package:mamba_fast_tracker/features/fasting/data/models/fasting_session_model.dart';
import 'package:mamba_fast_tracker/features/fasting/data/repositories/fasting_repository_impl.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/entities/fasting_protocol.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/entities/fasting_status.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/usecases/get_active_session_usecase.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/usecases/get_fasting_history_usecase.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/usecases/start_fasting_usecase.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/usecases/stop_fasting_usecase.dart';
import 'package:mamba_fast_tracker/features/fasting/presentation/cubit/fasting_cubit.dart';
import 'package:mamba_fast_tracker/features/fasting/presentation/cubit/fasting_state.dart';

class FakeNotificationService implements NotificationService {
  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermissions() async => true;
  @override
  Future<void> showFastStartedNotification({required String protocolTitle, required Duration targetDuration}) async {}
  @override
  Future<void> scheduleFastCompletedNotification({required String protocolTitle, required DateTime targetEndTime}) async {}
  @override
  Future<void> cancelAllNotifications() async {}
}

class FakeFastingLocalDataSource implements FastingLocalDataSource {
  FastingSessionModel? activeSession;
  final List<FastingSessionModel> history = [];

  @override
  Future<void> saveActiveSession(FastingSessionModel sessionModel) async {
    activeSession = sessionModel;
  }

  @override
  Future<FastingSessionModel?> getActiveSession() async {
    return activeSession;
  }

  @override
  Future<void> clearActiveSession() async {
    activeSession = null;
  }

  @override
  Future<void> saveToHistory(FastingSessionModel sessionModel) async {
    history.insert(0, sessionModel);
  }

  @override
  Future<List<FastingSessionModel>> getFastingHistory() async {
    return history;
  }
}

void main() {
  group('FastingCubit Flow Unit Tests', () {
    late FakeFastingLocalDataSource fakeDataSource;
    late FastingRepositoryImpl repository;
    late StartFastingUseCase startUseCase;
    late StopFastingUseCase stopUseCase;
    late GetActiveSessionUseCase getActiveUseCase;
    late GetFastingHistoryUseCase getHistoryUseCase;
    late FakeNotificationService fakeNotificationService;
    late FastingCubit cubit;

    setUp(() {
      fakeDataSource = FakeFastingLocalDataSource();
      repository = FastingRepositoryImpl(localDataSource: fakeDataSource);
      startUseCase = StartFastingUseCase(repository);
      stopUseCase = StopFastingUseCase(repository);
      getActiveUseCase = GetActiveSessionUseCase(repository);
      getHistoryUseCase = GetFastingHistoryUseCase(repository);
      fakeNotificationService = FakeNotificationService();

      cubit = FastingCubit(
        startFastingUseCase: startUseCase,
        stopFastingUseCase: stopUseCase,
        getActiveSessionUseCase: getActiveUseCase,
        getFastingHistoryUseCase: getHistoryUseCase,
        notificationService: fakeNotificationService,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('selectProtocol should update selectedProtocol and customDuration in FastingState', () {
      cubit.selectProtocol(FastingProtocolType.p12_12);
      expect(cubit.state.selectedProtocol, equals(FastingProtocolType.p12_12));
      expect(cubit.state.targetDuration, equals(const Duration(hours: 12)));

      cubit.selectProtocol(FastingProtocolType.custom, customDuration: const Duration(hours: 20));
      expect(cubit.state.selectedProtocol, equals(FastingProtocolType.custom));
      expect(cubit.state.targetDuration, equals(const Duration(hours: 20)));
    });

    test('startFasting should activate session with selected custom duration', () async {
      cubit.selectProtocol(FastingProtocolType.custom, customDuration: const Duration(hours: 20));
      await cubit.startFasting();

      expect(cubit.state, isA<FastingActiveState>());
      final activeState = cubit.state as FastingActiveState;
      expect(activeState.session.targetDuration, equals(const Duration(hours: 20)));
      expect(activeState.session.status, equals(FastingStatus.fasting));
    });

    test('stopFasting early should save to history as endedEarly and clear active session', () async {
      await cubit.startFasting();
      expect(cubit.state, isA<FastingActiveState>());

      // Stop immediately after 0s (before target goal)
      await cubit.stopFasting(isCancelled: false);

      expect(fakeDataSource.activeSession, isNull);
      expect(fakeDataSource.history.length, equals(1));
      expect(fakeDataSource.history.first.status, equals(FastingStatus.endedEarly));
    });

    test('stopFasting after target goal is reached should save to history as completed', () async {
      // Create session started 17 hours ago
      final pastStart = DateTime.now().toUtc().subtract(const Duration(hours: 17));
      final sessionModel = FastingSessionModel(
        id: 'past_session',
        startTime: pastStart,
        targetDuration: const Duration(hours: 16),
        protocol: FastingProtocolType.p16_8,
        status: FastingStatus.fasting,
      );
      await fakeDataSource.saveActiveSession(sessionModel);
      await cubit.init();

      expect(cubit.state, isA<FastingActiveState>());
      final activeState = cubit.state as FastingActiveState;
      expect(activeState.isGoalReached, isTrue);

      await cubit.stopFasting(isCancelled: false);

      expect(fakeDataSource.activeSession, isNull);
      expect(fakeDataSource.history.length, equals(1));
      expect(fakeDataSource.history.first.status, equals(FastingStatus.completed));
    });

    test('cancelFasting should cancel session, save as cancelled in history and return to FastingIdle', () async {
      await cubit.startFasting();
      expect(cubit.state, isA<FastingActiveState>());

      await cubit.cancelFasting();

      expect(fakeDataSource.activeSession, isNull);
      expect(fakeDataSource.history.length, equals(1));
      expect(fakeDataSource.history.first.status, equals(FastingStatus.cancelled));
      expect(cubit.state, isA<FastingIdle>());
    });
  });
}
