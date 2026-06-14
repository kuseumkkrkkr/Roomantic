import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/profile.dart';
import '../utils/persona_scoring.dart';
import 'persona_compare_screen.dart';

class PersonaDetailScreen extends StatelessWidget {
  final Profile profile;

  const PersonaDetailScreen({super.key, required this.profile});

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

  @override
  Widget build(BuildContext context) {
    final scores = calculatePersonaScores(profile);
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
                    BoxShadow(
                      color: topColor.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '가장 잘 맞는 유형',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      topPersona,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _personaDescriptions[topPersona] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                '유형별 일치도',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '설문 응답과 각 유형의 전형적인 패턴을 비교한 결과예요.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              ...scores.entries.map((e) {
                final color = _personaColors[e.key] ?? const Color(0xFF2563EB);
                return InkWell(
                  onTap: () {
                    Get.to(
                      () => PersonaCompareScreen(
                        profile: profile,
                        personaName: e.key,
                      ),
                    );
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
                                Text(
                                  e.key,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12,
                                  color: Colors.grey.shade400,
                                ),
                              ],
                            ),
                            Text(
                              '${e.value.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
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
