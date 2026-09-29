import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/components/app_back_button.dart';

/// Stylized header with route background, back button, and order number identifier.
class DetailsMapHeader extends StatelessWidget {
  final String orderNumber;
  final VoidCallback? onBack;

  const DetailsMapHeader({
    super.key,
    required this.orderNumber,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.mapHeaderHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.surfaceVariant.withValues(alpha: 0.8),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.6),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Subtle stylized map route geometry
            Positioned.fill(
              child: CustomPaint(
                painter: _MapRoutePatternPainter(),
              ),
            ),
            // Header content
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: AppDimensions.spaceSM,
                end: AppDimensions.spaceMD,
                top: AppDimensions.spaceSM,
                bottom: AppDimensions.spaceSM,
              ),
              child: Row(
                children: [
                  AppBackButton(onPressed: onBack),
                  const SizedBox(width: AppDimensions.spaceSM),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spaceSM,
                            vertical: AppDimensions.spaceXXS,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusSM),
                          ),
                          child: Text(
                            orderNumber,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.navigation_outlined,
                      size: AppDimensions.iconMD,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapRoutePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.8)
      ..cubicTo(
        size.width * 0.35,
        size.height * 0.2,
        size.width * 0.65,
        size.height * 0.9,
        size.width * 0.9,
        size.height * 0.3,
      );

    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
