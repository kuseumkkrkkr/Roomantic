import 'package:flutter/material.dart';

class MatchUiGrade {
  final String label;
  final Color background;
  final Color foreground;

  const MatchUiGrade({
    required this.label,
    required this.background,
    required this.foreground,
  });
}

class MatchUiSummary {
  final MatchUiGrade grade;
  final List<String> strengths;
  final List<String> cautions;
  final String subtitle;

  const MatchUiSummary({
    required this.grade,
    required this.strengths,
    required this.cautions,
    required this.subtitle,
  });
}

class MatchUiHelper {
  const MatchUiHelper._();

  static double scoreFrom(Map<String, dynamic> item) {
    return (item['shared_score'] as num?)?.toDouble() ??
        (item['score'] as num?)?.toDouble() ??
        0.0;
  }

  static MatchUiGrade gradeFromScore(double score) {
    if (score >= 85) {
      return const MatchUiGrade(
        label: '매우 잘 맞음',
        background: Color(0xFFDCFCE7),
        foreground: Color(0xFF166534),
      );
    }
    if (score >= 75) {
      return const MatchUiGrade(
        label: '잘 맞음',
        background: Color(0xFFDBEAFE),
        foreground: Color(0xFF1E40AF),
      );
    }
    if (score >= 65) {
      return const MatchUiGrade(
        label: '조율 필요',
        background: Color(0xFFFEF3C7),
        foreground: Color(0xFF92400E),
      );
    }
    return const MatchUiGrade(
      label: '신중 검토',
      background: Color(0xFFFEE2E2),
      foreground: Color(0xFF991B1B),
    );
  }

  static MatchUiSummary summaryFrom(Map<String, dynamic> item) {
    final score = scoreFrom(item);
    final isRoom =
        (item['candidate_type']?.toString() ?? 'individual') == 'room';
    final memberScores = List<double>.from(
      (item['member_scores'] as List<dynamic>? ?? const []).map(
        (e) => (e as num).toDouble(),
      ),
    );
    final subtitle = isRoom && memberScores.isNotEmpty
        ? '공통 일치율 ${score.toStringAsFixed(1)}% · 개별 ${memberScores.map((e) => '${e.toStringAsFixed(1)}%').join(' / ')}'
        : '일치율 ${score.toStringAsFixed(1)}%';

    final detail = (item['detail'] is Map<String, dynamic>)
        ? item['detail'] as Map<String, dynamic>
        : <String, dynamic>{};
    final ranked = _rankedDetails(detail);

    final strengths = ranked.reversed
        .take(2)
        .map((e) => '${_labelForKey(e.key)} ${e.value.toStringAsFixed(0)}점')
        .toList();
    final cautions = ranked
        .take(1)
        .map(
          (e) =>
              '${_labelForKey(e.key)} 조율 필요 (${e.value.toStringAsFixed(0)}점)',
        )
        .toList();

    return MatchUiSummary(
      grade: gradeFromScore(score),
      strengths: strengths.isEmpty ? const ['생활 루틴이 전반적으로 무난해요'] : strengths,
      cautions: cautions.isEmpty ? const ['첫 대화에서 생활 규칙을 먼저 맞춰보세요'] : cautions,
      subtitle: subtitle,
    );
  }

  static String candidateLabel(bool isRoom) => isRoom ? '2인 방 후보' : '1인 후보';

  static List<MapEntry<String, double>> _rankedDetails(
    Map<String, dynamic> detail,
  ) {
    final entries = <MapEntry<String, double>>[];
    detail.forEach((key, value) {
      if (value is num) {
        final normalized = value.toDouble().clamp(0, 100).toDouble();
        entries.add(MapEntry(key, normalized));
      }
    });
    entries.sort((a, b) => a.value.compareTo(b.value));
    return entries;
  }

  static String _labelForKey(String key) {
    const labels = <String, String>{
      'sleep': '수면 패턴',
      'wake': '기상 시간',
      'clean': '청결 습관',
      'noise': '소음 민감도',
      'study': '학습 스타일',
      'social': '대인 성향',
      'smoking': '흡연 성향',
      'schedule': '생활 리듬',
    };
    for (final entry in labels.entries) {
      if (key.toLowerCase().contains(entry.key)) {
        return entry.value;
      }
    }
    return key.replaceAll('_', ' ');
  }
}
