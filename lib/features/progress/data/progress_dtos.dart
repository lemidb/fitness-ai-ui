import '../../../core/formatting/json_numbers.dart';

class ProgressTrend {
  const ProgressTrend({
    required this.direction,
    required this.slope,
    required this.projectedWeight,
  });

  final String direction;
  final double slope;
  final double projectedWeight;

  factory ProgressTrend.fromJson(Map<String, dynamic> json) {
    return ProgressTrend(
      direction: json['direction'] as String? ?? 'maintaining',
      slope: asDouble(json['slope']),
      projectedWeight: asDouble(json['projected_weight']),
    );
  }
}

class ProgressPr {
  const ProgressPr({required this.type, required this.value, required this.date});

  final String type;
  final double value;
  final DateTime? date;

  factory ProgressPr.fromJson(Map<String, dynamic> json) {
    return ProgressPr(
      type: json['type'] as String? ?? '',
      value: asDouble(json['value']),
      date: DateTime.tryParse(json['date'] as String? ?? ''),
    );
  }
}

class ProgressPoint {
  const ProgressPoint({
    required this.date,
    required this.maxWeight,
    required this.volume,
    required this.oneRm,
  });

  final DateTime date;
  final double maxWeight;
  final double volume;
  final double oneRm;

  factory ProgressPoint.fromJson(Map<String, dynamic> json) {
    return ProgressPoint(
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      maxWeight: asDouble(json['max_weight']),
      volume: asDouble(json['volume']),
      oneRm: asDouble(json['one_rm']),
    );
  }
}

class ProgressReport {
  const ProgressReport({
    required this.exercise,
    required this.totalWorkouts,
    required this.maxWeight,
    required this.avgWeight,
    required this.maxVolume,
    required this.avgVolume,
    required this.trend,
    required this.prs,
    required this.points,
  });

  final String exercise;
  final int totalWorkouts;
  final double maxWeight;
  final double avgWeight;
  final double maxVolume;
  final double avgVolume;
  final ProgressTrend? trend;
  final List<ProgressPr> prs;
  final List<ProgressPoint> points;

  factory ProgressReport.fromJson(Map<String, dynamic> json) {
    return ProgressReport(
      exercise: json['exercise'] as String? ?? '',
      totalWorkouts: asInt(json['total_workouts']),
      maxWeight: asDouble(json['max_weight']),
      avgWeight: asDouble(json['avg_weight']),
      maxVolume: asDouble(json['max_volume']),
      avgVolume: asDouble(json['avg_volume']),
      trend: json['trend'] is Map<String, dynamic>
          ? ProgressTrend.fromJson(json['trend'] as Map<String, dynamic>)
          : null,
      prs: (json['prs'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ProgressPr.fromJson)
          .toList(),
      points: (json['points'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ProgressPoint.fromJson)
          .toList(),
    );
  }
}
