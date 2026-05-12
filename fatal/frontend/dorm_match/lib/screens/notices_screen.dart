import 'package:flutter/material.dart';

class NoticesScreen extends StatelessWidget {
  const NoticesScreen({super.key});

  static final List<Map<String, String>> _notices = [
    {
      'title': '🎉 룸앤틱 베타 서비스 오픈!',
      'date': '2026-05-01',
      'body': '룸앤틱이 드디어 베타 서비스를 시작합니다. 다양한 기능을 통해 딱 맞는 기숙사 룸메이트를 찾아보세요.',
    },
    {
      'title': '📋 설문조사 기능 업데이트',
      'date': '2026-05-03',
      'body': '설문지를 수정하고, 유형 상세보기에서 8가지 성향과 비교할 수 있는 기능이 추가되었습니다.',
    },
    {
      'title': '🏠 매칭 알고리즘 개선 안내',
      'date': '2026-05-08',
      'body': '더 정확한 성향 분석과 우선순위 기반 매칭 로직이 적용되었습니다.',
    },
    {
      'title': '🔔 알림 기능 안내',
      'date': '2026-05-10',
      'body': '이제 중요한 공지사항과 매칭 요청 알림을 실시간으로 받아볼 수 있습니다.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('공지사항')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _notices.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final n = _notices[i];
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x0D000000),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        n['title']!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      n['date']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  n['body']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
