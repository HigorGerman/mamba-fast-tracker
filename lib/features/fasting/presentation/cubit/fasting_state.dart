import 'package:equatable/equatable.dart';
import '../../domain/entities/fasting_protocol.dart';
import '../../domain/entities/fasting_session.dart';

abstract class FastingState extends Equatable {
  final FastingProtocolType selectedProtocol;
  final Duration customDuration;
  final List<FastingSessionEntity> history;

  const FastingState({
    required this.selectedProtocol,
    this.customDuration = const Duration(hours: 16),
    this.history = const [],
  });

  Duration get targetDuration {
    if (selectedProtocol == FastingProtocolType.custom) {
      return customDuration;
    }
    return selectedProtocol.defaultDuration;
  }

  @override
  List<Object?> get props => [selectedProtocol, customDuration, history];
}

class FastingInitial extends FastingState {
  const FastingInitial({
    super.selectedProtocol = FastingProtocolType.p16_8,
    super.customDuration = const Duration(hours: 16),
    super.history,
  });
}

class FastingLoading extends FastingState {
  const FastingLoading({
    required super.selectedProtocol,
    super.customDuration,
    super.history,
  });
}

class FastingIdle extends FastingState {
  const FastingIdle({
    required super.selectedProtocol,
    super.customDuration,
    super.history,
  });
}

class FastingActiveState extends FastingState {
  final FastingSessionEntity session;
  final Duration elapsed;
  final Duration remaining;
  final double progress;
  final bool isGoalReached;

  const FastingActiveState({
    required this.session,
    required this.elapsed,
    required this.remaining,
    required this.progress,
    required this.isGoalReached,
    required super.selectedProtocol,
    super.customDuration,
    super.history,
  });

  @override
  List<Object?> get props => [
        session,
        elapsed,
        remaining,
        progress,
        isGoalReached,
        selectedProtocol,
        customDuration,
        history,
      ];
}

class FastingCompletedState extends FastingState {
  final FastingSessionEntity session;

  const FastingCompletedState({
    required this.session,
    required super.selectedProtocol,
    super.customDuration,
    super.history,
  });

  @override
  List<Object?> get props => [session, selectedProtocol, customDuration, history];
}

class FastingError extends FastingState {
  final String message;

  const FastingError({
    required this.message,
    required super.selectedProtocol,
    super.customDuration,
    super.history,
  });

  @override
  List<Object?> get props => [message, selectedProtocol, customDuration, history];
}
