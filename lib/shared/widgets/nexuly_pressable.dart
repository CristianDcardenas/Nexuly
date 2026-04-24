import 'package:flutter/material.dart';

class NexulyPressable extends StatefulWidget {
  const NexulyPressable({
    required this.child,
    required this.onTap,
    this.borderRadius,
    super.key,
  });

  final Widget child;
  final VoidCallback onTap;
  final BorderRadius? borderRadius;

  @override
  State<NexulyPressable> createState() => _NexulyPressableState();
}

class _NexulyPressableState extends State<NexulyPressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          borderRadius: widget.borderRadius,
          child: InkWell(
            borderRadius: widget.borderRadius,
            onTap: widget.onTap,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
