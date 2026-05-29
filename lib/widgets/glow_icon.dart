import 'package:flutter/material.dart';

class GlowIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final Color glowColor;
  final double glowRadius;

  const GlowIcon({
    Key? key,
    required this.icon,
    this.size = 24,
    required this.color,
    required this.glowColor,
    this.glowRadius = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect behind the icon
        Icon(
          icon,
          size: size,
          color: glowColor.withOpacity(0.4),
        ),
        Icon(
          icon,
          size: size,
          color: color,
          shadows: [
            Shadow(
              color: glowColor.withOpacity(0.8),
              blurRadius: glowRadius,
            ),
          ],
        ),
      ],
    );
  }
}
