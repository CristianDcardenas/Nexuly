import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/models/app_user.dart';
import '../../../data/repositories/users_repository.dart';
import '../../../features/auth/providers/auth_providers.dart';
import '../../../shared/widgets/nexuly_badge.dart';
import '../../../shared/widgets/user_avatar.dart';

/// Pantalla de perfil del paciente (tab "Perfil" del shell).
///
/// Réplica del mockup:
/// - Header blanco con avatar + email + badges
/// - Card gradient de progreso de verificación
/// - Secciones: Info médica, Familia, Guardados, Configuración, Soporte, Logout
class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return profileAsync.when(
      data: (user) {
        if (user == null) {
          return const _NoProfile();
        }
        return _ProfileBody(user: user);
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
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verification = _VerificationLevel.fromUser(user);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // --- Header blanco con avatar ---
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  UserAvatar(
                    name: user.fullName,
                    photoUrl: user.photoUrl,
                    size: 96,
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: verification.badgeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(
                        Icons.shield,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                user.fullName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user.email,
                style: const TextStyle(fontSize: 13, color: AppColors.gray600),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  NexulyBadge(
                    label: verification.label,
                    icon: Icons.shield_outlined,
                    backgroundColor: verification.badgeBgColor,
                    foregroundColor: verification.badgeTextColor,
                  ),
                ],
              ),
            ],
          ),
        ),

        // --- Card gradient de progreso ---
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            0,
          ),
          child: _VerificationProgressCard(level: verification),
        ),

        // --- Sección: Información personal ---
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: _MenuCard(
            children: [
              _MenuTile(
                icon: Icons.favorite_outline,
                iconBg: AppColors.violet100,
                iconColor: AppColors.violet600,
                label: 'Tu información médica',
                onTap: () => _showSoon(context),
              ),
              const Divider(height: 1, indent: 68),
              _MenuTile(
                icon: Icons.group_outlined,
                iconBg: AppColors.infoBg,
                iconColor: AppColors.info,
                label: 'Miembros de la familia',
                onTap: () => _showSoon(context),
              ),
            ],
          ),
        ),

        // --- Guardados (estado vacío) ---
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: _SavedProfessionalsCard(),
        ),

        // --- Sección: Configuración ---
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: _MenuCard(
            title: 'Configuración de cuenta',
            children: [
              _MenuTile(
                icon: Icons.credit_card_outlined,
                iconColor: AppColors.gray600,
                label: 'Métodos de pago',
                onTap: () => _showSoon(context),
              ),
              const Divider(height: 1, indent: 60),
              _MenuTile(
                icon: Icons.notifications_outlined,
                iconColor: AppColors.gray600,
                label: 'Notificaciones',
                onTap: () => _showSoon(context),
              ),
              const Divider(height: 1, indent: 60),
              _MenuTile(
                icon: Icons.lock_outline,
                iconColor: AppColors.gray600,
                label: 'Privacidad y seguridad',
                onTap: () => _showSoon(context),
              ),
            ],
          ),
        ),

        // --- Sección: Soporte ---
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: _MenuCard(
            title: 'Soporte',
            children: [
              _MenuTile(
                icon: Icons.help_outline,
                iconColor: AppColors.gray600,
                label: 'Centro de ayuda',
                onTap: () => _showSoon(context),
              ),
              const Divider(height: 1, indent: 60),
              _MenuTile(
                icon: Icons.description_outlined,
                iconColor: AppColors.gray600,
                label: 'Términos y condiciones',
                onTap: () => _showSoon(context),
              ),
            ],
          ),
        ),

        // --- Logout ---
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            child: InkWell(
              onTap: () => _confirmLogout(context, ref),
              borderRadius: BorderRadius.circular(AppRadii.lg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: AppColors.danger, size: 18),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // --- Versión ---
        const SizedBox(height: AppSpacing.lg),
        const Center(
          child: Text(
            'Nexuly v1.0.0',
            style: TextStyle(fontSize: 11, color: AppColors.gray400),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  void _showSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Próximamente')));
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text(
          'Tendrás que volver a iniciar sesión para usar la app.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext, rootNavigator: true).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext, rootNavigator: true).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }
}

// ---------------------------------------------------------------------------
// VERIFICATION LEVEL
// ---------------------------------------------------------------------------

class _VerificationLevel {
  const _VerificationLevel({
    required this.label,
    required this.progress,
    required this.nextLevel,
    required this.badgeColor,
    required this.badgeBgColor,
    required this.badgeTextColor,
    required this.completedSteps,
  });

  final String label;
  final double progress; // 0..1
  final String? nextLevel;
  final Color badgeColor;
  final Color badgeBgColor;
  final Color badgeTextColor;
  final List<String> completedSteps;

  factory _VerificationLevel.fromUser(AppUser u) {
    // Basic: email confirmado (implícito si hay user con uid)
    // Verified: email + phone confirmados
    // Trusted: 3+ servicios completados con rating ≥ 4.5
    final level = u.verificationLevel;

    switch (level) {
      case 'trusted':
        return const _VerificationLevel(
          label: 'Confiable',
          progress: 1.0,
          nextLevel: null,
          badgeColor: AppColors.success,
          badgeBgColor: AppColors.successBg,
          badgeTextColor: AppColors.successText,
          completedSteps: [
            'Email verificado',
            'Teléfono verificado',
            'Historial positivo',
          ],
        );
      case 'verified':
        return const _VerificationLevel(
          label: 'Verificado',
          progress: 0.75,
          nextLevel: 'Confiable',
          badgeColor: AppColors.info,
          badgeBgColor: AppColors.infoBg,
          badgeTextColor: AppColors.infoText,
          completedSteps: ['Email verificado', 'Teléfono verificado'],
        );
      case 'basic':
      default:
        return const _VerificationLevel(
          label: 'Básico',
          progress: 0.33,
          nextLevel: 'Verificado',
          badgeColor: AppColors.gray500,
          badgeBgColor: AppColors.gray100,
          badgeTextColor: AppColors.gray700,
          completedSteps: ['Email verificado'],
        );
    }
  }
}

class _VerificationProgressCard extends StatelessWidget {
  const _VerificationProgressCard({required this.level});
  final _VerificationLevel level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.violet50, AppColors.purple100],
        ),
        border: Border.all(color: AppColors.violet200),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.violet100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium_outlined,
                  color: AppColors.violet600,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nivel: ${level.label}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                    if (level.nextLevel != null)
                      Text(
                        'Sigue para subir a ${level.nextLevel}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.gray500,
                        ),
                      )
                    else
                      const Text(
                        '¡Máximo nivel alcanzado! 🎉',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.violet400),
            ],
          ),
          if (level.nextLevel != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progreso hacia ${level.nextLevel}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.gray600,
                  ),
                ),
                Text(
                  '${(level.progress * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.violet600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: level.progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradientButton,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: 4,
            children: [
              for (final step in level.completedSteps)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      step,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// MENU CARDS
// ---------------------------------------------------------------------------

class _MenuCard extends StatelessWidget {
  const _MenuCard({this.title, required this.children});
  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text(
                title!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
            ),
          ...children,
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.iconBg,
  });
  final IconData icon;
  final Color iconColor;
  final Color? iconBg;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              if (iconBg != null)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                )
              else
                Icon(icon, color: iconColor, size: 20),
              SizedBox(width: iconBg != null ? AppSpacing.md : AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.gray800,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.gray400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedProfessionalsCard extends StatelessWidget {
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
          const Text(
            'Guardados',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
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
                    Icons.favorite_outline,
                    size: 24,
                    color: AppColors.gray400,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'No has guardado ningún profesional',
                  style: TextStyle(fontSize: 13, color: AppColors.gray600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: () => context.go('/search'),
                  icon: const Icon(Icons.search, size: 14),
                  label: const Text('Encontrar profesionales'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gray700,
                    side: const BorderSide(color: AppColors.gray200),
                    backgroundColor: AppColors.gray100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    textStyle: const TextStyle(fontSize: 12),
                    minimumSize: const Size(0, 36),
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

class _NoProfile extends StatelessWidget {
  const _NoProfile();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Text(
          'No se encontró tu perfil.\n'
          'Intenta cerrar sesión y volver a iniciar.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.gray500),
        ),
      ),
    );
  }
}
