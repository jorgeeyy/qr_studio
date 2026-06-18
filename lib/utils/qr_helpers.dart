import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr_studio/utils/qr_shapes.dart';
import 'package:qr_studio/utils/custom_qr_shapes.dart';

PrettyQrShape getQrShape(QrStyle style, Color color) {
  switch (style) {
    case QrStyle.square:
      return PrettyQrSquaresSymbol(color: color);
    case QrStyle.rounded:
      return PrettyQrSquaresSymbol(color: color, rounding: 1.0);
    case QrStyle.dots:
      return PrettyQrDotsSymbol(color: color);
    case QrStyle.smooth:
      return PrettyQrSmoothSymbol(color: color, roundFactor: 1.0);
    case QrStyle.diamond:
      return QrDiamondShape(color: color);
    case QrStyle.star:
      return QrStarShape(color: color);
    case QrStyle.hexagon:
      return QrHexagonShape(color: color);
    case QrStyle.leaf:
      return QrLeafShape(color: color);
  }
}

String formatDate(DateTime dt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(dt.year, dt.month, dt.day);
  final diff = today.difference(date).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  if (diff < 7) return '$diff days ago';
  return '${dt.day}/${dt.month}/${dt.year}';
}

String qrLabel(String qrData) {
  if (qrData.startsWith('WIFI:')) {
    final match = RegExp(r'S:([^;]+)').firstMatch(qrData);
    final ssid = match?.group(1) ?? '';
    return 'WiFi · $ssid';
  }
  const platforms = {
    'instagram.com': 'Instagram',
    'x.com': 'X / Twitter',
    'facebook.com': 'Facebook',
    'linkedin.com': 'LinkedIn',
    'tiktok.com': 'TikTok',
    'youtube.com': 'YouTube',
    'snapchat.com': 'Snapchat',
    'wa.me': 'WhatsApp',
    't.me': 'Telegram',
    'github.com': 'GitHub',
  };
  for (final entry in platforms.entries) {
    if (qrData.contains(entry.key)) {
      final uri = Uri.tryParse(qrData);
      final parts = uri?.pathSegments.where((s) => s.isNotEmpty).toList();
      final handle = (parts != null && parts.isNotEmpty) ? parts.last : '';
      return '${entry.value} · $handle';
    }
  }
  return qrData;
}
