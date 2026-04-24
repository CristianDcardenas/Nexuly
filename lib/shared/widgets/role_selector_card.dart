import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

/// Tarjeta cuadrada seleccionable (icon + label). Dos se usan en grid 2×1
/// para la selección de rol en la pantalla de login.
class RoleSelectorCard extends StatelessWidget {
  const RoleSelectorCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            color: selected ? AppColors.violet50 : Colors.white,
            border: Border.all(
              color: selected ? AppColors.violet600 : AppColors.gray200,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 26,
                color: selected ? AppColors.violet600 : AppColors.gray400,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: selected ? AppColors.violet700 : AppColors.gray600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
