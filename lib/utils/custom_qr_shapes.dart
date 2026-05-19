import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class QrDiamondShape extends PrettyQrShape {
  final Color color;

  const QrDiamondShape({this.color = const Color(0xFF000000)});

  @override
  void paint(PrettyQrPaintingContext context) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    for (final module in context.matrix) {
      if (!module.isDark) continue;

      final rect = module.resolveRect(context);
      final center = rect.center;
      final halfWidth = rect.width / 2;
      final halfHeight = rect.height / 2;

      path.moveTo(center.dx, center.dy - halfHeight);
      path.lineTo(center.dx + halfWidth, center.dy);
      path.lineTo(center.dx, center.dy + halfHeight);
      path.lineTo(center.dx - halfWidth, center.dy);
      path.close();
    }
    context.canvas.drawPath(path, paint);
  }
}

class QrStarShape extends PrettyQrShape {
  final Color color;

  const QrStarShape({this.color = const Color(0xFF000000)});

  @override
  void paint(PrettyQrPaintingContext context) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();

    for (final module in context.matrix) {
      if (!module.isDark) continue;

      final rect = module.resolveRect(context);
      final center = rect.center;
      final radius = rect.width / 2;
      final innerRadius = radius * 0.4;

      for (int i = 0; i < 10; i++) {
        double angle = i * math.pi / 5 - math.pi / 2;
        double r = (i % 2 == 0) ? radius : innerRadius;
        if (i == 0) {
          path.moveTo(
            center.dx + r * math.cos(angle),
            center.dy + r * math.sin(angle),
          );
        } else {
          path.lineTo(
            center.dx + r * math.cos(angle),
            center.dy + r * math.sin(angle),
          );
        }
      }
      path.close();
    }
    context.canvas.drawPath(path, paint);
  }
}

class QrHexagonShape extends PrettyQrShape {
  final Color color;

  const QrHexagonShape({this.color = const Color(0xFF000000)});

  @override
  void paint(PrettyQrPaintingContext context) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();

    for (final module in context.matrix) {
      if (!module.isDark) continue;

      final rect = module.resolveRect(context);
      final center = rect.center;
      final radius = rect.width / 2;

      for (int i = 0; i < 6; i++) {
        double angle = i * math.pi / 3 + math.pi / 6;
        if (i == 0) {
          path.moveTo(
            center.dx + radius * math.cos(angle),
            center.dy + radius * math.sin(angle),
          );
        } else {
          path.lineTo(
            center.dx + radius * math.cos(angle),
            center.dy + radius * math.sin(angle),
          );
        }
      }
      path.close();
    }
    context.canvas.drawPath(path, paint);
  }
}

class QrLeafShape extends PrettyQrShape {
  final Color color;

  const QrLeafShape({this.color = const Color(0xFF000000)});

  @override
  void paint(PrettyQrPaintingContext context) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();

    for (final module in context.matrix) {
      if (!module.isDark) continue;

      final rect = module.resolveRect(context);
      final rrect = RRect.fromRectAndCorners(
        rect,
        topLeft: Radius.circular(rect.width),
        bottomRight: Radius.circular(rect.width),
        topRight: Radius.zero,
        bottomLeft: Radius.zero,
      );
      path.addRRect(rrect);
    }
    context.canvas.drawPath(path, paint);
  }
}
