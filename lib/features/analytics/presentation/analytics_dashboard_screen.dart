import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';

import '../../../core/providers/firebase_providers.dart';
import '../../../core/storage/local_cache.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/models/service_request.dart';
import '../../../data/repositories/service_requests_repository.dart';
import '../domain/analytics_models.dart';

enum AnalyticsDashboardMode { admin, professional }

final _adminAnalyticsRequestsProvider =
    StreamProvider.autoDispose<List<ServiceRequest>>((ref) {
      return ref.watch(serviceRequestsRepositoryProvider).watchRecent();
    });

final _professionalAnalyticsRequestsProvider = StreamProvider.autoDispose
    .family<List<ServiceRequest>, String>((ref, uid) {
      return ref
          .watch(serviceRequestsRepositoryProvider)
          .watchByProfessional(uid, limit: 400);
    });

enum _DatePreset { today, week, month, custom }

class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({required this.mode, super.key});

  final AnalyticsDashboardMode mode;

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState
    extends ConsumerState<AnalyticsDashboardScreen> {
  final _screenshotController = ScreenshotController();
  _DatePreset _preset = _DatePreset.week;
  DateTimeRange? _customRange;
  String? _lastCacheSignature;
  bool _isExporting = false;

  bool get _isAdmin => widget.mode == AnalyticsDashboardMode.admin;

  @override
  Widget build(BuildContext context) {
    final professionalUid = ref.watch(firebaseAuthProvider).currentUser?.uid;
    final requestsAsync = _isAdmin
        ? ref.watch(_adminAnalyticsRequestsProvider)
        : professionalUid == null
        ? const AsyncValue<List<ServiceRequest>>.data([])
        : ref.watch(_professionalAnalyticsRequestsProvider(professionalUid));
    final cacheKey = _isAdmin
        ? CacheKeys.analyticsAdminSnapshot
        : CacheKeys.analyticsProfessionalSnapshot(professionalUid ?? 'local');

    final body = requestsAsync.when(
      data: (requests) {
        final range = _currentRange();
        final snapshot = AnalyticsSnapshot.fromRequests(
          title: _isAdmin ? 'Analiticas generales' : 'Mis analiticas',
          rangeLabel: range.label,
          start: range.start,
          end: range.end,
          requests: requests,
        );
        _cacheSnapshot(cacheKey, snapshot);
        return _DashboardBody(
          controller: _screenshotController,
          snapshot: snapshot,
          preset: _preset,
          isCached: false,
          isExporting: _isExporting,
          onPresetChanged: _setPreset,
          onExport: () => _exportPdf(snapshot),
          onRefresh: _refresh,
        );
      },
      loading: () {
        final cached = _readCachedSnapshot(cacheKey);
        if (cached != null) {
          return _DashboardBody(
            controller: _screenshotController,
            snapshot: cached,
            preset: _preset,
            isCached: true,
            isExporting: _isExporting,
            onPresetChanged: _setPreset,
            onExport: () => _exportPdf(cached),
            onRefresh: _refresh,
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
      error: (error, _) {
        final cached = _readCachedSnapshot(cacheKey);
        if (cached != null) {
          return _DashboardBody(
            controller: _screenshotController,
            snapshot: cached,
            preset: _preset,
            isCached: true,
            isExporting: _isExporting,
            onPresetChanged: _setPreset,
            onExport: () => _exportPdf(cached),
            onRefresh: _refresh,
          );
        }
        return _DashboardError(message: 'Error cargando analiticas: $error');
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _isAdmin
          ? AppBar(
              title: const Text('Dashboard'),
              actions: [
                IconButton(
                  tooltip: 'Exportar PDF',
                  onPressed: _isExporting ? null : () => _exportCurrentCache(),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                ),
              ],
            )
          : null,
      body: body,
    );
  }

  Future<void> _refresh() async {
    if (_isAdmin) {
      ref.invalidate(_adminAnalyticsRequestsProvider);
    } else {
      final uid = ref.read(firebaseAuthProvider).currentUser?.uid;
      if (uid != null) {
        ref.invalidate(_professionalAnalyticsRequestsProvider(uid));
      }
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  void _setPreset(_DatePreset preset) async {
    if (preset == _DatePreset.custom) {
      final now = DateTime.now();
      final initial =
          _customRange ??
          DateTimeRange(start: now.subtract(const Duration(days: 6)), end: now);
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(now.year - 2),
        lastDate: now.add(const Duration(days: 1)),
        initialDateRange: initial,
      );
      if (picked == null) return;
      setState(() {
        _customRange = picked;
        _preset = preset;
      });
      return;
    }
    setState(() => _preset = preset);
  }

  _DashboardRange _currentRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (_preset) {
      _DatePreset.today => _DashboardRange(
        start: today,
        end: today,
        label: 'Hoy',
      ),
      _DatePreset.month => _DashboardRange(
        start: today.subtract(const Duration(days: 29)),
        end: today,
        label: 'Ultimos 30 dias',
      ),
      _DatePreset.custom => _DashboardRange(
        start: _customRange?.start ?? today.subtract(const Duration(days: 6)),
        end: _customRange?.end ?? today,
        label: _customRange == null
            ? 'Personalizado'
            : '${_shortDate(_customRange!.start)} - ${_shortDate(_customRange!.end)}',
      ),
      _ => _DashboardRange(
        start: today.subtract(const Duration(days: 6)),
        end: today,
        label: 'Ultimos 7 dias',
      ),
    };
  }

  AnalyticsSnapshot? _readCachedSnapshot(String key) {
    final json = ref
        .read(localCacheProvider)
        .getJson<Map<String, dynamic>>(key);
    if (json == null) return null;
    return AnalyticsSnapshot.fromJson(json);
  }

  void _cacheSnapshot(String key, AnalyticsSnapshot snapshot) {
    final signature =
        '$key-${snapshot.rangeLabel}-${snapshot.totalRequests}-${snapshot.revenue}-${snapshot.statusCounts}';
    if (_lastCacheSignature == signature) return;
    _lastCacheSignature = signature;
    unawaited(ref.read(localCacheProvider).putJson(key, snapshot.toJson()));
  }

  Future<void> _exportCurrentCache() async {
    final uid = ref.read(firebaseAuthProvider).currentUser?.uid;
    final key = _isAdmin
        ? CacheKeys.analyticsAdminSnapshot
        : CacheKeys.analyticsProfessionalSnapshot(uid ?? 'local');
    final cached = _readCachedSnapshot(key);
    if (cached != null) await _exportPdf(cached);
  }

  Future<void> _exportPdf(AnalyticsSnapshot snapshot) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      final imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 120),
        pixelRatio: 2,
      );
      if (imageBytes == null) return;

      final document = pw.Document();
      final image = pw.MemoryImage(imageBytes);
      document.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(18),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                snapshot.title,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text('Rango: ${snapshot.rangeLabel}'),
              pw.SizedBox(height: 12),
              pw.Expanded(child: pw.Image(image, fit: pw.BoxFit.contain)),
            ],
          ),
        ),
      );

      await Printing.sharePdf(
        bytes: await document.save(),
        filename:
            'nexuly_dashboard_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}

class _DashboardRange {
  const _DashboardRange({
    required this.start,
    required this.end,
    required this.label,
  });

  final DateTime start;
  final DateTime end;
  final String label;
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.controller,
    required this.snapshot,
    required this.preset,
    required this.isCached,
    required this.isExporting,
    required this.onPresetChanged,
    required this.onExport,
    required this.onRefresh,
  });

  final ScreenshotController controller;
  final AnalyticsSnapshot snapshot;
  final _DatePreset preset;
  final bool isCached;
  final bool isExporting;
  final ValueChanged<_DatePreset> onPresetChanged;
  final VoidCallback onExport;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Screenshot(
        controller: controller,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _DashboardHeader(
              snapshot: snapshot,
              isCached: isCached,
              isExporting: isExporting,
              onExport: onExport,
            ),
            const SizedBox(height: AppSpacing.lg),
            _DateFilters(active: preset, onChanged: onPresetChanged),
            const SizedBox(height: AppSpacing.lg),
            _KpiGrid(snapshot: snapshot),
            const SizedBox(height: AppSpacing.lg),
            _InsightsCard(snapshot: snapshot),
            const SizedBox(height: AppSpacing.lg),
            _ResponsiveCharts(snapshot: snapshot),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.snapshot,
    required this.isCached,
    required this.isExporting,
    required this.onExport,
  });

  final AnalyticsSnapshot snapshot;
  final bool isCached;
  final bool isExporting;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradientSoft,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snapshot.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      snapshot.rangeLabel,
                      style: const TextStyle(
                        color: AppColors.gray300,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filled(
                tooltip: 'Exportar PDF',
                onPressed: isExporting ? null : onExport,
                icon: isExporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.ios_share_outlined),
              ),
            ],
          ),
          if (isCached) ...[
            const SizedBox(height: AppSpacing.md),
            const _CachedBadge(),
          ],
        ],
      ),
    );
  }
}

