import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    required this.onPressed,
    this.isLoading = false,
    this.label = 'Continuar con Google',
    super.key,
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo de Google con colores oficiales
                  CustomPaint(
                    size: const Size(20, 20),
                    painter: _GoogleLogoPainter(),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Dibuja el logo de Google con sus 4 colores oficiales, evitando depender
/// de un asset externo.
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paints = [
      Paint()..color = const Color(0xFF4285F4), // Azul
      Paint()..color = const Color(0xFFEA4335), // Rojo
      Paint()..color = const Color(0xFFFBBC05), // Amarillo
      Paint()..color = const Color(0xFF34A853), // Verde
    ];

    final rect = Rect.fromCircle(center: center, radius: radius);

    // 4 cuartos de círculo con los 4 colores
    for (var i = 0; i < 4; i++) {
      canvas.drawArc(
        rect,
        (i * 90) * 3.14159 / 180,
        90 * 3.14159 / 180,
        true,
        paints[i],
      );
    }

    // Círculo blanco interior para que parezca una "G"
    canvas.drawCircle(
      center,
      radius * 0.5,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
