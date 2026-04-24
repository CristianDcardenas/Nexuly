import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/models/professional.dart';
import '../../../data/models/review.dart';
import '../../../data/models/service.dart';
import '../../../data/repositories/professionals_repository.dart';
import '../../../data/repositories/reviews_repository.dart';
import '../../../data/repositories/services_repository.dart';
import '../../../shared/widgets/nexuly_badge.dart';
import '../../../shared/widgets/nexuly_gradient_button.dart';
import '../../../shared/widgets/user_avatar.dart';

/// Pantalla de detalle de un profesional. Muestra header con info básica,
/// tabs (Sobre mí / Servicios / Reseñas) y un CTA sticky abajo.
class ProfessionalDetailScreen extends ConsumerWidget {
  const ProfessionalDetailScreen({required this.professionalId, super.key});

  final String professionalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final professionalAsync = ref.watch(
      _professionalByIdProvider(professionalId),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: professionalAsync.when(
        data: (professional) {
          if (professional == null) {
            return const _NotFound();
          }
          return _DetailBody(professional: professional);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Text(
              'Error cargando perfil: $e',
              style: const TextStyle(color: AppColors.dangerText),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

// --- Provider del profesional por ID (stream individual) ---
final _professionalByIdProvider = StreamProvider.autoDispose
    .family<Professional?, String>((ref, id) {
  return ref.watch(professionalsRepositoryProvider).watchById(id);
});

// ---------------------------------------------------------------------------

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.professional});
  final Professional professional;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // --- Header con foto + back ---
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppColors.violet600,
                foregroundColor: Colors.white,
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).canPop()
                        ? Navigator.of(context).pop()
                        : context.go('/home'),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border,
                          color: Colors.white),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Guardado — próximamente')),
                        );
                      },
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _HeaderBackground(professional: professional),
                ),
              ),

              // --- Card blanca superpuesta con resumen ---
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -24),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          professional.fullName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _specialtiesLabel(professional.specialties),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.gray600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: 6,
                          children: [
                            if (professional.validationStatus == 'approved')
                              const NexulyBadge(
                                label: 'Verificado',
                                icon: Icons.verified,
                                backgroundColor: AppColors.infoBg,
                                foregroundColor: AppColors.infoText,
                              ),
                            if (professional.isAvailable)
                              const NexulyBadge.success(
                                label: 'Disponible ahora',
                                dot: true,
                              ),
                            NexulyBadge(
                              label:
                                  '${professional.ratingAvg.toStringAsFixed(1)} · ${professional.ratingCount} reseñas',
                              icon: Icons.star_rounded,
                              iconColor: const Color(0xFFFBBF24),
                              backgroundColor: AppColors.warningBg,
                              foregroundColor: AppColors.warningText,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _StatsRow(professional: professional),
                      ],
                    ),
                  ),
                ),
              ),

              // --- Tabs sticky ---
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(),
              ),

              // --- Contenido de tabs ---
              SliverFillRemaining(
                hasScrollBody: true,
                child: TabBarView(
                  children: [
                    _AboutTab(professional: professional),
                    _ServicesTab(professionalId: professional.uid),
                    _ReviewsTab(professionalId: professional.uid),
                  ],
                ),
              ),
            ],
          ),

          // --- CTA sticky al pie ---
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                MediaQuery.of(context).padding.bottom + AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: NexulyGradientButton(
                label: 'Agendar servicio',
                icon: Icons.calendar_today_outlined,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Agendamiento disponible en el próximo sprint'),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _specialtiesLabel(List<String> s) {
    return s.map(_readable).join(' · ');
  }

  static String _readable(String s) => switch (s) {
        'enfermeria' => 'Enfermería',
        'cuidado' || 'cuidado_adulto_mayor' => 'Cuidado de adulto mayor',
        'fisioterapia' => 'Fisioterapia',
        'rehabilitacion' => 'Rehabilitación',
        'pediatria' => 'Pediatría',
        'acompanamiento' => 'Acompañamiento',
        _ => s.replaceAll('_', ' '),
      };
}

// ---------------------------------------------------------------------------
// HEADER
// ---------------------------------------------------------------------------

class _HeaderBackground extends StatelessWidget {
  const _HeaderBackground({required this.professional});
  final Professional professional;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.brandGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xxl * 2,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: ClipOval(
                    child: (professional.photoUrl?.isNotEmpty ?? false)
                        ? Image.network(
                            professional.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _fallbackAvatar(),
                          )
                        : _fallbackAvatar(),
                  ),
                ),
                if (professional.validationStatus == 'approved')
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.info,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(Icons.verified_user,
                          color: Colors.white, size: 18),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fallbackAvatar() {
    return Container(
      color: AppColors.violet100,
      alignment: Alignment.center,
      child: UserAvatar(name: professional.fullName, size: 120),
    );
  }
}

