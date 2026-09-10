import 'package:flutter_test/flutter_test.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/entities/fasting_protocol.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/entities/fasting_session.dart';
import 'package:mamba_fast_tracker/features/fasting/domain/entities/fasting_status.dart';

void main() {
  group('FastingSessionEntity Domain Unit Tests', () {
    final startTimeUtc = DateTime.utc(2026, 9, 10, 0, 0, 0); // 00:00 UTC
    const targetDuration = Duration(hours: 16); // 16:8 Protocol

    final session = FastingSessionEntity(
      id: 'test_session_1',
      startTime: startTimeUtc,
      targetDuration: targetDuration,
      protocol: FastingProtocolType.p16_8,
      status: FastingStatus.fasting,
    );

    test('should calculate correct elapsed duration from UTC timestamp difference', () {
      final currentTime = DateTime.utc(2026, 9, 10, 8, 0, 0); // 8 hours later
      final elapsed = session.getElapsedDuration(currentTime);

      expect(elapsed, equals(const Duration(hours: 8)));
    });

    test('should calculate correct remaining duration until target goal', () {
      final currentTime = DateTime.utc(2026, 9, 10, 10, 0, 0); // 10 hours later
      final remaining = session.getRemainingDuration(currentTime);

      expect(remaining, equals(const Duration(hours: 6)));
    });

    test('should compute exact progress percentage between 0.0 and 1.0', () {
      final currentTimeHalfway = DateTime.utc(2026, 9, 10, 8, 0, 0); // 8/16 hours = 50%
      final progressHalfway = session.getProgress(currentTimeHalfway);

      expect(progressHalfway, equals(0.5));

      final currentTimeFull = DateTime.utc(2026, 9, 10, 16, 0, 0); // 16/16 hours = 100%
      final progressFull = session.getProgress(currentTimeFull);

      expect(progressFull, equals(1.0));
    });

    test('should return isGoalReached true when target duration is met or exceeded', () {
      final beforeGoalTime = DateTime.utc(2026, 9, 10, 15, 59, 0);
      expect(session.isGoalReached(beforeGoalTime), isFalse);

      final exactGoalTime = DateTime.utc(2026, 9, 10, 16, 0, 0);
      expect(session.isGoalReached(exactGoalTime), isTrue);

      final exceededGoalTime = DateTime.utc(2026, 9, 10, 18, 0, 0);
      expect(session.isGoalReached(exceededGoalTime), isTrue);
    });

    test('should compute correct target end time', () {
      final expectedEndTimeLocal = startTimeUtc.add(targetDuration).toLocal();
      expect(session.targetEndTime, equals(expectedEndTimeLocal));
    });
  });
}
