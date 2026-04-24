import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/services/qr_payload.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/widgets/nexuly_gradient_button.dart';

/// Pantalla que muestra un QR con el ID del servicio activo para que el
/// profesional escanee al llegar al domicilio (check-in).
///
/// Se accede desde la pantalla "Servicio activo" con el icono de QR.
class ServiceQrScreen extends ConsumerWidget {
  const ServiceQrScreen({
    required this.requestId,
    required this.patientUid,
    required this.serviceId,
    required this.patientName,
    required this.serviceName,
    super.key,
  });

  final String requestId;
  final String patientUid;
  final String serviceId;
  final String patientName;
  final String serviceName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payload = NexulyQrPayload.serviceCheckIn(
      requestId: requestId,
      patientUid: patientUid,
      serviceId: serviceId,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Check-in de servicio'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),

              // --- Hero card con instrucciones ---
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradientSoft,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.qr_code_2,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Muéstrale este código al profesional',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Lo escaneará al llegar a tu domicilio',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // --- QR ---
              Container(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.violet500.withValues(alpha: 0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: payload.encode(),
                  version: QrVersions.auto,
                  size: 240,
                  gapless: true,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.violet700,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.gray900,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // --- Datos del servicio ---
              _InfoRow(icon: Icons.person_outline, label: patientName),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.medical_services_outlined,
                label: serviceName,
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.tag,
                label: 'ID: ${requestId.substring(0, requestId.length.clamp(0, 8))}',
              ),

              const Spacer(),

              NexulyGradientButton(
                label: 'Listo',
                icon: Icons.check,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: AppColors.gray500),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.gray700),
        ),
      ],
    );
  }
}
