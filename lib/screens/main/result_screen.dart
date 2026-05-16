import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
// import 'package:qr_studio/screens/main/create_screen.dart';

class ResultScreen extends StatelessWidget {
  final String qrData;
  final Color foregroundColor;
  final Color backgroundColor;
  final bool isRounded;
  final ImageProvider? logoImage;

  const ResultScreen({
    super.key,
    required this.qrData,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.isRounded,
    this.logoImage,
  });

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
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                  size: 250.0,
                  backgroundColor: backgroundColor,
                  embeddedImage: logoImage,
                  embeddedImageStyle: const QrEmbeddedImageStyle(
                    size: Size(150, 150),
                  ),
                  eyeStyle: QrEyeStyle(
                    eyeShape: isRounded ? QrEyeShape.circle : QrEyeShape.square,
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
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'export options'.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'File Format',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.blue[700],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            minimumSize: Size(110, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'PNG',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                        SizedBox(width: 10),
                        // ElevatedButton(onPressed: () {}, child: Text('JPG')),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.grey[200],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            minimumSize: Size(110, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'SVG',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.grey[200],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            minimumSize: Size(110, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'PDF',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              // fontWeight: FontWeight.bold,
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
                    onPressed: () {
                      // TODO: Add save functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Downloading coming soon!'),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.download_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                    label: const Text(
                      'Download Image',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.blue[800],
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
                    onPressed: () {
                      // TODO: Add share functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share coming soon!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.grey[300],
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
                      color: Colors.blue[800],
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
                    color: Colors.blue[800],
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
