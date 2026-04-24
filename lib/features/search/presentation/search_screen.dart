import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/models/professional.dart';
import '../../../data/repositories/professionals_repository.dart';
import '../../../shared/widgets/professional_card.dart';

/// Categorías conocidas para filtrar. Debe coincidir con lo que guarda el seed
/// y con los valores almacenados en el campo `specialties` del documento.
const _kCategories = [
  ('Todas', null),
  ('Enfermería', 'enfermeria'),
  ('Cuidado', 'cuidado_adulto_mayor'),
  ('Fisioterapia', 'fisioterapia'),
  ('Pediatría', 'pediatria'),
  ('Acompañamiento', 'acompanamiento'),
];

/// Pantalla de búsqueda de profesionales.
///
/// Acepta opcionalmente `?category=<slug>` al entrar desde el Home. El query
/// principal contra Firestore es todos los aprobados, y filtramos + buscamos
/// en el cliente (los resultados son pocos y así evitamos más índices).
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({this.initialCategory, super.key});

  final String? initialCategory;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _category;
  bool _onlyAvailable = false;
  bool _onlyVerified = true;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topAsync = ref.watch(
      // Reusamos el stream existente. watchApproved trae los aprobados;
      // luego filtramos localmente según los toggles del usuario.
      _allApprovedProfessionalsProvider,
    );

    return Column(
      children: [
        // --- Search bar + toggle de filtros ---
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) =>
                          setState(() => _query = v.trim().toLowerCase()),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Buscar profesional...',
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.gray400, size: 20),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 44),
                        filled: true,
                        fillColor: AppColors.gray50,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          borderSide:
                              const BorderSide(color: AppColors.gray200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          borderSide:
                              const BorderSide(color: AppColors.gray200),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Material(
                    color: _showFilters
                        ? AppColors.violet600
                        : AppColors.violet50,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    child: InkWell(
                      onTap: () => setState(() => _showFilters = !_showFilters),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.tune,
                          color: _showFilters
                              ? Colors.white
                              : AppColors.violet600,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // --- Chips de categorías (scroll horizontal) ---
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _kCategories.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (_, i) {
                    final (label, slug) = _kCategories[i];
                    final selected = _category == slug;
                    return _CategoryChip(
                      label: label,
                      selected: selected,
                      onTap: () => setState(() => _category = slug),
                    );
                  },
                ),
              ),

              // --- Panel de filtros expandible ---
              if (_showFilters) ...[
                const SizedBox(height: AppSpacing.md),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.md),
                _FilterRow(
                  label: 'Solo disponibles ahora',
                  value: _onlyAvailable,
                  onChanged: (v) => setState(() => _onlyAvailable = v),
                ),
                _FilterRow(
                  label: 'Solo verificados',
                  value: _onlyVerified,
                  onChanged: (v) => setState(() => _onlyVerified = v),
                ),
              ],
            ],
          ),
        ),
        Container(height: 1, color: AppColors.border),

        // --- Resultados ---
        Expanded(
          child: topAsync.when(
            data: (all) {
              final filtered = _applyFilters(all);
              if (filtered.isEmpty) {
                return _EmptyResults(
                  hasQuery: _query.isNotEmpty || _category != null,
                  onClear: () => setState(() {
                    _searchCtrl.clear();
                    _query = '';
                    _category = null;
                    _onlyAvailable = false;
                  }),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (_, i) =>
                    ProfessionalCard(professional: filtered[i]),
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Text(
                  'Error cargando profesionales: $e',
                  style: const TextStyle(color: AppColors.dangerText),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Professional> _applyFilters(List<Professional> all) {
    return all.where((p) {
      // Filtro por categoría
      if (_category != null && !p.specialties.contains(_category)) {
        return false;
      }
      // Solo disponibles
      if (_onlyAvailable && !p.isAvailable) return false;
      // Solo verificados
      if (_onlyVerified && p.validationStatus != 'approved') return false;
      // Búsqueda por nombre (case-insensitive)
      if (_query.isNotEmpty &&
          !p.fullName.toLowerCase().contains(_query)) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
  }
}

/// Stream de todos los aprobados (limit alto). Lo definimos aparte para que
/// lo compartan Home y Search sin duplicar suscripciones.
final _allApprovedProfessionalsProvider =
    StreamProvider.autoDispose<List<Professional>>((ref) {
  return ref
      .watch(professionalsRepositoryProvider)
      .watchApproved(limit: 50);
});

// ---------------------------------------------------------------------------

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.violet600 : Colors.white,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: selected ? AppColors.violet600 : AppColors.gray200,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : AppColors.gray700,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.gray700,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.violet600,
          ),
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.hasQuery, required this.onClear});
  final bool hasQuery;
  final VoidCallback onClear;

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
                color: AppColors.gray100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off,
                  size: 32, color: AppColors.gray400),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              hasQuery
                  ? 'Sin resultados para tu búsqueda'
                  : 'Aún no hay profesionales disponibles',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.gray700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              hasQuery
                  ? 'Prueba con otros filtros o limpia la búsqueda'
                  : 'Pronto tendremos profesionales verificados en tu zona.',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.gray500,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasQuery) ...[
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Limpiar filtros'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
