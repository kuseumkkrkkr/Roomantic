import 'package:flutter/material.dart';

class PublicProfileScreen extends StatelessWidget {
  final Map<String, dynamic> profile;
  final String title;

  const PublicProfileScreen({
    super.key,
    required this.profile,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$title 설문')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('기본 정보'),
          _row('이름', profile['name']),
          _row('학번', profile['student_id']),
          _row('단과대', profile['college']),
          _row('학과', profile['department']),
          _row('기숙사관', profile['dormitory_hall']),
          const SizedBox(height: 12),
          _sectionTitle('생활 패턴'),
          _row('기상 시간', _hour(profile['wake_time'])),
          _row('취침 시간', _hour(profile['bedtime'])),
          _row('청소 주기', '${profile['cleaning_cycle'] ?? '-'}일'),
          _row('빨래 주기', '${profile['laundry_cycle'] ?? '-'}일'),
          _row('샤워 시각', _hour(profile['shower_time'])),
          _row('샤워 시간', '${profile['shower_duration'] ?? '-'}분'),
          const SizedBox(height: 12),
          _sectionTitle('성향'),
          _row('소음 민감도', _score5(profile['noise_sensitivity'])),
          _row('수면 민감도', _score5(profile['sleep_sensitivity'])),
          _row('온도 선호', _score5(profile['temperature_pref'])),
          _row('친밀도 선호', _score5(profile['desired_intimacy'])),
          _row('실내 통화', _bool(profile['indoor_call'])),
          _row('흡연', _bool(profile['smoking'])),
          _row('스피커 사용', _bool(profile['speaker_use'])),
          _row('코골이', _bool(profile['snoring'])),
          const SizedBox(height: 12),
          _sectionTitle('교류'),
          _row('같이 밥', _score3(profile['meal_together'])),
          _row('같이 운동', _score3(profile['exercise_together'])),
          _row('친구 초대', _score3((profile['friend_invite'] ?? 0) + 1)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1F2937),
        ),
      ),
    );
  }

  Widget _row(String label, dynamic value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          Text(
            (value == null || value.toString().isEmpty)
                ? '-'
                : value.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  String _hour(dynamic hour) {
    final h = int.tryParse(hour?.toString() ?? '');
    if (h == null) return '-';
    return '${h.toString().padLeft(2, '0')}:00';
  }

  String _bool(dynamic v) => (v == 1 || v == true) ? '예' : '아니오';

  String _score5(dynamic v) {
    final n = int.tryParse(v?.toString() ?? '');
    if (n == null) return '-';
    return '$n / 5';
  }

  String _score3(dynamic v) {
    final n = int.tryParse(v?.toString() ?? '');
    if (n == null) return '-';
    return '$n / 3';
  }
}
