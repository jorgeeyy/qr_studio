import 'dart:ui';
import 'package:flutter/material.dart';

class ScannerInstructionText extends StatelessWidget {
  const ScannerInstructionText({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 32,
      left: 24,
      right: 24,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: const Text(
              'Align QR code within the frame to scan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
