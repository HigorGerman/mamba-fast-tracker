import '../entities/fasting_session.dart';

abstract class FastingRepository {
  /// Save or update an active fasting session
  Future<void> saveActiveSession(FastingSessionEntity session);

  /// Fetch active session from persistent local storage
  Future<FastingSessionEntity?> getActiveSession();

  /// Clear active session upon completion or cancellation
  Future<void> clearActiveSession();

  /// Save completed/cancelled session to historical log
  Future<void> saveToHistory(FastingSessionEntity session);

  /// Fetch all historical completed fasting sessions
  Future<List<FastingSessionEntity>> getFastingHistory();
}
