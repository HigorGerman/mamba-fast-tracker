import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/ticker.dart';
import '../../domain/entities/fasting_protocol.dart';
import '../../domain/entities/fasting_session.dart';
import '../../domain/entities/fasting_status.dart';
import '../../domain/usecases/get_active_session_usecase.dart';
import '../../domain/usecases/get_fasting_history_usecase.dart';
import '../../domain/usecases/start_fasting_usecase.dart';
import '../../domain/usecases/stop_fasting_usecase.dart';
import 'fasting_state.dart';

class FastingCubit extends Cubit<FastingState> {
  final StartFastingUseCase startFastingUseCase;
  final StopFastingUseCase stopFastingUseCase;
  final GetActiveSessionUseCase getActiveSessionUseCase;
  final GetFastingHistoryUseCase getFastingHistoryUseCase;
  final NotificationService notificationService;
  final Ticker ticker;

  StreamSubscription<int>? _tickerSubscription;

  FastingCubit({
    required this.startFastingUseCase,
    required this.stopFastingUseCase,
    required this.getActiveSessionUseCase,
    required this.getFastingHistoryUseCase,
    required this.notificationService,
    this.ticker = const Ticker(),
  }) : super(const FastingInitial());

  /// Automatically restores state from persisted local storage on app start
  Future<void> init() async {
    emit(FastingLoading(
      selectedProtocol: state.selectedProtocol,
      customDuration: state.customDuration,
      history: state.history,
    ));
    try {
      await notificationService.requestPermissions();
      final history = await getFastingHistoryUseCase(NoParams());
      final activeSession = await getActiveSessionUseCase(NoParams());

      if (activeSession != null && activeSession.status == FastingStatus.fasting) {
        _startTicker(activeSession, history);
      } else {
        emit(FastingIdle(
          selectedProtocol: state.selectedProtocol,
          customDuration: state.customDuration,
          history: history,
        ));
      }
    } catch (e) {
      emit(FastingError(
        message: 'Failed to restore fasting state: ${e.toString()}',
        selectedProtocol: state.selectedProtocol,
        customDuration: state.customDuration,
        history: state.history,
      ));
    }
  }

  /// Change selected protocol or custom duration when idle
  void selectProtocol(FastingProtocolType protocol, {Duration? customDuration}) {
    if (state is FastingIdle || state is FastingInitial) {
      emit(FastingIdle(
        selectedProtocol: protocol,
        customDuration: customDuration ?? state.customDuration,
        history: state.history,
      ));
    }
  }

  /// Start a new fasting session persisted with UTC timestamp and local notifications
  Future<void> startFasting({Duration? customDuration}) async {
    final effectiveCustomDuration = customDuration ?? state.customDuration;

    emit(FastingLoading(
      selectedProtocol: state.selectedProtocol,
      customDuration: effectiveCustomDuration,
      history: state.history,
    ));
    try {
      final session = await startFastingUseCase(
        StartFastingParams(
          protocol: state.selectedProtocol,
          customDuration: effectiveCustomDuration,
        ),
      );

      // Trigger & Schedule Local Notifications
      await notificationService.showFastStartedNotification(
        protocolTitle: session.protocol.title,
        targetDuration: session.targetDuration,
      );
      await notificationService.scheduleFastCompletedNotification(
        protocolTitle: session.protocol.title,
        targetEndTime: session.targetEndTime,
      );

      _startTicker(session, state.history);
    } catch (e) {
      emit(FastingError(
        message: 'Failed to start fasting session: ${e.toString()}',
        selectedProtocol: state.selectedProtocol,
        customDuration: effectiveCustomDuration,
        history: state.history,
      ));
    }
  }

  /// Stop or finish the active session and save to history
  Future<void> stopFasting({bool isCancelled = false}) async {
    final currentState = state;
    if (currentState is! FastingActiveState) return;

    // Immediately stop ticker subscription
    _tickerSubscription?.cancel();
    _tickerSubscription = null;

    // Clear pending scheduled notifications
    await notificationService.cancelAllNotifications();

    emit(FastingLoading(
      selectedProtocol: currentState.selectedProtocol,
      customDuration: currentState.customDuration,
      history: currentState.history,
    ));
    try {
      final finishedSession = await stopFastingUseCase(
        StopFastingParams(
          activeSession: currentState.session,
          isCancelled: isCancelled,
        ),
      );

      final updatedHistory = await getFastingHistoryUseCase(NoParams());

      if (!isCancelled && finishedSession.status == FastingStatus.completed) {
        emit(FastingCompletedState(
          session: finishedSession,
          selectedProtocol: currentState.selectedProtocol,
          customDuration: currentState.customDuration,
          history: updatedHistory,
        ));
      } else {
        emit(FastingIdle(
          selectedProtocol: currentState.selectedProtocol,
          customDuration: currentState.customDuration,
          history: updatedHistory,
        ));
      }
    } catch (e) {
      emit(FastingError(
        message: 'Failed to end fasting session: ${e.toString()}',
        selectedProtocol: currentState.selectedProtocol,
        customDuration: currentState.customDuration,
        history: currentState.history,
      ));
    }
  }

  /// Cancel active fasting session
  Future<void> cancelFasting() async {
    await stopFasting(isCancelled: true);
  }

  /// Subscribes ticker stream to re-calculate timestamp difference every tick
  void _startTicker(FastingSessionEntity session, List<FastingSessionEntity> history) {
    _tickerSubscription?.cancel();

    // Perform immediate first calculation
    _updateActiveState(session, history);

    _tickerSubscription = ticker.tick().listen((_) {
      _updateActiveState(session, history);
    });
  }

  /// Calculates elapsed/remaining duration strictly from DateTime.now() difference
  void _updateActiveState(FastingSessionEntity session, List<FastingSessionEntity> history) {
    final now = DateTime.now().toUtc();
    final elapsed = session.getElapsedDuration(now);
    final remaining = session.getRemainingDuration(now);
    final progress = session.getProgress(now);
    final isGoalReached = session.isGoalReached(now);

    emit(FastingActiveState(
      session: session,
      elapsed: elapsed,
      remaining: remaining,
      progress: progress,
      isGoalReached: isGoalReached,
      selectedProtocol: session.protocol,
      customDuration: session.targetDuration,
      history: history,
    ));
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }
}
