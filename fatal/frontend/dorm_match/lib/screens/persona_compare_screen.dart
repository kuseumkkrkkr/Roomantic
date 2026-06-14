import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../utils/persona_scoring.dart';

class PersonaCompareScreen extends StatelessWidget {
  final Profile profile;
  final String personaName;

  const PersonaCompareScreen({
    super.key,
    required this.profile,
    required this.personaName,
  });

  static const Map<String, String> _personaDescriptions = {
    '학습집중형': '방 안에서 조용히 공부하는 것을 선호하고, 소음과 교류에 민감해요.',
    '섬세감성형': '실내 분위기와 청결에 신경 쓰며 감성적인 생활을 추구해요.',
    '야행성게이머형': '늦은 밤까지 게임과 여가 활동을 즐기는 편이에요.',
    'FM관리형': '규칙적이고 청결한 생활을 중시하고, 룸메이트와도 기준 공유를 원해요.',
    '생존형': '최소한의 생활을 하며, 크게 신경 쓰지 않는 타입이에요.',
    '공동체형': '룸메이트와 식사, 대화, 활동을 함께하며 가까운 관계를 원해요.',
    '생활분리형': '개인 생활과 공동 생활의 경계를 중요하게 생각해요.',
    '수면민감형': '수면 환경(소리, 빛, 시간)에 매우 민감해요.',
  };

  static const Map<String, Color> _personaColors = {
    '학습집중형': Color(0xFF2563EB),
    '섬세감성형': Color(0xFFEC4899),
    '야행성게이머형': Color(0xFF7C3AED),
    'FM관리형': Color(0xFF059669),
    '생존형': Color(0xFF9CA3AF),
    '공동체형': Color(0xFFF59E0B),
    '생활분리형': Color(0xFF6366F1),
    '수면민감형': Color(0xFF14B8A6),
  };

  static const Map<String, String> _labels = {
    'homeVisitCycle': '본가 방문 주기',
    'perfume': '향수 사용',
    'indoorScentSensitivity': '실내 냄새 민감도',
    'alcoholTolerance': '주량',
    'alcoholFrequency': '음주 빈도',
    'drunkHabit': '주사 있음',
    'gamingHoursPerWeek': '게임/인터넷 시간(일)',
    'speakerUse': '스피커 사용',
    'exercise': '규칙적 운동',
    'bedtime': '취침 시간',
    'wakeTime': '기상 시간',
    'sleepHabit': '잠버릇 있음',
    'sleepSensitivity': '수면 민감도',
    'alarmStrength': '알람 강도',
    'sleepLight': '불 켜고 잠',
    'snoring': '코골이',
    'showerCycle': '샤워 주기',
    'showerDuration': '샤워 시간',
    'showerTime': '샤워 시각',
    'cleaningCycle': '청소 주기',
    'ventilation': '환기 횟수(일)',
    'hairdryerInBathroom': '드라이기 화장실 보관',
    'toiletPaperShare': '휴지 공유',
    'indoorEating': '방 안 취식',
    'smoking': '흡연',
    'temperaturePref': '온도 선호(1~5)',
    'indoorCall': '실내 통화',
    'bugHandling': '벌레 대처(1~5)',
    'laundryCycle': '빨래 주기',
    'dryingRack': '건조대 사용',
    'fridgeUse': '냉장고 사용',
    'studyInRoom': '방 안 공부',
    'noiseSensitivity': '소음 민감도',
    'desiredIntimacy': '친밀도(1~5)',
    'mealTogether': '같이 밥',
    'exerciseTogether': '같이 운동',
    'friendInvite': '친구 초대',
  };

  static Profile _idealProfile(String persona) {
    switch (persona) {
      case '학습집중형':
        return Profile(
          studyInRoom: 1,
          noiseSensitivity: 5,
          speakerUse: 0,
          gamingHoursPerWeek: 0,
          bedtime: 23,
          friendInvite: 0,
          desiredIntimacy: 1,
        );
      case '섬세감성형':
        return Profile(
          indoorScentSensitivity: 5,
          indoorEating: 1,
          fridgeUse: 1,
          toiletPaperShare: 1,
          ventilation: 2.0,
          temperaturePref: 2,
          cleaningCycle: 3,
        );
      case '야행성게이머형':
        return Profile(
          gamingHoursPerWeek: 56,
          bedtime: 2,
          alarmStrength: 5,
          speakerUse: 1,
          homeVisitCycle: 1,
        );
      case 'FM관리형':
        return Profile(
          cleaningCycle: 1,
          showerCycle: 4,
          laundryCycle: 3,
          hairdryerInBathroom: 1,
          desiredIntimacy: 4,
          showerDuration: 10,
        );
      case '생존형':
        return Profile(
          cleaningCycle: 60,
          showerCycle: 0,
          fridgeUse: 0,
          desiredIntimacy: 1,
          studyInRoom: 0,
          noiseSensitivity: 1,
        );
      case '공동체형':
        return Profile(
          desiredIntimacy: 5,
          mealTogether: 3,
          exerciseTogether: 3,
          friendInvite: 2,
        );
      case '생활분리형':
        return Profile(
          desiredIntimacy: 1,
          toiletPaperShare: 0,
          indoorCall: 0,
          friendInvite: 0,
          mealTogether: 1,
        );
      case '수면민감형':
        return Profile(
          sleepSensitivity: 5,
          sleepLight: 1,
          bedtime: 23,
          snoring: 0,
          noiseSensitivity: 5,
        );
      default:
        return Profile();
    }
  }

