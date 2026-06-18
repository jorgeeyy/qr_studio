import 'package:flutter/material.dart';

class ScannerLaserLine extends StatelessWidget {
  final Animation<double> laserAnimation;

  const ScannerLaserLine({super.key, required this.laserAnimation});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double scanSize = 250;
          const double laserInset = 10;
          final double left = (constraints.maxWidth - scanSize) / 2;
          final double top = (constraints.maxHeight - scanSize) / 2;

          return Stack(
            children: [
              Positioned(
                left: left,
                top: top,
                width: scanSize,
                height: scanSize,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      AnimatedBuilder(
                        animation: laserAnimation,
                        builder: (context, child) {
                          final travelRange = scanSize - 2 * laserInset;
                          return Positioned(
                            top: laserInset + (laserAnimation.value * travelRange),
                            left: laserInset,
                            right: laserInset,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withValues(alpha: 0.8),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.blue,
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
