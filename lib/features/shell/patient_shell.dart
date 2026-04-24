import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/nexuly_logo.dart';

/// Shell de la zona de paciente: header fijo + bottom nav + contenido.
///
/// Se usa como contenedor de una `ShellRoute` en go_router. El contenido de
/// cada tab se pasa como `child`.
class PatientShell extends ConsumerWidget {
  const PatientShell({required this.child, super.key});

  final Widget child;

  static const _tabs = [
    _TabItem(
      path: '/home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Inicio',
    ),
    _TabItem(
      path: '/search',
      icon: Icons.search,
      activeIcon: Icons.search,
      label: 'Buscar',
    ),
    _TabItem(
      path: '/bookings',
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
      label: 'Reservas',
    ),
    _TabItem(
      path: '/history',
      icon: Icons.history,
      activeIcon: Icons.history,
      label: 'Historial',
    ),
    _TabItem(
      path: '/profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Perfil',
    ),
  ];

  int _currentIndex(String location) {
    for (var i = 0; i < _tabs.length; i++) {
      if (location == _tabs[i].path ||
          location.startsWith('${_tabs[i].path}/')) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _currentIndex(location);

    return Scaffold(
      appBar: AppBar(
        title: const NexulyLogo(size: 32),
        titleSpacing: 16,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: AppColors.violet600),
            tooltip: 'Asistente IA',
            onPressed: () {
              // TODO: navegar a /ai-symptoms cuando exista
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.gray600,
                ),
                onPressed: () async {
                  await NotificationService.instance.showCareAlert(
                    title: 'Nexuly está atento',
                    body:
                        'Cuando haya cambios importantes, te avisaremos aquí.',
                  );
                },
              ),
              Positioned(
                top: 10,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  child: _BottomTab(
                    item: _tabs[i],
                    active: currentIndex == i,
                    onTap: () => context.go(_tabs[i].path),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  const _TabItem({
    required this.path,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _BottomTab extends StatelessWidget {
  const _BottomTab({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _TabItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? item.activeIcon : item.icon,
              size: 24,
              color: active ? AppColors.violet600 : AppColors.gray400,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w500 : FontWeight.w400,
                color: active ? AppColors.violet600 : AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
