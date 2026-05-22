import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr_studio/models/qr_history_item.dart';
import 'package:qr_studio/providers/history_provider.dart';
import 'package:qr_studio/utils/qr_shapes.dart';
import 'package:qr_studio/screens/main/scanned_result_screen.dart';

// Decoupled Widgets
import 'package:qr_studio/widgets/scanscreen_widgets/scanner_overlay_painter.dart';
import 'package:qr_studio/widgets/scanscreen_widgets/scanner_laser_line.dart';
import 'package:qr_studio/widgets/scanscreen_widgets/scanner_instruction_text.dart';
import 'package:qr_studio/widgets/scanscreen_widgets/scanner_control_dock.dart';
import 'package:qr_studio/widgets/scanscreen_widgets/scanner_error_view.dart';

/// Returns true on platforms where [mobile_scanner] has native QR detection.
/// Windows and Linux are NOT supported by the package.
bool get _isNativeScanSupported =>
    !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen>
    with SingleTickerProviderStateMixin {
  late MobileScannerController _scannerController;
  bool _isFlashOn = false;
  bool _hasScanned = false; // debounce guard
  late AnimationController _animationController;
  late Animation<double> _laserAnimation;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.normal,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _laserAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    _animationController.repeat(reverse: true);
  }

  // ── Torch ────────────────────────────────────────────────────────────────

  Future<void> _toggleFlash() async {
    if (!_isNativeScanSupported) return; // no torch on desktop
    try {
      await _scannerController.toggleTorch();
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      debugPrint('Failed to toggle torch: $e');
    }
  }

  // ── Gallery import ────────────────────────────────────────────────────────

  Future<void> _importFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    if (!mounted) return;

    if (_isNativeScanSupported) {
      // ── Real native decode via mobile_scanner ──────────────────────────
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _buildDecodingDialog(),
      );

      final BarcodeCapture? capture = await _scannerController.analyzeImage(
        image.path,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (capture == null || capture.barcodes.isEmpty) {
        _showNoQrFoundSnackbar();
        return;
      }

      final rawValue = capture.barcodes.first.rawValue;
      if (rawValue != null && rawValue.isNotEmpty) {
        await _handleScanSuccess(rawValue);
      } else {
        _showNoQrFoundSnackbar();
      }
    } else {
      // ── Simulation fallback on Windows / Linux ─────────────────────────
      _showSimulationSheet(
        title: 'Gallery Image (Simulated)',
        defaultData: 'https://qr-studio.app/gallery-imported-code',
      );
    }
  }

  Widget _buildDecodingDialog() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(strokeWidth: 3),
                SizedBox(height: 24),
                Text(
                  'Decoding QR Code...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNoQrFoundSnackbar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('No QR code found in the selected image.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Simulation (Windows / Linux fallback) ─────────────────────────────────

  void _showSimulationSheet({
    String title = 'Manual Scan Trigger',
    String defaultData = 'https://qr-studio.app/manual-scan',
  }) {
    final controller = TextEditingController(text: defaultData);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'QR scanning is not supported on Windows/Linux desktop. Enter the content you want to simulate as scanned to test the full app flow.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Scanned Content',
                    hintText: 'Enter URL, text, or details',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    final data = controller.text.trim();
                    Navigator.pop(context);
                    if (data.isNotEmpty) {
                      _handleScanSuccess(data);
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Simulate Scan Success'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Scan success handler ──────────────────────────────────────────────────

  Future<void> _handleScanSuccess(String data) async {
    if (_hasScanned) return;
    _hasScanned = true;

    await HapticFeedback.mediumImpact();

    if (_isNativeScanSupported) {
      await _scannerController.stop();
    }

    final historyItem = QrHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      qrData: data,
      createdAt: DateTime.now(),
      foregroundColor: Colors.blue,
      backgroundColor: Colors.white,
      eyeStyle: QrStyle.square,
      bodyStyle: QrStyle.square,
      logoPosition: PrettyQrDecorationImagePosition.embedded,
    );
    await ref.read(historyProvider.notifier).addItem(historyItem);

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ScannedResultScreen(data: data)),
    );

    if (mounted) {
      _hasScanned = false;
      if (_isNativeScanSupported) {
        await _scannerController.start();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Camera feed or desktop placeholder ─────────────────────────────
        if (_isNativeScanSupported)
          Positioned.fill(
            child: MobileScanner(
              controller: _scannerController,
              fit: BoxFit.cover,
              onDetect: (BarcodeCapture capture) {
                final rawValue = capture.barcodes.firstOrNull?.rawValue;
                if (rawValue != null && rawValue.isNotEmpty) {
                  _handleScanSuccess(rawValue);
                }
              },
              errorBuilder: (context, error) {
                return ScannerErrorView(
                  errorMessage:
                      error.errorDetails?.message ??
                      'Failed to start camera. Please grant camera permissions.',
                  onRetryTap: () async {
                    await _scannerController.stop();
                    await _scannerController.start();
                  },
                );
              },
            ),
          )
        else
          // Windows / Linux — dark background with a "simulation" label
          Positioned.fill(
            child: Container(
              color: const Color(0xFF0A0A0F),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.desktop_windows_outlined,
                      size: 48,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Camera scanning unavailable on Windows',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap the QR button below to simulate a scan',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.2),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // ── Dark overlay with 250×250 cutout + glowing corners ─────────────
        const Positioned.fill(
          child: CustomPaint(painter: ScannerOverlayPainter()),
        ),

        // ── Animated laser line inside the cutout ──────────────────────────
        ScannerLaserLine(laserAnimation: _laserAnimation),

        // ── "Point at a QR code" instruction text ─────────────────────────
        const ScannerInstructionText(),

        // ── Bottom floating control dock ───────────────────────────────────
        ScannerControlDock(
          onGalleryTap: _importFromGallery,
          // On native: camera scans automatically — center button does nothing.
          // On Windows: center button triggers the simulation sheet.
          onCenterTap: _isNativeScanSupported ? () {} : _showSimulationSheet,
          onFlashlightTap: _toggleFlash,
          isFlashOn: _isFlashOn,
        ),
      ],
    );
  }
}
