import 'package:flutter/material.dart';

/// Icono "G" oficial de Google dibujado con CustomPaint.
/// Evita depender de un asset PNG/SVG externo.
class GoogleLogoIcon extends StatelessWidget {
  const GoogleLogoIcon({this.size = 20, super.key});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paths = <({String color, List<Offset> points})>[];

    // Versión simplificada: 4 arcos de colores Google en una circunferencia
    // con "G" minimalista. Es un buen compromiso entre fidelidad y código.
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    // Paths de la G oficial (con SVG path scaling)
    _drawArc(canvas, center, radius, 0, 90, const Color(0xFF4285F4)); // Azul
    _drawArc(canvas, center, radius, 90, 90, const Color(0xFF34A853)); // Verde
    _drawArc(canvas, center, radius, 180, 90, const Color(0xFFFBBC05)); // Amarillo
    _drawArc(canvas, center, radius, 270, 90, const Color(0xFFEA4335)); // Rojo

    // "Hueco" blanco interior para que parezca "G"
    final inner = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.55, inner);

    // Barra horizontal azul (brazo de la G)
    final bar = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - radius * 0.1, radius, radius * 0.2),
      bar,
    );
  }

  void _drawArc(Canvas canvas, Offset center, double radius,
      double startDeg, double sweepDeg, Color color) {
    final paint = Paint()..color = color;
    const k = 3.14159265 / 180;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startDeg * k,
      sweepDeg * k,
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
