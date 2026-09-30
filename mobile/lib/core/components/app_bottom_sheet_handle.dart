import 'package:flutter/material.dart';
import '../../config/theme/colors.dart';

/// Standard drag handle indicator for bottom sheets (52x4 rounded).
class AppBottomSheetHandle extends StatelessWidget {
  final Color? color;

  const AppBottomSheetHandle({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 52,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color ?? AppColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
