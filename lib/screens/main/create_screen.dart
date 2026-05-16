import 'package:flutter/material.dart';
import 'package:qr_studio/screens/main/result_screen.dart';
import 'package:qr_studio/widgets/createscreem_widgets/custom_appearance.dart';
import 'package:qr_studio/widgets/createscreem_widgets/preview.dart';
import 'package:qr_studio/widgets/createscreem_widgets/url_create.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final TextEditingController _urlController = TextEditingController();

  String _qrData = '';
  Color _foregroundColor = Colors.black;
  Color _backgroundColor = Colors.white;
  bool _isRounded = false;
  ImageProvider? _logoImage;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const createData = [
      (icon: Icons.link, title: 'URL'),
      (icon: Icons.wifi, title: 'WiFi'),
      (icon: Icons.contact_page_outlined, title: 'Contact'),
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final item = createData[index];
                    return Container(
                      width: 100,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.grey[300],
                      ),
                      child: Row(
                        children: [
                          Icon(item.icon, size: 20),
                          SizedBox(width: 8),
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => SizedBox(width: 20),
                  itemCount: createData.length,
                ),
              ),
              SizedBox(height: 20),
              Preview(
                qrData: _qrData,
                foregroundColor: _foregroundColor,
                backgroundColor: _backgroundColor,
                isRounded: _isRounded,
                logoImage: _logoImage,
              ),
              SizedBox(height: 10),
              UrlCreate(
                controller: _urlController,
                onChanged: (value) {
                  setState(() {
                    _qrData = value;
                  });
                },
              ),
              SizedBox(height: 20),
              CustomAppearance(
                foregroundColor: _foregroundColor,
                backgroundColor: _backgroundColor,
                isRounded: _isRounded,
                onForegroundChanged: (c) =>
                    setState(() => _foregroundColor = c),
                onBackgroundChanged: (c) =>
                    setState(() => _backgroundColor = c),
                onShapeChanged: (r) => setState(() => _isRounded = r),
                onLogoChanged: (img) => setState(() => _logoImage = img),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_qrData.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Please enter data for your QR code first',
                                style: TextStyle(
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
                  final shouldReset = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultScreen(
                        qrData: _qrData,
                        foregroundColor: _foregroundColor,
                        backgroundColor: _backgroundColor,
                        isRounded: _isRounded,
                        logoImage: _logoImage,
                      ),
                    ),
                  );

                  if (shouldReset == true) {
                    setState(() {
                      _qrData = '';
                      _foregroundColor = Colors.black;
                      _backgroundColor = Colors.white;
                      _isRounded = false;
                      _logoImage = null;
                      _urlController.clear();
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_2, size: 24, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'GENERATE CODE',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
