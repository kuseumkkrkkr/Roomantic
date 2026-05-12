import 'package:flutter/material.dart';
import '../models/profile.dart';

class PersonaCompareScreen extends StatelessWidget {
  final Profile profile;
  final String personaName;

  const PersonaCompareScreen({
    super.key,
    required this.profile,
    required this.personaName,
  });

  static const Map<String, String> _personaDescriptions = {
    '독서실형': '방 안에서 조용히 공부하는 것을 선호하며, 외부 소음과 교류에 민감해요.',
    '자취감성형': '실내 분위기와 향, 청결에 신경 쓰며 감성적인 자취 생활을 추구해요.',
    '야행성게이머형': '늦은 밤까지 게임과 스크린 활동을 즐기며, 수면 패턴이 낮과 밤이 뒤바뀔 수 있어요.',
    'FM군대형': '규칙적이고 청결한 생활을 중시하며, 룸메이트와의 규칙 준수를 바라요.',
    '생존형': '최소한의 생활만 하며, 크게 신경 쓰지 않는 타입이에요.',
    '공동체형': '룸메이트와 식사·운동·모임을 함께 하며, 가까운 관계를 원해요.',
    '생활분리형': '개인 생활과 공동 생활을 명확히 구분하며, 서로를 존중하는 것을 중요하게 여겨요.',
    '수면민감형': '수면 환경(소리, 빛, 시간)에 매우 예민하며, 맞춤형 수면 환경이 필요해요.',
  };

  static const Map<String, Color> _personaColors = {
    '독서실형': Color(0xFF2563EB),
    '자취감성형': Color(0xFFEC4899),
    '야행성게이머형': Color(0xFF7C3AED),
    'FM군대형': Color(0xFF059669),
    '생존형': Color(0xFF9CA3AF),
    '공동체형': Color(0xFFF59E0B),
    '생활분리형': Color(0xFF6366F1),
    '수면민감형': Color(0xFF14B8A6),
  };

