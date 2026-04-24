import '../../../data/models/service_request.dart';

class AnalyticsPoint {
  const AnalyticsPoint({required this.label, required this.value});

  final String label;
  final double value;

  Map<String, dynamic> toJson() => {'label': label, 'value': value};

  factory AnalyticsPoint.fromJson(Map<String, dynamic> json) {
    return AnalyticsPoint(
      label: json['label'] as String? ?? '',
      value: (json['value'] as num? ?? 0).toDouble(),
    );
  }
}

class AnalyticsFunnelStep {
  const AnalyticsFunnelStep({required this.label, required this.value});

  final String label;
  final int value;

  Map<String, dynamic> toJson() => {'label': label, 'value': value};

  factory AnalyticsFunnelStep.fromJson(Map<String, dynamic> json) {
    return AnalyticsFunnelStep(
      label: json['label'] as String? ?? '',
      value: (json['value'] as num? ?? 0).toInt(),
    );
  }
}

class AnalyticsSnapshot {
  const AnalyticsSnapshot({
    required this.title,
    required this.rangeLabel,
    required this.generatedAt,
    required this.totalRequests,
    required this.completedRequests,
    required this.activeRequests,
    required this.cancelledRequests,
    required this.revenue,
    required this.averageTicket,
    required this.completionRate,
    required this.cancellationRate,
    required this.requestsTrend,
    required this.revenueTrend,
    required this.weekdayDemand,
    required this.statusCounts,
    required this.funnel,
    required this.insights,
  });

  final String title;
  final String rangeLabel;
  final DateTime generatedAt;
  final int totalRequests;
  final int completedRequests;
  final int activeRequests;
  final int cancelledRequests;
  final double revenue;
  final double averageTicket;
  final double completionRate;
  final double cancellationRate;
  final List<AnalyticsPoint> requestsTrend;
  final List<AnalyticsPoint> revenueTrend;
  final List<AnalyticsPoint> weekdayDemand;
  final Map<String, int> statusCounts;
  final List<AnalyticsFunnelStep> funnel;
  final List<String> insights;

  bool get hasData => totalRequests > 0;

