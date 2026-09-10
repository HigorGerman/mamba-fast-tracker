import 'package:equatable/equatable.dart';
import 'fasting_protocol.dart';
import 'fasting_status.dart';

class FastingSessionEntity extends Equatable {
  final String id;
  final DateTime startTime; // Persisted UTC timestamp
  final Duration targetDuration; // Target fasting duration
  final FastingProtocolType protocol;
  final FastingStatus status;
  final DateTime? endTime; // Completed/cancelled actual end timestamp UTC

  const FastingSessionEntity({
    required this.id,
    required this.startTime,
    required this.targetDuration,
    required this.protocol,
    required this.status,
    this.endTime,
  });

  /// Calculates the exact elapsed duration using standard UTC time comparison.
  Duration getElapsedDuration([DateTime? currentTime]) {
    final now = (currentTime ?? DateTime.now()).toUtc();
    if (status == FastingStatus.completed || status == FastingStatus.cancelled) {
      if (endTime != null) {
        return endTime!.difference(startTime);
      }
    }
    final diff = now.difference(startTime);
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Calculates exact remaining duration to reach target duration.
  Duration getRemainingDuration([DateTime? currentTime]) {
    final elapsed = getElapsedDuration(currentTime);
    final remaining = targetDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Expected target completion date/time in local time.
  DateTime get targetEndTime => startTime.add(targetDuration).toLocal();

  /// Calculates real-time progress ratio between 0.0 and 1.0.
  double getProgress([DateTime? currentTime]) {
    if (targetDuration.inSeconds == 0) return 0.0;
    final elapsedSeconds = getElapsedDuration(currentTime).inSeconds;
    final targetSeconds = targetDuration.inSeconds;
    final progress = elapsedSeconds / targetSeconds;
    return progress > 1.0 ? 1.0 : progress;
  }

  /// Indicates if the current target duration has been reached or exceeded.
  bool isGoalReached([DateTime? currentTime]) {
    return getElapsedDuration(currentTime) >= targetDuration;
  }

  FastingSessionEntity copyWith({
    String? id,
    DateTime? startTime,
    Duration? targetDuration,
    FastingProtocolType? protocol,
    FastingStatus? status,
    DateTime? endTime,
  }) {
    return FastingSessionEntity(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      targetDuration: targetDuration ?? this.targetDuration,
      protocol: protocol ?? this.protocol,
      status: status ?? this.status,
      endTime: endTime ?? this.endTime,
    );
  }

  @override
  List<Object?> get props => [
        id,
        startTime,
        targetDuration,
        protocol,
        status,
        endTime,
      ];
}
