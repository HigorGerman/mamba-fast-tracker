import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/mamba_theme.dart';
import '../cubit/history_metrics_cubit.dart';
import '../cubit/history_metrics_state.dart';
import '../widgets/weekly_bar_chart.dart';

class HistoryMetricsPage extends StatefulWidget {
  const HistoryMetricsPage({super.key});

  @override
  State<HistoryMetricsPage> createState() => _HistoryMetricsPageState();
}

class _HistoryMetricsPageState extends State<HistoryMetricsPage> {
  @override
  void initState() {
    super.initState();
    context.read<HistoryMetricsCubit>().loadWeeklyMetrics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart, color: MambaTheme.neonCyan, size: 22),
            SizedBox(width: 8),
            Text('MÉTRICAS & HISTÓRICO'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: MambaTheme.textSecondary),
            onPressed: () {
              context.read<HistoryMetricsCubit>().loadWeeklyMetrics();
            },
          ),
        ],
      ),
      body: BlocConsumer<HistoryMetricsCubit, HistoryMetricsState>(
        listener: (context, state) {
          if (state is HistoryMetricsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: MambaTheme.alertRed,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is HistoryMetricsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: MambaTheme.neonCyan),
            );
          }

          if (state is HistoryMetricsLoaded) {
            final summary = state.summary;
            final completionPercent = '${(summary.completionRate * 100).toStringAsFixed(0)}%';

            return RefreshIndicator(
              color: MambaTheme.neonCyan,
              backgroundColor: MambaTheme.cardSurface,
              onRefresh: () async {
                await context.read<HistoryMetricsCubit>().loadWeeklyMetrics();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Summary Cards Row
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            title: 'MÉDIA JEJUM',
                            value: '${summary.avgFastingHours}h',
                            icon: Icons.timer,
                            iconColor: MambaTheme.neonGold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricCard(
                            title: 'CALORIAS SEMANA',
                            value: '${summary.totalCaloriesWeek}',
                            icon: Icons.local_fire_department,
                            iconColor: MambaTheme.neonGreen,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricCard(
                            title: 'META CUMP.',
                            value: completionPercent,
                            icon: Icons.check_circle_outline,
                            iconColor: MambaTheme.neonCyan,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 2. Bar Chart Section
                    const Text(
                      'Evolução de Jejum (Últimos 7 Dias)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: MambaTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    WeeklyBarChartWidget(dailyMetrics: summary.dailyMetrics),

                    const SizedBox(height: 28),

                    // 3. History Breakdown Section
                    const Text(
                      'Resumo dos Últimos 7 Dias',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: MambaTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: summary.dailyMetrics.length,
                      itemBuilder: (context, index) {
                        final item = summary.dailyMetrics[index];
                        final dateFormat = DateFormat('dd/MM/yyyy');

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: item.fastingHours >= 12
                                  ? MambaTheme.neonGreen.withValues(alpha: 0.2)
                                  : MambaTheme.cardSurface,
                              child: Icon(
                                Icons.calendar_today,
                                color: item.fastingHours >= 12
                                    ? MambaTheme.neonGreen
                                    : MambaTheme.textMuted,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              '${item.dayLabel} • ${dateFormat.format(item.date.toLocal())}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              'Jejum: ${item.fastingHours}h',
                              style: const TextStyle(fontSize: 12, color: MambaTheme.textSecondary),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${item.totalCalories} kcal',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: MambaTheme.neonGold,
                                  ),
                                ),
                                Text(
                                  item.completedFastsCount > 0 ? 'Concluído' : 'Sem registro',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: item.completedFastsCount > 0
                                        ? MambaTheme.neonGreen
                                        : MambaTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: MambaTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: MambaTheme.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: MambaTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
