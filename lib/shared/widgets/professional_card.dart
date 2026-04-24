import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/models/professional.dart';
import 'nexuly_badge.dart';
import 'user_avatar.dart';

/// Card de profesional usado en Home (recomendados) y Search.
///
/// Muestra avatar, nombre, especialidad, rating, precio aproximado (si se
/// pasa) y un badge de disponibilidad. Tap navega al detalle.
class ProfessionalCard extends StatelessWidget {
  const ProfessionalCard({
    required this.professional,
    this.fromPrice,
    super.key,
  });

  final Professional professional;
  final double? fromPrice;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        onTap: () => context.go('/professional/${professional.uid}'),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar con badge de verificación
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: _Avatar(professional: professional),
                    ),
                  ),
                  if (professional.validationStatus == 'approved')
                    const Positioned(
                      top: -4,
                      right: -4,
                      child: _VerifiedBadge(),
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre + estado
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            professional.fullName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        if (professional.isAvailable)
                          const NexulyBadge.success(
                            label: 'Ahora',
                            dot: true,
                          )
                        else
                          const NexulyBadge.neutral(label: 'No disp.'),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _specialtyLabel(professional.specialties),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Rating + métricas
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 14, color: Color(0xFFFBBF24)),
                        const SizedBox(width: 2),
                        Text(
                          professional.ratingAvg.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.gray800,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '(${professional.ratingCount})',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.gray500,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        if (professional.coverageRadiusKm != null) ...[
                          const Icon(Icons.location_on_outlined,
                              size: 13, color: AppColors.gray500),
                          const SizedBox(width: 2),
                          Text(
                            '${professional.coverageRadiusKm!.toStringAsFixed(0)} km',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.gray500,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Precio + CTA
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (fromPrice != null)
                          Text(
                            _formatPrice(fromPrice!),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.violet600,
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.violet600,
                            borderRadius:
                                BorderRadius.circular(AppRadii.pill),
                          ),
                          child: const Text(
                            'Ver perfil',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _specialtyLabel(List<String> specialties) {
    if (specialties.isEmpty) return 'Sin especialidad';
    return specialties.map(_readableSpecialty).join(' · ');
  }

  static String _readableSpecialty(String s) {
    switch (s) {
      case 'enfermeria':
        return 'Enfermería';
      case 'cuidado':
      case 'cuidado_adulto_mayor':
        return 'Cuidado';
      case 'fisioterapia':
        return 'Fisioterapia';
      case 'rehabilitacion':
        return 'Rehabilitación';
      case 'pediatria':
        return 'Pediatría';
      case 'acompanamiento':
        return 'Acompañamiento';
      default:
        return s[0].toUpperCase() + s.substring(1);
    }
  }

  static String _formatPrice(double p) {
    // Formato simple en COP: "$50.000/hora"
    final thousands = p.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return '\$$thousands/hora';
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.professional});
  final Professional professional;

  @override
  Widget build(BuildContext context) {
    if (professional.photoUrl != null && professional.photoUrl!.isNotEmpty) {
      return Image.network(
        professional.photoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      color: AppColors.violet100,
      child: Center(
        child: UserAvatar(
          name: professional.fullName,
          size: 80,
        ),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: AppColors.violet600,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Icon(Icons.check, size: 12, color: Colors.white),
    );
  }
}
