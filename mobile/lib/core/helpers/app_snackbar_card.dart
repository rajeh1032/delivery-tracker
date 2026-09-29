import 'package:flutter/material.dart';
import '../../config/theme/app_dimensions.dart';
import '../extensions/context_extensions.dart';
import 'snackbar_animated_icon.dart';

/// Premium animated snackbar card matching the done_app visual design and motion.
class AppSnackbarCard extends StatelessWidget {
  final String message;
  final Color accentColor;
  final IconData icon;
  final SnackbarVariant variant;
  final VoidCallback onDismiss;

  const AppSnackbarCard({
    super.key,
    required this.message,
    required this.accentColor,
    required this.icon,
    required this.variant,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    const cardBackgroundColor = Color(0xFF242C32);
    const bodyTextColor = Color(0xFFC8C5C5);
    final borderRadius = BorderRadius.circular(AppDimensions.radiusXL);

    final title = switch (variant) {
      SnackbarVariant.success => context.tr.snackbarSuccess,
      SnackbarVariant.error => context.tr.snackbarError,
      SnackbarVariant.warning => context.tr.snackbarWarning,
      SnackbarVariant.info => context.tr.snackbarInfo,
    };

    return Semantics(
      container: true,
      liveRegion: true,
      label: '$title. $message',
      child: GestureDetector(
        onTap: onDismiss,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                PositionedDirectional(
                  start: -18,
                  top: -10,
                  width: 120,
                  height: 120,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            accentColor.withValues(alpha: 0.15),
                            Colors.transparent,
                          ],
                          stops: const [0, 1],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceLG,
                    vertical: AppDimensions.spaceMD,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SnackbarAnimatedIcon(
                        accentColor: accentColor,
                        icon: icon,
                        variant: variant,
                      ),
                      const SizedBox(width: AppDimensions.spaceMD),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.spaceXS),
                            Text(
                              message,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: bodyTextColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