class _CachedBadge extends StatelessWidget {
  const _CachedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: const Text(
        'Mostrando ultimo snapshot local',
        style: TextStyle(
          color: AppColors.warningText,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DateFilters extends StatelessWidget {
  const _DateFilters({required this.active, required this.onChanged});

  final _DatePreset active;
  final ValueChanged<_DatePreset> onChanged;

  static const _items = [
    (_DatePreset.today, 'Hoy'),
    (_DatePreset.week, 'Semana'),
    (_DatePreset.month, 'Mes'),
    (_DatePreset.custom, 'Rango'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final (preset, label) = _items[index];
          final selected = active == preset;
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            selectedColor: AppColors.violet600,
            onSelected: (_) => onChanged(preset),
            labelStyle: TextStyle(
              color: selected ? Colors.white : AppColors.gray700,
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.snapshot});

  final AnalyticsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final items = [
      _KpiData(
        'Solicitudes',
        '${snapshot.totalRequests}',
        Icons.inbox_outlined,
      ),
      _KpiData(
        'Completadas',
        '${snapshot.completedRequests}',
        Icons.check_circle_outline,
      ),
      _KpiData('Ingresos', _formatCurrency(snapshot.revenue), Icons.payments),
      _KpiData(
        'Finalizacion',
        '${(snapshot.completionRate * 100).toStringAsFixed(0)}%',
        Icons.trending_up,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - AppSpacing.md) / 2;
        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final item in items)
              SizedBox(width: width, child: _KpiCard(item)),
          ],
        );
      },
    );
  }
}

