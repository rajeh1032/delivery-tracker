import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom painter for the searching radar animation.
///
/// Draws 4 concentric rings, a rotating gradient sweep beam,
/// a pulsating center beacon, and randomized shimmer dots.
class RadarSweepPainter extends CustomPainter {
  const RadarSweepPainter({
    required this.sweepAngle,
    required this.ringColor,
    required this.beamColors,
    required this.dotColor,
  });

  final double sweepAngle;
  final Color ringColor;
  final List<Color> beamColors;
  final Color dotColor;

  static const int _dotCount = 4;
  static const double _dotRadius = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.47);
    final maxRadius = math.min(size.width * 0.48, size.height * 0.52);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = ringColor;

    for (final factor in [0.18, 0.38, 0.62, 0.88]) {
      canvas.drawCircle(center, maxRadius * factor, ringPaint);
    }

    final beamLength = maxRadius * 1.18;
    const tailSweep = math.pi * 0.18;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(sweepAngle);

    final gradientTailPath = Path()
      ..moveTo(0, 0)
      ..arcTo(
        Rect.fromCircle(center: Offset.zero, radius: beamLength),
        -tailSweep,
        tailSweep,
        false,
      )
      ..close();

    final gradientTailPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: beamColors,
        stops: const [0.0, 0.62, 1.0],
      ).createShader(
        Rect.fromLTWH(
          -beamLength,
          -beamLength,
          beamLength * 2,
          beamLength * 2,
        ),
      );

    canvas.drawPath(gradientTailPath, gradientTailPaint);
    canvas.restore();

    final haloPaint = Paint()..color = dotColor.withValues(alpha: 0.22);
    canvas.drawCircle(center, 15.0, haloPaint);
    final dotPaint = Paint()..color = dotColor;
    canvas.drawCircle(center, 8.0, dotPaint);

    final rng = math.Random(42);
    final normalizedSweep = sweepAngle / (math.pi * 2);
    for (var i = 0; i < _dotCount; i++) {
      final angle = rng.nextDouble() * math.pi * 2;
      final radiusFactor = 0.2 + rng.nextDouble() * 0.65;
      final phaseOffset = rng.nextDouble();

      final dotPhase = (normalizedSweep + phaseOffset) % 1.0;
      final opacity = dotPhase < 0.5
          ? (dotPhase * 2.0).clamp(0.0, 1.0)
          : ((1.0 - dotPhase) * 2.0).clamp(0.0, 1.0);

      if (opacity < 0.05) continue;

      final dx = center.dx + math.cos(angle) * maxRadius * radiusFactor;
      final dy = center.dy + math.sin(angle) * maxRadius * radiusFactor;
      final shimmerPaint = Paint()
        ..color = dotColor.withValues(alpha: opacity * 0.8);
      canvas.drawCircle(
        Offset(dx, dy),
        _dotRadius * (0.6 + opacity * 0.4),
        shimmerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RadarSweepPainter oldDelegate) {
    return oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.dotColor != dotColor ||
        oldDelegate.beamColors != beamColors;
  }
}