  /// 각 유형별 정석(전형적) 패턴
  static Profile _idealProfile(String persona) {
    switch (persona) {
      case '독서실형':
        return Profile(
          studyInRoom: 1,
          noiseSensitivity: 5,
          speakerUse: 0,
          gamingHoursPerWeek: 0,
          bedtime: 23,
          wakeTime: 7,
          friendInvite: 0,
          desiredIntimacy: 1,
          indoorCall: 0,
          sleepSensitivity: 4,
          sleepLight: 0,
          snoring: 0,
          alarmStrength: 4,
          sleepHabit: 0,
          indoorEating: 0,
          indoorScentSensitivity: 4,
          fridgeUse: 1,
          toiletPaperShare: 1,
          ventilation: 3,
          temperaturePref: 2,
          cleaningCycle: 3,
          showerCycle: 1,
          showerDuration: 15,
          showerTime: 22,
          hairdryerInBathroom: 1,
          laundryCycle: 7,
          dryingRack: 1,
          smoking: 0,
          bugHandling: 3,
          mealTogether: 1,
          exerciseTogether: 1,
          homeVisitCycle: 2,
          perfume: 0,
          alcoholTolerance: 1.0,
          alcoholFrequency: 0,
          drunkHabit: 0,
          exercise: 1,
          dormDuration: 2,
          birthYear: 2005,
        );
      case '자취감성형':
        return Profile(
          indoorScentSensitivity: 5,
          indoorEating: 1,
          fridgeUse: 1,
          toiletPaperShare: 1,
          ventilation: 4,
          temperaturePref: 2,
          cleaningCycle: 3,
          perfume: 1,
          showerDuration: 20,
          showerCycle: 1,
          hairdryerInBathroom: 1,
          laundryCycle: 5,
          dryingRack: 1,
          smoking: 0,
          indoorCall: 1,
          desiredIntimacy: 3,
          friendInvite: 1,
          mealTogether: 2,
          exerciseTogether: 2,
          bedtime: 23,
          wakeTime: 8,
          sleepSensitivity: 3,
          noiseSensitivity: 3,
          studyInRoom: 1,
          gamingHoursPerWeek: 5,
          speakerUse: 0,
          bugHandling: 3,
          homeVisitCycle: 2,
          alcoholTolerance: 1.5,
          alcoholFrequency: 1,
          drunkHabit: 0,
          exercise: 1,
          dormDuration: 2,
          birthYear: 2005,
          sleepHabit: 0,
          sleepLight: 0,
          snoring: 0,
          alarmStrength: 3,
          showerTime: 21,
        );
      case '야행성게이머형':
        return Profile(
          gamingHoursPerWeek: 30,
          bedtime: 2,
          wakeTime: 11,
          alarmStrength: 5,
          speakerUse: 1,
          homeVisitCycle: 1,
          sleepLight: 1,
          snoring: 1,
          sleepSensitivity: 2,
          noiseSensitivity: 2,
          studyInRoom: 0,
          indoorCall: 1,
          desiredIntimacy: 2,
          friendInvite: 1,
          mealTogether: 1,
          exerciseTogether: 1,
          exercise: 0,
          cleaningCycle: 14,
          showerCycle: 2,
          showerDuration: 20,
          hairdryerInBathroom: 1,
          laundryCycle: 7,
          dryingRack: 1,
          smoking: 0,
          bugHandling: 3,
          indoorEating: 1,
          fridgeUse: 1,
          toiletPaperShare: 1,
          ventilation: 2,
          temperaturePref: 3,
          perfume: 0,
          alcoholTolerance: 2.0,
          alcoholFrequency: 2,
          drunkHabit: 0,
          dormDuration: 2,
          birthYear: 2005,
          sleepHabit: 0,
          showerTime: 23,
        );
      case 'FM군대형':
        return Profile(
          cleaningCycle: 1,
          showerCycle: 0,
          laundryCycle: 3,
          hairdryerInBathroom: 1,
          desiredIntimacy: 4,
          showerDuration: 10,
          bedtime: 22,
          wakeTime: 6,
          sleepSensitivity: 3,
          noiseSensitivity: 3,
          studyInRoom: 1,
          indoorCall: 0,
          friendInvite: 1,
          mealTogether: 3,
          exerciseTogether: 3,
          exercise: 1,
          smoking: 0,
          bugHandling: 3,
          indoorEating: 0,
          fridgeUse: 1,
          toiletPaperShare: 1,
          ventilation: 3,
          temperaturePref: 3,
          perfume: 0,
          alcoholTolerance: 1.0,
          alcoholFrequency: 0,
          drunkHabit: 0,
          gamingHoursPerWeek: 0,
          speakerUse: 0,
          homeVisitCycle: 2,
          dormDuration: 4,
          birthYear: 2005,
          sleepHabit: 0,
          sleepLight: 0,
          snoring: 0,
          alarmStrength: 4,
          showerTime: 21,
          dryingRack: 1,
        );
      case '생존형':
        return Profile(
          cleaningCycle: 30,
          showerCycle: 4,
          fridgeUse: 0,
          desiredIntimacy: 1,
          studyInRoom: 0,
          noiseSensitivity: 1,
          sleepSensitivity: 2,
          bedtime: 24,
          wakeTime: 10,
          indoorCall: 1,
          friendInvite: 1,
          mealTogether: 1,
          exerciseTogether: 1,
          exercise: 0,
          laundryCycle: 14,
          dryingRack: 0,
          smoking: 0,
          bugHandling: 3,
          indoorEating: 1,
          toiletPaperShare: 0,
          ventilation: 1,
          temperaturePref: 3,
          perfume: 0,
          alcoholTolerance: 3.0,
          alcoholFrequency: 3,
          drunkHabit: 1,
          gamingHoursPerWeek: 20,
          speakerUse: 1,
          homeVisitCycle: 1,
          dormDuration: 1,
          birthYear: 2005,
          sleepHabit: 0,
          sleepLight: 1,
          snoring: 1,
          alarmStrength: 2,
          showerTime: 22,
          hairdryerInBathroom: 0,
          showerDuration: 10,
        );
      case '공동체형':
        return Profile(
          desiredIntimacy: 5,
          mealTogether: 3,
          exerciseTogether: 3,
          friendInvite: 2,
          fridgeUse: 1,
          cleaningCycle: 3,
          bedtime: 23,
          wakeTime: 8,
          sleepSensitivity: 3,
          noiseSensitivity: 2,
          studyInRoom: 0,
          indoorCall: 1,
          exercise: 1,
          smoking: 0,
          bugHandling: 3,
          indoorEating: 1,
          toiletPaperShare: 1,
          ventilation: 3,
          temperaturePref: 3,
          perfume: 0,
          alcoholTolerance: 2.0,
          alcoholFrequency: 2,
          drunkHabit: 0,
          gamingHoursPerWeek: 5,
          speakerUse: 0,
          homeVisitCycle: 2,
          dormDuration: 3,
          birthYear: 2005,
          sleepHabit: 0,
          sleepLight: 0,
          snoring: 0,
          alarmStrength: 3,
          showerTime: 21,
          hairdryerInBathroom: 1,
          showerDuration: 15,
          showerCycle: 1,
          laundryCycle: 5,
          dryingRack: 1,
        );
      case '생활분리형':
        return Profile(
          desiredIntimacy: 1,
          toiletPaperShare: 0,
          indoorCall: 0,
          friendInvite: 0,
          mealTogether: 1,
          cleaningCycle: 7,
          showerCycle: 2,
          bedtime: 23,
          wakeTime: 8,
          sleepSensitivity: 3,
          noiseSensitivity: 3,
          studyInRoom: 1,
          exercise: 0,
          smoking: 0,
          bugHandling: 3,
          indoorEating: 0,
          fridgeUse: 0,
          ventilation: 2,
          temperaturePref: 3,
          perfume: 0,
          alcoholTolerance: 1.0,
          alcoholFrequency: 0,
          drunkHabit: 0,
          gamingHoursPerWeek: 5,
          speakerUse: 0,
          homeVisitCycle: 2,
          dormDuration: 2,
          birthYear: 2005,
          sleepHabit: 0,
          sleepLight: 0,
          snoring: 0,
          alarmStrength: 3,
          showerTime: 22,
          hairdryerInBathroom: 1,
          showerDuration: 15,
          laundryCycle: 7,
          dryingRack: 1,
          exerciseTogether: 1,
        );
      case '수면민감형':
        return Profile(
          sleepSensitivity: 5,
          sleepLight: 1,
          bedtime: 23,
          wakeTime: 7,
          snoring: 0,
          noiseSensitivity: 5,
          sleepHabit: 0,
          alarmStrength: 5,
          cleaningCycle: 7,
          showerCycle: 2,
          desiredIntimacy: 2,
          indoorCall: 0,
          friendInvite: 0,
          mealTogether: 1,
          exerciseTogether: 1,
          studyInRoom: 1,
          exercise: 0,
          smoking: 0,
          bugHandling: 3,
          indoorEating: 0,
          fridgeUse: 1,
          toiletPaperShare: 1,
          ventilation: 2,
          temperaturePref: 3,
          perfume: 0,
          alcoholTolerance: 1.0,
          alcoholFrequency: 0,
          drunkHabit: 0,
          gamingHoursPerWeek: 0,
          speakerUse: 0,
          homeVisitCycle: 2,
          dormDuration: 2,
          birthYear: 2005,
          showerTime: 21,
          hairdryerInBathroom: 1,
          showerDuration: 15,
          laundryCycle: 7,
          dryingRack: 1,
        );
      default:
        return Profile();
    }
  }

