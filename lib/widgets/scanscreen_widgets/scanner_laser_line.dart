import 'package:flutter/material.dart';

class ScannerLaserLine extends StatelessWidget {
  final Animation<double> laserAnimation;

  const ScannerLaserLine({super.key, required this.laserAnimation});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double scanWidth = 250;
          const double scanHeight = 250;
          final double left = (constraints.maxWidth - scanWidth) / 2;
          final double top = (constraints.maxHeight - scanHeight) / 2;

          return Stack(
            children: [
              Positioned(
                left: left,
                top: top,
                width: scanWidth,
                height: scanHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      AnimatedBuilder(
                        animation: laserAnimation,
                        builder: (context, child) {
                          return Positioned(
                            top: 10 + (laserAnimation.value * 230),
                            left: 10,
                            right: 10,
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
