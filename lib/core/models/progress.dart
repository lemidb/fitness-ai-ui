class ProgressPoint {
  final String date;
  final double maxWeight;
  final double volume;
  final double oneRm;

  ProgressPoint({
    required this.date,
    required this.maxWeight,
    required this.volume,
    required this.oneRm,
  });

  factory ProgressPoint.fromJson(Map<String, dynamic> json) {
    return ProgressPoint(
      date: json['date']?.toString() ?? '',
      maxWeight: (json['max_weight'] as num?)?.toDouble() ?? 0.0,
      volume: (json['volume'] as num?)?.toDouble() ?? 0.0,
      oneRm: (json['one_rm'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ProgressTrend {
  final String direction;
  final double slope;
  final double projectedWeight;

  ProgressTrend({
    required this.direction,
    required this.slope,
    required this.projectedWeight,
  });

  factory ProgressTrend.fromJson(Map<String, dynamic> json) {
    return ProgressTrend(
      direction: json['direction']?.toString() ?? 'maintaining',
      slope: (json['slope'] as num?)?.toDouble() ?? 0.0,
      projectedWeight: (json['projected_weight'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ProgressPR {
  final String type;
  final double value;
  final String date;

  ProgressPR({
    required this.type,
    required this.value,
    required this.date,
  });

  factory ProgressPR.fromJson(Map<String, dynamic> json) {
    return ProgressPR(
      type: json['type']?.toString() ?? 'pr',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      date: json['date']?.toString() ?? '',
    );
  }
}

class ProgressData {
  final String exercise;
  final int totalWorkouts;
  final double maxWeight;
  final double avgWeight;
  final double maxVolume;
  final double avgVolume;
  final ProgressTrend trend;
  final List<ProgressPR> prs;
  final List<ProgressPoint> points;

  ProgressData({
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

  factory ProgressData.fromJson(Map<String, dynamic> json) {
    var prsList = json['prs'] as List?;
    var pointsList = json['points'] as List?;

    return ProgressData(
      exercise: json['exercise']?.toString() ?? 'Unknown',
      totalWorkouts: (json['total_workouts'] as num?)?.toInt() ?? 0,
      maxWeight: (json['max_weight'] as num?)?.toDouble() ?? 0.0,
      avgWeight: (json['avg_weight'] as num?)?.toDouble() ?? 0.0,
      maxVolume: (json['max_volume'] as num?)?.toDouble() ?? 0.0,
      avgVolume: (json['avg_volume'] as num?)?.toDouble() ?? 0.0,
      trend: ProgressTrend.fromJson((json['trend'] as Map<String, dynamic>?) ?? {}),
      prs: prsList != null
          ? prsList.map((e) => ProgressPR.fromJson(e as Map<String, dynamic>)).toList()
          : [],
      points: pointsList != null
          ? pointsList.map((e) => ProgressPoint.fromJson(e as Map<String, dynamic>)).toList()
          : [],
    );
  }
}
