import 'package:flutter/material.dart';
import '../../config/theme/app_dimensions.dart';
import '../../config/theme/colors.dart';

/// Clean back navigation button that adapts automatically to RTL and LTR.
class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;

  const AppBackButton({super.key, this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed ?? () => Navigator.maybePop(context),
      icon: Icon(
        Icons.arrow_back_ios_new,
        size: AppDimensions.iconMD,
        color: color ?? AppColors.textPrimary,
      ),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    );
  }
}
