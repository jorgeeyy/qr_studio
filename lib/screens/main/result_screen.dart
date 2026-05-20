import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_saver/file_saver.dart';
import 'package:qr_studio/utils/qr_shapes.dart';
import 'package:qr_studio/utils/custom_qr_shapes.dart';

class ResultScreen extends StatefulWidget {
  final String qrData;
  final Color foregroundColor;
  final Color backgroundColor;
  final QrStyle eyeStyle;
  final QrStyle bodyStyle;
  final ImageProvider? logoImage;
  final PrettyQrDecorationImagePosition logoPosition;

  const ResultScreen({
    super.key,
    required this.qrData,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.eyeStyle,
    required this.bodyStyle,
    this.logoImage,
    this.logoPosition = PrettyQrDecorationImagePosition.embedded,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final GlobalKey _qrKey = GlobalKey();
  String _selectedFormat = 'PNG';

  Future<Uint8List?> _capturePng() async {
    try {
      RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 5.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<Map<String, dynamic>?> _generateFileData() async {
    final imageBytes = await _capturePng();
    if (imageBytes == null) return null;

    Uint8List fileBytes;
    String extension;

    if (_selectedFormat == 'PDF') {
      final pdfDoc = pw.Document();
      final imageParams = pw.MemoryImage(imageBytes);
      pdfDoc.addPage(
        pw.Page(
          pageFormat: const PdfPageFormat(1250, 1250),
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(imageParams));
          },
          margin: pw.EdgeInsets.zero,
        ),
      );
      fileBytes = await pdfDoc.save();
      extension = 'pdf';
    } else if (_selectedFormat == 'SVG') {
      final base64Image = base64Encode(imageBytes);
      final svgString =
          '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1250 1250" width="100%" height="100%">
  <image href="data:image/png;base64,$base64Image" width="1250" height="1250" />
</svg>''';
      fileBytes = Uint8List.fromList(utf8.encode(svgString));
      extension = 'svg';
    } else {
      fileBytes = imageBytes;
      extension = 'png';
    }

    return {'bytes': fileBytes, 'extension': extension};
  }

  Future<void> _downloadImage() async {
    final fileData = await _generateFileData();
    if (fileData == null) return;

    try {
      final bytes = fileData['bytes'] as Uint8List;
      final extension = fileData['extension'] as String;
      final fileName = 'qr_code_${DateTime.now().millisecondsSinceEpoch}';

      if (extension == 'png' && (Platform.isAndroid || Platform.isIOS)) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/$fileName.png');
        await file.writeAsBytes(bytes);
        await Gal.putImage(file.path);
      } else {
        final path = await FileSaver.instance.saveAs(
          name: fileName,
          bytes: bytes,
          fileExtension: extension,
          mimeType: extension == 'pdf'
              ? MimeType.pdf
              : (extension == 'svg' ? MimeType.other : MimeType.png),
        );

        // If path is null or empty, the user cancelled the dialog.
        if (path == null || path.isEmpty) return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  extension == 'png'
                      ? 'Saved to Gallery!'
                      : 'Saved to Downloads!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          elevation: 6,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save file: $e')));
    }
  }

  Future<void> _shareImage() async {
    final fileData = await _generateFileData();
    if (fileData == null) return;

    try {
      final bytes = fileData['bytes'] as Uint8List;
      final extension = fileData['extension'] as String;

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/qr_code.$extension');
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Check out my generated QR code!',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to share: $e')));
    }
  }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QR Code Generated',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Your high-quality QR code is ready! You can save or share it with others.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 1.5,
                  ),
                ),
                child: RepaintBoundary(
                  key: _qrKey,
                  child: Container(
                    color: Colors.white, // Ensure background is captured
                    padding: const EdgeInsets.all(
                      12,
                    ), // Give a little white aesthetic border so it doesn't bleed into the physical edge
                    height: 200,
                    width: 200,
                    child: PrettyQrView.data(
                      data: widget.qrData,
                      errorCorrectLevel: QrErrorCorrectLevel.H,
                      decoration: PrettyQrDecoration(
                        background: widget.backgroundColor,
                        // ignore: experimental_api
                        shape: PrettyQrShape.custom(
                          _getShape(widget.bodyStyle, widget.foregroundColor),
                          finderPattern: _getShape(
                            widget.eyeStyle,
                            widget.foregroundColor,
                          ),
                        ),
                        image: widget.logoImage != null
                            ? PrettyQrDecorationImage(
                                image: widget.logoImage!,
                                scale: 0.35,
                                position: widget.logoPosition,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'export options'.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'File Format',
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedFormat = 'PNG';
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: _selectedFormat == 'PNG'
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey[700],
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'PNG',
                              style: TextStyle(
                                color: _selectedFormat == 'PNG'
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedFormat = 'SVG';
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: _selectedFormat == 'SVG'
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey[700],
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'SVG',
                              style: TextStyle(
                                color: _selectedFormat == 'SVG'
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedFormat = 'PDF';
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: _selectedFormat == 'PDF'
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey[700],
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'PDF',
                              style: TextStyle(
                                color: _selectedFormat == 'PDF'
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _downloadImage,
                    icon: const Icon(
                      Icons.download_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                    label: Text(
                      _selectedFormat == 'PNG'
                          ? 'Save to Gallery'
                          : 'Download File',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  // const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _shareImage,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: CircleBorder(
                        // borderRadius: BorderRadius.circular(60),
                      ),
                    ),
                    child: Icon(
                      Icons.share_outlined,
                      size: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),
              // Spacer(),
              TextButton(
                onPressed: () {
                  // Pop the ResultScreen to return to the previously focused tab (CreateScreen)
                  // inside the HomeScreen with the BottomNavigationBar intact.
                  // Pass 'true' back to indicate that the form should be reset.
                  Navigator.pop(context, true);
                },
                child: Text(
                  'Create another QR Code',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
