import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/enums/domain_enums.dart';
import '../../../core/services/service_evidence_service.dart';
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
// Stage config
// ---------------------------------------------------------------------------

class _StageConfig {
  const _StageConfig({
    required this.title,
    required this.description,
    required this.icon,
    required this.estimatedTime,
    required this.bgFrom,
    required this.bgTo,
    required this.borderColor,
    required this.iconColor,
    required this.circleBg,
  });

  final String title;
  final String description;
  final IconData icon;
  final String estimatedTime;
  final Color bgFrom;
  final Color bgTo;
  final Color borderColor;
  final Color iconColor;
  final Color circleBg;
}

const _stages = [
  _StageConfig(
    title: 'En camino',
    description: 'El profesional está en camino a tu ubicación',
    icon: Icons.near_me_rounded,
    estimatedTime: '15 minutos',
    bgFrom: AppColors.violet50,
    bgTo: AppColors.violet100,
    borderColor: AppColors.violet200,
    iconColor: AppColors.violet600,
    circleBg: AppColors.violet100,
  ),
  _StageConfig(
    title: 'Ha llegado',
    description: 'El profesional llegó a tu domicilio',
    icon: Icons.location_on_outlined,
    estimatedTime: 'Ahora',
    bgFrom: Color(0xFFEFF6FF),
    bgTo: AppColors.infoBg,
    borderColor: AppColors.info,
    iconColor: AppColors.info,
    circleBg: AppColors.infoBg,
  ),
  _StageConfig(
    title: 'Servicio en progreso',
    description: 'El profesional está realizando la atención',
    icon: Icons.person_outline_rounded,
    estimatedTime: '30 minutos aprox.',
    bgFrom: Color(0xFFFFFBEB),
    bgTo: AppColors.warningBg,
    borderColor: AppColors.warning,
    iconColor: AppColors.warning,
    circleBg: AppColors.warningBg,
  ),
  _StageConfig(
    title: 'Servicio completado',
    description: 'La atención se completó exitosamente',
    icon: Icons.check_circle_outline_rounded,
    estimatedTime: 'Finalizado',
    bgFrom: Color(0xFFF0FDF4),
    bgTo: AppColors.successBg,
    borderColor: AppColors.success,
    iconColor: AppColors.success,
    circleBg: AppColors.successBg,
  ),
];

// ms to wait IN stage[i] before advancing to stage[i+1]
const _stageDelays = [5000, 3000, 8000];

// ---------------------------------------------------------------------------
// Feature-local providers
// ---------------------------------------------------------------------------

final _activeRequestProvider = StreamProvider.autoDispose
    .family<ServiceRequest?, String>(
      (ref, id) => ref.watch(serviceRequestsRepositoryProvider).watchById(id),
    );

final _activeProProvider = FutureProvider.autoDispose
    .family<Professional?, String>((ref, id) async {
      if (id.isEmpty) return null;
      return ref.watch(professionalsRepositoryProvider).getById(id);
    });

final _activeSvcProvider = FutureProvider.autoDispose.family<Service?, String>((
  ref,
  id,
) async {
  if (id.isEmpty) return null;
  return ref.watch(servicesRepositoryProvider).getById(id);
});

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class ActiveServiceScreen extends ConsumerStatefulWidget {
  const ActiveServiceScreen({required this.requestId, super.key});

  final String requestId;

  @override
  ConsumerState<ActiveServiceScreen> createState() =>
      _ActiveServiceScreenState();
}

