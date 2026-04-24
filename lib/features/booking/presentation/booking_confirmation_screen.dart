import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/domain_enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/models/professional.dart';
import '../../../data/models/service.dart';
import '../../../data/models/service_request.dart';
import '../../../data/repositories/professionals_repository.dart';
import '../../../data/repositories/service_requests_repository.dart';
import '../../../data/repositories/services_repository.dart';
import '../../../shared/widgets/user_avatar.dart';

// ---------------------------------------------------------------------------
// Feature-local providers
// ---------------------------------------------------------------------------

final _confirmationRequestProvider =
    StreamProvider.autoDispose.family<ServiceRequest?, String>(
  (ref, id) => ref.watch(serviceRequestsRepositoryProvider).watchById(id),
);

final _confirmationProProvider =
    FutureProvider.autoDispose.family<Professional?, String>(
  (ref, id) async {
    if (id.isEmpty) return null;
    return ref.watch(professionalsRepositoryProvider).getById(id);
  },
);

final _confirmationSvcProvider =
    FutureProvider.autoDispose.family<Service?, String>(
  (ref, id) async {
    if (id.isEmpty) return null;
    return ref.watch(servicesRepositoryProvider).getById(id);
  },
);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class BookingConfirmationScreen extends ConsumerStatefulWidget {
  const BookingConfirmationScreen({required this.requestId, super.key});

  final String requestId;

  @override
  ConsumerState<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends ConsumerState<BookingConfirmationScreen> {
  bool _simulationStarted = false;
  bool _redirectStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSimulation());
  }

  void _startSimulation() {
    if (_simulationStarted) return;
    _simulationStarted = true;

    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;
      final isAccepted = Random().nextDouble() > 0.1;
      try {
        final repo = ref.read(serviceRequestsRepositoryProvider);
        if (isAccepted) {
          // CREATED → PENDING_CONFIRMATION → CONFIRMED
          await repo.changeStatus(
            requestId: widget.requestId,
            to: ServiceRequestStatus.pendingConfirmation,
            changedBy: ActorRole.system,
            changedById: 'system',
          );
          await repo.changeStatus(
            requestId: widget.requestId,
            to: ServiceRequestStatus.confirmed,
            changedBy: ActorRole.system,
            changedById: 'system',
          );
        } else {
          // CREATED → CANCELLED
          await repo.changeStatus(
            requestId: widget.requestId,
            to: ServiceRequestStatus.cancelled,
            changedBy: ActorRole.system,
            changedById: 'system',
            reason: 'Profesional no disponible',
          );
        }
      } catch (_) {
        // Simulation errors are non-critical — ignore silently.
      }
    });
  }

  void _onStatusChange(ServiceRequest? request) {
    if (request == null || _redirectStarted) return;
    final status = ServiceRequestStatus.fromValue(request.status);
    if (status == ServiceRequestStatus.confirmed) {
      _redirectStarted = true;
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) context.go('/active-service/${widget.requestId}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestAsync =
        ref.watch(_confirmationRequestProvider(widget.requestId));

    // Drive redirect from stream
    ref.listen(_confirmationRequestProvider(widget.requestId), (_, next) {
      _onStatusChange(next.value);
    });

    final request = requestAsync.value;
    final professionalId = request?.professionalId ?? '';
    final serviceId = request?.serviceId ?? '';

    final proAsync = ref.watch(_confirmationProProvider(professionalId));
    final svcAsync = ref.watch(_confirmationSvcProvider(serviceId));

    final status = ServiceRequestStatus.fromValue(request?.status);
    final isRejected = status == ServiceRequestStatus.cancelled ||
        status == ServiceRequestStatus.noShow;
    final isAccepted = status == ServiceRequestStatus.confirmed;

    if (isRejected) {
      return _RejectionModal(
        professionalName: proAsync.value?.fullName ?? 'el profesional',
        onFindAlternative: () => context.go('/search'),
        onGoHistory: () => context.go('/history'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: requestAsync.when(
          data: (_) => _Content(
            request: request,
            professional: proAsync.value,
            service: svcAsync.value,
            isAccepted: isAccepted,
            requestId: widget.requestId,
            onCallTap: () => _showContactSnack(
              context,
              proAsync.value?.phone ?? '',
            ),
            onEmailTap: () => _showContactSnack(
              context,
              proAsync.value?.email ?? '',
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text('Error: $e',
                style: const TextStyle(color: AppColors.dangerText)),
          ),
        ),
      ),
    );
  }

  void _showContactSnack(BuildContext context, String value) {
    if (value.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value)),
    );
  }
}