// ---------------------------------------------------------------------------
// STATS
// ---------------------------------------------------------------------------

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.professional});
  final Professional professional;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatItem(
            value: professional.ratingAvg.toStringAsFixed(1),
            label: 'Rating',
          ),
        ),
        Container(width: 1, height: 32, color: AppColors.gray200),
        Expanded(
          child: _StatItem(
            value: '${professional.ratingCount}',
            label: 'Reseñas',
          ),
        ),
        Container(width: 1, height: 32, color: AppColors.gray200),
        Expanded(
          child: _StatItem(
            value: '${(professional.completionRate * 100).round()}%',
            label: 'Completados',
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.gray500),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// TAB BAR (sticky)
// ---------------------------------------------------------------------------

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: Container(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: TabBar(
          indicatorColor: AppColors.violet600,
          indicatorWeight: 2,
          labelColor: AppColors.violet600,
          unselectedLabelColor: AppColors.gray500,
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
          tabs: const [
            Tab(text: 'Sobre mí'),
            Tab(text: 'Servicios'),
            Tab(text: 'Reseñas'),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate old) => false;
}

// ---------------------------------------------------------------------------
// TABS
// ---------------------------------------------------------------------------

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.professional});
  final Professional professional;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        120, // espacio para no quedar debajo del CTA
      ),
      children: [
        const _SectionLabel('Biografía'),
        const SizedBox(height: AppSpacing.sm),
        Text(
          professional.bio?.isNotEmpty == true
              ? professional.bio!
              : 'Este profesional aún no ha agregado una biografía.',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.gray700,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        const _SectionLabel('Especialidades'),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final sp in professional.specialties)
              NexulyBadge.primary(label: _readable(sp)),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        const _SectionLabel('Zona de cobertura'),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            const Icon(Icons.location_on_outlined,
                size: 18, color: AppColors.gray500),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                professional.coverageRadiusKm != null
                    ? 'Hasta ${professional.coverageRadiusKm!.toStringAsFixed(0)} km desde su ubicación'
                    : 'Cobertura definida por zonas',
                style:
                    const TextStyle(fontSize: 13, color: AppColors.gray700),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _readable(String s) => switch (s) {
        'enfermeria' => 'Enfermería',
        'cuidado' || 'cuidado_adulto_mayor' => 'Cuidado adulto mayor',
        'fisioterapia' => 'Fisioterapia',
        'rehabilitacion' => 'Rehabilitación',
        'pediatria' => 'Pediatría',
        'acompanamiento' => 'Acompañamiento',
        _ => s.replaceAll('_', ' '),
      };
}

class _ServicesTab extends ConsumerWidget {
  const _ServicesTab({required this.professionalId});
  final String professionalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync =
        ref.watch(_servicesByProfessionalProvider(professionalId));

    return servicesAsync.when(
      data: (services) {
        if (services.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: Text(
                'Este profesional aún no ha publicado servicios.',
                style: TextStyle(color: AppColors.gray500),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            120,
          ),
          itemCount: services.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (_, i) => _ServiceCard(service: services[i]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text('Error: $e',
              style: const TextStyle(color: AppColors.dangerText)),
        ),
      ),
    );
  }
}

final _servicesByProfessionalProvider =
    StreamProvider.autoDispose.family<List<Service>, String>((ref, id) {
  return ref.watch(servicesRepositoryProvider).watchByProfessional(id);
});

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});
  final Service service;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  service.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _formatPrice(service.price),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.violet600,
                ),
              ),
            ],
          ),
          if (service.description?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              service.description!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.gray600,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.schedule, size: 14, color: AppColors.gray500),
              const SizedBox(width: 4),
              Text(
                '${service.durationMin} min',
                style:
                    const TextStyle(fontSize: 12, color: AppColors.gray500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatPrice(double p) {
    final s = p.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return '\$$s';
  }
}

class _ReviewsTab extends ConsumerWidget {
  const _ReviewsTab({required this.professionalId});
  final String professionalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync =
        ref.watch(_reviewsByProfessionalProvider(professionalId));

    return reviewsAsync.when(
      data: (reviews) {
        if (reviews.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: Text(
                'Aún no hay reseñas públicas para este profesional.',
                style: TextStyle(color: AppColors.gray500),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            120,
          ),
          itemCount: reviews.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (_, i) => _ReviewCard(review: reviews[i]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text('Error: $e',
              style: const TextStyle(color: AppColors.dangerText)),
        ),
      ),
    );
  }
}

final _reviewsByProfessionalProvider =
    StreamProvider.autoDispose.family<List<Review>, String>((ref, id) {
  return ref.watch(reviewsRepositoryProvider).watchPublicForProfessional(id);
});

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(name: review.authorName ?? 'Anónimo', size: 40),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.authorName ?? 'Usuario anónimo',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        for (var i = 0; i < 5; i++)
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: i < (review.rating ?? 0)
                                ? const Color(0xFFFBBF24)
                                : AppColors.gray200,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment?.isNotEmpty == true) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              review.comment!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.gray700,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HELPERS
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.gray500,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off, size: 64, color: AppColors.gray400),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Profesional no encontrado',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'El perfil que intentas ver ya no está disponible.',
              style: TextStyle(fontSize: 13, color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}
