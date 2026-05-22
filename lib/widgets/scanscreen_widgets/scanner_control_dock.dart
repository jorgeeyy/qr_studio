import 'dart:ui';
import 'package:flutter/material.dart';

class ScannerControlDock extends StatelessWidget {
  final VoidCallback onGalleryTap;
  final VoidCallback onCenterTap;
  final VoidCallback onFlashlightTap;
  final bool isFlashOn;

  const ScannerControlDock({
    super.key,
    required this.onGalleryTap,
    required this.onCenterTap,
    required this.onFlashlightTap,
    required this.isFlashOn,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Gallery Button
                _buildActionButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onPressed: onGalleryTap,
                ),
                // Central Rounded Button with QR icon
                _buildCenterQRButton(),
                // Flashlight Button
                _buildActionButton(
                  icon: isFlashOn ? Icons.flash_on : Icons.flash_off_outlined,
                  label: 'Flashlight',
                  color: isFlashOn ? Colors.amber : Colors.white,
                  onPressed: onFlashlightTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterQRButton() {
    return GestureDetector(
      onTap: onCenterTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.35),
              blurRadius: 18,
              spreadRadius: 3,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.qr_code_scanner,
          size: 32,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color color = Colors.white,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: color, size: 28),
          onPressed: onPressed,
          splashRadius: 28,
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
