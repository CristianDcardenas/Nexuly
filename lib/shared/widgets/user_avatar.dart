import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Avatar circular que:
/// - Muestra `photoUrl` si está disponible
/// - Si no, muestra iniciales sobre color auto-derivado del nombre
///
/// El color es determinístico (mismo nombre → mismo color siempre).
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    required this.name,
    this.photoUrl,
    this.size = 40,
    this.textStyle,
    super.key,
  });

  final String name;
  final String? photoUrl;
  final double size;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      if (photoUrl!.startsWith('data:image/')) {
        final comma = photoUrl!.indexOf(',');
        if (comma != -1) {
          final bytes = base64Decode(photoUrl!.substring(comma + 1));
          return CircleAvatar(
            radius: size / 2,
            backgroundImage: MemoryImage(bytes),
            backgroundColor: AppColors.gray200,
          );
        }
      }
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(photoUrl!),
        backgroundColor: AppColors.gray200,
      );
    }
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: _colorFromName(name),
      child: Text(
        _initials(name),
        style:
            textStyle ??
            TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: size * 0.38,
            ),
      ),
    );
  }

  static String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  static Color _colorFromName(String name) {
    // Paleta que combina con el branding (evitamos rojo, rosa y azul eléctrico
    // que confunden con estados semánticos).
    const palette = <Color>[
      AppColors.violet600,
      AppColors.purple600,
      AppColors.info,
      Color(0xFF14B8A6), // teal-500
      Color(0xFF0EA5E9), // sky-500
      Color(0xFFF59E0B), // amber-500
      Color(0xFF10B981), // emerald-500
      Color(0xFFEC4899), // pink-500
    ];
    var hash = 0;
    for (final codeUnit in name.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7FFFFFFF;
    }
    return palette[hash % palette.length];
  }
}
