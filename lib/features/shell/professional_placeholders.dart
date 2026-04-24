import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../auth/providers/auth_providers.dart';

/// Home del profesional. R1: añadimos botón "Escanear QR" para el flujo de
/// check-in en domicilio.
class ProfessionalHomePlaceholder extends ConsumerWidget {
  const ProfessionalHomePlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Welcome card ---
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              gradient: AppColors.brandGradientSoft,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola, profesional',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Gestiona tus servicios del día',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.medical_services,
                      color: Colors.white, size: 24),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // --- Quick Actions ---
          const Text(
            'Acciones rápidas',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // --- Fila con 2 quick actions ---
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.qr_code_scanner,
                  label: 'Escanear QR',
                  subtitle: 'Check-in al llegar',
                  iconBg: AppColors.violet100,
                  iconColor: AppColors.violet600,
                  onTap: () async {
                    final result = await context.push<dynamic>('/qr/scan');
                    // El scanner devuelve QrScanResult via Navigator.pop.
                    if (result != null && context.mounted) {
                      // Pasamos el payload al screen de resultado.
                      final payloadDynamic = (result as dynamic).payload;
                      context.push('/qr/result', extra: payloadDynamic);
                    }
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.calendar_today_outlined,
                  label: 'Hoy',
                  subtitle: 'Ver servicios',
                  iconBg: AppColors.infoBg,
                  iconColor: AppColors.info,
                  onTap: () => context.go('/pro/requests'),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // --- Perfil en revisión ---
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.warningBg,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.hourglass_empty,
                        color: AppColors.warningText, size: 18),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Perfil en revisión',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.warningText,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Tu registro se envió correctamente. Un administrador '
                  'revisará tus documentos en las próximas 24–48 horas.',
                  style: TextStyle(fontSize: 13, color: AppColors.gray700),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          OutlinedButton.icon(
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
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfessionalRequestsPlaceholder extends StatelessWidget {
  const ProfessionalRequestsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimplePlaceholder(
      icon: Icons.calendar_today,
      title: 'Solicitudes',
      subtitle: 'Próximo sprint',
    );
  }
}

class ProfessionalAvailabilityPlaceholder extends StatelessWidget {
  const ProfessionalAvailabilityPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimplePlaceholder(
      icon: Icons.schedule,
      title: 'Mis horarios',
      subtitle: 'Próximo sprint',
    );
  }
}

class ProfessionalServicesPlaceholder extends StatelessWidget {
  const ProfessionalServicesPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimplePlaceholder(
      icon: Icons.medical_services,
      title: 'Mis servicios',
      subtitle: 'Próximo sprint',
    );
  }
}

class ProfessionalProfilePlaceholder extends StatelessWidget {
  const ProfessionalProfilePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimplePlaceholder(
      icon: Icons.person,
      title: 'Mi perfil profesional',
      subtitle: 'Próximo sprint',
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
            decoration: const BoxDecoration(
              color: AppColors.violet100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: AppColors.violet600),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              )),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppColors.gray500, fontSize: 13)),
        ],
      ),
    );
  }
}
