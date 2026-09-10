import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/mamba_theme.dart';

class CircularFastingProgressWidget extends StatelessWidget {
  final double progress;
  final Duration elapsed;
  final Duration remaining;
  final Duration targetDuration;
  final String protocolTitle;
  final bool isFasting;
  final bool isGoalReached;

  const CircularFastingProgressWidget({
    super.key,
    required this.progress,
    required this.elapsed,
    required this.remaining,
    required this.targetDuration,
    required this.protocolTitle,
    required this.isFasting,
    required this.isGoalReached,
  });

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final percentageText = '${(clampedProgress * 100).toStringAsFixed(1)}%';

    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow & Gradient Arc
          CustomPaint(
            size: const Size(280, 280),
            painter: _CircularProgressPainter(
              progress: clampedProgress,
              isGoalReached: isGoalReached,
              isFasting: isFasting,
            ),
          ),
          // Inner Central Info Stack
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isGoalReached
                      ? MambaTheme.neonGreen.withValues(alpha: 0.2)
                      : isFasting
                          ? MambaTheme.neonGold.withValues(alpha: 0.15)
                          : MambaTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isGoalReached
                        ? MambaTheme.neonGreen
                        : isFasting
                            ? MambaTheme.neonGold
                            : MambaTheme.textMuted.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  isGoalReached
                      ? 'META ATINGIDA!'
                      : isFasting
                          ? protocolTitle.toUpperCase()
                          : 'PRONTO PARA JEJUAR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: isGoalReached
                        ? MambaTheme.neonGreen
                        : isFasting
                            ? MambaTheme.neonGold
                            : MambaTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Elapsed / Total Display
              Text(
                isFasting ? _formatDuration(elapsed) : _formatDuration(targetDuration),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  letterSpacing: 1.0,
                  color: isFasting ? MambaTheme.textPrimary : MambaTheme.neonGold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isFasting
                    ? 'RESTANTE: ${_formatDuration(remaining)}'
                    : 'META DE ${targetDuration.inHours} HORAS',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: MambaTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              // Percentage Badge
              if (isFasting)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: MambaTheme.cardSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    percentageText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isGoalReached ? MambaTheme.neonGreen : MambaTheme.neonCyan,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final bool isGoalReached;
  final bool isFasting;

  _CircularProgressPainter({
    required this.progress,
    required this.isGoalReached,
    required this.isFasting,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    const strokeWidth = 16.0;

    // 1. Background Track
    final bgPaint = Paint()
      ..color = MambaTheme.cardSurface
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    if (!isFasting && progress == 0.0) return;

    // 2. Foreground Progress Arc with Sweep Gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -math.pi / 2; // Top 12 o'clock
    final sweepAngle = 2 * math.pi * progress;

    final gradientColors = isGoalReached
        ? [MambaTheme.neonGreen, MambaTheme.neonCyan, MambaTheme.neonGreen]
        : [MambaTheme.neonGold, MambaTheme.neonGreen];

    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: gradientColors,
        startAngle: 0.0,
        endAngle: 2 * math.pi,
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Glowing shadow effect
    final glowPaint = Paint()
      ..color = (isGoalReached ? MambaTheme.neonGreen : MambaTheme.neonGold).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);
    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isGoalReached != isGoalReached ||
        oldDelegate.isFasting != isFasting;
  }
}
