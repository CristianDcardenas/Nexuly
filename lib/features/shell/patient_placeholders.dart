import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

/// Placeholders temporales para los tabs del paciente que aún no tienen
/// pantalla real. Home y Profile ya usan pantallas reales (HomeScreen,
/// UserProfileScreen).
///
/// Los que quedan son: Bookings e History — se implementarán en el Sprint 3
/// cuando tengamos flujo de reservas real.

class PatientBookingsPlaceholder extends StatelessWidget {
  const PatientBookingsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimplePlaceholder(
      icon: Icons.calendar_today,
      title: 'Mis reservas',
      subtitle: 'Tus próximas citas aparecerán acá (Sprint 3)',
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
      subtitle: 'Servicios completados (Sprint 3)',
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
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
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
              style: const TextStyle(color: AppColors.gray500, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
