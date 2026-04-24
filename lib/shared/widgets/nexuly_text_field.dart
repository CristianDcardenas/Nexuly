import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

/// Campo de texto estilo mockup:
/// - Label encima del input
/// - Fondo gris suave que cambia a blanco al hacer focus
/// - Icono prefix opcional, botón suffix opcional
class NexulyTextField extends StatelessWidget {
  const NexulyTextField({
    required this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.validator,
    this.autofillHints,
    this.maxLines = 1,
    this.enabled = true,
    super.key,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;
  final int maxLines;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final labelColor = isDark
        ? theme.colorScheme.onSurfaceVariant
        : AppColors.gray700;
    final textColor = isDark ? theme.colorScheme.onSurface : AppColors.gray700;
    final iconColor = isDark
        ? theme.colorScheme.onSurfaceVariant
        : AppColors.gray400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          autofillHints: autofillHints,
          maxLines: obscureText ? 1 : maxLines,
          enabled: enabled,
          cursorColor: AppColors.violet600,
          style: TextStyle(fontSize: 15, color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.lg,
                      right: AppSpacing.sm,
                    ),
                    child: Icon(prefixIcon, color: iconColor, size: 20),
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 44),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
