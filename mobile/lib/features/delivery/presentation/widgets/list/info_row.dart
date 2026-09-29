import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';

/// Single-line icon + text info row.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.maxLines = 1,
    this.iconColor,
    this.textColor,
  });

  final IconData icon;
  final String text;
  final int maxLines;
  final Color? iconColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppDimensions.iconSM,
          color: iconColor ?? AppColors.textSecondary,
        ),
        const SizedBox(width: AppDimensions.spaceSM),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
