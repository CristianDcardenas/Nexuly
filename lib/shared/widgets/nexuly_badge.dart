import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

/// Badge pequeño con ícono opcional. Uso: "Disponible", "4.9", "Verificado".
class NexulyBadge extends StatelessWidget {
  const NexulyBadge({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.icon,
    this.iconColor,
    this.dot = false,
    this.dotColor,
    super.key,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData? icon;
  final Color? iconColor;
  final bool dot;
  final Color? dotColor;

  const NexulyBadge.success({
    required String label,
    Key? key,
    IconData? icon,
    bool dot = false,
  }) : this(
          label: label,
          backgroundColor: AppColors.successBg,
          foregroundColor: AppColors.successText,
          icon: icon,
          dot: dot,
          dotColor: AppColors.success,
          key: key,
        );

  const NexulyBadge.warning({
    required String label,
    Key? key,
    IconData? icon,
  }) : this(
          label: label,
          backgroundColor: AppColors.warningBg,
          foregroundColor: AppColors.warningText,
          icon: icon,
          key: key,
        );

  const NexulyBadge.neutral({
    required String label,
    Key? key,
    IconData? icon,
  }) : this(
          label: label,
          backgroundColor: AppColors.gray100,
          foregroundColor: AppColors.gray600,
          icon: icon,
          key: key,
        );

  const NexulyBadge.primary({
    required String label,
    Key? key,
    IconData? icon,
  }) : this(
          label: label,
          backgroundColor: AppColors.violet100,
          foregroundColor: AppColors.violet700,
          icon: icon,
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor ?? foregroundColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          if (icon != null) ...[
            Icon(icon, size: 12, color: iconColor ?? foregroundColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
