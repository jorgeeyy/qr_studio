import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr_studio/utils/qr_shapes.dart';
import 'package:qr_studio/widgets/createscreem_widgets/contact_create.dart';
import 'package:qr_studio/widgets/createscreem_widgets/qr_tab_shell.dart';
import 'package:qr_studio/widgets/createscreem_widgets/url_create.dart';
import 'package:qr_studio/widgets/createscreem_widgets/wifi_create.dart';

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

  // Per-tab QR data
  String _qrData = '';
  String _wifiQrData = '';
  String _contactQrData = '';

  // Shared appearance
  Color _foregroundColor = Colors.black;
  Color _backgroundColor = Colors.white;
  QrStyle _eyeStyle = QrStyle.square;
  QrStyle _bodyStyle = QrStyle.square;
  ImageProvider? _logoImage;
  PrettyQrDecorationImagePosition _logoPosition =
      PrettyQrDecorationImagePosition.embedded;

  void setType(QrCreateType type) => setState(() => _selectedType = type);

  void _resetAppearance() {
    _foregroundColor = Colors.black;
    _backgroundColor = Colors.white;
    _eyeStyle = QrStyle.square;
    _bodyStyle = QrStyle.square;
    _logoImage = null;
    _logoPosition = PrettyQrDecorationImagePosition.embedded;
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
    final tabs = [
      (icon: Icons.language, title: 'Website', type: QrCreateType.website),
      (icon: Icons.wifi, title: 'WiFi', type: QrCreateType.wifi),
      (icon: Icons.campaign, title: 'Socials', type: QrCreateType.contact),
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tab selector
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: tabs.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final tab = tabs[index];
                    final isSelected = _selectedType == tab.type;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedType = tab.type),
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue[600]!
                                : Theme.of(context).colorScheme.outlineVariant,
                            width: 1.5,
                          ),
                          color: isSelected
                              ? Colors.blue[600]
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              tab.icon,
                              size: 20,
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              tab.title,
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
                ),
              ),
              const SizedBox(height: 20),

              // Tab body
              if (_selectedType == QrCreateType.website)
                QrTabShell(
                  qrData: _qrData,
                  inputWidget: UrlCreate(
                    controller: _urlController,
                    onChanged: (v) => setState(() => _qrData = v),
                  ),
                  buttonLabel: 'GENERATE CODE',
                  buttonIcon: Icons.qr_code_2,
                  buttonColor: Colors.blue[600]!,
                  emptyMessage: 'Please enter data for your QR code first',
                  foregroundColor: _foregroundColor,
                  backgroundColor: _backgroundColor,
                  eyeStyle: _eyeStyle,
                  bodyStyle: _bodyStyle,
                  logoImage: _logoImage,
                  logoPosition: _logoPosition,
                  onForegroundChanged: (c) =>
                      setState(() => _foregroundColor = c),
                  onBackgroundChanged: (c) =>
                      setState(() => _backgroundColor = c),
                  onEyeShapeChanged: (s) => setState(() => _eyeStyle = s),
                  onBodyShapeChanged: (s) => setState(() => _bodyStyle = s),
                  onLogoChanged: (img) => setState(() => _logoImage = img),
                  onLogoPositionChanged: (pos) =>
                      setState(() => _logoPosition = pos),
                  transformQrData: (data) =>
                      data.startsWith('http://') || data.startsWith('https://')
                          ? data
                          : 'https://$data',
                  onReset: () => setState(() {
                    _qrData = '';
                    _urlController.clear();
                    _resetAppearance();
                  }),
                )
              else if (_selectedType == QrCreateType.wifi)
                QrTabShell(
                  qrData: _wifiQrData,
                  inputWidget: WifiCreate(
                    onChanged: (v) => setState(() => _wifiQrData = v),
                  ),
                  buttonLabel: 'GENERATE WIFI QR',
                  buttonIcon: Icons.wifi,
                  buttonColor: Colors.teal[600]!,
                  emptyMessage: 'Please fill in the network name first',
                  foregroundColor: _foregroundColor,
                  backgroundColor: _backgroundColor,
                  eyeStyle: _eyeStyle,
                  bodyStyle: _bodyStyle,
                  logoImage: _logoImage,
                  logoPosition: _logoPosition,
                  onForegroundChanged: (c) =>
                      setState(() => _foregroundColor = c),
                  onBackgroundChanged: (c) =>
                      setState(() => _backgroundColor = c),
                  onEyeShapeChanged: (s) => setState(() => _eyeStyle = s),
                  onBodyShapeChanged: (s) => setState(() => _bodyStyle = s),
                  onLogoChanged: (img) => setState(() => _logoImage = img),
                  onLogoPositionChanged: (pos) =>
                      setState(() => _logoPosition = pos),
                  onReset: () => setState(() {
                    _wifiQrData = '';
                    _resetAppearance();
                  }),
                )
              else if (_selectedType == QrCreateType.contact)
                QrTabShell(
                  qrData: _contactQrData,
                  inputWidget: ContactCreate(
                    onChanged: (v) => setState(() => _contactQrData = v),
                  ),
                  buttonLabel: 'GENERATE SOCIAL QR',
                  buttonIcon: Icons.contact_page_outlined,
                  buttonColor: Colors.orange[700]!,
                  emptyMessage: 'Please enter your username first',
                  foregroundColor: _foregroundColor,
                  backgroundColor: _backgroundColor,
                  eyeStyle: _eyeStyle,
                  bodyStyle: _bodyStyle,
                  logoImage: _logoImage,
                  logoPosition: _logoPosition,
                  onForegroundChanged: (c) =>
                      setState(() => _foregroundColor = c),
                  onBackgroundChanged: (c) =>
                      setState(() => _backgroundColor = c),
                  onEyeShapeChanged: (s) => setState(() => _eyeStyle = s),
                  onBodyShapeChanged: (s) => setState(() => _bodyStyle = s),
                  onLogoChanged: (img) => setState(() => _logoImage = img),
                  onLogoPositionChanged: (pos) =>
                      setState(() => _logoPosition = pos),
                  onReset: () => setState(() {
                    _contactQrData = '';
                    _resetAppearance();
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
