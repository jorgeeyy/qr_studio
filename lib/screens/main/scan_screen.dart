import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:pretty_qr_code/pretty_qr_code.dart';
// import 'package:qr_studio/models/qr_history_item.dart';
// import 'package:qr_studio/providers/history_provider.dart';
// import 'package:qr_studio/utils/qr_shapes.dart';
import 'package:qr_studio/utils/image_utils.dart';
import 'package:qr_studio/screens/main/scanned_result_screen.dart';

// Decoupled Widgets
import 'package:qr_studio/widgets/scanscreen_widgets/scanner_overlay_painter.dart';
import 'package:qr_studio/widgets/scanscreen_widgets/scanner_laser_line.dart';
import 'package:qr_studio/widgets/scanscreen_widgets/scanner_instruction_text.dart';
import 'package:qr_studio/widgets/scanscreen_widgets/scanner_control_dock.dart';
import 'package:qr_studio/widgets/scanscreen_widgets/scanner_error_view.dart';

bool get _isNativeScanSupported =>
    !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

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
    if (!_isNativeScanSupported) return; // no torch on desktop
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

    if (_isNativeScanSupported) {
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
        // dispose temporary controller if we created one
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
    } else {
      // ── Simulation fallback on Windows / Linux ─────────────────────────
      if (!mounted) return;
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
      await _scannerController?.stop();
    }

    // final historyItem = QrHistoryItem(
    //   id: DateTime.now().millisecondsSinceEpoch.toString(),
    //   qrData: data,
    //   createdAt: DateTime.now(),
    //   foregroundColor: Colors.blue,
    //   backgroundColor: Colors.white,
    //   eyeStyle: QrStyle.square,
    //   bodyStyle: QrStyle.square,
    //   logoPosition: PrettyQrDecorationImagePosition.embedded,
    // );
    // await ref.read(historyProvider.notifier).addItem(historyItem);

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ScannedResultScreen(data: data)),
    );

    if (mounted) {
      _hasScanned = false;
      if (_isNativeScanSupported) {
        await _scannerController?.start();
      }
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
        // ── Camera feed or desktop placeholder ─────────────────────────────
        if (_isNativeScanSupported)
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
          // onCenterTap: _isNativeScanSupported ? () {} : _showSimulationSheet,
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

  /// Public entry point. Safe to call multiple times concurrently — subsequent
  /// calls while a check is already running will await the same [Future].
  Future<void> _checkAndInitScanner({bool forceRequest = false}) {
    if (!_isNativeScanSupported) return Future.value();
    _permissionFuture ??= _doPermissionCheck(
      forceRequest,
    ).whenComplete(() => _permissionFuture = null);
    return _permissionFuture!;
  }

  /// The actual permission + init work. Only ever runs one at a time thanks to
  /// the [_permissionFuture] lock in [_checkAndInitScanner].

  Future<void> _doPermissionCheck(bool forceRequest) async {
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
    debugPrint('🎥 _initScannerController called — existing: $_scannerController');
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
    debugPrint('🎥 controller created, widget will call start()');
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