  /// 각 문항의 표시 이름
  static const Map<String, String> _labels = {
    'birthYear': '출생 연도',
    'college': '단과대학',
    'department': '학과',
    'dormDuration': '기숙사 거주 경험',
    'homeVisitCycle': '귀가 주기(월)',
    'perfume': '향수 사용',
    'indoorScentSensitivity': '실내 냄새 민감도',
    'alcoholTolerance': '주량',
    'alcoholFrequency': '음주 빈도(주)',
    'drunkHabit': '주사 있음',
    'gamingHoursPerWeek': '게임/인터넷 시간/주',
    'speakerUse': '스피커 사용',
    'exercise': '규칙적 운동',
    'bedtime': '취침시간',
    'wakeTime': '기상시간',
    'sleepHabit': '이버릇 있음',
    'sleepSensitivity': '잠귀(수면 예민도)',
    'alarmStrength': '알람 잘 들음?',
    'sleepLight': '수면등(불 켜고 잠)',
    'snoring': '코골이',
    'showerDuration': '샤워 시간',
    'showerTime': '샤워 시각',
    'showerCycle': '샤워 주기',
    'cleaningCycle': '청소 주기(일)',
    'ventilation': '환기 횟수(일)',
    'hairdryerInBathroom': '헤어드라이기 비치',
    'toiletPaperShare': '휴지 공유',
    'indoorEating': '방안 취식',
    'smoking': '흡연',
    'temperaturePref': '온도 선호(1:추위 → 5:더위)',
    'indoorCall': '방안 통화',
    'bugHandling': '벌레 대응(1:무서움 → 5:못잡음)',
    'laundryCycle': '빨래 주기(일)',
    'dryingRack': '건조대 사용',
    'fridgeUse': '냉장고 사용',
    'studyInRoom': '방안 공부',
    'noiseSensitivity': '소음 민감도',
    'desiredIntimacy': '룸메이트 친밀도(1~5)',
    'mealTogether': '밥 같이',
    'exerciseTogether': '운동 같이',
    'friendInvite': '친구 방문',
  };

