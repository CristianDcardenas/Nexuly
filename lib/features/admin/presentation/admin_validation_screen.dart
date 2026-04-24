import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/firebase_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/models/admin_action.dart';
import '../../../data/models/professional.dart';
import '../../../data/repositories/admin_actions_repository.dart';
import '../../../data/repositories/professionals_repository.dart';
import '../../../shared/widgets/user_avatar.dart';

final _adminProfessionalsProvider =
    StreamProvider.autoDispose<List<Professional>>((ref) {
      return ref.watch(professionalsRepositoryProvider).watchForAdmin();
    });

final _adminActionsProvider = StreamProvider.autoDispose<List<AdminAction>>((
  ref,
) {
  return ref.watch(adminActionsRepositoryProvider).watchRecent(limit: 20);
});

final _professionalDocumentsProvider = StreamProvider.autoDispose
    .family<List<ProfessionalDocument>, String>((ref, uid) {
      return ref.watch(professionalsRepositoryProvider).watchDocuments(uid);
    });

class AdminValidationScreen extends ConsumerStatefulWidget {
  const AdminValidationScreen({super.key});

  @override
  ConsumerState<AdminValidationScreen> createState() =>
      _AdminValidationScreenState();
}

class _AdminValidationScreenState extends ConsumerState<AdminValidationScreen> {
  String _activeTab = 'all';
  String _query = '';
  Professional? _selected;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    if (_selected != null) {
      return _AdminProfessionalDetail(
        professional: _selected!,
        isSaving: _isSaving,
        onBack: () => setState(() => _selected = null),
        onApprove: () => _approve(_selected!),
        onReject: () => _askReject(_selected!),
      );
    }

