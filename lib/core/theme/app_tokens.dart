/// Tokens de diseño de Nexuly. Alineados con el mockup (Tailwind rounded-2xl = 16px).
abstract class AppRadii {
  AppRadii._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16; // el más usado — "rounded-2xl" de Tailwind
  static const double xl = 24;
  static const double xxl = 32; // rounded-t-[32px] del login
  static const double pill = 999;
}

abstract class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}
