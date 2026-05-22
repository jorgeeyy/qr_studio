import 'package:flutter/material.dart';

class ScannerOverlayPainter extends CustomPainter {
  const ScannerOverlayPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    // Background mask Path
    final bgPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Custom 250x250 scanning box size
    const double scanWidth = 250;
    const double scanHeight = 250;
    final double left = (size.width - scanWidth) / 2;
    final double top = (size.height - scanHeight) / 2;

    final scanRect = Rect.fromLTWH(left, top, scanWidth, scanHeight);
    final RRect scanRRect = RRect.fromRectAndRadius(
      scanRect,
      const Radius.circular(24),
    );

    // Combine paths to create the mask with transparent cutout
    final cutoutPath = Path()..addRRect(scanRRect);
    final combinedPath = Path.combine(
      PathOperation.difference,
      bgPath,
      cutoutPath,
    );

    canvas.drawPath(combinedPath, paint);

    // Glowing framing corners
    final borderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    const double cornerLength = 24.0;

    // Top-Left Corner
    canvas.drawPath(
      Path()
        ..moveTo(left + cornerLength, top)
        ..lineTo(left, top)
        ..lineTo(left, top + cornerLength),
      borderPaint,
    );

    // Top-Right Corner
    canvas.drawPath(
      Path()
        ..moveTo(left + scanWidth - cornerLength, top)
        ..lineTo(left + scanWidth, top)
        ..lineTo(left + scanWidth, top + cornerLength),
      borderPaint,
    );

    // Bottom-Left Corner
    canvas.drawPath(
      Path()
        ..moveTo(left + cornerLength, top + scanHeight)
        ..lineTo(left, top + scanHeight)
        ..lineTo(left, top + scanHeight - cornerLength),
      borderPaint,
    );

    // Bottom-Right Corner
    canvas.drawPath(
      Path()
        ..moveTo(left + scanWidth - cornerLength, top + scanHeight)
        ..lineTo(left + scanWidth, top + scanHeight)
        ..lineTo(left + scanWidth, top + scanHeight - cornerLength),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
