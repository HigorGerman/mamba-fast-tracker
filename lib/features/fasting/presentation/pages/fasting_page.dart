import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/mamba_theme.dart';
import '../../domain/entities/fasting_protocol.dart';
import '../../domain/entities/fasting_session.dart';
import '../../domain/entities/fasting_status.dart';
import '../cubit/fasting_cubit.dart';
import '../cubit/fasting_state.dart';
import '../widgets/circular_fasting_progress.dart';

class FastingPage extends StatelessWidget {
  const FastingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: MambaTheme.neonGold.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bolt, color: MambaTheme.neonGold, size: 20),
            ),
            const SizedBox(width: 8),
            const Text('MAMBA FAST TRACKER'),
          ],
        ),
      ),
      body: BlocConsumer<FastingCubit, FastingState>(
        listener: (context, state) {
          if (state is FastingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: MambaTheme.alertRed,
              ),
            );
          } else if (state is FastingCompletedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🎉 Parabéns! Meta de jejum concluída!'),
                backgroundColor: MambaTheme.neonGreen,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is FastingLoading) {
            return const Center(
              child: CircularProgressIndicator(color: MambaTheme.neonGold),
            );
          }

          final isFasting = state is FastingActiveState;
          final activeState = state is FastingActiveState ? state : null;
          final selectedProtocol = state.selectedProtocol;
          final currentTargetDuration = activeState?.session.targetDuration ?? state.targetDuration;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Protocol Selector Pills (Enabled only when idle)
                if (!isFasting) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Escolha o Protocolo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: MambaTheme.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ProtocolSelector(
                    selectedProtocol: selectedProtocol,
                    customHours: state.customDuration.inHours,
                    onSelect: (protocol) {
                      if (protocol == FastingProtocolType.custom) {
                        _showCustomHoursDialog(context, state.customDuration);
                      } else {
                        context.read<FastingCubit>().selectProtocol(protocol);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // 2. Circular Timer Visualization
                CircularFastingProgressWidget(
                  progress: activeState?.progress ?? 0.0,
                  elapsed: activeState?.elapsed ?? Duration.zero,
                  remaining: activeState?.remaining ?? Duration.zero,
                  targetDuration: currentTargetDuration,
                  protocolTitle: activeState?.session.protocol.title ??
                      (selectedProtocol == FastingProtocolType.custom
                          ? 'Personalizado (${currentTargetDuration.inHours}h)'
                          : selectedProtocol.title),
                  isFasting: isFasting,
                  isGoalReached: activeState?.isGoalReached ?? false,
                ),

                const SizedBox(height: 28),

                // 3. Stats & Details Section
                _SessionStatsCards(
                  session: activeState?.session,
                  selectedProtocol: selectedProtocol,
                  targetDuration: currentTargetDuration,
                  isFasting: isFasting,
                ),

                const SizedBox(height: 28),

                // 4. Action Control Buttons
                if (!isFasting)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<FastingCubit>().startFasting(
                              customDuration: state.targetDuration,
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MambaTheme.neonGold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded, size: 28),
                          SizedBox(width: 8),
                          Text(
                            'INICIAR JEJUM',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: OutlinedButton(
                            onPressed: () {
                              _showCancelDialog(context);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: MambaTheme.alertRed, width: 1.5),
                              foregroundColor: MambaTheme.alertRed,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'CANCELAR JEJUM',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              if (activeState != null && !activeState.isGoalReached) {
                                _showEndEarlyDialog(context, activeState);
                              } else {
                                context.read<FastingCubit>().stopFasting();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: activeState?.isGoalReached ?? false
                                  ? MambaTheme.neonGreen
                                  : MambaTheme.neonGold,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  activeState?.isGoalReached ?? false
                                      ? Icons.emoji_events
                                      : Icons.stop_rounded,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  activeState?.isGoalReached ?? false ? 'CONCLUIR JEJUM' : 'ENCERRAR JEJUM',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 36),

                // 5. Fasting History Section
                _FastingHistoryList(history: state.history),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCustomHoursDialog(BuildContext context, Duration currentDuration) {
    final controller = TextEditingController(text: currentDuration.inHours.toString());
    int selectedHours = currentDuration.inHours;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: MambaTheme.cardSurface,
          title: const Text('Jejum Personalizado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Defina a quantidade de horas para a sua meta de jejum:',
                style: TextStyle(color: MambaTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: MambaTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  suffixText: 'Horas',
                  filled: true,
                  fillColor: MambaTheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  final parsed = int.tryParse(val.trim());
                  if (parsed != null && parsed > 0 && parsed <= 72) {
                    selectedHours = parsed;
                  }
                },
              ),
              const SizedBox(height: 16),
              // Quick Hours Chips
              Wrap(
                spacing: 8,
                children: [14, 20, 24, 36, 48].map((h) {
                  return ActionChip(
                    label: Text('${h}h'),
                    backgroundColor: selectedHours == h ? MambaTheme.neonGold : MambaTheme.surface,
                    labelStyle: TextStyle(
                      color: selectedHours == h ? Colors.black : MambaTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedHours = h;
                        controller.text = h.toString();
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CANCELAR', style: TextStyle(color: MambaTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                final finalHours = int.tryParse(controller.text.trim()) ?? selectedHours;
                if (finalHours > 0 && finalHours <= 168) {
                  context.read<FastingCubit>().selectProtocol(
                        FastingProtocolType.custom,
                        customDuration: Duration(hours: finalHours),
                      );
                }
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MambaTheme.neonGold,
                foregroundColor: Colors.black,
              ),
              child: const Text('SALVAR PROTOCOLO', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEndEarlyDialog(BuildContext context, FastingActiveState activeState) {
    final hours = activeState.elapsed.inHours;
    final mins = activeState.elapsed.inMinutes % 60;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: MambaTheme.cardSurface,
        title: const Text('Encerrar Jejum Antecipadamente?'),
        content: Text(
          'Você jejuou $hours h ${mins}m até agora. Deseja encerrar a sessão e registrar este tempo cumprido no seu histórico?',
          style: const TextStyle(color: MambaTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CONTINUAR JEJUANDO', style: TextStyle(color: MambaTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<FastingCubit>().stopFasting();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MambaTheme.neonGold,
              foregroundColor: Colors.black,
            ),
            child: const Text('SIM, ENCERRAR', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: MambaTheme.cardSurface,
        title: const Text('Cancelar Sessão de Jejum?'),
        content: const Text(
          'A sessão será descartada e registrada como CANCELADA no seu histórico.',
          style: TextStyle(color: MambaTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('VOLTAR', style: TextStyle(color: MambaTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<FastingCubit>().cancelFasting();
            },
            child: const Text('SIM, CANCELAR', style: TextStyle(color: MambaTheme.alertRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _ProtocolSelector extends StatelessWidget {
  final FastingProtocolType selectedProtocol;
  final int customHours;
  final ValueChanged<FastingProtocolType> onSelect;

  const _ProtocolSelector({
    required this.selectedProtocol,
    required this.customHours,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: FastingProtocolType.values.map((protocol) {
          final isSelected = protocol == selectedProtocol;
          final title = protocol == FastingProtocolType.custom
              ? 'Personalizado (${customHours}h)'
              : protocol.title;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(title),
              selected: isSelected,
              onSelected: (_) => onSelect(protocol),
              selectedColor: MambaTheme.neonGold,
              backgroundColor: MambaTheme.cardSurface,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : MambaTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? MambaTheme.neonGold : Colors.transparent,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SessionStatsCards extends StatelessWidget {
  final FastingSessionEntity? session;
  final FastingProtocolType selectedProtocol;
  final Duration targetDuration;
  final bool isFasting;

  const _SessionStatsCards({
    this.session,
    required this.selectedProtocol,
    required this.targetDuration,
    required this.isFasting,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM, HH:mm');
    final startTimeStr = session != null ? dateFormat.format(session!.startTime.toLocal()) : '--:--';
    final targetTimeStr = session != null ? dateFormat.format(session!.targetEndTime) : '--:--';
    final targetHours = '${targetDuration.inHours}h';

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.play_circle_outline,
            title: 'INÍCIO DO JEJUM',
            value: isFasting ? startTimeStr : 'Inativo',
            iconColor: MambaTheme.neonCyan,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.flag_outlined,
            title: 'META PREVISTA',
            value: isFasting ? targetTimeStr : 'Meta de $targetHours',
            iconColor: MambaTheme.neonGold,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MambaTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: MambaTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
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

class _FastingHistoryList extends StatelessWidget {
  final List<FastingSessionEntity> history;

  const _FastingHistoryList({required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: MambaTheme.cardSurface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          children: [
            Icon(Icons.history, color: MambaTheme.textMuted, size: 32),
            SizedBox(height: 8),
            Text(
              'Nenhum jejum concluído ainda',
              style: TextStyle(color: MambaTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    final dateFormat = DateFormat('EEE, dd/MM • HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Histórico de Jejum',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: MambaTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[index];
            final elapsed = item.getElapsedDuration();
            final hours = elapsed.inHours;
            final mins = elapsed.inMinutes % 60;
            final isCompleted = item.status == FastingStatus.completed;
            final isEndedEarly = item.status == FastingStatus.endedEarly;

            final statusColor = isCompleted
                ? MambaTheme.neonGreen
                : isEndedEarly
                    ? MambaTheme.neonGold
                    : MambaTheme.alertRed;

            final statusIcon = isCompleted
                ? Icons.check_circle
                : isEndedEarly
                    ? Icons.timelapse
                    : Icons.cancel;

            final statusLabel = isCompleted
                ? 'CONCLUÍDO'
                : isEndedEarly
                    ? 'ENCERRADO ANTES'
                    : 'CANCELADO';

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: 0.2),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  item.protocol.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                subtitle: Text(
                  dateFormat.format(item.startTime.toLocal()),
                  style: const TextStyle(fontSize: 12, color: MambaTheme.textSecondary),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${hours}h ${mins}m',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: MambaTheme.textPrimary,
                      ),
                    ),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