class _KpiData {
  const _KpiData(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard(this.data);

  final _KpiData data;

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
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.infoBg,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Icon(data.icon, color: AppColors.infoText, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.gray500,
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

class _InsightsCard extends StatelessWidget {
  const _InsightsCard({required this.snapshot});

  final AnalyticsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Insights',
      child: Column(
        children: [
          for (final insight in snapshot.insights) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: AppColors.violet600,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    insight,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.gray700,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _ResponsiveCharts extends StatelessWidget {
  const _ResponsiveCharts({required this.snapshot});

  final AnalyticsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final charts = [
      _Panel(title: 'Ingresos por dia', child: _RevenueBarChart(snapshot)),
      _Panel(
        title: 'Solicitudes en el tiempo',
        child: _RequestsLineChart(snapshot),
      ),
      _Panel(
        title: 'Distribucion por estado',
        child: _StatusPieChart(snapshot),
      ),
      _Panel(title: 'Embudo de atencion', child: _FunnelChart(snapshot)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return Column(
            children: [
              for (final chart in charts) ...[
                chart,
                const SizedBox(height: AppSpacing.lg),
              ],
            ],
          );
        }
        return Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.lg,
          children: [
            for (final chart in charts)
              SizedBox(
                width: (constraints.maxWidth - AppSpacing.lg) / 2,
                child: chart,
              ),
          ],
        );
      },
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

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
              fontWeight: FontWeight.w800,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class _RevenueBarChart extends StatelessWidget {
  const _RevenueBarChart(this.snapshot);

  final AnalyticsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final points = snapshot.revenueTrend;
    if (!snapshot.hasData) return const _NoChartData();
    final maxY = math.max(1.0, points.map((p) => p.value).fold(0.0, math.max));
    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: maxY * 1.2,
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          titlesData: _axisTitles(points, leftFormatter: _shortMoney),
          barGroups: [
            for (var i = 0; i < points.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: points[i].value,
                    width: 14,
                    color: AppColors.info,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _RequestsLineChart extends StatelessWidget {
  const _RequestsLineChart(this.snapshot);

  final AnalyticsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final points = snapshot.requestsTrend;
    if (!snapshot.hasData) return const _NoChartData();
    final maxY = math.max(1.0, points.map((p) => p.value).fold(0.0, math.max));
    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY * 1.25,
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          titlesData: _axisTitles(points),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < points.length; i++)
                  FlSpot(i.toDouble(), points[i].value),
              ],
              isCurved: true,
              barWidth: 3,
              color: AppColors.violet600,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.violet100.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPieChart extends StatelessWidget {
  const _StatusPieChart(this.snapshot);

  final AnalyticsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final entries = snapshot.statusCounts.entries
        .where((e) => e.value > 0)
        .toList();
    if (entries.isEmpty) return const _NoChartData();
    return SizedBox(
      height: 220,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 34,
                sectionsSpace: 2,
                sections: [
                  for (final entry in entries)
                    PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${entry.value}',
                      radius: 58,
                      color: _statusColor(entry.key),
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _statusColor(entry.key),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            _statusLabel(entry.key),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.gray600,
                            ),
                          ),
                        ),
                      ],
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

class _FunnelChart extends StatelessWidget {
  const _FunnelChart(this.snapshot);

  final AnalyticsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (!snapshot.hasData) return const _NoChartData();
    final maxValue = math.max(
      1,
      snapshot.funnel.map((s) => s.value).fold(0, math.max),
    );
    return SizedBox(
      height: 220,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final step in snapshot.funnel) ...[
            Row(
              children: [
                SizedBox(
                  width: 92,
                  child: Text(
                    step.label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gray600,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    child: LinearProgressIndicator(
                      minHeight: 16,
                      value: step.value / maxValue,
                      backgroundColor: AppColors.gray100,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.success,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                SizedBox(
                  width: 32,
                  child: Text(
                    '${step.value}',
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _NoChartData extends StatelessWidget {
  const _NoChartData();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 220,
      child: Center(
        child: Text(
          'Sin datos en este rango',
          style: TextStyle(color: AppColors.gray500, fontSize: 13),
        ),
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.dangerText),
        ),
      ),
    );
  }
}

FlTitlesData _axisTitles(
  List<AnalyticsPoint> points, {
  String Function(double value)? leftFormatter,
}) {
  final step = math.max(1, (points.length / 5).ceil());
  return FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 42,
        getTitlesWidget: (value, meta) {
          final label = leftFormatter?.call(value) ?? value.toStringAsFixed(0);
          return Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.gray500),
          );
        },
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30,
        getTitlesWidget: (value, meta) {
          final index = value.toInt();
          if (index < 0 || index >= points.length) {
            return const SizedBox.shrink();
          }
          if (index % step != 0 && index != points.length - 1) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              points[index].label,
              style: const TextStyle(fontSize: 10, color: AppColors.gray500),
            ),
          );
        },
      ),
    ),
  );
}

Color _statusColor(String status) {
  return switch (status) {
    'COMPLETED' => AppColors.success,
    'CANCELLED' || 'NO_SHOW' => AppColors.danger,
    'IN_PROGRESS' => AppColors.info,
    'CONFIRMED' => AppColors.violet600,
    'PENDING_CONFIRMATION' => AppColors.warning,
    _ => AppColors.gray400,
  };
}

String _statusLabel(String status) {
  return switch (status) {
    'CREATED' => 'Creada',
    'PENDING_ASSIGNMENT' => 'Buscando pro',
    'PENDING_CONFIRMATION' => 'Por confirmar',
    'CONFIRMED' => 'Confirmada',
    'IN_PROGRESS' => 'En curso',
    'COMPLETED' => 'Completada',
    'CANCELLED' => 'Cancelada',
    'NO_SHOW' => 'No asistio',
    _ => status,
  };
}

String _shortDate(DateTime value) {
  return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}';
}

String _formatCurrency(double value) {
  final formatted = value
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  return '\$$formatted';
}

String _shortMoney(double value) {
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}k';
  return value.toStringAsFixed(0);
}
