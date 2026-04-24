import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/firebase_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/models/professional.dart';
import '../../../data/models/service.dart';
import '../../../data/models/service_request.dart';
import '../../../data/repositories/professionals_repository.dart';
import '../../../data/repositories/service_requests_repository.dart';
import '../../../data/repositories/services_repository.dart';
import '../../../shared/widgets/user_avatar.dart';

// ---------------------------------------------------------------------------
// Feature-local providers
// ---------------------------------------------------------------------------

final _bookingProProvider =
    StreamProvider.autoDispose.family<Professional?, String>(
  (ref, id) => ref.watch(professionalsRepositoryProvider).watchById(id),
);

final _bookingSvcProvider =
    StreamProvider.autoDispose.family<List<Service>, String>(
  (ref, id) => ref.watch(servicesRepositoryProvider).watchByProfessional(id),
);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({required this.professionalId, super.key});

  final String professionalId;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;
  String? _selectedTime;
  final Set<String> _selectedServiceIds = {};
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  static const _timeSlots = [
    '08:00 AM', '09:00 AM', '10:00 AM', '11:00 AM',
    '12:00 PM', '01:00 PM', '02:00 PM', '03:00 PM',
    '04:00 PM', '05:00 PM', '06:00 PM',
  ];

  static const _monthNames = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _addressController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _canConfirm =>
      _selectedDate != null &&
      _selectedTime != null &&
      _addressController.text.trim().isNotEmpty;

  List<DateTime?> _buildCalendarDays(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // Dart weekday: 1=Mon..7=Sun. Sunday-first layout: offset = weekday % 7.
    final startOffset = firstDay.weekday % 7;
    final days = <DateTime?>[
      for (var i = 0; i < startOffset; i++) null,
      for (var d = 1; d <= daysInMonth; d++)
        DateTime(month.year, month.month, d),
    ];
    return days;
  }

  bool _isAvailable(DateTime? date) {
    if (date == null) return false;
    final today = DateTime.now();
    final d = DateTime(date.year, date.month, date.day);
    return !d.isBefore(DateTime(today.year, today.month, today.day));
  }

  bool _isSelected(DateTime? date) {
    if (date == null || _selectedDate == null) return false;
    return date.year == _selectedDate!.year &&
        date.month == _selectedDate!.month &&
        date.day == _selectedDate!.day;
  }

  Future<void> _confirm(List<Service> services) async {
    if (!_canConfirm || _isSubmitting) return;
    final userId = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (userId == null) return;

    setState(() => _isSubmitting = true);
    try {
      // Parse hour/minute from slot string (e.g. "02:00 PM")
      final clean = _selectedTime!.replaceAll(' AM', '').replaceAll(' PM', '');
      var hour = int.parse(clean.split(':')[0]);
      final minute = int.parse(clean.split(':')[1]);
      if (_selectedTime!.contains('PM') && hour != 12) hour += 12;
      if (_selectedTime!.contains('AM') && hour == 12) hour = 0;

      final requestedDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        hour,
        minute,
      );

      // Primary service: first selected, or first available, or 'general'
      final primaryId = _selectedServiceIds.isNotEmpty
          ? _selectedServiceIds.first
          : (services.isNotEmpty ? services.first.id : 'general');

      final selectedServices =
          services.where((s) => _selectedServiceIds.contains(s.id)).toList();
      final totalPrice =
          selectedServices.fold(0.0, (acc, s) => acc + s.price);

      // Build description: notes + extra service names
      final extras = selectedServices
          .where((s) => s.id != primaryId)
          .map((s) => s.name)
          .join(', ');
      final parts = [
        if (_notesController.text.trim().isNotEmpty)
          _notesController.text.trim(),
        if (extras.isNotEmpty) 'Servicios adicionales: $extras',
      ];

      final now = DateTime.now();
      final request = ServiceRequest(
        id: '',
        userId: userId,
        professionalId: widget.professionalId,
        serviceId: primaryId,
        status: 'CREATED',
        requestType: 'manual',
        requestedDate: requestedDate,
        location: const GeoPoint(0, 0),
        locationAddress: _addressController.text.trim(),
        userNeedDescription: parts.isNotEmpty ? parts.join('\n') : null,
        priceQuoted: totalPrice > 0 ? totalPrice : null,
        currency: 'COP',
        createdAt: now,
        updatedAt: now,
      );

      final requestId =
          await ref.read(serviceRequestsRepositoryProvider).add(request);

      if (mounted) {
        context.pushReplacement('/booking-confirmation/$requestId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear la reserva: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final proAsync = ref.watch(_bookingProProvider(widget.professionalId));
    final svcAsync = ref.watch(_bookingSvcProvider(widget.professionalId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reservar servicio'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: proAsync.when(
        data: (professional) {
          if (professional == null) {
            return const Center(
              child: Text(
                'Profesional no encontrado',
                style: TextStyle(color: AppColors.gray500),
              ),
            );
          }
          final services = svcAsync.value ?? [];
          return _Body(
            professional: professional,
            services: services,
            currentMonth: _currentMonth,
            selectedDate: _selectedDate,
            selectedTime: _selectedTime,
            selectedServiceIds: _selectedServiceIds,
            addressController: _addressController,
            notesController: _notesController,
            isSubmitting: _isSubmitting,
            canConfirm: _canConfirm,
            monthNames: _monthNames,
            timeSlots: _timeSlots,
            buildDays: _buildCalendarDays,
            isAvailable: _isAvailable,
            isSelected: _isSelected,
            onPrevMonth: () => setState(() => _currentMonth =
                DateTime(_currentMonth.year, _currentMonth.month - 1)),
            onNextMonth: () => setState(() => _currentMonth =
                DateTime(_currentMonth.year, _currentMonth.month + 1)),
            onDateSelected: (d) =>
                setState(() { _selectedDate = d; _selectedTime = null; }),
            onTimeSelected: (t) => setState(() => _selectedTime = t),
            onServiceToggle: (id) => setState(() {
              _selectedServiceIds.contains(id)
                  ? _selectedServiceIds.remove(id)
                  : _selectedServiceIds.add(id);
            }),
            onConfirm: () => _confirm(services),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: const TextStyle(color: AppColors.dangerText)),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

class _Body extends StatelessWidget {
  const _Body({
    required this.professional,
    required this.services,
    required this.currentMonth,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedServiceIds,
    required this.addressController,
    required this.notesController,
    required this.isSubmitting,
    required this.canConfirm,
    required this.monthNames,
    required this.timeSlots,
    required this.buildDays,
    required this.isAvailable,
    required this.isSelected,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onDateSelected,
    required this.onTimeSelected,
    required this.onServiceToggle,
    required this.onConfirm,
  });

  final Professional professional;
  final List<Service> services;
  final DateTime currentMonth;
  final DateTime? selectedDate;
  final String? selectedTime;
  final Set<String> selectedServiceIds;
  final TextEditingController addressController;
  final TextEditingController notesController;
  final bool isSubmitting;
  final bool canConfirm;
  final List<String> monthNames;
  final List<String> timeSlots;
  final List<DateTime?> Function(DateTime) buildDays;
  final bool Function(DateTime?) isAvailable;
  final bool Function(DateTime?) isSelected;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final void Function(DateTime) onDateSelected;
  final void Function(String) onTimeSelected;
  final void Function(String) onServiceToggle;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            120,
          ),
          children: [
            _ProfessionalCard(professional: professional),
            const SizedBox(height: AppSpacing.lg),
            _CalendarSection(
              currentMonth: currentMonth,
              monthNames: monthNames,
              buildDays: buildDays,
              isAvailable: isAvailable,
              isSelected: isSelected,
              onPrevMonth: onPrevMonth,
              onNextMonth: onNextMonth,
              onDateSelected: onDateSelected,
            ),
            if (selectedDate != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _TimeSlotsSection(
                timeSlots: timeSlots,
                selectedTime: selectedTime,
                onTimeSelected: onTimeSelected,
              ),
            ],
            if (selectedTime != null) ...[
              if (services.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                _ServicesSection(
                  services: services,
                  selectedIds: selectedServiceIds,
                  onToggle: onServiceToggle,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              _AddressSection(controller: addressController),
              const SizedBox(height: AppSpacing.lg),
              _NotesSection(controller: notesController),
            ],
          ],
        ),
        if (canConfirm)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomBar(
              services: services,
              selectedServiceIds: selectedServiceIds,
              isSubmitting: isSubmitting,
              onConfirm: onConfirm,
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Professional card
// ---------------------------------------------------------------------------

class _ProfessionalCard extends StatelessWidget {
  const _ProfessionalCard({required this.professional});
  final Professional professional;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: SizedBox(
              width: 64,
              height: 64,
              child: professional.photoUrl?.isNotEmpty == true
                  ? Image.network(
                      professional.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _Fallback(name: professional.fullName),
                    )
                  : _Fallback(name: professional.fullName),
            ),
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
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  professional.specialties
                      .take(2)
                      .map(_readableSpecialty)
                      .join(' · '),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _readableSpecialty(String s) => switch (s) {
        'enfermeria' => 'Enfermería',
        'cuidado' || 'cuidado_adulto_mayor' => 'Cuidado adulto mayor',
        'fisioterapia' => 'Fisioterapia',
        'rehabilitacion' => 'Rehabilitación',
        'pediatria' => 'Pediatría',
        'acompanamiento' => 'Acompañamiento',
        _ => s.replaceAll('_', ' '),
      };
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.violet100,
      alignment: Alignment.center,
      child: UserAvatar(name: name, size: 64),
    );
  }
}

// ---------------------------------------------------------------------------
// Calendar
// ---------------------------------------------------------------------------

class _CalendarSection extends StatelessWidget {
  const _CalendarSection({
    required this.currentMonth,
    required this.monthNames,
    required this.buildDays,
    required this.isAvailable,
    required this.isSelected,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onDateSelected,
  });

  final DateTime currentMonth;
  final List<String> monthNames;
  final List<DateTime?> Function(DateTime) buildDays;
  final bool Function(DateTime?) isAvailable;
  final bool Function(DateTime?) isSelected;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final void Function(DateTime) onDateSelected;

  @override
  Widget build(BuildContext context) {
    final days = buildDays(currentMonth);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Selecciona una fecha',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray900,
                  ),
                ),
              ),
              _NavButton(icon: Icons.chevron_left, onTap: onPrevMonth),
              const SizedBox(width: 4),
              SizedBox(
                width: 136,
                child: Text(
                  '${monthNames[currentMonth.month - 1]} ${currentMonth.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray900,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _NavButton(icon: Icons.chevron_right, onTap: onNextMonth),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Day-of-week headers
          Row(
            children: ['D', 'L', 'M', 'M', 'J', 'V', 'S']
                .map(
                  (label) => Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.gray500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Days grid
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: days.map((date) {
              if (date == null) return const SizedBox.shrink();
              final available = isAvailable(date);
              final selected = isSelected(date);
              return GestureDetector(
                onTap: available ? () => onDateSelected(date) : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: selected ? AppColors.violet600 : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 13,
                      color: selected
                          ? Colors.white
                          : available
                              ? AppColors.gray900
                              : AppColors.gray300,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Icon(icon, size: 18, color: AppColors.gray700),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Time slots
// ---------------------------------------------------------------------------

class _TimeSlotsSection extends StatelessWidget {
  const _TimeSlotsSection({
    required this.timeSlots,
    required this.selectedTime,
    required this.onTimeSelected,
  });

  final List<String> timeSlots;
  final String? selectedTime;
  final void Function(String) onTimeSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecciona una hora',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 2.6,
            children: timeSlots.map((slot) {
              final selected = slot == selectedTime;
              return GestureDetector(
                onTap: () => onTimeSelected(slot),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  decoration: BoxDecoration(
                    color:
                        selected ? AppColors.violet600 : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    border: Border.all(
                      color: selected
                          ? AppColors.violet600
                          : AppColors.gray300,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    slot,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          selected ? Colors.white : AppColors.gray900,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Additional services
// ---------------------------------------------------------------------------

class _ServicesSection extends StatelessWidget {
  const _ServicesSection({
    required this.services,
    required this.selectedIds,
    required this.onToggle,
  });

  final List<Service> services;
  final Set<String> selectedIds;
  final void Function(String) onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Servicios adicionales (opcional)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...services.map(
            (service) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _ServiceItem(
                service: service,
                selected: selectedIds.contains(service.id),
                onTap: () => onToggle(service.id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  const _ServiceItem({
    required this.service,
    required this.selected,
    required this.onTap,
  });

  final Service service;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.violet50 : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: selected ? AppColors.violet600 : AppColors.border,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '+${_formatPrice(service.price)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    selected ? AppColors.violet600 : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? AppColors.violet600
                      : AppColors.gray300,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check,
                      size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  static String _formatPrice(double p) {
    return '\$${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }
}

// ---------------------------------------------------------------------------
// Address
// ---------------------------------------------------------------------------

class _AddressSection extends StatelessWidget {
  const _AddressSection({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dirección',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 14),
                child: Icon(Icons.location_on_outlined,
                    size: 20, color: AppColors.gray400),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Ingresa tu dirección completa',
                    hintStyle: const TextStyle(
                        color: AppColors.gray400, fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      borderSide:
                          const BorderSide(color: AppColors.gray300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      borderSide:
                          const BorderSide(color: AppColors.gray300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      borderSide: const BorderSide(
                          color: AppColors.violet500, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
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

// ---------------------------------------------------------------------------
// Notes
// ---------------------------------------------------------------------------

class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notas adicionales (opcional)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'Describe brevemente tu necesidad o alguna instrucción especial...',
              hintStyle:
                  const TextStyle(color: AppColors.gray400, fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                borderSide: const BorderSide(color: AppColors.gray300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                borderSide: const BorderSide(color: AppColors.gray300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                borderSide: const BorderSide(
                    color: AppColors.violet500, width: 2),
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.md),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom bar
// ---------------------------------------------------------------------------

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.services,
    required this.selectedServiceIds,
    required this.isSubmitting,
    required this.onConfirm,
  });

  final List<Service> services;
  final Set<String> selectedServiceIds;
  final bool isSubmitting;
  final VoidCallback onConfirm;

  double get _total => services
      .where((s) => selectedServiceIds.contains(s.id))
      .fold(0.0, (acc, s) => acc + s.price);

  @override
  Widget build(BuildContext context) {
    final total = _total;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (total > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total a pagar',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.gray600),
                ),
                Text(
                  '\$${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.violet600,
                disabledBackgroundColor:
                    AppColors.violet600.withValues(alpha: 0.6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                elevation: 0,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Confirmar reserva',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
