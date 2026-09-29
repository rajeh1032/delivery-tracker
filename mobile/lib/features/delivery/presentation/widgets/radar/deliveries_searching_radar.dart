import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';
import 'radar_sweep_painter.dart';
import 'radar_zone_glow.dart';

/// Full-screen radar animation displayed when initially searching for deliveries.
class DeliveriesSearchingRadar extends StatefulWidget {
  const DeliveriesSearchingRadar({super.key});

  @override
  State<DeliveriesSearchingRadar> createState() =>
      _DeliveriesSearchingRadarState();
}

class _DeliveriesSearchingRadarState extends State<DeliveriesSearchingRadar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final beamColors = [
      colorScheme.primary.withValues(alpha: 0),
      colorScheme.primary.withValues(alpha: 0.08),
      colorScheme.primary.withValues(alpha: 0.20),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.surface,
                      AppColors.mapBackdrop,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: -constraints.maxWidth * 0.20,
              bottom: -constraints.maxHeight * 0.06,
              child: RadarZoneGlow(
                size: constraints.maxWidth * 0.72,
                color: colorScheme.primary.withValues(alpha: 0.08),
              ),
            ),
            Positioned(
              right: -constraints.maxWidth * 0.14,
              top: constraints.maxHeight * 0.20,
              child: RadarZoneGlow(
                size: constraints.maxWidth * 0.42,
                color: colorScheme.primary.withValues(alpha: 0.05),
              ),
            ),
            Positioned.fill(
              top: AppDimensions.spaceXXL,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => CustomPaint(
                  painter: RadarSweepPainter(
                    sweepAngle: _controller.value * math.pi * 2,
                    beamColors: beamColors,
                    dotColor: colorScheme.primary,
                    ringColor: colorScheme.primary.withValues(alpha: 0.25),
                  ),
                ),
              ),
            ),
            Positioned(
              top: AppDimensions.spaceXL,
              left: AppDimensions.spaceLG,
              right: AppDimensions.spaceLG,
              child: Center(
                child: Text(
                  context.tr.deliveriesSearching,
                  textAlign: TextAlign.center,
                  style: context.textStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
