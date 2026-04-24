import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/enums/domain_enums.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/qr_payload.dart';
import '../../../core/services/service_evidence_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/repositories/service_requests_repository.dart';
import '../../../shared/widgets/nexuly_gradient_button.dart';

/// Pantalla que se muestra después de escanear un QR de Nexuly.
/// Presenta los datos y permite al usuario confirmar la acción.
class QrScanResultScreen extends ConsumerWidget {
  const QrScanResultScreen({required this.payload, super.key});

  final NexulyQrPayload payload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Código QR escaneado'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xxl),

              // --- Check de confirmación ---
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: AppColors.successBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.success,
                  size: 48,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              Text(
                _titleForType(payload.type),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                _subtitleForType(payload.type),
                style: const TextStyle(fontSize: 13, color: AppColors.gray600),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xxl),

              // --- Datos del QR en una card ---
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildDataRows(),
                ),
              ),

              const Spacer(),

              // --- CTAs ---
              if (payload.type == NexulyQrType.serviceCheckIn) ...[
                NexulyGradientButton(
                  label: 'Confirmar llegada',
                  icon: Icons.location_on,
                  onPressed: () => _onConfirmCheckIn(context, ref),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Cancelar'),
                ),
              ] else if (payload.type == NexulyQrType.professionalProfile) ...[
                NexulyGradientButton(
                  label: 'Ver perfil',
                  icon: Icons.person_outline,
                  onPressed: () {
                    final uid = payload.data['uid'];
                    if (uid is String) {
                      context.go('/professional/$uid');
                    }
                  },
                ),
              ] else ...[
                NexulyGradientButton(
                  label: 'Entendido',
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDataRows() {
    return payload.data.entries
        .where((e) => e.value != null)
        .map(
          (e) => _DataRow(
            label: _labelForKey(e.key),
            value: _formatValue(e.value),
          ),
        )
        .toList()
        .expand<Widget>(
          (w) => [w, const Divider(height: 16, color: AppColors.border)],
        )
        .toList()
      ..removeLast(); // quitar el último divider sobrante
  }

  String _titleForType(NexulyQrType type) => switch (type) {
    NexulyQrType.serviceCheckIn => 'Check-in de servicio',
    NexulyQrType.professionalProfile => 'Perfil profesional',
    NexulyQrType.bookingReference => 'Referencia de reserva',
  };

  String _subtitleForType(NexulyQrType type) => switch (type) {
    NexulyQrType.serviceCheckIn =>
      'El paciente te está esperando. Confirma tu llegada para iniciar el servicio.',
    NexulyQrType.professionalProfile =>
      'Abre el perfil para ver reseñas y servicios.',
    NexulyQrType.bookingReference => 'Detalles de la reserva.',
  };

  String _labelForKey(String key) => switch (key) {
    'request_id' => 'ID de servicio',
    'patient_uid' => 'ID del paciente',
    'service_id' => 'ID del servicio',
    'uid' => 'ID',
    'name' => 'Nombre',
    'generated_at' => 'Generado',
    _ => key.replaceAll('_', ' '),
  };

  String _formatValue(dynamic value) {
    if (value is String) {
      // Si es una fecha ISO, formateamos bonita.
      final date = DateTime.tryParse(value);
      if (date != null) {
        return DateFormat.yMMMd('es').add_jm().format(date);
      }
      // Truncar IDs muy largos.
      if (value.length > 20) {
        return '${value.substring(0, 8)}...${value.substring(value.length - 4)}';
      }
      return value;
    }
    return value.toString();
  }

  Future<void> _onConfirmCheckIn(BuildContext context, WidgetRef ref) async {
    final requestId = payload.data['request_id'] as String?;
    if (requestId == null || requestId.isEmpty) return;

    LocationResult? location;
    try {
      location = await ref.read(locationServiceProvider).requestCurrent();
    } catch (_) {
      location = null;
    }

    await ref
        .read(serviceEvidenceServiceProvider)
        .saveQrCheckIn(
          requestId: requestId,
          payload: payload,
          location: location,
        );

    try {
      await ref
          .read(serviceRequestsRepositoryProvider)
          .changeStatus(
            requestId: requestId,
            to: ServiceRequestStatus.inProgress,
            changedBy: ActorRole.professional,
            changedById:
                ref.read(firebaseAuthProvider).currentUser?.uid ?? 'local',
          );
    } catch (_) {
      // El check-in ya quedo guardado localmente para soportar modo offline.
    }

    if (!context.mounted) return;
    // En R1 solo cerramos con un toast. La integración real con
    // ServiceRequestsRepository (cambiar status a IN_PROGRESS) se conecta
    // con el flujo existente de booking/active_service.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Check-in guardado. Servicio iniciado.'),
        backgroundColor: AppColors.success,
      ),
    );
    await Navigator.of(context).maybePop(true);
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.gray500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.gray900,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