  /// 값 포맷팅 헬퍼
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
      case 'bedtime':
      case 'wakeTime':
      case 'showerTime':
        return '$value시';
      case 'dormDuration':
        final d = value as int;
        if (d == 0) return '거주 경험 없음';
        if (d <= 8) return '$d학기';
        return '8학기 이상';
      case 'showerDuration':
        final sd = value as int;
        if (sd == 31) return '30분+';
        return '$sd분';
      case 'showerCycle':
        final sc = ['하루 2회이상', '하루 2회', '하루 1회', '2일 1회', '3일 1회미만'];
        if (value is int && value >= 0 && value < sc.length) return sc[value];
        return '$value';
      case 'friendInvite':
        final fi = ['X', '사전허락', '항상 OK'];
        if (value is int && value >= 0 && value < fi.length) return fi[value];
        return '$value';
      case 'alcoholTolerance':
        return '$value병';
      case 'cleaningCycle':
      case 'laundryCycle':
        return '$value일';
      case 'ventilation':
        return '$value회';
      case 'mealTogether':
      case 'exerciseTogether':
        final me = ['', '거의 안함', '가끔', '자주'];
        if (value is int && value >= 0 && value < me.length) return me[value];
        return '$value';
      case 'desiredIntimacy':
      case 'noiseSensitivity':
      case 'sleepSensitivity':
      case 'indoorScentSensitivity':
      case 'bugHandling':
      case 'alarmStrength':
      case 'temperaturePref':
        return '$value';
      default:
        return '$value';
    }
  }

  /// 각 섹션별로 필드 그룹화
  List<Map<String, dynamic>> _buildSections(Profile ideal) {
    final my = profile;
    final sections = <Map<String, dynamic>>[];

    sections.add({
      'title': '기본 정보',
      'items': [
        _item('birthYear', my.birthYear, ideal.birthYear),
        _item('college', my.college, ideal.college),
        _item('department', my.department, ideal.department),
        _item('dormDuration', my.dormDuration, ideal.dormDuration),
      ],
    });

    sections.add({
      'title': '생활 습관',
      'items': [
        _item('homeVisitCycle', my.homeVisitCycle, ideal.homeVisitCycle),
        _item('perfume', my.perfume, ideal.perfume),
        _item('indoorScentSensitivity', my.indoorScentSensitivity, ideal.indoorScentSensitivity),
        _item('alcoholTolerance', my.alcoholTolerance, ideal.alcoholTolerance),
        _item('alcoholFrequency', my.alcoholFrequency, ideal.alcoholFrequency),
        _item('drunkHabit', my.drunkHabit, ideal.drunkHabit),
        _item('gamingHoursPerWeek', my.gamingHoursPerWeek, ideal.gamingHoursPerWeek),
        _item('speakerUse', my.speakerUse, ideal.speakerUse),
        _item('exercise', my.exercise, ideal.exercise),
      ],
    });

    sections.add({
      'title': '수면 습관',
      'items': [
        _item('bedtime', my.bedtime, ideal.bedtime),
        _item('wakeTime', my.wakeTime, ideal.wakeTime),
        _item('sleepHabit', my.sleepHabit, ideal.sleepHabit),
        _item('sleepSensitivity', my.sleepSensitivity, ideal.sleepSensitivity),
        _item('alarmStrength', my.alarmStrength, ideal.alarmStrength),
        _item('sleepLight', my.sleepLight, ideal.sleepLight),
        _item('snoring', my.snoring, ideal.snoring),
      ],
    });

    sections.add({
      'title': '위생 / 화장실',
      'items': [
        _item('showerDuration', my.showerDuration, ideal.showerDuration),
        _item('showerTime', my.showerTime, ideal.showerTime),
        _item('showerCycle', my.showerCycle, ideal.showerCycle),
        _item('cleaningCycle', my.cleaningCycle, ideal.cleaningCycle),
        _item('ventilation', my.ventilation, ideal.ventilation),
        _item('hairdryerInBathroom', my.hairdryerInBathroom, ideal.hairdryerInBathroom),
        _item('toiletPaperShare', my.toiletPaperShare, ideal.toiletPaperShare),
        _item('indoorEating', my.indoorEating, ideal.indoorEating),
        _item('smoking', my.smoking, ideal.smoking),
      ],
    });

    sections.add({
      'title': '생활 태도',
      'items': [
        _item('temperaturePref', my.temperaturePref, ideal.temperaturePref),
        _item('indoorCall', my.indoorCall, ideal.indoorCall),
        _item('bugHandling', my.bugHandling, ideal.bugHandling),
        _item('laundryCycle', my.laundryCycle, ideal.laundryCycle),
        _item('dryingRack', my.dryingRack, ideal.dryingRack),
        _item('fridgeUse', my.fridgeUse, ideal.fridgeUse),
        _item('studyInRoom', my.studyInRoom, ideal.studyInRoom),
        _item('noiseSensitivity', my.noiseSensitivity, ideal.noiseSensitivity),
      ],
    });

    sections.add({
      'title': '교류',
      'items': [
        _item('desiredIntimacy', my.desiredIntimacy, ideal.desiredIntimacy),
        _item('mealTogether', my.mealTogether, ideal.mealTogether),
        _item('exerciseTogether', my.exerciseTogether, ideal.exerciseTogether),
        _item('friendInvite', my.friendInvite, ideal.friendInvite),
      ],
    });

    return sections;
  }

  Map<String, dynamic> _item(String key, dynamic myValue, dynamic idealValue) {
    return {
      'key': key,
      'label': _labels[key] ?? key,
      'myValue': myValue,
      'idealValue': idealValue,
      'match': _valuesEqual(key, myValue, idealValue),
    };
  }

  bool _valuesEqual(String key, dynamic a, dynamic b) {
    if (a is double && b is double) return (a - b).abs() < 0.01;
    if (a is double && b is int) return (a - b).abs() < 0.01;
    if (a is int && b is double) return (a - b).abs() < 0.01;
    return a == b;
  }

  @override
  Widget build(BuildContext context) {
    final ideal = _idealProfile(personaName);
    final sections = _buildSections(ideal);
    final color = _personaColors[personaName] ?? const Color(0xFF2563EB);
    final description = _personaDescriptions[personaName] ?? '';

    // 일치율 계산
    int totalItems = 0;
    int matchCount = 0;
    for (final section in sections) {
      for (final item in (section['items'] as List)) {
        totalItems++;
        if (item['match'] == true) matchCount++;
      }
    }
    final matchPercent = totalItems > 0 ? (matchCount / totalItems * 100).round() : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('$personaName vs 나'),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 유형 설명 카드
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
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '정석 패턴',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$matchPercent% 일치',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      personaName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 범례
              Row(
                children: [
                  _legendItem(Colors.green, '일치'),
                  const SizedBox(width: 16),
                  _legendItem(Colors.orange, '차이'),
                ],
              ),
              const SizedBox(height: 16),

              // 섹션별 비교 목록
              ...sections.map((section) {
                final items = section['items'] as List<Map<String, dynamic>>;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section['title'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x0D000000),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          children: items.asMap().entries.map((entry) {
                            final i = entry.key;
                            final item = entry.value;
                            final isMatch = item['match'] as bool;
                            return Column(
                              children: [
                                if (i > 0)
                                  const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF3F4F6)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          item['label'] as String,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF374151),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            const Text(
                                              '정석',
                                              style: TextStyle(fontSize: 10, color: Colors.grey),
                                            ),
                                            Text(
                                              _fmt(item['key'] as String, item['idealValue']),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF9CA3AF),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            const Text(
                                              '나',
                                              style: TextStyle(fontSize: 10, color: Colors.grey),
                                            ),
                                            Text(
                                              _fmt(item['key'] as String, item['myValue']),
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: isMatch ? Colors.green.shade700 : Colors.orange.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        isMatch ? Icons.check_circle : Icons.error_outline,
                                        color: isMatch ? Colors.green : Colors.orange,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 10, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
