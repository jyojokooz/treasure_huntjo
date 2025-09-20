import 'dart:ui';
import 'package:flutter/material.dart';

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  const GlassmorphicContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            // FIX 1: Replaced deprecated withOpacity
            color: Colors.black.withAlpha((0.2 * 255).round()),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              // FIX 2: Replaced deprecated withOpacity
              color: Colors.white.withAlpha((0.2 * 255).round()),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