  Map<String, List<Map<String, dynamic>>> _buildSections(Profile ideal) {
    final p = profile;
    return {
      '생활 습관': [
        _item('homeVisitCycle', p.homeVisitCycle, ideal.homeVisitCycle),
        _item('perfume', p.perfume, ideal.perfume),
        _item(
          'indoorScentSensitivity',
          p.indoorScentSensitivity,
          ideal.indoorScentSensitivity,
        ),
        _item('alcoholTolerance', p.alcoholTolerance, ideal.alcoholTolerance),
        _item('alcoholFrequency', p.alcoholFrequency, ideal.alcoholFrequency),
        _item('drunkHabit', p.drunkHabit, ideal.drunkHabit),
        _item(
          'gamingHoursPerWeek',
          p.gamingHoursPerWeek,
          ideal.gamingHoursPerWeek,
        ),
        _item('speakerUse', p.speakerUse, ideal.speakerUse),
        _item('exercise', p.exercise, ideal.exercise),
      ],
      '수면': [
        _item('bedtime', p.bedtime, ideal.bedtime),
        _item('wakeTime', p.wakeTime, ideal.wakeTime),
        _item('sleepHabit', p.sleepHabit, ideal.sleepHabit),
        _item('sleepSensitivity', p.sleepSensitivity, ideal.sleepSensitivity),
        _item('alarmStrength', p.alarmStrength, ideal.alarmStrength),
        _item('sleepLight', p.sleepLight, ideal.sleepLight),
        _item('snoring', p.snoring, ideal.snoring),
      ],
      '위생': [
        _item('showerCycle', p.showerCycle, ideal.showerCycle),
        _item('showerDuration', p.showerDuration, ideal.showerDuration),
        _item('showerTime', p.showerTime, ideal.showerTime),
        _item('cleaningCycle', p.cleaningCycle, ideal.cleaningCycle),
        _item('ventilation', p.ventilation, ideal.ventilation),
        _item(
          'hairdryerInBathroom',
          p.hairdryerInBathroom,
          ideal.hairdryerInBathroom,
        ),
        _item('toiletPaperShare', p.toiletPaperShare, ideal.toiletPaperShare),
        _item('indoorEating', p.indoorEating, ideal.indoorEating),
        _item('smoking', p.smoking, ideal.smoking),
      ],
      '생활 선호': [
        _item('temperaturePref', p.temperaturePref, ideal.temperaturePref),
        _item('indoorCall', p.indoorCall, ideal.indoorCall),
        _item('bugHandling', p.bugHandling, ideal.bugHandling),
        _item('laundryCycle', p.laundryCycle, ideal.laundryCycle),
        _item('dryingRack', p.dryingRack, ideal.dryingRack),
        _item('fridgeUse', p.fridgeUse, ideal.fridgeUse),
        _item('studyInRoom', p.studyInRoom, ideal.studyInRoom),
        _item('noiseSensitivity', p.noiseSensitivity, ideal.noiseSensitivity),
      ],
      '교류': [
        _item('desiredIntimacy', p.desiredIntimacy, ideal.desiredIntimacy),
        _item('mealTogether', p.mealTogether, ideal.mealTogether),
        _item('exerciseTogether', p.exerciseTogether, ideal.exerciseTogether),
        _item('friendInvite', p.friendInvite, ideal.friendInvite),
      ],
    };
  }

  Map<String, dynamic> _item(String key, dynamic myValue, dynamic idealValue) {
    final diff = _normalizedDiff(key, myValue, idealValue);
    final tone =
        Color.lerp(const Color(0xFF15803D), const Color(0xFF86EFAC), diff) ??
        const Color(0xFF22C55E);
    return {
      'key': key,
      'label': _labels[key] ?? key,
      'myValue': myValue,
      'idealValue': idealValue,
      'tone': tone,
      'bg': tone.withValues(alpha: 0.05),
    };
  }