// ---------------------------------------------------------------------------
// Main content
// ---------------------------------------------------------------------------

class _Content extends StatelessWidget {
  const _Content({
    required this.request,
    required this.professional,
    required this.service,
    required this.isAccepted,
    required this.requestId,
    required this.onCallTap,
    required this.onEmailTap,
  });

  final ServiceRequest? request;
  final Professional? professional;
  final Service? service;
  final bool isAccepted;
  final String requestId;
  final VoidCallback onCallTap;
  final VoidCallback onEmailTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const SizedBox(height: AppSpacing.xxl),
        _StatusHeader(isAccepted: isAccepted),
        const SizedBox(height: AppSpacing.xxl),
        if (professional != null)
          _ProfessionalCard(
            professional: professional!,
            onCallTap: onCallTap,
            onEmailTap: onEmailTap,
          ),
        if (professional != null) const SizedBox(height: AppSpacing.lg),
        if (request != null)
          _BookingDetails(request: request!, service: service),
        if (request != null) const SizedBox(height: AppSpacing.lg),
        if (request?.userNeedDescription?.isNotEmpty == true) ...[
          _NotesCard(notes: request!.userNeedDescription!),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (request?.priceQuoted != null) ...[
          _TotalCard(price: request!.priceQuoted!),
          const SizedBox(height: AppSpacing.lg),
        ],
        _StatusInfoCard(
          isAccepted: isAccepted,
          professionalName: professional?.fullName,
        ),
        const SizedBox(height: AppSpacing.lg),
        _Actions(
          isAccepted: isAccepted,
          requestId: requestId,
          onGoHistory: () => context.go('/history'),
          onGoHome: () => context.go('/home'),
          onGoActiveService: () => context.go('/active-service/$requestId'),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Status header
// ---------------------------------------------------------------------------

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.isAccepted});
  final bool isAccepted;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isAccepted ? AppColors.successBg : AppColors.violet100,
          ),
          child: isAccepted
              ? const Icon(Icons.check_circle_outline,
                  size: 40, color: AppColors.success)
              : const _PulsingClock(),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          isAccepted ? '¡Reserva confirmada!' : 'Solicitud enviada',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          isAccepted
              ? 'El profesional aceptó tu solicitud'
              : 'Esperando confirmación del profesional...',
          style: const TextStyle(fontSize: 13, color: AppColors.gray600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _PulsingClock extends StatefulWidget {
  const _PulsingClock();

  @override
  State<_PulsingClock> createState() => _PulsingClockState();
}

class _PulsingClockState extends State<_PulsingClock>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: const Icon(Icons.access_time_rounded,
          size: 40, color: AppColors.violet600),
    );
  }
}

// ---------------------------------------------------------------------------
// Professional card
// ---------------------------------------------------------------------------

class _ProfessionalCard extends StatelessWidget {
  const _ProfessionalCard({
    required this.professional,
    required this.onCallTap,
    required this.onEmailTap,
  });

  final Professional professional;
  final VoidCallback onCallTap;
  final VoidCallback onEmailTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.md),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: professional.photoUrl?.isNotEmpty == true
                      ? Image.network(
                          professional.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _AvatarFallback(name: professional.fullName),
                        )
                      : _AvatarFallback(name: professional.fullName),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      professional.fullName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _specialty(professional),
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.gray600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 14, color: Color(0xFFFBBF24)),
                        const SizedBox(width: 3),
                        Text(
                          professional.ratingAvg.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.gray700),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Text('•',
                              style:
                                  TextStyle(color: AppColors.gray300)),
                        ),
                        Text(
                          '${professional.ratingCount} reseñas',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.gray600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _ContactButton(
                  icon: Icons.phone_outlined,
                  label: 'Llamar',
                  onTap: onCallTap,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ContactButton(
                  icon: Icons.mail_outline_rounded,
                  label: 'Email',
                  onTap: onEmailTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _specialty(Professional p) {
    if (p.specialties.isEmpty) return '';
    return switch (p.specialties.first) {
      'enfermeria' => 'Enfermería',
      'cuidado' || 'cuidado_adulto_mayor' => 'Cuidado adulto mayor',
      'fisioterapia' => 'Fisioterapia',
      'rehabilitacion' => 'Rehabilitación',
      'pediatria' => 'Pediatría',
      _ => p.specialties.first.replaceAll('_', ' '),
    };
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(color: AppColors.gray300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.gray700),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.gray700),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.violet100,
      alignment: Alignment.center,
      child: UserAvatar(name: name, size: 64),
    );
  }
}

// ---------------------------------------------------------------------------
// Booking details
// ---------------------------------------------------------------------------

