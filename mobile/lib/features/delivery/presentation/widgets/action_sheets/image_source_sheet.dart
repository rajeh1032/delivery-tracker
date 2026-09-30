import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/components/bottom_sheet_scaffold.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';

/// Modal bottom sheet allowing the courier to choose between Camera and Gallery.
class ImageSourceSheet extends StatelessWidget {
  const ImageSourceSheet({super.key});

  /// Displays the modal sheet and returns the selected [ImageSource].
  static Future<ImageSource?> show(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const ImageSourceSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetScaffold(
      title: context.tr.chooseSource,
      child: Column(
        children: [
          _SourceTile(
            icon: Icons.camera_alt_outlined,
            label: context.tr.camera,
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          const SizedBox(height: AppDimensions.spaceSM),
          _SourceTile(
            icon: Icons.photo_library_outlined,
            label: context.tr.gallery,
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          const SizedBox(height: AppDimensions.spaceMD),
        ],
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceVariant.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceLG,
            vertical: AppDimensions.spaceMD,
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: AppDimensions.iconLG),
              const SizedBox(width: AppDimensions.spaceMD),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: AppDimensions.iconSM,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
