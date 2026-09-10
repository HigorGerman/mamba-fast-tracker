import 'package:hive_flutter/hive_flutter.dart';
import '../models/fasting_session_model.dart';

abstract class FastingLocalDataSource {
  Future<void> saveActiveSession(FastingSessionModel sessionModel);
  Future<FastingSessionModel?> getActiveSession();
  Future<void> clearActiveSession();
  Future<void> saveToHistory(FastingSessionModel sessionModel);
  Future<List<FastingSessionModel>> getFastingHistory();
}

class FastingLocalDataSourceImpl implements FastingLocalDataSource {
  static const String activeSessionBoxName = 'active_fasting_session_box';
  static const String historyBoxName = 'fasting_history_box';
  static const String activeSessionKey = 'current_active_session';

  final Box activeBox;
  final Box historyBox;

  FastingLocalDataSourceImpl({
    required this.activeBox,
    required this.historyBox,
  });

  @override
  Future<void> saveActiveSession(FastingSessionModel sessionModel) async {
    await activeBox.put(activeSessionKey, sessionModel.toJson());
  }

  @override
  Future<FastingSessionModel?> getActiveSession() async {
    final rawData = activeBox.get(activeSessionKey);
    if (rawData == null) return null;
    final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(rawData as Map);
    return FastingSessionModel.fromJson(jsonMap);
  }

  @override
  Future<void> clearActiveSession() async {
    await activeBox.delete(activeSessionKey);
  }

  @override
  Future<void> saveToHistory(FastingSessionModel sessionModel) async {
    await historyBox.put(sessionModel.id, sessionModel.toJson());
  }

  @override
  Future<List<FastingSessionModel>> getFastingHistory() async {
    final historyList = <FastingSessionModel>[];
    for (var key in historyBox.keys) {
      final rawData = historyBox.get(key);
      if (rawData != null) {
        final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(rawData as Map);
        historyList.add(FastingSessionModel.fromJson(jsonMap));
      }
    }
    // Sort descending by start time
    historyList.sort((a, b) => b.startTime.compareTo(a.startTime));
    return historyList;
  }
}