    final professionalsAsync = ref.watch(_adminProfessionalsProvider);
    final actionsAsync = ref.watch(_adminActionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Panel de validacion'),
            SizedBox(height: 2),
            Text(
              'Gestion de profesionales',
              style: TextStyle(fontSize: 12, color: AppColors.gray500),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Cerrar sesion',
          onPressed: () async {
            await ref.read(firebaseAuthProvider).signOut();
          },
        ),
      ),
      body: professionalsAsync.when(
        data: (professionals) {
          final filtered = _filter(professionals);
          final stats = _Stats.from(professionals);
          return RefreshIndicator(
            onRefresh: () async {
              ref
                ..invalidate(_adminProfessionalsProvider)
                ..invalidate(_adminActionsProvider);
              await Future<void>.delayed(const Duration(milliseconds: 300));
            },
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                _SearchBox(
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: AppSpacing.lg),
                _StatsGrid(stats: stats),
                const SizedBox(height: AppSpacing.lg),
                _StatusTabs(
                  active: _activeTab,
                  onChanged: (value) => setState(() => _activeTab = value),
                ),
                const SizedBox(height: AppSpacing.md),
                if (filtered.isEmpty)
                  const _EmptyState()
                else
                  for (final professional in filtered) ...[
                    _ProfessionalRequestCard(
                      professional: professional,
                      onTap: () => setState(() => _selected = professional),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                const SizedBox(height: AppSpacing.lg),
                _RecentActions(actionsAsync: actionsAsync),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(message: 'Error cargando panel: $e'),
      ),
    );
  }

  List<Professional> _filter(List<Professional> professionals) {
    return professionals.where((professional) {
      final matchesTab =
          _activeTab == 'all' || professional.validationStatus == _activeTab;
      final q = _query.trim().toLowerCase();
      final matchesQuery =
          q.isEmpty ||
          professional.fullName.toLowerCase().contains(q) ||
          professional.email.toLowerCase().contains(q) ||
          professional.specialties.any((s) => s.toLowerCase().contains(q));
      return matchesTab && matchesQuery;
    }).toList();
  }

  Future<void> _approve(Professional professional) async {
    await _setValidationStatus(
      professional,
      status: 'approved',
      actionType: 'approve_professional',
      notes: 'Profesional aprobado desde panel admin',
    );
  }

  Future<void> _askReject(Professional professional) async {
    var reason = '';
    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rechazar solicitud'),
        content: TextFormField(
          maxLines: 4,
          onChanged: (value) => reason = value.trim(),
          decoration: const InputDecoration(
            hintText: 'Motivo del rechazo',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext, rootNavigator: true).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () =>
                Navigator.of(dialogContext, rootNavigator: true).pop(true),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _setValidationStatus(
      professional,
      status: 'rejected',
      actionType: 'reject_professional',
      notes: reason.isEmpty ? 'Rechazado sin nota interna' : reason,
    );
  }

  Future<void> _setValidationStatus(
    Professional professional, {
    required String status,
    required String actionType,
    required String notes,
  }) async {
    final adminId = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (adminId == null || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(professionalsRepositoryProvider).update(professional.uid, {
        'validation_status': status,
        'rejection_reason': status == 'rejected' ? notes : FieldValue.delete(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      await ref
          .read(adminActionsRepositoryProvider)
          .add(
            AdminAction(
              id: '',
              adminId: adminId,
              actionType: actionType,
              targetId: professional.uid,
              targetType: 'professional',
              notes: notes,
              createdAt: DateTime.now(),
            ),
          );
      if (!mounted) return;
      setState(() => _selected = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_actionMessage(status))));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo actualizar: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _AdminProfessionalDetail extends ConsumerWidget {
  const _AdminProfessionalDetail({
    required this.professional,
    required this.isSaving,
    required this.onBack,
    required this.onApprove,
    required this.onReject,
  });

  final Professional professional;
  final bool isSaving;
  final VoidCallback onBack;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(
      _professionalDocumentsProvider(professional.uid),
    );
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: const Text('Detalle de solicitud'),
        actions: [_StatusBadge(status: professional.validationStatus)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _DetailHeader(professional: professional),
          const SizedBox(height: AppSpacing.md),
          _InfoPanel(professional: professional),
          const SizedBox(height: AppSpacing.md),
          _DocumentsPanel(documentsAsync: documentsAsync),
          const SizedBox(height: AppSpacing.md),
          if (professional.rejectionReason?.isNotEmpty == true)
            _NotePanel(note: professional.rejectionReason!),
          const SizedBox(height: AppSpacing.lg),
          if (professional.validationStatus == 'pending' ||
              professional.validationStatus == 'rejected')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isSaving ? null : onReject,
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Rechazar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isSaving ? null : onApprove,
                    icon: isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: const Text('Aprobar'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Buscar por nombre, correo o especialidad...',
        prefixIcon: const Icon(Icons.search, color: AppColors.gray400),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final _Stats stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Pendientes',
            value: stats.pending,
            color: AppColors.warningText,
            bg: AppColors.warningBg,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            label: 'Aprobados',
            value: stats.approved,
            color: AppColors.successText,
            bg: AppColors.successBg,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            label: 'Rechazados',
            value: stats.rejected,
            color: AppColors.dangerText,
            bg: AppColors.dangerBg,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  final String label;
  final int value;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatusTabs extends StatelessWidget {
  const _StatusTabs({required this.active, required this.onChanged});

  final String active;
  final ValueChanged<String> onChanged;

  static const _tabs = [
    ('all', 'Todas'),
    ('pending', 'Pendientes'),
    ('approved', 'Aprobadas'),
    ('rejected', 'Rechazadas'),
    ('suspended', 'Suspendidas'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, index) {
          final (value, label) = _tabs[index];
          final selected = active == value;
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => onChanged(value),
            selectedColor: AppColors.violet600,
            labelStyle: TextStyle(
              color: selected ? Colors.white : AppColors.gray700,
              fontSize: 12,
            ),
          );
        },
      ),
    );
  }
}

class _ProfessionalRequestCard extends StatelessWidget {
  const _ProfessionalRequestCard({
    required this.professional,
    required this.onTap,
  });

  final Professional professional;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserAvatar(
                    name: professional.fullName,
                    photoUrl: professional.photoUrl,
                    size: 52,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          professional.fullName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _specialties(professional),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: professional.validationStatus),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: AppColors.gray500,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _dateLabel(professional.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray500,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.gray400),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.professional});

  final Professional professional;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        children: [
          UserAvatar(
            name: professional.fullName,
            photoUrl: professional.photoUrl,
            size: 72,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  professional.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _specialties(professional),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.gray500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  professional.email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.violet600,
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

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.professional});

  final Professional professional;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Informacion profesional',
      children: [
        _InfoRow(label: 'Telefono', value: professional.phone),
        _InfoRow(
          label: 'Radio de cobertura',
          value:
              '${professional.coverageRadiusKm?.toStringAsFixed(0) ?? '0'} km',
        ),
        _InfoRow(
          label: 'Rating',
          value:
              '${professional.ratingAvg.toStringAsFixed(1)} (${professional.ratingCount})',
        ),
        if (professional.bio?.isNotEmpty == true)
          _InfoRow(label: 'Bio', value: professional.bio!),
      ],
    );
  }
}

class _DocumentsPanel extends StatelessWidget {
  const _DocumentsPanel({required this.documentsAsync});

  final AsyncValue<List<ProfessionalDocument>> documentsAsync;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Documentos subidos',
      children: [
        documentsAsync.when(
          data: (documents) {
            if (documents.isEmpty) {
              return const Text(
                'Este profesional aun no ha subido documentos.',
                style: TextStyle(fontSize: 13, color: AppColors.gray500),
              );
            }
            return Column(
              children: [
                for (final document in documents) ...[
                  _DocumentTile(document: document),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(
            'Error cargando documentos: $e',
            style: const TextStyle(color: AppColors.dangerText),
          ),
        ),
      ],
    );
  }
}

class _NotePanel extends StatelessWidget {
  const _NotePanel({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Nota interna',
      children: [
        Text(
          note,
          style: const TextStyle(fontSize: 13, color: AppColors.gray700),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.children});

  final String title;
  final List<Widget> children;

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
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.gray500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: AppColors.gray900),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.document});

  final ProfessionalDocument document;

  @override
  Widget build(BuildContext context) {
    final status = _DocumentStatus.from(document.status);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: status.bg,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(Icons.description_outlined, color: status.fg),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _documentTypeLabel(document.type),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
                Text(
                  status.label,
                  style: TextStyle(fontSize: 11, color: status.fg),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.visibility_outlined),
            tooltip: document.storageUrl,
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(document.storageUrl)));
            },
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final data = _ValidationStatus.from(status);
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: data.bg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        data.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: data.fg,
        ),
      ),
    );
  }
}

