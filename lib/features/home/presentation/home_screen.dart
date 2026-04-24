import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/models/professional.dart';
import '../../../data/repositories/professionals_repository.dart';
import '../../../data/repositories/users_repository.dart';
import '../../../shared/widgets/nexuly_pressable.dart';
import '../../../shared/widgets/nexuly_shimmer.dart';
import '../../../shared/widgets/professional_card.dart';

part 'home_screen.g.dart';

/// Top profesionales aprobados y disponibles (máx 5) ordenados por rating.
/// Se suscribe al stream de Firestore — se actualiza solo si cambia algo.
@riverpod
Stream<List<Professional>> topProfessionals(Ref ref) {
  return ref
      .watch(professionalsRepositoryProvider)
      .watchApproved(limit: 10)
      .map((list) {
        // Ordenamos por rating desc del lado cliente para ahorrar un índice.
        final sorted = [...list]
          ..sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
        return sorted.take(5).toList();
      });
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final topAsync = ref.watch(topProfessionalsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(topProfessionalsProvider);
        await Future<void>.delayed(const Duration(milliseconds: 400));
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // --- Welcome card ---
          _WelcomeCard(
            firstName: profileAsync.valueOrNull?.fullName.split(' ').first,
          ),
          const SizedBox(height: AppSpacing.xxl),
          const _CareNotificationsPanel(),
          const SizedBox(height: AppSpacing.xxl),

          // --- Grid de categorías ---
          const _SectionTitle('Servicios'),
          const SizedBox(height: AppSpacing.md),
          const _ServiceCategoriesGrid(),
          const SizedBox(height: AppSpacing.xxl),

          // --- Recomendados ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _SectionTitle('Recomendados para ti'),
              TextButton(
                onPressed: () => context.go('/search'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Ver todos',
                  style: TextStyle(fontSize: 13, color: AppColors.violet600),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          topAsync.when(
            data: (profs) {
              if (profs.isEmpty) {
                return const _EmptyProfessionals();
              }
              return Column(
                children: [
                  for (final p in profs) ...[
                    ProfessionalCard(professional: p),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
              );
            },
            loading: () => const _ProfessionalsShimmer(),
            error: (e, _) => _ErrorState(error: '$e'),
          ),

          const SizedBox(height: AppSpacing.lg),

          // --- Quick actions ---
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.history,
                  label: 'Historial',
                  onTap: () => context.go('/history'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _QuickAction(
                  icon: Icons.calendar_today_outlined,
                  label: 'Próximas citas',
                  onTap: () => context.go('/bookings'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets internos
// ---------------------------------------------------------------------------

class _CareNotificationsPanel extends StatelessWidget {
  const _CareNotificationsPanel();

  Future<void> _scheduleDaily(BuildContext context) async {
    final now = TimeOfDay.now();
    final minute = (now.minute + 1) % 60;
    final hour = minute == 0 ? (now.hour + 1) % 24 : now.hour;

    await NotificationService.instance.scheduleDailyCareReminder(
      hour: hour,
      minute: minute,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recordatorio diario programado.')),
    );
  }

  Future<void> _scheduleAppointment(BuildContext context) async {
    await NotificationService.instance.scheduleUpcomingAppointmentAlert();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alerta de reserva en 15 segundos.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: AppColors.warningText,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'La app habla primero',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _CareAction(
                  icon: Icons.medication_outlined,
                  label: 'Recordatorio',
                  onTap: () => _scheduleDaily(context),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _CareAction(
                  icon: Icons.event_available_outlined,
                  label: 'Alerta cita',
                  onTap: () => _scheduleAppointment(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CareAction extends StatelessWidget {
  const _CareAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return NexulyPressable(
      borderRadius: BorderRadius.circular(AppRadii.md),
      onTap: onTap,
      child: Container(
        height: 76,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.violet50,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.violet600, size: 22),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.violet700,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfessionalsShimmer extends StatelessWidget {
  const _ProfessionalsShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 3; i++) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: const Row(
              children: [
                NexulyShimmer(width: 56, height: 56, borderRadius: AppRadii.lg),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NexulyShimmer(width: double.infinity, height: 14),
                      SizedBox(height: AppSpacing.sm),
                      NexulyShimmer(width: 160, height: 12),
                      SizedBox(height: AppSpacing.sm),
                      NexulyShimmer(width: 96, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.gray900,
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({this.firstName});
  final String? firstName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradientSoft,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            firstName != null ? '¡Hola, $firstName! 👋' : '¡Hola! 👋',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '¿Qué servicio necesitas hoy?',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Ubicación actual
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ubicación actual',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                      const Text(
                        'Valledupar, Cesar',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Cambiar',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 11,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Asistente IA (placeholder)
          _AIAssistantBar(),
        ],
      ),
    );
  }
}

class _AIAssistantBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: () {
          // TODO: navegar a /ai-symptoms (Sprint futuro)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Asistente IA — próximamente')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Asistente IA',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    Text(
                      'Encuentra el profesional ideal para ti',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCategoriesGrid extends StatelessWidget {
  const _ServiceCategoriesGrid();

  static const _items = <_CategoryItem>[
    _CategoryItem(
      icon: Icons.favorite_outline,
      label: 'Enfermería',
      category: 'enfermeria',
      bg: AppColors.redBg,
      fg: AppColors.redFg,
    ),
    _CategoryItem(
      icon: Icons.people_alt_outlined,
      label: 'Cuidado',
      category: 'cuidado_adulto_mayor',
      bg: AppColors.violetServiceBg,
      fg: AppColors.violetServiceFg,
    ),
    _CategoryItem(
      icon: Icons.directions_run,
      label: 'Fisioterapia',
      category: 'fisioterapia',
      bg: AppColors.greenBg,
      fg: AppColors.greenFg,
    ),
    _CategoryItem(
      icon: Icons.child_care_outlined,
      label: 'Pediatría',
      category: 'pediatria',
      bg: AppColors.purpleBg,
      fg: AppColors.purpleFg,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _items.length; i++) ...[
          Expanded(child: _CategoryTile(item: _items[i])),
          if (i < _items.length - 1) const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _CategoryItem {
  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.category,
    required this.bg,
    required this.fg,
  });
  final IconData icon;
  final String label;
  final String category;
  final Color bg;
  final Color fg;
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.item});
  final _CategoryItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      onTap: () => context.go('/search?category=${item.category}'),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: item.bg,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Icon(item.icon, color: item.fg, size: 26),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.label,
            style: const TextStyle(fontSize: 11, color: AppColors.gray700),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: AppColors.violet600),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: const TextStyle(fontSize: 13, color: AppColors.gray700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyProfessionals extends StatelessWidget {
  const _EmptyProfessionals();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.gray100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people_outline,
              size: 28,
              color: AppColors.gray400,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Aún no hay profesionales disponibles',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pronto tendremos profesionales verificados en tu zona.',
            style: TextStyle(fontSize: 12, color: AppColors.gray500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.dangerBg,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.dangerText),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Error cargando profesionales: $error',
              style: const TextStyle(color: AppColors.dangerText, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
