import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// Helper utility for picking and automatically compressing delivery proof photos.
abstract final class ImageCompressorUtils {
  static final ImagePicker _picker = ImagePicker();

  /// Captures or selects an image with automatic compression (max 1024x1024, 70% quality).
  static Future<String?> pickAndCompressImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 70,
      );

      if (pickedFile == null) return null;

      final file = File(pickedFile.path);
      if (await file.exists()) {
        return pickedFile.path;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
