import 'package:flutter/material.dart';

/// Small circular badge displaying a single letter (e.g. 'A' for pickup, 'B' for dropoff).
class LetterBadge extends StatelessWidget {
  const LetterBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    this.size = 18.0,
  });

  final String label;
  final Color backgroundColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}