class _ActiveServiceScreenState extends ConsumerState<ActiveServiceScreen>
    with SingleTickerProviderStateMixin {
  int _stage = 0;
  double _progress = 0;
  bool _simulationStarted = false;
  bool _redirectStarted = false;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 850),
      vsync: this,
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(
      begin: 0.92,
      end: 1.08,
    ).animate(_pulseController);

    WidgetsBinding.instance.addPostFrameCallback((_) => _startSimulation());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startSimulation() {
    if (_simulationStarted) return;
    _simulationStarted = true;
    _scheduleNext(0);
  }

  void _scheduleNext(int current) {
    if (!mounted || current >= _stageDelays.length) return;

    Future.delayed(Duration(milliseconds: _stageDelays[current]), () async {
      if (!mounted) return;
      final next = current + 1;

      setState(() {
        _stage = next;
        _progress = next / (_stages.length - 1);
      });

      // Firestore status transitions at key stages
      try {
        final repo = ref.read(serviceRequestsRepositoryProvider);
        if (next == 2) {
          await repo.changeStatus(
            requestId: widget.requestId,
            to: ServiceRequestStatus.inProgress,
            changedBy: ActorRole.professional,
            changedById: 'system',
          );
        } else if (next == 3) {
          await repo.changeStatus(
            requestId: widget.requestId,
            to: ServiceRequestStatus.completed,
            changedBy: ActorRole.professional,
            changedById: 'system',
          );
        }
      } catch (_) {
        // Non-critical — UI progression continues.
      }

      if (next < _stages.length - 1) {
        _scheduleNext(next);
      } else if (!_redirectStarted) {
        _redirectStarted = true;
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) context.go('/rating/${widget.requestId}');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final requestAsync = ref.watch(_activeRequestProvider(widget.requestId));

    final request = requestAsync.value;
    final professionalId = request?.professionalId ?? '';
    final serviceId = request?.serviceId ?? '';

    final professional = ref.watch(_activeProProvider(professionalId)).value;
    final service = ref.watch(_activeSvcProvider(serviceId)).value;

    final current = _stages[_stage];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // --- Map placeholder (40% height) ---
          _MapSection(
            stage: _stage,
            progress: _progress,
            current: current,
            pulseScale: _pulseScale,
          ),

          // --- Scrollable content ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _StatusCard(current: current),
                const SizedBox(height: AppSpacing.lg),
                _ProfessionalCard(
                  professional: professional,
                  onCallTap: () =>
                      _showSnack(context, professional?.phone ?? ''),
                  onChatTap: () => context.push('/chat/${widget.requestId}'),
                ),
                const SizedBox(height: AppSpacing.lg),
                _ServiceDetailsCard(
                  request: request,
                  service: service,
                  onQrTap: request == null
                      ? null
                      : () => context.push(
                          '/qr/service/${request.id}',
                          extra: {
                            'patientUid': request.userId,
                            'serviceId': request.serviceId,
                            'patientName': 'Paciente',
                            'serviceName': service?.name ?? 'Servicio',
                          },
                        ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _EvidenceCard(requestId: widget.requestId),
                const SizedBox(height: AppSpacing.lg),
                _TimelineCard(currentStage: _stage),
                const SizedBox(height: AppSpacing.lg),
                const _SafetyCard(),
                if (_stage == 3) ...[
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          context.go('/rating/${widget.requestId}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.violet600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Calificar servicio',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String value) {
    if (value.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}

// ---------------------------------------------------------------------------
// Map section
// ---------------------------------------------------------------------------

class _MapSection extends StatelessWidget {
  const _MapSection({
    required this.stage,
    required this.progress,
    required this.current,
    required this.pulseScale,
  });

  final int stage;
  final double progress;
  final _StageConfig current;
  final Animation<double> pulseScale;

  @override
  Widget build(BuildContext context) {
    final mapHeight = MediaQuery.of(context).size.height * 0.4;

    return SizedBox(
      height: mapHeight,
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.violet100, AppColors.purple100],
              ),
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
          ),

          // Center content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status circle
                _StatusCircle(
                  stage: stage,
                  current: current,
                  pulseScale: pulseScale,
                ),
                const SizedBox(height: AppSpacing.lg),
                // Info card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        current.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        current.estimatedTime,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Progress bar at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white,
              child: Stack(
                children: [
                  Container(height: 4, color: AppColors.gray200),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    height: 4,
                    width: MediaQuery.of(context).size.width * progress,
                    color: AppColors.violet600,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCircle extends StatelessWidget {
  const _StatusCircle({
    required this.stage,
    required this.current,
    required this.pulseScale,
  });

  final int stage;
  final _StageConfig current;
  final Animation<double> pulseScale;

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(current.icon, size: 48, color: current.iconColor),
    );

    if (stage == 0) {
      return ScaleTransition(scale: pulseScale, child: circle);
    }
    return circle;
  }
}

// ---------------------------------------------------------------------------
// Status card
// ---------------------------------------------------------------------------

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.current});
  final _StageConfig current;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [current.bgFrom, current.bgTo],
        ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: current.borderColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(current.icon, size: 24, color: current.iconColor),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  current.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  current.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.gray700,
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

// ---------------------------------------------------------------------------
// Professional card
// ---------------------------------------------------------------------------

class _ProfessionalCard extends StatelessWidget {
  const _ProfessionalCard({
    required this.professional,
    required this.onCallTap,
    required this.onChatTap,
  });

  final Professional? professional;
  final VoidCallback onCallTap;
  final VoidCallback onChatTap;

  @override
  Widget build(BuildContext context) {
    final name = professional?.fullName ?? '—';
    final specialty = _specialty(professional);
    final rating = professional?.ratingAvg.toStringAsFixed(1) ?? '—';

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
                  child: professional?.photoUrl?.isNotEmpty == true
                      ? Image.network(
                          professional!.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _AvatarFallback(name: name),
                        )
                      : _AvatarFallback(name: name),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      specialty,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.gray600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Color(0xFFFBBF24),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          rating,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.gray700,
                          ),
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
                child: ElevatedButton.icon(
                  onPressed: onCallTap,
                  icon: const Icon(Icons.phone_outlined, size: 16),
                  label: const Text('Llamar', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.violet600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm + 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onChatTap,
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                  label: const Text('Chat', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.violet600,
                    side: const BorderSide(color: AppColors.violet600),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm + 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _specialty(Professional? p) {
    if (p == null || p.specialties.isEmpty) return '';
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
// Service details
// ---------------------------------------------------------------------------

class _ServiceDetailsCard extends StatelessWidget {
  const _ServiceDetailsCard({
    required this.request,
    required this.service,
    required this.onQrTap,
  });

  final ServiceRequest? request;
  final Service? service;
  final VoidCallback? onQrTap;

  @override
  Widget build(BuildContext context) {
    final date = request?.requestedDate;
    final dateStr = date != null
        ? '${date.day} ${_month(date.month)} ${date.year}'
        : '—';
    final timeStr = date != null ? _timeStr(date) : '—';
    final address = request?.locationAddress ?? '—';
    final serviceName = service?.name ?? '—';

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
            'Detalles del servicio',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _DetailRow(
            icon: Icons.schedule_outlined,
            primary: dateStr,
            secondary: timeStr,
          ),
          const SizedBox(height: AppSpacing.md),
          _DetailRow(
            icon: Icons.location_on_outlined,
            primary: address,
            secondary: 'Servicio a domicilio',
          ),
          const SizedBox(height: AppSpacing.md),
          _DetailRow(
            icon: Icons.person_outline_rounded,
            primary: serviceName,
            secondary: null,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: onQrTap,
            icon: const Icon(Icons.qr_code_2, size: 16),
            label: const Text('Mostrar QR de check-in'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.violet600,
              side: const BorderSide(color: AppColors.violet200),
              minimumSize: const Size.fromHeight(44),
            ),
          ),
        ],
      ),
    );
  }

  static String _month(int m) => const [
    '',
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ][m];

  static String _timeStr(DateTime d) {
    final h = d.hour;
    final m = d.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final display = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$display:$m $period';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.primary, this.secondary});

  final IconData icon;
  final String primary;
  final String? secondary;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.gray400),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                primary,
                style: const TextStyle(fontSize: 13, color: AppColors.gray900),
              ),
              if (secondary != null)
                Text(
                  secondary!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.gray600,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Local evidence
// ---------------------------------------------------------------------------

class _EvidenceCard extends ConsumerWidget {
  const _EvidenceCard({required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evidenceAsync = ref.watch(serviceEvidenceProvider(requestId));
    final evidence = evidenceAsync.valueOrNull ?? const <ServiceEvidenceItem>[];

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
            'Evidencia local del servicio',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Fotos y videos quedan guardados en este dispositivo, incluso sin internet.',
            style: TextStyle(fontSize: 11, color: AppColors.gray600),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _EvidenceButton(
                  icon: Icons.photo_camera_outlined,
                  label: 'Foto',
                  onTap: () => _capturePhoto(context, ref, ImageSource.camera),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _EvidenceButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Galeria',
                  onTap: () => _capturePhoto(context, ref, ImageSource.gallery),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _EvidenceButton(
                  icon: Icons.videocam_outlined,
                  label: 'Video',
                  onTap: () => _captureVideo(context, ref),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (evidenceAsync.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (evidence.isEmpty)
            const Text(
              'Aun no hay evidencia capturada.',
              style: TextStyle(fontSize: 12, color: AppColors.gray500),
            )
          else
            Column(
              children: [
                for (final item in evidence.take(4)) ...[
                  _EvidenceTile(item: item),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _capturePhoto(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    final item = await ref
        .read(serviceEvidenceServiceProvider)
        .capturePhoto(requestId: requestId, source: source);
    if (!context.mounted || item == null) return;
    ref.invalidate(serviceEvidenceProvider(requestId));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Foto guardada localmente.')));
  }

  Future<void> _captureVideo(BuildContext context, WidgetRef ref) async {
    final item = await ref
        .read(serviceEvidenceServiceProvider)
        .captureVideo(requestId: requestId);
    if (!context.mounted || item == null) return;
    ref.invalidate(serviceEvidenceProvider(requestId));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Video guardado localmente.')));
  }
}

class _EvidenceButton extends StatelessWidget {
  const _EvidenceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(42),
        padding: const EdgeInsets.symmetric(horizontal: 6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _EvidenceTile extends StatelessWidget {
  const _EvidenceTile({required this.item});

  final ServiceEvidenceItem item;

  @override
  Widget build(BuildContext context) {
    final isPhoto = item.type == ServiceEvidenceType.photo;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            child: SizedBox(
              width: 48,
              height: 48,
              child: isPhoto
                  ? Image.memory(
                      base64Decode(item.base64),
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    )
                  : Container(
                      color: AppColors.violet100,
                      child: const Icon(
                        Icons.play_circle_outline,
                        color: AppColors.violet600,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPhoto ? 'Foto del servicio' : 'Video del servicio',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.hasLocation
                      ? 'GPS ${item.latitude!.toStringAsFixed(4)}, ${item.longitude!.toStringAsFixed(4)}'
                      : 'Sin GPS registrado',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.offline_pin_outlined, color: AppColors.success),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Timeline
// ---------------------------------------------------------------------------

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.currentStage});
  final int currentStage;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estado del servicio',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...List.generate(_stages.length, (i) {
            final stage = _stages[i];
            final isReached = currentStage >= i;
            final isCurrent = currentStage == i;

            return Padding(
              padding: EdgeInsets.only(
                bottom: i < _stages.length - 1 ? AppSpacing.lg : 0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stage circle
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isReached ? stage.circleBg : AppColors.gray100,
                    ),
                    child: Icon(
                      stage.icon,
                      size: 20,
                      color: isReached ? stage.iconColor : AppColors.gray400,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Stage text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stage.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isCurrent
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isCurrent
                                ? AppColors.gray900
                                : isReached
                                ? AppColors.gray700
                                : AppColors.gray500,
                          ),
                        ),
                        if (isCurrent) ...[
                          const SizedBox(height: 2),
                          Text(
                            stage.description,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.gray600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Checkmark
                  if (isReached)
                    Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: stage.iconColor,
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Safety card
// ---------------------------------------------------------------------------

class _SafetyCard extends StatelessWidget {
  const _SafetyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEFF6FF), Color(0xFFEEF2FF)],
        ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.infoBg),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu seguridad es importante',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.gray900,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Todos nuestros profesionales están verificados y certificados. Si tienes alguna emergencia durante el servicio, contacta inmediatamente al 123.',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.gray600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
