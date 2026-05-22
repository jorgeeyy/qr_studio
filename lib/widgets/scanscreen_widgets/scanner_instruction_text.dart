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
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1.0,
                ),
              ),
              child: const Text(
                'Align QR code within the frame to scan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
