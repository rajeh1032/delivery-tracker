import 'package:flutter/material.dart';
import '../../config/theme/app_dimensions.dart';
import '../../config/theme/colors.dart';
import 'app_bottom_sheet_handle.dart';

/// Reusable bottom sheet surface with standard chrome, handle, and keyboard handling.
class BottomSheetScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final EdgeInsetsGeometry? padding;

  const BottomSheetScaffold({
    super.key,
    required this.child,
    this.title,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXXL),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: padding ?? const EdgeInsets.all(AppDimensions.spaceLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppBottomSheetHandle(),
              if (title != null) ...[
                const SizedBox(height: AppDimensions.spaceSM),
                Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceMD),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
