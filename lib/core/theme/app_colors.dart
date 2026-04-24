import 'package:flutter/material.dart';

/// Paleta de colores de Nexuly, alineada 1:1 con el mockup React/Tailwind.
///
/// Los nombres coinciden con los de Tailwind CSS (violet-500, purple-600, etc)
/// para que cualquier traducción del mockup sea directa.
abstract class AppColors {
  AppColors._();

  // --- Violet ramp (marca principal) ---
  static const Color violet50 = Color(0xFFF5F3FF);
  static const Color violet100 = Color(0xFFEDE9FE);
  static const Color violet200 = Color(0xFFDDD6FE);
  static const Color violet400 = Color(0xFFA78BFA);
  static const Color violet500 = Color(0xFF8B5CF6);
  static const Color violet600 = Color(0xFF7C3AED);
  static const Color violet700 = Color(0xFF6D28D9);

  // --- Purple ramp (complementario del gradiente) ---
  static const Color purple100 = Color(0xFFF3E8FF);
  static const Color purple500 = Color(0xFFA855F7);
  static const Color purple600 = Color(0xFF9333EA);
  static const Color purple700 = Color(0xFF7E22CE);

  // --- Grises (fondos, bordes, texto secundario) ---
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // --- Semánticos ---
  static const Color successBg = Color(0xFFDCFCE7); // green-100
  static const Color success = Color(0xFF16A34A); // green-600
  static const Color successText = Color(0xFF15803D); // green-700

  static const Color warningBg = Color(0xFFFEF3C7); // amber-100
  static const Color warning = Color(0xFFF59E0B); // amber-500
  static const Color warningText = Color(0xFFB45309); // amber-700

  static const Color infoBg = Color(0xFFDBEAFE); // blue-100
  static const Color info = Color(0xFF3B82F6); // blue-500
  static const Color infoText = Color(0xFF1D4ED8); // blue-700

  static const Color dangerBg = Color(0xFFFEE2E2); // red-100
  static const Color danger = Color(0xFFEF4444); // red-500
  static const Color dangerText = Color(0xFFDC2626); // red-600

  // --- Colores de servicios del Home ---
  static const Color redBg = Color(0xFFFEE2E2); // red-100
  static const Color redFg = Color(0xFFDC2626); // red-600
  static const Color violetServiceBg = Color(0xFFEDE9FE); // violet-100
  static const Color violetServiceFg = Color(0xFF7C3AED); // violet-600
  static const Color greenBg = Color(0xFFDCFCE7);
  static const Color greenFg = Color(0xFF16A34A);
  static const Color purpleBg = Color(0xFFF3E8FF);
  static const Color purpleFg = Color(0xFF9333EA);

  // --- Fondos ---
  static const Color background = Color(0xFFF9FAFB); // gray-50
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE5E7EB); // gray-200

  // --- Gradiente principal (login, welcome card, CTAs) ---
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [violet500, purple500, violet600],
  );

  /// Versión sólo 2 colores (más limpia para botones).
  static const LinearGradient brandGradientButton = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [violet600, purple600],
  );

  /// Gradiente suave para cards tipo "welcome".
  static const LinearGradient brandGradientSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [violet500, purple500],
  );
}
