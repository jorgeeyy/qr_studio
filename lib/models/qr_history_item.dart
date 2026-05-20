import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr_studio/utils/qr_shapes.dart';

class QrHistoryItem {
  final String id;
  final String qrData;
  final DateTime createdAt;
  final Color foregroundColor;
  final Color backgroundColor;
  final QrStyle eyeStyle;
  final QrStyle bodyStyle;
  final PrettyQrDecorationImagePosition logoPosition;
  final String? logoPath;

  QrHistoryItem({
    required this.id,
    required this.qrData,
    required this.createdAt,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.eyeStyle,
    required this.bodyStyle,
    required this.logoPosition,
    this.logoPath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'qrData': qrData,
    'createdAt': createdAt.toIso8601String(),
    'foregroundColor': foregroundColor.toARGB32(),
    'backgroundColor': backgroundColor.toARGB32(),
    'eyeStyle': eyeStyle.name,
    'bodyStyle': bodyStyle.name,
    'logoPosition': logoPosition.name,
    if (logoPath != null) 'logoPath': logoPath,
  };

  factory QrHistoryItem.fromJson(Map<String, dynamic> json) => QrHistoryItem(
    id: json['id'] as String,
    qrData: json['qrData'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    foregroundColor: Color(json['foregroundColor'] as int),
    backgroundColor: Color(json['backgroundColor'] as int),
    eyeStyle: QrStyle.values.firstWhere(
      (e) => e.name == json['eyeStyle'],
      orElse: () => QrStyle.square,
    ),
    bodyStyle: QrStyle.values.firstWhere(
      (e) => e.name == json['bodyStyle'],
      orElse: () => QrStyle.square,
    ),
    logoPosition: PrettyQrDecorationImagePosition.values.firstWhere(
      (e) => e.name == json['logoPosition'],
      orElse: () => PrettyQrDecorationImagePosition.embedded,
    ),
    logoPath: json['logoPath'] as String?,
  );

  String toJsonString() => jsonEncode(toJson());

  static QrHistoryItem fromJsonString(String s) =>
      QrHistoryItem.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