  factory AnalyticsSnapshot.fromRequests({
    required String title,
    required String rangeLabel,
    required DateTime start,
    required DateTime end,
    required List<ServiceRequest> requests,
  }) {
    final startDay = _dateOnly(start);
    final endDay = _dateOnly(end);
    final endExclusive = endDay.add(const Duration(days: 1));
    final filtered = requests.where((request) {
      final date = request.requestedDate;
      return !date.isBefore(startDay) && date.isBefore(endExclusive);
    }).toList();

    final days = <DateTime>[];
    for (
      var cursor = startDay;
      !cursor.isAfter(endDay);
      cursor = cursor.add(const Duration(days: 1))
    ) {
      days.add(cursor);
    }

    final requestsByDay = {for (final day in days) _dayKey(day): 0};
    final revenueByDay = {for (final day in days) _dayKey(day): 0.0};
    final weekdayCounts = <int, int>{for (var i = 1; i <= 7; i++) i: 0};
    final statusCounts = <String, int>{
      'CREATED': 0,
      'PENDING_CONFIRMATION': 0,
      'CONFIRMED': 0,
      'IN_PROGRESS': 0,
      'COMPLETED': 0,
      'CANCELLED': 0,
      'NO_SHOW': 0,
    };

    var completed = 0;
    var active = 0;
    var cancelled = 0;
    var revenue = 0.0;

    for (final request in filtered) {
      final key = _dayKey(request.requestedDate);
      requestsByDay[key] = (requestsByDay[key] ?? 0) + 1;
      weekdayCounts[request.requestedDate.weekday] =
          (weekdayCounts[request.requestedDate.weekday] ?? 0) + 1;
      statusCounts[request.status] = (statusCounts[request.status] ?? 0) + 1;

      if (_isCompleted(request.status)) {
        completed++;
        final price = request.priceQuoted ?? 0;
        revenue += price;
        revenueByDay[key] = (revenueByDay[key] ?? 0) + price;
      } else if (_isCancelled(request.status)) {
        cancelled++;
      } else {
        active++;
      }
    }

    final total = filtered.length;
    final averageTicket = completed == 0 ? 0.0 : revenue / completed;
    final completionRate = total == 0 ? 0.0 : completed / total;
    final cancellationRate = total == 0 ? 0.0 : cancelled / total;

    final requestsTrend = [
      for (final day in days)
        AnalyticsPoint(
          label: _shortDate(day),
          value: (requestsByDay[_dayKey(day)] ?? 0).toDouble(),
        ),
    ];
    final revenueTrend = [
      for (final day in days)
        AnalyticsPoint(
          label: _shortDate(day),
          value: revenueByDay[_dayKey(day)] ?? 0,
        ),
    ];
    final weekdayDemand = [
      for (var i = 1; i <= 7; i++)
        AnalyticsPoint(
          label: _weekdayLabel(i),
          value: weekdayCounts[i]!.toDouble(),
        ),
    ];

    final confirmedLike = filtered.where((request) {
      return request.status == 'CONFIRMED' ||
          request.status == 'IN_PROGRESS' ||
          request.status == 'COMPLETED';
    }).length;
    final startedLike = filtered.where((request) {
      return request.status == 'IN_PROGRESS' || request.status == 'COMPLETED';
    }).length;

    final funnel = [
      AnalyticsFunnelStep(label: 'Solicitadas', value: total),
      AnalyticsFunnelStep(label: 'Confirmadas', value: confirmedLike),
      AnalyticsFunnelStep(label: 'Iniciadas', value: startedLike),
      AnalyticsFunnelStep(label: 'Completadas', value: completed),
    ];

    return AnalyticsSnapshot(
      title: title,
      rangeLabel: rangeLabel,
      generatedAt: DateTime.now(),
      totalRequests: total,
      completedRequests: completed,
      activeRequests: active,
      cancelledRequests: cancelled,
      revenue: revenue,
      averageTicket: averageTicket,
      completionRate: completionRate,
      cancellationRate: cancellationRate,
      requestsTrend: requestsTrend,
      revenueTrend: revenueTrend,
      weekdayDemand: weekdayDemand,
      statusCounts: statusCounts,
      funnel: funnel,
      insights: _buildInsights(
        total: total,
        completionRate: completionRate,
        cancellationRate: cancellationRate,
        revenue: revenue,
        weekdayDemand: weekdayDemand,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'range_label': rangeLabel,
    'generated_at': generatedAt.millisecondsSinceEpoch,
    'total_requests': totalRequests,
    'completed_requests': completedRequests,
    'active_requests': activeRequests,
    'cancelled_requests': cancelledRequests,
    'revenue': revenue,
    'average_ticket': averageTicket,
    'completion_rate': completionRate,
    'cancellation_rate': cancellationRate,
    'requests_trend': requestsTrend.map((p) => p.toJson()).toList(),
    'revenue_trend': revenueTrend.map((p) => p.toJson()).toList(),
    'weekday_demand': weekdayDemand.map((p) => p.toJson()).toList(),
    'status_counts': statusCounts,
    'funnel': funnel.map((step) => step.toJson()).toList(),
    'insights': insights,
  };

  factory AnalyticsSnapshot.fromJson(Map<String, dynamic> json) {
    return AnalyticsSnapshot(
      title: json['title'] as String? ?? 'Dashboard',
      rangeLabel: json['range_label'] as String? ?? '',
      generatedAt: DateTime.fromMillisecondsSinceEpoch(
        json['generated_at'] as int? ?? 0,
      ),
      totalRequests: (json['total_requests'] as num? ?? 0).toInt(),
      completedRequests: (json['completed_requests'] as num? ?? 0).toInt(),
      activeRequests: (json['active_requests'] as num? ?? 0).toInt(),
      cancelledRequests: (json['cancelled_requests'] as num? ?? 0).toInt(),
      revenue: (json['revenue'] as num? ?? 0).toDouble(),
      averageTicket: (json['average_ticket'] as num? ?? 0).toDouble(),
      completionRate: (json['completion_rate'] as num? ?? 0).toDouble(),
      cancellationRate: (json['cancellation_rate'] as num? ?? 0).toDouble(),
      requestsTrend: _points(json['requests_trend']),
      revenueTrend: _points(json['revenue_trend']),
      weekdayDemand: _points(json['weekday_demand']),
      statusCounts: _intMap(json['status_counts']),
      funnel: _funnel(json['funnel']),
      insights: [
        for (final value in json['insights'] as List<dynamic>? ?? const [])
          value.toString(),
      ],
    );
  }
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

String _dayKey(DateTime value) {
  final date = _dateOnly(value);
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

String _shortDate(DateTime value) {
  return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}';
}

bool _isCompleted(String status) => status == 'COMPLETED';

bool _isCancelled(String status) =>
    status == 'CANCELLED' || status == 'NO_SHOW';

String _weekdayLabel(int weekday) {
  return switch (weekday) {
    1 => 'Lun',
    2 => 'Mar',
    3 => 'Mie',
    4 => 'Jue',
    5 => 'Vie',
    6 => 'Sab',
    _ => 'Dom',
  };
}

List<AnalyticsPoint> _points(Object? value) {
  return [
    for (final item in value as List<dynamic>? ?? const [])
      AnalyticsPoint.fromJson(Map<String, dynamic>.from(item as Map)),
  ];
}

List<AnalyticsFunnelStep> _funnel(Object? value) {
  return [
    for (final item in value as List<dynamic>? ?? const [])
      AnalyticsFunnelStep.fromJson(Map<String, dynamic>.from(item as Map)),
  ];
}

Map<String, int> _intMap(Object? value) {
  final map = value as Map<dynamic, dynamic>? ?? const {};
  return {
    for (final entry in map.entries)
      entry.key.toString(): (entry.value as num? ?? 0).toInt(),
  };
}

List<String> _buildInsights({
  required int total,
  required double completionRate,
  required double cancellationRate,
  required double revenue,
  required List<AnalyticsPoint> weekdayDemand,
}) {
  if (total == 0) {
    return const [
      'Aun no hay solicitudes en este rango.',
      'Cambia el filtro de fechas para revisar actividad historica.',
    ];
  }

  final strongestDay = [...weekdayDemand]
    ..sort((a, b) => b.value.compareTo(a.value));
  final peak = strongestDay.first;

  return [
    'El dia con mayor demanda es ${peak.label} con ${peak.value.toInt()} solicitudes.',
    'La tasa de finalizacion es ${(completionRate * 100).toStringAsFixed(0)}%.',
    'La tasa de cancelacion esta en ${(cancellationRate * 100).toStringAsFixed(0)}%.',
    'Los servicios completados suman ${_formatCurrency(revenue)} en el rango.',
  ];
}

String _formatCurrency(double value) {
  final formatted = value
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  return '\$$formatted';
}
