import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr_studio/utils/qr_shapes.dart';
import 'package:qr_studio/utils/custom_qr_shapes.dart';

class Preview extends StatelessWidget {
  const Preview({
    super.key,
    required this.qrData,
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.transparent,
    this.eyeStyle = QrStyle.square,
    this.bodyStyle = QrStyle.square,
    this.logoImage,
    this.logoPosition = PrettyQrDecorationImagePosition.embedded,
  });

  final String qrData;
  final Color foregroundColor;
  final Color backgroundColor;
  final QrStyle eyeStyle;
  final QrStyle bodyStyle;
  final ImageProvider? logoImage;
  final PrettyQrDecorationImagePosition logoPosition;

  PrettyQrShape _getShape(QrStyle style, Color color) {
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

  @override
  Widget build(BuildContext context) {
    final eyeShape = _getShape(eyeStyle, foregroundColor);
    final bodyShape = _getShape(bodyStyle, foregroundColor);

    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1.5,
        ),
      ),
      // height: 200,
      // color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Preview'.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            // width: double.infinity,
            height: 150,
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.circular(20),
            //   color: Theme.of(context).colorScheme.surfaceContainerHighest,
            //   // color: Colors.grey[500],
            // ),
            child: Center(
              child: qrData.trim().isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code, size: 50, color: Colors.white54),
                        SizedBox(height: 10),
                        Text(
                          'Your QR code will \nappear here as you \ntype',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PrettyQrView.data(
                        data: qrData,
                        errorCorrectLevel: QrErrorCorrectLevel.H,
                        decoration: PrettyQrDecoration(
                          background: backgroundColor,
                          // ignore: experimental_member_use
                          shape: PrettyQrShape.custom(
                            bodyShape,
                            finderPattern: eyeShape,
                          ),
                          image: logoImage != null
                              ? PrettyQrDecorationImage(
                                  image: logoImage!,
                                  scale: 0.35,
                                  position: logoPosition,
                                )
                              : null,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
