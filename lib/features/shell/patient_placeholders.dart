import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/providers/auth_providers.dart';
import '../../data/repositories/users_repository.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';


/// Placeholders temporales para los 5 tabs del paciente.
/// En el Sprint 2 reemplazaremos estos por las pantallas reales con datos
/// de Firestore.

class PatientHomePlaceholder extends ConsumerWidget {
  const PatientHomePlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Welcome card con gradiente ---
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              gradient: AppColors.brandGradientSoft,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                profileAsync.when(
                  data: (profile) => Text(
                    '¡Hola, ${profile?.fullName.split(' ').first ?? 'Usuario'}! 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  loading: () => const SizedBox(
                    height: 28,
                    child: LinearProgressIndicator(color: Colors.white24),
                  ),
                  error: (e, _) => const Text(
                    '¡Hola! 👋',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '¿Qué servicio necesitas hoy?',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _PlaceholderCard(
                  color: Colors.white.withValues(alpha: 0.2),
                  child: Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: Colors.white, size: 20),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // --- Nota de desarrollo ---
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.violet50,
              border: Border.all(color: AppColors.violet200),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.construction, color: AppColors.violet600, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    const Text(
                      'Sprint 1 completo ✓',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.violet700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Shell, theme, bottom nav y auth listos. '
                  'En el próximo sprint: catálogo de servicios, '
                  'búsqueda de profesionales y detalles.',
                  style: TextStyle(fontSize: 13, color: AppColors.gray700),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          _TempSignOutButton(),
        ],
      ),
    );
  }
}

class PatientSearchPlaceholder extends StatelessWidget {
  const PatientSearchPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimplePlaceholder(
      icon: Icons.search,
      title: 'Buscar profesionales',
      subtitle: 'Próximo sprint',
    );
  }
}

class PatientBookingsPlaceholder extends StatelessWidget {
  const PatientBookingsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimplePlaceholder(
      icon: Icons.calendar_today,
      title: 'Mis reservas',
      subtitle: 'Próximo sprint',
    );
  }
}

class PatientHistoryPlaceholder extends StatelessWidget {
  const PatientHistoryPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimplePlaceholder(
      icon: Icons.history,
      title: 'Historial',
      subtitle: 'Próximo sprint',
    );
  }
}

class PatientProfilePlaceholder extends ConsumerWidget {
  const PatientProfilePlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: profileAsync.when(
              data: (profile) {
                final name = profile?.fullName ?? 'Usuario';
                final email = profile?.email ?? '';
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.violet100,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: AppColors.violet700,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(email,
                        style: TextStyle(
                            color: AppColors.gray600, fontSize: 14)),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Text('Error: $e'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _TempSignOutButton(),
          ),
        ],
      ),
    );
  }
}

class _TempSignOutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () async {
        await ref.read(authControllerProvider.notifier).signOut();
      },
      icon: const Icon(Icons.logout, color: AppColors.danger),
      label: const Text(
        'Cerrar sesión',
        style: TextStyle(color: AppColors.danger),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.gray200),
        backgroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
      ),
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({required this.child, required this.color});
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: child,
    );
  }
}

class _SimplePlaceholder extends StatelessWidget {
  const _SimplePlaceholder({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.violet100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: AppColors.violet600),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: AppColors.gray500, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
