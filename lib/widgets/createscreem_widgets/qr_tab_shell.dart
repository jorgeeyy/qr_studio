import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr_studio/models/qr_history_item.dart';
import 'package:qr_studio/screens/main/result_screen.dart';
import 'package:qr_studio/services/qr_history_service.dart';
import 'package:qr_studio/utils/qr_shapes.dart';
import 'package:qr_studio/widgets/createscreem_widgets/custom_appearance.dart';
import 'package:qr_studio/widgets/createscreem_widgets/preview.dart';

class QrTabShell extends StatelessWidget {
  const QrTabShell({
    super.key,
    required this.qrData,
    required this.inputWidget,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.buttonColor,
    required this.emptyMessage,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.eyeStyle,
    required this.bodyStyle,
    required this.logoImage,
    required this.logoPosition,
    required this.onForegroundChanged,
    required this.onBackgroundChanged,
    required this.onEyeShapeChanged,
    required this.onBodyShapeChanged,
    required this.onLogoChanged,
    required this.onLogoPositionChanged,
    required this.onReset,
    this.transformQrData,
  });

  final String qrData;
  final Widget inputWidget;
  final String buttonLabel;
  final IconData buttonIcon;
  final Color buttonColor;
  final String emptyMessage;

  // Appearance state
  final Color foregroundColor;
  final Color backgroundColor;
  final QrStyle eyeStyle;
  final QrStyle bodyStyle;
  final ImageProvider? logoImage;
  final PrettyQrDecorationImagePosition logoPosition;

  // Appearance callbacks
  final ValueChanged<Color> onForegroundChanged;
  final ValueChanged<Color> onBackgroundChanged;
  final ValueChanged<QrStyle> onEyeShapeChanged;
  final ValueChanged<QrStyle> onBodyShapeChanged;
  final ValueChanged<ImageProvider?> onLogoChanged;
  final ValueChanged<PrettyQrDecorationImagePosition> onLogoPositionChanged;

  /// Called after a successful save — parent should reset its state here.
  final VoidCallback onReset;

  /// Optional transform applied to [qrData] before sending to ResultScreen
  /// and before saving (e.g. URL normalisation for website QR codes).
  final String Function(String)? transformQrData;

  Future<void> _onGenerate(BuildContext context) async {
    if (qrData.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  emptyMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          elevation: 6,
        ),
      );
      return;
    }

    final resultData = transformQrData != null
        ? transformQrData!(qrData)
        : qrData;

    final shouldReset = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          qrData: resultData,
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
          eyeStyle: eyeStyle,
          bodyStyle: bodyStyle,
          logoImage: logoImage,
          logoPosition: logoPosition,
        ),
      ),
    );

    if (shouldReset == true) {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      String? logoPath;
      if (!kIsWeb && logoImage is FileImage) {
        try {
          final src = (logoImage as FileImage).file;
          final dir = await getApplicationDocumentsDirectory();
          final logoDir = Directory('${dir.path}/qr_logos');
          await logoDir.create(recursive: true);
          final dest = '${logoDir.path}/$id.png';
          await src.copy(dest);
          logoPath = dest;
        } catch (_) {}
      }
      await QrHistoryService.addItem(
        QrHistoryItem(
          id: id,
          qrData: resultData,
          createdAt: DateTime.now(),
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
          eyeStyle: eyeStyle,
          bodyStyle: bodyStyle,
          logoPosition: logoPosition,
          logoPath: logoPath,
        ),
      );
      onReset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Preview(
          qrData: qrData,
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
          eyeStyle: eyeStyle,
          bodyStyle: bodyStyle,
          logoImage: logoImage,
          logoPosition: logoPosition,
        ),
        const SizedBox(height: 10),
        inputWidget,
        const SizedBox(height: 20),
        CustomAppearance(
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
          eyeStyle: eyeStyle,
          bodyStyle: bodyStyle,
          onForegroundChanged: onForegroundChanged,
          onBackgroundChanged: onBackgroundChanged,
          onEyeShapeChanged: onEyeShapeChanged,
          onBodyShapeChanged: onBodyShapeChanged,
          onLogoChanged: onLogoChanged,
          onLogoPositionChanged: onLogoPositionChanged,
          logoPosition: logoPosition,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _onGenerate(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(buttonIcon, size: 24, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                buttonLabel,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
