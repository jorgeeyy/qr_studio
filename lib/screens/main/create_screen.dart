import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr_studio/models/qr_history_item.dart';
import 'package:qr_studio/screens/main/result_screen.dart';
import 'package:qr_studio/services/qr_history_service.dart';
import 'package:qr_studio/widgets/createscreem_widgets/custom_appearance.dart';
import 'package:qr_studio/widgets/createscreem_widgets/preview.dart';
import 'package:qr_studio/widgets/createscreem_widgets/url_create.dart';
import 'package:qr_studio/utils/qr_shapes.dart';

enum QrCreateType { website, wifi, contact }

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key, this.initialType = QrCreateType.website});

  final QrCreateType initialType;

  @override
  State<CreateScreen> createState() => CreateScreenState();
}

class CreateScreenState extends State<CreateScreen> {
  final TextEditingController _urlController = TextEditingController();

  late QrCreateType _selectedType;
  String _qrData = '';
  Color _foregroundColor = Colors.black;
  Color _backgroundColor = Colors.white;
  QrStyle _eyeStyle = QrStyle.square;
  QrStyle _bodyStyle = QrStyle.square;
  ImageProvider? _logoImage;
  PrettyQrDecorationImagePosition _logoPosition =
      PrettyQrDecorationImagePosition.embedded;

  void setType(QrCreateType type) {
    setState(() => _selectedType = type);
  }

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final createData = [
      (icon: Icons.language, title: 'Website', type: QrCreateType.website),
      (icon: Icons.wifi, title: 'WiFi', type: QrCreateType.wifi),
      (
        icon: Icons.contact_page_outlined,
        title: 'Contact',
        type: QrCreateType.contact,
      ),
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
                    final isSelected = _selectedType == item.type;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedType = item.type),
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: isSelected
                              ? Colors.blue[600]
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 20,
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                            SizedBox(width: 8),
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => SizedBox(width: 10),
                  itemCount: createData.length,
                ),
              ),
              SizedBox(height: 20),
              if (_selectedType == QrCreateType.website) ...[
                Preview(
                  qrData: _qrData,
                  foregroundColor: _foregroundColor,
                  backgroundColor: _backgroundColor,
                  eyeStyle: _eyeStyle,
                  bodyStyle: _bodyStyle,
                  logoImage: _logoImage,
                  logoPosition: _logoPosition,
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
                  eyeStyle: _eyeStyle,
                  bodyStyle: _bodyStyle,
                  onForegroundChanged: (c) =>
                      setState(() => _foregroundColor = c),
                  onBackgroundChanged: (c) =>
                      setState(() => _backgroundColor = c),
                  onEyeShapeChanged: (r) => setState(() => _eyeStyle = r),
                  onBodyShapeChanged: (r) => setState(() => _bodyStyle = r),
                  onLogoChanged: (img) => setState(() => _logoImage = img),
                  onLogoPositionChanged: (pos) =>
                      setState(() => _logoPosition = pos),
                  logoPosition: _logoPosition,
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
                          qrData:
                              _qrData.startsWith('http://') ||
                                  _qrData.startsWith('https://')
                              ? _qrData
                              : 'https://$_qrData',
                          foregroundColor: _foregroundColor,
                          backgroundColor: _backgroundColor,
                          eyeStyle: _eyeStyle,
                          bodyStyle: _bodyStyle,
                          logoImage: _logoImage,
                          logoPosition: _logoPosition,
                        ),
                      ),
                    );

                    // Save to history and reset only when the user finalizes on the result screen
                    if (shouldReset == true) {
                      final normalizedData =
                          _qrData.startsWith('http://') ||
                              _qrData.startsWith('https://')
                          ? _qrData
                          : 'https://$_qrData';
                      await QrHistoryService.addItem(
                        QrHistoryItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          qrData: normalizedData,
                          createdAt: DateTime.now(),
                          foregroundColor: _foregroundColor,
                          backgroundColor: _backgroundColor,
                          eyeStyle: _eyeStyle,
                          bodyStyle: _bodyStyle,
                          logoPosition: _logoPosition,
                        ),
                      );
                      setState(() {
                        _qrData = '';
                        _foregroundColor = Colors.black;
                        _backgroundColor = Colors.black;
                        _eyeStyle = QrStyle.square;
                        _bodyStyle = QrStyle.square;
                        _logoImage = null;
                        _logoPosition =
                            PrettyQrDecorationImagePosition.embedded;
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
              ] else
                _ComingSoonPlaceholder(type: _selectedType),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComingSoonPlaceholder extends StatelessWidget {
  final QrCreateType type;
  const _ComingSoonPlaceholder({required this.type});

  @override
  Widget build(BuildContext context) {
    final isWifi = type == QrCreateType.wifi;
    final icon = isWifi ? Icons.wifi : Icons.contact_page_outlined;
    final label = isWifi ? 'WiFi' : 'Contact';
    final color = isWifi ? Colors.teal : Colors.orange;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, size: 56, color: color.withValues(alpha: 0.6)),
          const SizedBox(height: 16),
          Text(
            '$label QR Code',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