class _BookingDetails extends StatelessWidget {
  const _BookingDetails({required this.request, required this.service});

  final ServiceRequest request;
  final Service? service;

  @override
  Widget build(BuildContext context) {
    final date = request.requestedDate;
    final dateStr =
        '${date.day} ${_monthName(date.month)} ${date.year}';
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final timeStr = '$displayHour:$minute $period';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalles de la reserva',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            primary: dateStr,
            secondary: timeStr,
          ),
          const SizedBox(height: AppSpacing.md),
          _DetailRow(
            icon: Icons.location_on_outlined,
            primary: request.locationAddress ?? 'Sin dirección',
            secondary: 'Servicio a domicilio',
          ),
          if (service != null) ...[
            const SizedBox(height: AppSpacing.md),
            _DetailRow(
              icon: Icons.medical_services_outlined,
              primary: service!.name,
              secondary: null,
            ),
          ],
        ],
      ),
    );
  }

  static String _monthName(int m) => const [
        '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ][m];
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.primary,
    required this.secondary,
  });

  final IconData icon;
  final String primary;
  final String? secondary;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.violet600),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                primary,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.gray900),
              ),
              if (secondary != null)
                Text(
                  secondary!,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.gray600),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Notes card
// ---------------------------------------------------------------------------

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.notes});
  final String notes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.violet50,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.violet200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notas adicionales',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            notes,
            style: const TextStyle(fontSize: 13, color: AppColors.gray700),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Total card
// ---------------------------------------------------------------------------

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.price});
  final double price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total a pagar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray900,
                ),
              ),
              Text(
                '\$${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.violet600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Pago en efectivo al finalizar el servicio',
              style: TextStyle(fontSize: 11, color: AppColors.gray600),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status info card
// ---------------------------------------------------------------------------

class _StatusInfoCard extends StatelessWidget {
  const _StatusInfoCard({
    required this.isAccepted,
    required this.professionalName,
  });

  final bool isAccepted;
  final String? professionalName;

  @override
  Widget build(BuildContext context) {
    if (isAccepted) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.successBg,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle_outline,
                size: 20, color: AppColors.success),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¡Excelente!',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${professionalName ?? 'El profesional'} confirmó tu reserva. Te redirigiremos al seguimiento en tiempo real...',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.gray600),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.violet50, AppColors.purple100],
        ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.violet200),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.access_time_rounded,
              size: 20, color: AppColors.violet600),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tiempo estimado de respuesta',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'El profesional tiene hasta 10 minutos para aceptar tu solicitud. Te notificaremos cuando confirme.',
                  style: TextStyle(fontSize: 11, color: AppColors.gray600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action buttons
// ---------------------------------------------------------------------------

class _Actions extends StatelessWidget {
  const _Actions({
    required this.isAccepted,
    required this.requestId,
    required this.onGoHistory,
    required this.onGoHome,
    required this.onGoActiveService,
  });

  final bool isAccepted;
  final String requestId;
  final VoidCallback onGoHistory;
  final VoidCallback onGoHome;
  final VoidCallback onGoActiveService;

  @override
  Widget build(BuildContext context) {
    if (isAccepted) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onGoActiveService,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.violet600,
            foregroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Ver seguimiento en tiempo real',
            style:
                TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onGoHistory,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.gray700,
              side: const BorderSide(color: AppColors.gray300),
              padding:
                  const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
            ),
            child: const Text('Ver mis citas',
                style: TextStyle(fontSize: 14)),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onGoHome,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.gray700,
              side: const BorderSide(color: AppColors.gray300),
              padding:
                  const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
            ),
            child: const Text('Volver al inicio',
                style: TextStyle(fontSize: 14)),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Rejection modal (full screen)
// ---------------------------------------------------------------------------

class _RejectionModal extends StatelessWidget {
  const _RejectionModal({
    required this.professionalName,
    required this.onFindAlternative,
    required this.onGoHistory,
  });

  final String professionalName;
  final VoidCallback onFindAlternative;
  final VoidCallback onGoHistory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.dangerBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 32, color: AppColors.danger),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Profesional no disponible',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Lo sentimos, $professionalName no está disponible en este momento.',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.gray600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.violet50,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(color: AppColors.violet200),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¿Qué te gustaría hacer?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray900,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        'Encontramos 12 profesionales similares disponibles en tu zona',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.gray600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onFindAlternative,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.violet600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadii.md),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Ver profesionales disponibles',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onGoHistory,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.gray700,
                      side:
                          const BorderSide(color: AppColors.gray300),
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadii.md),
                      ),
                    ),
                    child: const Text('Ir a mis citas',
                        style: TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
