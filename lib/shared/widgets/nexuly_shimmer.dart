import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

class NexulyShimmer extends StatefulWidget {
  const NexulyShimmer({
    required this.width,
    required this.height,
    this.borderRadius = AppRadii.md,
    super.key,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<NexulyShimmer> createState() => _NexulyShimmerState();
}

class _NexulyShimmerState extends State<NexulyShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1 + (_controller.value * 2), 0),
              end: Alignment(1 + (_controller.value * 2), 0),
              colors: const [
                AppColors.gray100,
                AppColors.gray200,
                AppColors.gray100,
              ],
            ),
          ),
        );
      },
    );
  }
}
