import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/firebase_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/models/service_request.dart';
import '../../data/repositories/service_requests_repository.dart';

final _patientRequestsProvider =
    StreamProvider.autoDispose<List<ServiceRequest>>((ref) {
      final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;
      if (uid == null) return const Stream.empty();
      return ref.watch(serviceRequestsRepositoryProvider).watchByUser(uid);
    });

class PatientBookingsPlaceholder extends ConsumerWidget {
  const PatientBookingsPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _RequestsView(
      title: 'Mis reservas',
      emptyIcon: Icons.calendar_today_outlined,
      emptyTitle: 'Aun no tienes reservas activas',
      emptySubtitle: 'Busca un profesional y agenda tu primer servicio.',
      filter: (request) => !_isClosed(request) && !_isPast(request),
    );
  }
}

class PatientHistoryPlaceholder extends ConsumerWidget {
  const PatientHistoryPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _RequestsView(
      title: 'Historial',
      emptyIcon: Icons.history,
      emptyTitle: 'Sin servicios anteriores',
      emptySubtitle: 'Cuando completes una reserva aparecera aqui.',
      filter: (request) => _isClosed(request) || _isPast(request),
    );
  }
}

class _RequestsView extends ConsumerWidget {
  const _RequestsView({
    required this.title,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.filter,
  });

  final String title;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final bool Function(ServiceRequest request) filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;
    if (uid == null) {
      return const _EmptyState(
        icon: Icons.lock_outline,
        title: 'Inicia sesion',
        subtitle: 'Necesitas una cuenta para ver tus reservas.',
      );
    }

    final requestsAsync = ref.watch(_patientRequestsProvider);
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(_patientRequestsProvider);
        await Future<void>.delayed(const Duration(milliseconds: 300));
      },
      child: requestsAsync.when(
        data: (requests) {
          final visible = requests.where(filter).toList();
          if (visible.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _SectionHeader(title: title, count: 0),
                const SizedBox(height: AppSpacing.xxl),
                _EmptyState(
                  icon: emptyIcon,
                  title: emptyTitle,
                  subtitle: emptySubtitle,
                  actionLabel: 'Buscar profesionales',
                  onAction: () => context.go('/search'),
                ),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: visible.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _SectionHeader(title: title, count: visible.length);
              }
              return _RequestCard(request: visible[index - 1]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(message: 'Error cargando reservas: $e'),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final ServiceRequest request;

  @override
  Widget build(BuildContext context) {
    final status = _RequestStatus.fromValue(request.status);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: () {
          if (!_isClosed(request)) context.push('/active/${request.id}');
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Servicio ${request.serviceId}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatusBadge(status: status),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _MetaRow(
                icon: Icons.schedule,
                text: _dateLabel(request.requestedDate),
              ),
              if (request.locationAddress?.isNotEmpty == true) ...[
                const SizedBox(height: 6),
                _MetaRow(
                  icon: Icons.location_on_outlined,
                  text: request.locationAddress!,
                ),
              ],
              if (request.priceQuoted != null) ...[
                const SizedBox(height: 6),
                _MetaRow(
                  icon: Icons.payments_outlined,
                  text: _formatPrice(request.priceQuoted!),
                ),
              ],
              if (!_isClosed(request)) ...[
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => context.push('/active/${request.id}'),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('Ver seguimiento'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
        ),
        Text(
          '$count',
          style: const TextStyle(fontSize: 13, color: AppColors.gray500),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final _RequestStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status.bg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: status.fg,
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.gray500),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppColors.gray600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

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
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.search, size: 16),
                label: Text(actionLabel!),
              ),
            ],
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

class _RequestStatus {
  const _RequestStatus(this.label, this.bg, this.fg);

  final String label;
  final Color bg;
  final Color fg;

  static _RequestStatus fromValue(String value) {
    switch (value) {
      case 'CONFIRMED':
        return const _RequestStatus(
          'Confirmada',
          AppColors.successBg,
          AppColors.successText,
        );
      case 'IN_PROGRESS':
        return const _RequestStatus(
          'En curso',
          AppColors.infoBg,
          AppColors.infoText,
        );
      case 'COMPLETED':
        return const _RequestStatus(
          'Completada',
          AppColors.violet100,
          AppColors.violet700,
        );
      case 'CANCELLED':
        return const _RequestStatus(
          'Cancelada',
          AppColors.dangerBg,
          AppColors.dangerText,
        );
      case 'NO_SHOW':
        return const _RequestStatus(
          'No asistio',
          AppColors.warningBg,
          AppColors.warningText,
        );
      default:
        return const _RequestStatus(
          'Pendiente',
          AppColors.warningBg,
          AppColors.warningText,
        );
    }
  }
}

bool _isClosed(ServiceRequest request) {
  return request.status == 'COMPLETED' ||
      request.status == 'CANCELLED' ||
      request.status == 'NO_SHOW';
}

bool _isPast(ServiceRequest request) {
  return request.requestedDate.isBefore(DateTime.now()) &&
      request.status != 'IN_PROGRESS';
}

String _formatPrice(double value) {
  final formatted = value
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  return '\$$formatted COP';
}

String _dateLabel(DateTime date) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year} ${two(date.hour)}:${two(date.minute)}';
}
