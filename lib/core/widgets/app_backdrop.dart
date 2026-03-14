import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class AppBackdrop extends StatelessWidget {
  final Widget child;

  const AppBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    final baseGradient = isLight ? AppColors.lightSurfaceGradient : AppColors.surfaceGradient;
    final glow = isLight ? AppColors.lightAmbientGlowGradient : AppColors.ambientGlowGradient;

    final screenSize = MediaQuery.sizeOf(context);
    
    return Stack(
      children: [
        // Fixed size background to prevent resize repaints during keyboard animation
        SizedBox(
          width: screenSize.width,
          height: screenSize.height,
          child: RepaintBoundary(
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(decoration: BoxDecoration(gradient: baseGradient)),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(decoration: BoxDecoration(gradient: glow)),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            (isLight ? const Color(0x1A5B7C8A) : const Color(0x165B7C8A)),
                            isLight ? const Color(0x00FFFFFF) : const Color(0x000D0F12),
                          ],
                          radius: 1.1,
                          center: const Alignment(0.8, 0.9),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}

