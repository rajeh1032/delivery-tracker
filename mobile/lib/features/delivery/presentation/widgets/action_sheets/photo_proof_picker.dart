import 'dart:io';
import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/components/image_preview_dialog.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';

/// Photo proof capture section ported from Mumayaz delivery proof architecture.
class PhotoProofPicker extends StatelessWidget {
  final String? photoPath;
  final bool isLoading;
  final String? error;
  final VoidCallback onPickPhoto;
  final VoidCallback onRemovePhoto;

  const PhotoProofPicker({
    super.key,
    this.photoPath,
    this.isLoading = false,
    this.error,
    required this.onPickPhoto,
    required this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoPath != null && photoPath!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr.photoTitle,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceXXS),
        Text(
          context.tr.photoHint,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceSM),
        if (isLoading) ...[
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            ),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ),
        ] else if (hasPhoto) ...[
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () => ImagePreviewDialog.show(
                  context,
                  imagePath: photoPath!,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                  child: Image.file(
                    File(photoPath!),
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              PositionedDirectional(
                top: -6,
                end: -6,
                child: GestureDetector(
                  onTap: onRemovePhoto,
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.spaceXXS),
                    decoration: const BoxDecoration(
                      color: AppColors.failed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          Material(
            color: AppColors.surfaceVariant.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            child: InkWell(
              onTap: onPickPhoto,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                  border: Border.all(
                    color: AppColors.border,
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: AppDimensions.iconLG,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: AppDimensions.spaceXXS),
                    Icon(
                      Icons.add,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: AppDimensions.spaceXS),
          Text(
            error!,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.failed,
            ),
          ),
        ],
      ],
    );
  }
}
