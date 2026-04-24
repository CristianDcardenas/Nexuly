import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

/// Logo "N" de Nexuly. Dos variantes:
/// - `onDark = true` → fondo translúcido blanco (sobre gradiente morado)
/// - `onDark = false` → fondo con gradiente morado (sobre superficies blancas)
class NexulyLogo extends StatelessWidget {
  const NexulyLogo({
    this.size = 40,
    this.onDark = false,
    this.showName = true,
    this.proLabel = false,
    super.key,
  });

  final double size;
  final bool onDark;
  final bool showName;
  final bool proLabel;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: onDark ? null : AppColors.brandGradientSoft,
        color: onDark ? Colors.white.withValues(alpha: 0.20) : null,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: Text(
        'N',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.5,
        ),
      ),
    );

    if (!showName) return box;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        box,
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Nexuly',
          style: TextStyle(
            color: onDark ? Colors.white : AppColors.gray900,
            fontSize: size * 0.48,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (proLabel) ...[
          const SizedBox(width: 4),
          Text(
            'Pro',
            style: TextStyle(
              color: AppColors.violet600,
              fontSize: size * 0.32,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
