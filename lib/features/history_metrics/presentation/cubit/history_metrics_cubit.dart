import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_weekly_metrics_usecase.dart';
import 'history_metrics_state.dart';

class HistoryMetricsCubit extends Cubit<HistoryMetricsState> {
  final GetWeeklyMetricsUseCase getWeeklyMetricsUseCase;

  HistoryMetricsCubit({required this.getWeeklyMetricsUseCase})
      : super(HistoryMetricsInitial());

  Future<void> loadWeeklyMetrics() async {
    emit(HistoryMetricsLoading());
    try {
      final summary = await getWeeklyMetricsUseCase(NoParams());
      emit(HistoryMetricsLoaded(summary));
    } catch (e) {
      emit(HistoryMetricsError('Failed to load weekly metrics: ${e.toString()}'));
    }
  }
}
