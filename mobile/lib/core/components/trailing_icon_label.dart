import 'package:flutter/material.dart';
import '../../config/theme/app_dimensions.dart';

class TrailingIconLabel extends StatelessWidget {
  const TrailingIconLabel({
    super.key,
    required this.label,
    this.icon,
    this.style,
  });

  final String label;
  final Widget? icon;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Flexible(
        child: Text(
          label,
          style: style,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      if (icon != null) ...[
        const SizedBox(width: AppDimensions.spaceXS),
        icon!,
      ],
    ],
  );
}
