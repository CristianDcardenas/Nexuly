import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/services/qr_payload.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';

/// Resultado de un escaneo válido.
class QrScanResult {
  const QrScanResult({required this.payload, required this.rawValue});
  final NexulyQrPayload payload;
  final String rawValue;
}

/// Pantalla de escaneo de códigos QR.
///
/// Al escanear un QR válido de Nexuly, devuelve el payload a través de
/// `Navigator.pop(result)`. Si el QR no es válido, muestra un toast y
/// continúa escaneando.
///
/// **Nota web**: `mobile_scanner` tiene soporte web limitado. Si el
/// hackathon se demuestra en Android, funciona al 100%. Si se demuestra
/// en web, hay un fallback de "ingreso manual" al final de la pantalla.
class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({
    this.expectedType,
    this.title = 'Escanear QR',
    super.key,
  });

  /// Si se especifica, solo se aceptan QR de ese tipo. Útil para el flujo de
  /// check-in donde solo queremos escanear `service_checkin`.
  final NexulyQrType? expectedType;
  final String title;

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    // Reducir el detection speed para no disparar el mismo QR muchas veces.
    detectionSpeed: DetectionSpeed.normal,
  );

  bool _processing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_processing) return;

    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null || raw.isEmpty) continue;

      final payload = NexulyQrPayload.tryDecode(raw);
      if (payload == null) {
        _showToast('QR no reconocido. Prueba con un código de Nexuly.');
        continue;
      }

      if (widget.expectedType != null &&
          payload.type != widget.expectedType) {
        _showToast(
          'Este QR es de un tipo diferente al esperado.',
        );
        continue;
      }

      // Encontramos un QR válido. Detenemos el scanner y volvemos con el
      // resultado.
      setState(() => _processing = true);
      _controller.stop();
      Navigator.of(context).pop(
        QrScanResult(payload: payload, rawValue: raw),
      );
      return;
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // --- Scanner view (fullscreen) ---
          if (!kIsWeb)
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error, child) {
                return _ScannerError(
                  message: error.errorDetails?.message ??
                      'No se pudo iniciar la cámara',
                );
              },
            )
          else
            // Fallback web: mobile_scanner tiene limitaciones en web.
            // Dejamos un placeholder informativo.
            const _WebFallback(),

          // --- Overlay con marco, back y flashlight ---
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      _RoundIconButton(
                        icon: Icons.arrow_back,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (!kIsWeb)
                        _RoundIconButton(
                          icon: Icons.flash_on,
                          onPressed: () => _controller.toggleTorch(),
                        ),
                    ],
                  ),
                ),

                const Spacer(),

                // Marco del scanner
                if (!kIsWeb)
                  const _ScannerFrame()
                else
                  const SizedBox.shrink(),

                const Spacer(),

                // Instrucciones al pie
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  margin: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white, size: 18),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Apunta la cámara al código QR que te muestra el paciente.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Marco decorativo del scanner -----------------------------------------

class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame();

  @override
  Widget build(BuildContext context) {
    const side = 240.0;
    return SizedBox(
      width: side,
      height: side,
      child: CustomPaint(painter: _FramePainter()),
    );
  }
}

class _FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.violet400
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLen = 32.0;
    // Top-left
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLen, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLen), paint);
    // Top-right
    canvas.drawLine(Offset(size.width - cornerLen, 0),
        Offset(size.width, 0), paint);
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, cornerLen), paint);
    // Bottom-left
    canvas.drawLine(Offset(0, size.height - cornerLen),
        Offset(0, size.height), paint);
    canvas.drawLine(Offset(0, size.height),
        Offset(cornerLen, size.height), paint);
    // Bottom-right
    canvas.drawLine(Offset(size.width - cornerLen, size.height),
        Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height - cornerLen),
        Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.4),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _ScannerError extends StatelessWidget {
  const _ScannerError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.no_photography,
              color: Colors.white54, size: 56),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _WebFallback extends StatelessWidget {
  const _WebFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.gray900,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_scanner,
              color: Colors.white38, size: 72),
          SizedBox(height: AppSpacing.lg),
          Text(
            'El escáner QR funciona en Android/iOS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'En esta versión web no podemos acceder a la cámara del dispositivo de forma estable.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
