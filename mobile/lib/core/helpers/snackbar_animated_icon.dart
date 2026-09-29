import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

enum SnackbarVariant { success, error, warning, info }

/// Animated circular orb with status icon ported from done_app snackbar.
class SnackbarAnimatedIcon extends StatefulWidget {
  final Color accentColor;
  final IconData icon;
  final SnackbarVariant variant;
  final Color shellColor;

  const SnackbarAnimatedIcon({
    super.key,
    required this.accentColor,
    required this.icon,
    required this.variant,
    this.shellColor = const Color(0xFF303746),
  });

  @override
  State<SnackbarAnimatedIcon> createState() => _SnackbarAnimatedIconState();
}

class _SnackbarAnimatedIconState extends State<SnackbarAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: widget.variant == SnackbarVariant.error ? 520 : 420,
      ),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.shellColor,
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.accentColor,
            ),
            child: Icon(widget.icon, color: Colors.white, size: 14),
          ),
          builder: (context, child) {
            final progress = _controller.value;
            final rotation = widget.variant == SnackbarVariant.success
                ? (lerpDouble(-0.34, 0, Curves.easeOutBack.transform(progress)) ?? 0)
                : (widget.variant == SnackbarVariant.error
                    ? math.sin(progress * math.pi * 5) * (1 - progress) * 0.22
                    : 0.0);
            final horizontalOffset = widget.variant == SnackbarVariant.error
                ? math.sin(progress * math.pi * 5) * (1 - progress) * 4
                : 0.0;
            final scale = 0.6 + (Curves.easeOutBack.transform(progress) * 0.4);

            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset: Offset(horizontalOffset, 0),
                child: Transform.rotate(
                  angle: rotation,
                  child: Transform.scale(scale: scale, child: child),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
