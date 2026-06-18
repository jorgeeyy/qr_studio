import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_studio/utils/image_utils.dart';
import 'package:qr_studio/screens/main/scanned_result_screen.dart';

// Decoupled Widgets
import 'package:qr_studio/widgets/scanscreen_widgets/scanner_overlay_painter.dart';
import 'package:qr_studio/widgets/scanscreen_widgets/scanner_laser_line.dart';
import 'package:qr_studio/widgets/scanscreen_widgets/scanner_instruction_text.dart';
import 'package:qr_studio/widgets/scanscreen_widgets/scanner_control_dock.dart';
import 'package:qr_studio/widgets/scanscreen_widgets/scanner_error_view.dart';

class ScanScreen extends ConsumerStatefulWidget {
  final bool isActive;
  const ScanScreen({super.key, this.isActive = true});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  MobileScannerController? _scannerController;
  bool _isFlashOn = false;
  bool _hasScanned = false; // debounce guard
  late AnimationController _animationController;
  late Animation<double> _laserAnimation;
  bool _permissionGranted = false;

  /// Single-flight lock — prevents concurrent calls to Permission.camera.request().
  /// Any call to [_checkAndInitScanner] while a check is already in-flight
  /// will simply await the same Future instead of firing a second OS dialog.
  Future<void>? _permissionFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.isActive) {
      _checkAndInitScanner();
    }

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

  @override
  void didUpdateWidget(covariant ScanScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _checkAndInitScanner();
      } else {
        _deinitScanner();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.isActive) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _checkAndInitScanner();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _deinitScanner();
        break;
    }
  }

  // ── Torch ────────────────────────────────────────────────────────────────

  Future<void> _toggleFlash() async {
    try {
      if (_scannerController == null) return;
      await _scannerController!.toggleTorch();
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

    // ── Preprocess image for better QR detection ──
    final bytes = await image.readAsBytes();
    final processedBytes = await compute(preprocessForQrDetection, bytes);

    // Save to temp file for analyzeImage
    final tempDir = Directory.systemTemp;
    final tempFile = await File(
      '${tempDir.path}/qr_preprocessed_${DateTime.now().millisecondsSinceEpoch}.png',
    ).create();
    await tempFile.writeAsBytes(processedBytes);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _buildDecodingDialog(),
    );

    final controllerForAnalyze =
        _scannerController ?? MobileScannerController();
    final BarcodeCapture? capture = await controllerForAnalyze.analyzeImage(
      tempFile.path,
    );

    if (_scannerController == null) {
      await controllerForAnalyze.dispose();
    }

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

  // ── Scan success handler ──────────────────────────────────────────────────

  Future<void> _handleScanSuccess(String data) async {
    if (_hasScanned) return;
    _hasScanned = true;

    await HapticFeedback.mediumImpact();
    await _scannerController?.stop();

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ScannedResultScreen(data: data)),
    );

    if (mounted) {
      _hasScanned = false;
      await _scannerController?.start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Camera feed ────────────────────────────────────────────────────
        Positioned.fill(
          child: _permissionGranted
              ? MobileScanner(
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
                        await _scannerController?.stop();
                        await _scannerController?.start();
                      },
                    );
                  },
                )
              : _buildPermissionRequestView(),
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
          onFlashlightTap: _toggleFlash,
          isFlashOn: _isFlashOn,
        ),
      ],
    );
  }

  Widget _buildPermissionRequestView() {
    return Container(
      color: const Color(0xFF0A0A0F),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Camera permission required to scan QR codes.',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final opened = await openAppSettings();
                if (!opened && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Could not open settings. Please enable camera permission manually.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Grant Camera Permission'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Permission handling (single-flight) ───────────────────────────────────

  Future<void> _checkAndInitScanner() {
    if (_permissionGranted) return Future.value();
    _permissionFuture ??= _doPermissionCheck().whenComplete(
      () => _permissionFuture = null,
    );
    return _permissionFuture!;
  }

  Future<void> _doPermissionCheck() async {
    try {
      final status = await Permission.camera.status;
      if (status.isPermanentlyDenied) {
        if (mounted) setState(() => _permissionGranted = false);
        return;
      }

      if (status.isDenied) {
        final result = await Permission.camera.request();
        if (result.isPermanentlyDenied || result.isDenied) {
          if (mounted) setState(() => _permissionGranted = false);
          return;
        }
      }

      // Always attempt to init — let the controller itself fail if no permission
      await _initScannerController();

      final fresh = await Permission.camera.status;
      if (mounted) {
        setState(() => _permissionGranted = fresh.isGranted || fresh.isLimited);
      }
    } catch (e) {
      debugPrint('Permission check failed: $e');
      if (mounted) setState(() => _permissionGranted = false);
    }
  }

  Future<void> _initScannerController() async {
    if (_scannerController != null) return;

    _scannerController = MobileScannerController(
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.normal,
    );

    _scannerController!.addListener(_onTorchStateChanged);

    if (mounted) {
      setState(() {
        _isFlashOn = false;
      });
    }
  }

  void _onTorchStateChanged() {
    if (_scannerController == null) return;
    final state = _scannerController!.value.torchState;
    final isOn = state == TorchState.on;
    if (isOn != _isFlashOn && mounted) {
      setState(() {
        _isFlashOn = isOn;
      });
    }
  }

  Future<void> _deinitScanner() async {
    if (_scannerController != null) {
      _scannerController!.removeListener(_onTorchStateChanged);
      await _scannerController!.dispose();
      _scannerController = null;
    }
    if (mounted) {
      setState(() {
        _permissionGranted = false;
        _isFlashOn = false;
      });
    }
  }
}
