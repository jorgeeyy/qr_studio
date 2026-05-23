import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Removes the solid background from the provided image bytes using a flood-fill algorithm.
Uint8List removeBackgroundProcess(Uint8List bytes) {
  var decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;

  // Resize for performance. QR code embedded images are small anyway.
  if (decoded.width > 512 || decoded.height > 512) {
    decoded = img.copyResize(
      decoded,
      width: decoded.width > decoded.height ? 512 : 0,
      height: decoded.height >= decoded.width ? 512 : 0,
    );
  }

  if (decoded.numChannels != 4) {
    decoded = decoded.convert(numChannels: 4);
  }

  // Get corner pixel for background color
  final bgPixel = decoded.getPixel(0, 0);
  final bgR = bgPixel.r;
  final bgG = bgPixel.g;
  final bgB = bgPixel.b;

  const tolerance = 15;
  final width = decoded.width;
  final height = decoded.height;

  // Track visited pixels to avoid infinite loops and isolate the background
  final visited = List.filled(width * height, false);
  final queue = <int>[];

  // Start flood fill from the 4 corners of the image
  final startPoints = [
    0,
    width - 1,
    (height - 1) * width,
    (height - 1) * width + width - 1,
  ];

  for (final pt in startPoints) {
    queue.add(pt);
  }

  while (queue.isNotEmpty) {
    final pt = queue.removeLast();
    if (visited[pt]) continue;
    visited[pt] = true;

    final x = pt % width;
    final y = pt ~/ width;
    final pixel = decoded.getPixel(x, y);

    // If matches background color with tolerance
    if ((pixel.r - bgR).abs() <= tolerance &&
        (pixel.g - bgG).abs() <= tolerance &&
        (pixel.b - bgB).abs() <= tolerance &&
        pixel.a > 0) {
      // Only process if not already transparent
      // Make transparent
      decoded.setPixelRgba(x, y, pixel.r, pixel.g, pixel.b, 0);

      // Add adjacent pixels
      if (x > 0 && !visited[pt - 1]) queue.add(pt - 1);
      if (x < width - 1 && !visited[pt + 1]) queue.add(pt + 1);
      if (y > 0 && !visited[pt - width]) queue.add(pt - width);
      if (y < height - 1 && !visited[pt + width]) queue.add(pt + width);
    }
  }

  return img.encodePng(decoded);
}

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
