import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Preprocesses an image for QR code detection: grayscale, binarize, enhance contrast.
Uint8List preprocessForQrDetection(Uint8List bytes) {
  var decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;

  // Convert to grayscale
  decoded = img.grayscale(decoded);

  // Increase contrast
  decoded = img.adjustColor(decoded, contrast: 1.5);

  // Manual binarization (threshold)
  for (int y = 0; y < decoded.height; y++) {
    for (int x = 0; x < decoded.width; x++) {
      final luma = decoded.getPixel(x, y).r; // grayscale, so r=g=b
      final value = luma < 128 ? 0 : 255;
      decoded.setPixelRgba(x, y, value, value, value, 255);
    }
  }

  return img.encodePng(decoded);
}
