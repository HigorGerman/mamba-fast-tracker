import '../../domain/entities/fasting_protocol.dart';
import '../../domain/entities/fasting_session.dart';
import '../../domain/entities/fasting_status.dart';

class FastingSessionModel extends FastingSessionEntity {
  const FastingSessionModel({
    required super.id,
    required super.startTime,
    required super.targetDuration,
    required super.protocol,
    required super.status,
    super.endTime,
  });

  factory FastingSessionModel.fromEntity(FastingSessionEntity entity) {
    return FastingSessionModel(
      id: entity.id,
      startTime: entity.startTime,
      targetDuration: entity.targetDuration,
      protocol: entity.protocol,
      status: entity.status,
      endTime: entity.endTime,
    );
  }

  factory FastingSessionModel.fromJson(Map<String, dynamic> json) {
    return FastingSessionModel(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String).toUtc(),
      targetDuration: Duration(seconds: json['targetDurationSeconds'] as int),
      protocol: FastingProtocolType.values.byName(json['protocol'] as String),
      status: FastingStatus.values.byName(json['status'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String).toUtc()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'targetDurationSeconds': targetDuration.inSeconds,
      'protocol': protocol.name,
      'status': status.name,
      'endTime': endTime?.toIso8601String(),
    };
  }

  FastingSessionEntity toEntity() {
    return FastingSessionEntity(
      id: id,
      startTime: startTime,
      targetDuration: targetDuration,
      protocol: protocol,
      status: status,
      endTime: endTime,
    );
  }
}