class _RecentActions extends StatelessWidget {
  const _RecentActions({required this.actionsAsync});

  final AsyncValue<List<AdminAction>> actionsAsync;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Actividad reciente',
      children: [
        actionsAsync.when(
          data: (actions) {
            if (actions.isEmpty) {
              return const Text(
                'Aun no hay acciones administrativas.',
                style: TextStyle(fontSize: 13, color: AppColors.gray500),
              );
            }
            return Column(
              children: [
                for (final action in actions.take(5)) ...[
                  _InfoRow(
                    label: _actionLabel(action.actionType),
                    value: action.notes ?? action.targetId ?? '',
                  ),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(
            'Error cargando actividad: $e',
            style: const TextStyle(color: AppColors.dangerText),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 56),
          SizedBox(height: AppSpacing.md),
          Text('No hay solicitudes en esta categoria'),
        ],
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

class _Stats {
  const _Stats({
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  final int pending;
  final int approved;
  final int rejected;

  factory _Stats.from(List<Professional> professionals) {
    return _Stats(
      pending: professionals
          .where((p) => p.validationStatus == 'pending')
          .length,
      approved: professionals
          .where((p) => p.validationStatus == 'approved')
          .length,
      rejected: professionals
          .where((p) => p.validationStatus == 'rejected')
          .length,
    );
  }
}

class _ValidationStatus {
  const _ValidationStatus(this.label, this.bg, this.fg);

  final String label;
  final Color bg;
  final Color fg;

  static _ValidationStatus from(String value) {
    return switch (value) {
      'approved' => const _ValidationStatus(
        'Aprobado',
        AppColors.successBg,
        AppColors.successText,
      ),
      'rejected' => const _ValidationStatus(
        'Rechazado',
        AppColors.dangerBg,
        AppColors.dangerText,
      ),
      'suspended' => const _ValidationStatus(
        'Suspendido',
        AppColors.gray200,
        AppColors.gray700,
      ),
      _ => const _ValidationStatus(
        'Pendiente',
        AppColors.warningBg,
        AppColors.warningText,
      ),
    };
  }
}

class _DocumentStatus {
  const _DocumentStatus(this.label, this.bg, this.fg);

  final String label;
  final Color bg;
  final Color fg;

  static _DocumentStatus from(String value) {
    return switch (value) {
      'verified' => const _DocumentStatus(
        'Verificado',
        AppColors.successBg,
        AppColors.successText,
      ),
      'rejected' => const _DocumentStatus(
        'Rechazado',
        AppColors.dangerBg,
        AppColors.dangerText,
      ),
      _ => const _DocumentStatus(
        'Pendiente',
        AppColors.warningBg,
        AppColors.warningText,
      ),
    };
  }
}

String _specialties(Professional professional) {
  if (professional.specialties.isEmpty) return 'Sin especialidad registrada';
  return professional.specialties.map(_categoryLabel).join(' · ');
}

String _categoryLabel(String value) {
  return switch (value) {
    'enfermeria' => 'Enfermeria',
    'fisioterapia' => 'Fisioterapia',
    'cuidado' || 'cuidado_adulto_mayor' => 'Cuidado adulto mayor',
    'pediatria' => 'Pediatria',
    'acompanamiento' => 'Acompanamiento',
    _ => value.replaceAll('_', ' '),
  };
}

String _documentTypeLabel(String value) {
  return switch (value) {
    'id_card' => 'Documento de identidad',
    'license' => 'Tarjeta profesional',
    'certificate' => 'Certificado',
    _ => value.replaceAll('_', ' '),
  };
}

String _dateLabel(DateTime date) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year}';
}

String _actionLabel(String value) {
  return switch (value) {
    'approve_professional' => 'Aprobacion',
    'reject_professional' => 'Rechazo',
    'suspend_user' => 'Suspension',
    _ => 'Accion admin',
  };
}

String _actionMessage(String status) {
  return status == 'approved'
      ? 'Profesional aprobado'
      : 'Profesional rechazado';
}
