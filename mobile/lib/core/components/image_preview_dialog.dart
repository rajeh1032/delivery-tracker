import 'dart:io';
import 'package:flutter/material.dart';
import '../../config/theme/app_dimensions.dart';

/// Full-screen interactive dialog with zoom and pan to preview delivery photos.
class ImagePreviewDialog extends StatelessWidget {
  final String imagePath;
  final String? title;

  const ImagePreviewDialog({
    super.key,
    required this.imagePath,
    this.title,
  });

  /// Opens the full-screen photo preview dialog.
  static Future<void> show(
    BuildContext context, {
    required String imagePath,
    String? title,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (_) => ImagePreviewDialog(imagePath: imagePath, title: title),
    );
  }

  bool get _isNetwork =>
      imagePath.startsWith('http://') || imagePath.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppDimensions.spaceMD),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0x66000000),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceSM),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.7,
                maxWidth: MediaQuery.sizeOf(context).width * 0.9,
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: _isNetwork
                    ? Image.network(
                        imagePath,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(AppDimensions.spaceXL),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            _buildErrorState(),
                      )
                    : Image.file(
                        File(imagePath),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildErrorState(),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceXL),
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.broken_image_rounded,
            size: AppDimensions.iconXL,
            color: Colors.white60,
          ),
          SizedBox(height: AppDimensions.spaceSM),
          Text(
            'Unable to load image',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
