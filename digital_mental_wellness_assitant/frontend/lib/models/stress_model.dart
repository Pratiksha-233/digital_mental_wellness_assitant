import 'package:flutter/material.dart';


class StressData {
  final double stressLevel;
  final String stressCategory;
  final String primaryEmotion;
  final int energyLevel;
  final String moodPattern;
  final List<String> recommendations;
  final List<ContributingFactor> contributingFactors;
  final ComponentScores componentScores;
  final DateTime timestamp;

  StressData({
    required this.stressLevel,
    required this.stressCategory,
    required this.primaryEmotion,
    required this.energyLevel,
    required this.moodPattern,
    required this.recommendations,
    required this.contributingFactors,
    required this.componentScores,
    required this.timestamp,
  });

  factory StressData.fromJson(Map<String, dynamic> json) {
    return StressData(
      stressLevel: (json['stress_level'] as num).toDouble(),
      stressCategory: json['stress_category'] as String,
      primaryEmotion: json['primary_emotion'] as String,
      energyLevel: json['energy_level'] as int,
      moodPattern: json['mood_pattern'] as String,
      recommendations: List<String>.from(json['recommendations'] as List),
      contributingFactors: (json['contributing_factors'] as List)
          .map((f) => ContributingFactor.fromJson(f))
          .toList(),
      componentScores: ComponentScores.fromJson(json['component_scores']),
      timestamp: DateTime.now(),
    );
  }


  Color get categoryColor {
    switch (stressCategory) {
      case 'LOW':
        return Colors.green;
      case 'MODERATE':
        return Colors.amber;
      case 'HIGH':
        return Colors.orange;
      case 'CRITICAL':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }


  String get categoryEmoji {
    switch (stressCategory) {
      case 'LOW':
        return '🟢';
      case 'MODERATE':
        return '🟡';
      case 'HIGH':
        return '🟠';
      case 'CRITICAL':
        return '🔴';
      default:
        return '⚪';
    }
  }
}

class ContributingFactor {
  final String factor;
  final double contribution;

  ContributingFactor({required this.factor, required this.contribution});

  factory ContributingFactor.fromJson(Map<String, dynamic> json) {
    return ContributingFactor(
      factor: json['factor'] as String,
      contribution: (json['contribution'] as num).toDouble(),
    );
  }
}

class ComponentScores {
  final double emotionScore;
  final double moodScore;
  final double energyScore;
  final double activityScore;
  final double trendScore;

  ComponentScores({
    required this.emotionScore,
    required this.moodScore,
    required this.energyScore,
    required this.activityScore,
    required this.trendScore,
  });

  factory ComponentScores.fromJson(Map<String, dynamic> json) {
    return ComponentScores(
      emotionScore: (json['emotion_score'] as num).toDouble(),
      moodScore: (json['mood_score'] as num).toDouble(),
      energyScore: (json['energy_score'] as num).toDouble(),
      activityScore: (json['activity_score'] as num).toDouble(),
      trendScore: (json['trend_score'] as num).toDouble(),
    );
  }
}

class StressHistoryRecord {
  final int stressId;
  final int userId;
  final double stressLevel;
  final String stressCategory;
  final String primaryEmotion;
  final int energyLevel;
  final String moodPattern;
  final DateTime timestamp;

  StressHistoryRecord({
    required this.stressId,
    required this.userId,
    required this.stressLevel,
    required this.stressCategory,
    required this.primaryEmotion,
    required this.energyLevel,
    required this.moodPattern,
    required this.timestamp,
  });

  factory StressHistoryRecord.fromJson(Map<String, dynamic> json) {
    final energyRaw = json['energy_level'];
    final energy = energyRaw is int
        ? energyRaw
        : int.tryParse(energyRaw?.toString() ?? '') ?? 0;
    return StressHistoryRecord(
      stressId: int.tryParse(json['stress_id']?.toString() ?? '') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      stressLevel:
          (json['stress_level'] as num?)?.toDouble() ??
          double.tryParse(json['stress_level']?.toString() ?? '') ??
          0.0,
      stressCategory: (json['stress_category'] ?? 'MODERATE').toString(),
      primaryEmotion: (json['primary_emotion'] ?? 'Unknown').toString(),
      energyLevel: energy,
      moodPattern: (json['mood_pattern'] ?? 'unknown').toString(),
      timestamp:
          DateTime.tryParse((json['timestamp'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

class StressStats {
  final double averageStress;
  final double minStress;
  final double maxStress;
  final double currentStress;
  final String trend;
  final int periodDays;
  final int totalRecords;
  final int lowCount;
  final int moderateCount;
  final int highCount;
  final int criticalCount;

  StressStats({
    required this.averageStress,
    required this.minStress,
    required this.maxStress,
    required this.currentStress,
    required this.trend,
    required this.periodDays,
    required this.totalRecords,
    required this.lowCount,
    required this.moderateCount,
    required this.highCount,
    required this.criticalCount,
  });

  factory StressStats.fromJson(Map<String, dynamic> json) {
    return StressStats(
      averageStress: (json['average_stress'] as num).toDouble(),
      minStress: (json['min_stress'] as num).toDouble(),
      maxStress: (json['max_stress'] as num).toDouble(),
      currentStress: (json['current_stress'] as num).toDouble(),
      trend: json['trend'] as String,
      periodDays: json['period_days'] as int,
      totalRecords: json['total_records'] as int,
      lowCount: json['low_count'] as int,
      moderateCount: json['moderate_count'] as int,
      highCount: json['high_count'] as int,
      criticalCount: json['critical_count'] as int,
    );
  }

  String get trendEmoji {
    switch (trend) {
      case 'improving':
        return '📈';
      case 'worsening':
        return '📉';
      default:
        return '➡️';
    }
  }
}
