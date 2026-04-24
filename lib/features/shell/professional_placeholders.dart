import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/enums/domain_enums.dart';
import '../../core/providers/firebase_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/models/professional.dart';
import '../../data/models/service.dart';
import '../../data/models/service_request.dart';
import '../../data/repositories/professionals_repository.dart';
import '../../data/repositories/service_requests_repository.dart';
import '../../data/repositories/services_repository.dart';
import '../../shared/widgets/user_avatar.dart';
import '../auth/providers/auth_providers.dart';

final _professionalUidProvider = Provider<String?>((ref) {
  return ref.watch(firebaseAuthProvider).currentUser?.uid;
});

final _professionalProfileProvider = StreamProvider.autoDispose<Professional?>((
  ref,
) {
  final uid = ref.watch(_professionalUidProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(professionalsRepositoryProvider).watchById(uid);
});

final _professionalRequestsProvider =
    StreamProvider.autoDispose<List<ServiceRequest>>((ref) {
      final uid = ref.watch(_professionalUidProvider);
      if (uid == null) return const Stream.empty();
      return ref
          .watch(serviceRequestsRepositoryProvider)
          .watchByProfessional(uid);
    });

final _professionalServicesProvider = StreamProvider.autoDispose<List<Service>>(
  (ref) {
    final uid = ref.watch(_professionalUidProvider);
    if (uid == null) return const Stream.empty();
    return ref.watch(servicesRepositoryProvider).watchByProfessional(uid);
  },
);

final _professionalAvailabilityProvider =
    StreamProvider.autoDispose<List<AvailabilityBlock>>((ref) {
      final uid = ref.watch(_professionalUidProvider);
      if (uid == null) return const Stream.empty();
      return ref.watch(professionalsRepositoryProvider).watchAvailability(uid);
    });

class ProfessionalHomePlaceholder extends ConsumerWidget {
  const ProfessionalHomePlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(_professionalProfileProvider).valueOrNull;
    final requests = ref.watch(_professionalRequestsProvider).valueOrNull ?? [];
    final today = DateUtils.dateOnly(DateTime.now());
    final todayCount = requests
        .where((r) => DateUtils.isSameDay(r.requestedDate, today))
        .length;
    final pendingCount = requests.where((r) => !_isClosed(r)).length;

    return RefreshIndicator(
      onRefresh: () async {
        ref
          ..invalidate(_professionalProfileProvider)
          ..invalidate(_professionalRequestsProvider);
        await Future<void>.delayed(const Duration(milliseconds: 300));
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _HeroPanel(
            title:
                'Hola, ${profile?.fullName.split(' ').first ?? 'profesional'}',
            subtitle: 'Gestiona tus servicios del dia',
            trailing: UserAvatar(name: profile?.fullName ?? 'Profesional'),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'Hoy',
                  value: '$todayCount',
                  icon: Icons.today_outlined,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _MetricCard(
                  label: 'Activas',
                  value: '$pendingCount',
                  icon: Icons.assignment_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
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
                    if (result != null && context.mounted) {
                      final payloadDynamic = (result as dynamic).payload;
                      unawaited(
                        context.push('/qr/result', extra: payloadDynamic),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.calendar_today_outlined,
                  label: 'Solicitudes',
                  subtitle: 'Ver agenda',
                  iconBg: AppColors.infoBg,
                  iconColor: AppColors.info,
                  onTap: () => context.go('/pro/requests'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _ProfileStatusCard(profile: profile),
        ],
      ),
    );
  }
}

class ProfessionalRequestsPlaceholder extends ConsumerWidget {
  const ProfessionalRequestsPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(_professionalRequestsProvider);
    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return const _EmptyState(
            icon: Icons.calendar_today_outlined,
            title: 'Sin solicitudes',
            subtitle: 'Cuando un paciente te reserve, aparecera aqui.',
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(_professionalRequestsProvider);
            await Future<void>.delayed(const Duration(milliseconds: 300));
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemBuilder: (_, index) {
              if (index == 0) {
                return _ScreenTitle(
                  title: 'Solicitudes',
                  subtitle: '${requests.length} en agenda',
                );
              }
              return _ProfessionalRequestCard(request: requests[index - 1]);
            },
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemCount: requests.length + 1,
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorState(message: 'Error cargando solicitudes: $e'),
    );
  }
}

class ProfessionalAvailabilityPlaceholder extends ConsumerWidget {
  const ProfessionalAvailabilityPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocksAsync = ref.watch(_professionalAvailabilityProvider);
    final uid = ref.watch(_professionalUidProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: uid == null
            ? null
            : () => _showAvailabilityDialog(context, ref, uid),
        icon: const Icon(Icons.add),
        label: const Text('Horario'),
      ),
      body: blocksAsync.when(
        data: (blocks) {
          if (blocks.isEmpty) {
            return const _EmptyState(
              icon: Icons.schedule,
              title: 'Define tus horarios',
              subtitle:
                  'Agrega bloques de disponibilidad para recibir reservas.',
            );
          }
          final sorted = [...blocks]
            ..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemBuilder: (_, index) {
              if (index == 0) {
                return const _ScreenTitle(
                  title: 'Mis horarios',
                  subtitle: 'Disponibilidad activa',
                );
              }
              final block = sorted[index - 1];
              return _InfoCard(
                icon: Icons.schedule,
                title: _dayLabel(block.dayOfWeek),
                subtitle: '${block.startTime} - ${block.endTime}',
                trailing: block.isActive ? 'Activo' : 'Pausado',
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemCount: sorted.length + 1,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(message: 'Error cargando horarios: $e'),
      ),
    );
  }
}

class ProfessionalServicesPlaceholder extends ConsumerWidget {
  const ProfessionalServicesPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(_professionalServicesProvider);
    final uid = ref.watch(_professionalUidProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: uid == null
            ? null
            : () => _showServiceDialog(context, ref, uid),
        icon: const Icon(Icons.add),
        label: const Text('Servicio'),
      ),
      body: servicesAsync.when(
        data: (services) {
          if (services.isEmpty) {
            return const _EmptyState(
              icon: Icons.medical_services_outlined,
              title: 'Crea tu catalogo',
              subtitle:
                  'Agrega servicios con precio y duracion para que los pacientes reserven.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemBuilder: (_, index) {
              if (index == 0) {
                return _ScreenTitle(
                  title: 'Mis servicios',
                  subtitle: '${services.length} publicados',
                );
              }
              final service = services[index - 1];
              return _InfoCard(
                icon: Icons.medical_services_outlined,
                title: service.name,
                subtitle:
                    '${_categoryLabel(service.category)} · ${service.durationMin} min',
                trailing: _formatPrice(service.price),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemCount: services.length + 1,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(message: 'Error cargando servicios: $e'),
      ),
    );
  }
}

class ProfessionalProfilePlaceholder extends ConsumerWidget {
  const ProfessionalProfilePlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(_professionalProfileProvider);
    return profileAsync.when(
      data: (profile) {
        if (profile == null) {
          return const _EmptyState(
            icon: Icons.person_outline,
            title: 'Perfil no encontrado',
            subtitle:
                'Completa tu registro profesional para aparecer en busquedas.',
          );
        }
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _HeroPanel(
              title: profile.fullName,
              subtitle: _categoryLabel(
                profile.specialties.firstOrNull ?? 'salud',
              ),
              trailing: UserAvatar(
                name: profile.fullName,
                photoUrl: profile.photoUrl,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _InfoCard(
              icon: Icons.verified_user_outlined,
              title: 'Estado de validacion',
              subtitle: _validationLabel(profile.validationStatus),
              trailing: profile.isAvailable ? 'Disponible' : 'No disponible',
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoCard(
              icon: Icons.star_rounded,
              title: 'Reputacion',
              subtitle: '${profile.ratingAvg.toStringAsFixed(1)} de 5',
              trailing: '${profile.ratingCount} resenas',
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).signOut();
              },
              icon: const Icon(Icons.logout, color: AppColors.danger),
              label: const Text(
                'Cerrar sesion',
                style: TextStyle(color: AppColors.danger),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.gray200),
                backgroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorState(message: 'Error cargando perfil: $e'),
    );
  }
}

class _ProfessionalRequestCard extends ConsumerWidget {
  const _ProfessionalRequestCard({required this.request});

  final ServiceRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _InfoCard(
      icon: Icons.assignment_outlined,
      title: _statusLabel(request.status),
      subtitle:
          '${_dateLabel(request.requestedDate)}\n${request.locationAddress ?? 'Direccion pendiente'}',
      trailing: request.priceQuoted == null
          ? null
          : _formatPrice(request.priceQuoted!),
      actions: _requestActions(context, ref),
    );
  }

  List<Widget> _requestActions(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(_professionalUidProvider);
    if (uid == null || _isClosed(request)) return const [];
    Future<void> change(ServiceRequestStatus status) async {
      await ref
          .read(serviceRequestsRepositoryProvider)
          .changeStatus(
            requestId: request.id,
            to: status,
            changedBy: ActorRole.professional,
            changedById: uid,
          );
    }

    if (request.status == 'CONFIRMED') {
      return [
        TextButton.icon(
          onPressed: () => change(ServiceRequestStatus.inProgress),
          icon: const Icon(Icons.play_arrow, size: 16),
          label: const Text('Iniciar'),
        ),
      ];
    }
    if (request.status == 'IN_PROGRESS') {
      return [
        TextButton.icon(
          onPressed: () => change(ServiceRequestStatus.completed),
          icon: const Icon(Icons.check, size: 16),
          label: const Text('Completar'),
        ),
      ];
    }
    return [
      TextButton.icon(
        onPressed: () => change(ServiceRequestStatus.confirmed),
        icon: const Icon(Icons.check, size: 16),
        label: const Text('Confirmar'),
      ),
      TextButton.icon(
        onPressed: () => change(ServiceRequestStatus.cancelled),
        icon: const Icon(Icons.close, size: 16),
        label: const Text('Cancelar'),
      ),
    ];
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradientSoft,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(icon: icon, title: value, subtitle: label);
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
                style: const TextStyle(fontSize: 11, color: AppColors.gray500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileStatusCard extends StatelessWidget {
  const _ProfileStatusCard({required this.profile});

  final Professional? profile;

  @override
  Widget build(BuildContext context) {
    if (profile == null) {
      return const _InfoCard(
        icon: Icons.hourglass_empty,
        title: 'Perfil profesional',
        subtitle: 'Cargando estado de validacion...',
      );
    }
    return _InfoCard(
      icon: Icons.verified_user_outlined,
      title: _validationLabel(profile!.validationStatus),
      subtitle: profile!.validationStatus == 'approved'
          ? 'Tu perfil ya puede recibir reservas.'
          : 'Un administrador revisara tus documentos.',
      trailing: profile!.isAvailable ? 'Disponible' : 'Pausado',
    );
  }
}

class _ScreenTitle extends StatelessWidget {
  const _ScreenTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: AppColors.gray500),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.actions = const [],
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailing;
  final List<Widget> actions;

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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.violet100,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.violet600, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Text(
                  trailing!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.violet600,
                  ),
                ),
              ],
            ],
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: actions),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
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
          mainAxisSize: MainAxisSize.min,
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
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Text(
          message,
          style: const TextStyle(color: AppColors.dangerText),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

Future<void> _showAvailabilityDialog(
  BuildContext context,
  WidgetRef ref,
  String uid,
) async {
  var day = 1;
  var startTime = '08:00';
  var endTime = '17:00';
  final saved = await showDialog<bool>(
    context: context,
    useRootNavigator: true,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Nuevo horario'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            initialValue: day,
            items: [
              for (var i = 0; i < 7; i++)
                DropdownMenuItem(value: i, child: Text(_dayLabel(i))),
            ],
            onChanged: (value) => day = value ?? day,
            decoration: const InputDecoration(labelText: 'Dia'),
          ),
          TextFormField(
            initialValue: startTime,
            onChanged: (value) => startTime = value.trim(),
            decoration: const InputDecoration(labelText: 'Inicio'),
          ),
          TextFormField(
            initialValue: endTime,
            onChanged: (value) => endTime = value.trim(),
            decoration: const InputDecoration(labelText: 'Fin'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(dialogContext, rootNavigator: true).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(dialogContext, rootNavigator: true).pop(true),
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
  if (saved != true) return;
  await ref
      .read(professionalsRepositoryProvider)
      .addAvailabilityBlock(
        uid,
        AvailabilityBlock(
          dayOfWeek: day,
          startTime: startTime,
          endTime: endTime,
        ),
      );
}

Future<void> _showServiceDialog(
  BuildContext context,
  WidgetRef ref,
  String uid,
) async {
  var name = '';
  var priceText = '';
  var durationText = '60';
  var category = 'enfermeria';
  final saved = await showDialog<bool>(
    context: context,
    useRootNavigator: true,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Nuevo servicio'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              onChanged: (value) => name = value.trim(),
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            DropdownButtonFormField<String>(
              initialValue: category,
              items: const [
                DropdownMenuItem(
                  value: 'enfermeria',
                  child: Text('Enfermeria'),
                ),
                DropdownMenuItem(
                  value: 'fisioterapia',
                  child: Text('Fisioterapia'),
                ),
                DropdownMenuItem(value: 'cuidado', child: Text('Cuidado')),
                DropdownMenuItem(value: 'pediatria', child: Text('Pediatria')),
              ],
              onChanged: (value) => category = value ?? category,
              decoration: const InputDecoration(labelText: 'Categoria'),
            ),
            TextFormField(
              onChanged: (value) => priceText = value.trim(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Precio COP'),
            ),
            TextFormField(
              initialValue: durationText,
              onChanged: (value) => durationText = value.trim(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Duracion min'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(dialogContext, rootNavigator: true).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(dialogContext, rootNavigator: true).pop(true),
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
  final price = double.tryParse(priceText) ?? 0;
  final duration = int.tryParse(durationText) ?? 60;
  if (saved != true || name.isEmpty || price <= 0) return;
  final now = DateTime.now();
  await ref
      .read(servicesRepositoryProvider)
      .add(
        Service(
          id: '',
          professionalId: uid,
          name: name,
          category: category,
          price: price,
          currency: 'COP',
          durationMin: duration,
          createdAt: now,
          updatedAt: now,
        ),
      );
  await ref.read(professionalsRepositoryProvider).update(uid, {
    'specialties': FieldValue.arrayUnion([category]),
    'updated_at': FieldValue.serverTimestamp(),
  });
}

bool _isClosed(ServiceRequest request) {
  return request.status == 'COMPLETED' ||
      request.status == 'CANCELLED' ||
      request.status == 'NO_SHOW';
}

String _dateLabel(DateTime date) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year} ${two(date.hour)}:${two(date.minute)}';
}

String _dayLabel(int day) {
  return switch (day) {
    0 => 'Domingo',
    1 => 'Lunes',
    2 => 'Martes',
    3 => 'Miercoles',
    4 => 'Jueves',
    5 => 'Viernes',
    _ => 'Sabado',
  };
}

String _statusLabel(String value) {
  return switch (value) {
    'CONFIRMED' => 'Reserva confirmada',
    'IN_PROGRESS' => 'Servicio en curso',
    'COMPLETED' => 'Servicio completado',
    'CANCELLED' => 'Servicio cancelado',
    'NO_SHOW' => 'No asistio',
    _ => 'Pendiente de confirmacion',
  };
}

String _validationLabel(String value) {
  return switch (value) {
    'approved' => 'Perfil aprobado',
    'rejected' => 'Perfil rechazado',
    'suspended' => 'Perfil suspendido',
    _ => 'Perfil en revision',
  };
}

String _categoryLabel(String value) {
  return switch (value) {
    'enfermeria' => 'Enfermeria',
    'fisioterapia' => 'Fisioterapia',
    'cuidado' || 'cuidado_adulto_mayor' => 'Cuidado',
    'pediatria' => 'Pediatria',
    'acompanamiento' => 'Acompanamiento',
    _ => value.replaceAll('_', ' '),
  };
}

String _formatPrice(double value) {
  final formatted = value
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  return '\$$formatted';
}
