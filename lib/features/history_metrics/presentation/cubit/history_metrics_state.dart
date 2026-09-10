import 'package:equatable/equatable.dart';
import '../../domain/entities/weekly_summary.dart';

abstract class HistoryMetricsState extends Equatable {
  const HistoryMetricsState();

  @override
  List<Object?> get props => [];
}

class HistoryMetricsInitial extends HistoryMetricsState {}

class HistoryMetricsLoading extends HistoryMetricsState {}

class HistoryMetricsLoaded extends HistoryMetricsState {
  final WeeklySummary summary;

  const HistoryMetricsLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class HistoryMetricsError extends HistoryMetricsState {
  final String message;

  const HistoryMetricsError(this.message);

  @override
  List<Object?> get props => [message];
}
