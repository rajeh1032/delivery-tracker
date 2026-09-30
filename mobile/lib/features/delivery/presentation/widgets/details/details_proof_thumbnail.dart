import 'dart:io';
import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/components/image_preview_dialog.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';

/// Interactive photo proof thumbnail opening full-screen image viewer on tap.
class DetailsProofThumbnail extends StatelessWidget {
  final String proofUrl;

  const DetailsProofThumbnail({
    super.key,
    required this.proofUrl,
  });

  bool get _isNetwork =>
      proofUrl.startsWith('http://') || proofUrl.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ImagePreviewDialog.show(context, imagePath: proofUrl),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            child: _isNetwork
                ? Image.network(
                    proofUrl,
                    height: 130,
                    width: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _errorPlaceholder(),
                  )
                : Image.file(
                    File(proofUrl),
                    height: 130,
                    width: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _errorPlaceholder(),
                  ),
          ),
          PositionedDirectional(
            bottom: 6,
            end: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.fullscreen_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    context.tr.viewPhoto,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorPlaceholder() {
    return Container(
      height: 130,
      width: 130,
      color: AppColors.surfaceVariant,
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_outlined,
        color: AppColors.textMuted,
        size: AppDimensions.iconLG,
      ),
    );
  }
}
