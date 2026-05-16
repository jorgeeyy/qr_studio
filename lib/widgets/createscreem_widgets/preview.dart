import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Preview extends StatelessWidget {
  const Preview({
    super.key,
    required this.qrData,
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.transparent,
    this.isRounded = false,
    this.logoImage,
  });

  final String qrData;
  final Color foregroundColor;
  final Color backgroundColor;
  final bool isRounded;
  final ImageProvider? logoImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      // height: 200,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Preview'.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey[100],
            ),
            child: Center(
              child: qrData.trim().isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code, size: 50, color: Colors.grey[500]),
                        SizedBox(height: 10),
                        Text(
                          'Your QR code will \nappear here as you \ntype',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                      size: 130.0,
                      backgroundColor: backgroundColor,
                      embeddedImage: logoImage,
                      embeddedImageStyle: const QrEmbeddedImageStyle(
                        size: Size(80, 80),
                      ),
                      eyeStyle: QrEyeStyle(
                        eyeShape: isRounded
                            ? QrEyeShape.circle
                            : QrEyeShape.square,
                        color: foregroundColor,
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: isRounded
                            ? QrDataModuleShape.circle
                            : QrDataModuleShape.square,
                        color: foregroundColor,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
