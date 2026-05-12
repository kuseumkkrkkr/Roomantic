import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/profile.dart';
import 'persona_compare_screen.dart';

class PersonaDetailScreen extends StatelessWidget {
  final Profile profile;

  const PersonaDetailScreen({super.key, required this.profile});

  Map<String, double> _calculateScores(Profile p) {
    final Map<String, double> scores = {};

    // 1. 독서실형 (max 10)
    double s1 = 0;
    if (p.studyInRoom == 1) { s1 += 3; }
    if (p.noiseSensitivity >= 4) { s1 += 2; }
    if (p.speakerUse == 0) s1 += 1;
    if (p.gamingHoursPerWeek <= 5) s1 += 1;
    if (p.bedtime >= 22 || p.bedtime <= 1) s1 += 1;
    if (p.friendInvite == 0) s1 += 1;
    if (p.desiredIntimacy <= 2) s1 += 1;
    scores['독서실형'] = (s1 / 10.0) * 100;

    // 2. 자취감성형 (max 8)
    double s2 = 0;
    if (p.indoorScentSensitivity >= 4) s2 += 2;
    if (p.indoorEating == 1) s2 += 1;
    if (p.fridgeUse == 1) s2 += 1;
    if (p.toiletPaperShare == 1) s2 += 1;
    if (p.ventilation >= 3) s2 += 1;
    if (p.temperaturePref != 3) s2 += 1;
    if (p.cleaningCycle <= 7) s2 += 1;
    scores['자취감성형'] = (s2 / 8.0) * 100;

    // 3. 야행성게이머형 (max 8)
    double s3 = 0;
    if (p.gamingHoursPerWeek >= 15) s3 += 3;
    if (p.bedtime >= 1 && p.bedtime <= 5) s3 += 2;
    if (p.alarmStrength >= 4) s3 += 1;
    if (p.speakerUse == 1) s3 += 1;
    if (p.homeVisitCycle <= 1) s3 += 1;
    scores['야행성게이머형'] = (s3 / 8.0) * 100;

    // 4. FM군대형 (max 8)
    double s4 = 0;
    if (p.cleaningCycle <= 3) s4 += 2;
    if (p.showerCycle <= 1) s4 += 2;
    if (p.laundryCycle <= 3) s4 += 1;
    if (p.hairdryerInBathroom == 1) s4 += 1;
    if (p.desiredIntimacy >= 3) s4 += 1;
    if (p.showerDuration <= 15) s4 += 1;
    scores['FM군대형'] = (s4 / 8.0) * 100;

    // 5. 생존형 (max 8)
    double s5 = 0;
    if (p.cleaningCycle >= 14) s5 += 2;
    if (p.showerCycle >= 3) s5 += 2;
    if (p.fridgeUse == 0) s5 += 1;
    if (p.desiredIntimacy <= 2) s5 += 1;
    if (p.studyInRoom == 0) s5 += 1;
    if (p.noiseSensitivity <= 2) s5 += 1;
    scores['생존형'] = (s5 / 8.0) * 100;

    // 6. 공동체형 (max 6)
    double s6 = 0;
    if (p.desiredIntimacy >= 4) s6 += 2;
    if (p.mealTogether >= 2) s6 += 1;
    if (p.exerciseTogether >= 2) s6 += 1;
    if (p.friendInvite == 2) {
      s6 += 2;
    } else if (p.friendInvite == 1) {
      s6 += 1;
    }
    scores['공동체형'] = (s6 / 6.0) * 100;

    // 7. 생활분리형 (max 6)
    double s7 = 0;
    if (p.desiredIntimacy <= 2) s7 += 2;
    if (p.toiletPaperShare == 0) s7 += 1;
    if (p.indoorCall == 0) s7 += 1;
    if (p.friendInvite == 0) s7 += 1;
    if (p.mealTogether <= 1) s7 += 1;
    scores['생활분리형'] = (s7 / 6.0) * 100;

    // 8. 수면민감형 (max 7)
    double s8 = 0;
    if (p.sleepSensitivity >= 4) s8 += 3;
    if (p.sleepLight == 1) s8 += 1;
    if (p.bedtime >= 22 || p.bedtime <= 1) s8 += 1;
    if (p.snoring == 0) s8 += 1;
    if (p.noiseSensitivity >= 4) s8 += 1;
    scores['수면민감형'] = (s8 / 7.0) * 100;

    // Sort descending
    final sorted = Map<String, double>.fromEntries(
      scores.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
    return sorted;
  }

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

  @override
  Widget build(BuildContext context) {
    final scores = _calculateScores(profile);
    final topPersona = scores.keys.first;
    final topColor = _personaColors[topPersona] ?? const Color(0xFF2563EB);

    return Scaffold(
      appBar: AppBar(title: const Text('나의 유형 상세보기')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [topColor, topColor.withValues(alpha: 0.75)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: topColor.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '가장 잘 맞는 유형',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      topPersona,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _personaDescriptions[topPersona] ?? '',
                      style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                '유형별 일치율',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E)),
              ),
              const SizedBox(height: 4),
              Text(
                '내 설문 답변과 각 유형의 전형적인 패턴을 비교한 결과예요.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),

              // Progress bars
              ...scores.entries.map((e) {
                final color = _personaColors[e.key] ?? const Color(0xFF2563EB);
                return InkWell(
                  onTap: () {
                    Get.to(() => PersonaCompareScreen(
                      profile: profile,
                      personaName: e.key,
                    ));
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(e.key, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                                const SizedBox(width: 6),
                                Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey.shade400),
                              ],
                            ),
                            Text('${e.value.toStringAsFixed(1)}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (e.value / 100).clamp(0.0, 1.0),
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