  double _normalizedDiff(String key, dynamic myValue, dynamic idealValue) {
    final a = (myValue as num?)?.toDouble();
    final b = (idealValue as num?)?.toDouble();
    if (a == null || b == null) return 1.0;

    if (key == 'bedtime' || key == 'wakeTime' || key == 'showerTime') {
      final d = (a - b).abs() % 24;
      final circular = d > 12 ? 24 - d : d;
      return (circular / 12).clamp(0.0, 1.0);
    }

    const rangeMap = {
      'noiseSensitivity': 4.0,
      'sleepSensitivity': 4.0,
      'alarmStrength': 4.0,
      'temperaturePref': 4.0,
      'desiredIntimacy': 4.0,
      'mealTogether': 2.0,
      'exerciseTogether': 2.0,
      'friendInvite': 2.0,
      'showerCycle': 4.0,
      'alcoholFrequency': 3.0,
      'homeVisitCycle': 3.0,
      'cleaningCycle': 60.0,
      'laundryCycle': 60.0,
      'gamingHoursPerWeek': 56.0,
      'showerDuration': 45.0,
      'ventilation': 2.0,
      'alcoholTolerance': 2.0,
    };

    final range = rangeMap[key] ?? 1.0;
    return ((a - b).abs() / range).clamp(0.0, 1.0);
  }

  String _fmt(String key, dynamic value) {
    if (value == null) return '-';

    switch (key) {
      case 'perfume':
      case 'drunkHabit':
      case 'speakerUse':
      case 'sleepHabit':
      case 'hairdryerInBathroom':
      case 'toiletPaperShare':
      case 'indoorEating':
      case 'smoking':
      case 'indoorCall':
      case 'dryingRack':
      case 'fridgeUse':
      case 'studyInRoom':
      case 'sleepLight':
      case 'snoring':
      case 'exercise':
        return value == 1 ? '예' : '아니오';
      case 'homeVisitCycle':
        return const [
          '매주',
          '2주 1회',
          '월 1회',
          '거의 안감',
        ][(value as int).clamp(1, 4) - 1];
      case 'alcoholTolerance':
        final v = (value as num).toDouble();
        if (v <= 0.0) return '못마심';
        if (v <= 0.5) return '반병';
        if (v <= 1.0) return '1병';
        if (v <= 1.5) return '1.5병';
        return '2병이상';
      case 'alcoholFrequency':
        return const ['1달 1회 이하', '2주 1회', '주 1회', '주 3회 이상'][(value as int)
            .clamp(0, 3)];
      case 'gamingHoursPerWeek':
        final v = value as int;
        if (v >= 56) return '8시간 이상';
        if (v >= 35) return '5시간';
        if (v >= 21) return '3시간';
        if (v >= 7) return '1시간';
        return '거의안함';
      case 'bedtime':
      case 'wakeTime':
      case 'showerTime':
        return '$value시';
      case 'showerCycle':
        final v = value as int;
        if (v >= 4) return '일 3회이상';
        if (v == 3) return '일 2회';
        if (v == 2) return '일 1회';
        if (v == 1) return '2일1회';
        return '2일 1회 미만';
      case 'showerDuration':
        final v = value as int;
        if (v >= 45) return '30분이상';
        if (v >= 30) return '30분';
        if (v >= 15) return '15분';
        if (v >= 10) return '10분';
        return '5분';
      case 'cleaningCycle':
      case 'laundryCycle':
        final v = value as int;
        if (v <= 1) return '매일';
        if (v <= 3) return '3일';
        if (v <= 7) return '1주일';
        if (v <= 30) return '1달';
        return '안함';
      case 'ventilation':
        final v = (value as num).toDouble();
        if (v >= 2) return '2회이상';
        if (v >= 1) return '1회';
        return '안함';
      default:
        return '$value';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ideal = _idealProfile(personaName);
    final sections = _buildSections(ideal);
    final color = _personaColors[personaName] ?? const Color(0xFF2563EB);
    final description = _personaDescriptions[personaName] ?? '';
    final personaScores = calculatePersonaScores(profile);
    final matchPercent = (personaScores[personaName] ?? 0).round();

    return Scaffold(
      appBar: AppBar(
        title: Text('$personaName 비교'),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.75)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$matchPercent% 일치',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      personaName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _legend(),
              const SizedBox(height: 14),
              ...sections.entries.map((section) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.key,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0D000000),
                              blurRadius: 12,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            children: section.value.asMap().entries.map((
                              entry,
                            ) {
                              final i = entry.key;
                              final item = entry.value;
                              final tone = item['tone'] as Color;
                              final bg = item['bg'] as Color;
                              return Container(
                                color: bg,
                                child: Column(
                                  children: [
                                    if (i > 0)
                                      const Divider(
                                        height: 1,
                                        indent: 16,
                                        endIndent: 16,
                                        color: Color(0xFFE5E7EB),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 4,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: tone,
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              item['label'] as String,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF1F2937),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                const Text(
                                                  '정석',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                                Text(
                                                  _fmt(
                                                    item['key'] as String,
                                                    item['idealValue'],
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF374151),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                const Text(
                                                  '내 응답',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                                Text(
                                                  _fmt(
                                                    item['key'] as String,
                                                    item['myValue'],
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w800,
                                                    color: Color(0xFF111827),
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
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '일치 차이',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              colors: [Color(0xFF15803D), Color(0xFF22C55E), Color(0xFF86EFAC)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '일치율 높음',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF166534),
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '일치율 낮음',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF047857),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
