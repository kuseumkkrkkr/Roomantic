import 'package:flutter/material.dart';

class MatchDetailScreen extends StatelessWidget {
  final Map<String, dynamic> matchData;

  const MatchDetailScreen({super.key, required this.matchData});

  @override
  Widget build(BuildContext context) {
    final score = (matchData['score'] as num?)?.toDouble() ?? 0.0;
    final block = matchData['hard_block'] == true || matchData['hard_block'] == 1;
    final reasons = List<String>.from(matchData['block_reasons'] ?? []);
    final detail = matchData['detail'] ?? {};
    // detail is a flat map: {"카테고리명": score, ...}
    final categories = detail is Map<String, dynamic> ? detail : <String, dynamic>{};
    final diff = <String, dynamic>{};

    final profile = matchData['profile_b'] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('매칭 상세'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16).copyWith(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score header
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(color: const Color(0x0D000000), blurRadius: 20, offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      profile['name']?.toString() ?? '이름 없음',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _scoreBg(score),
                        border: Border.all(color: _scoreColor(score).withValues(alpha: 0.15), width: 6),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        score.toStringAsFixed(1),
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: _scoreColor(score)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('총점', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (block && reasons.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFECACA), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.block, color: Color(0xFFDC2626), size: 18),
                        SizedBox(width: 8),
                        Text('Hard Block', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFDC2626))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: reasons.map((r) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                        child: Text(r, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF991B1B))),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            ...categories.entries.map<Widget>((entry) {
              final name = entry.key.toString();
              final scoreValue = entry.value;
              final cat = scoreValue is num ? <String, dynamic>{'score': scoreValue} : <String, dynamic>{};
              return _buildCategory(name, cat, diff[name]);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(String name, Map<String, dynamic> cat, dynamic diffEntry) {
    if (cat['score'] == null) return const SizedBox.shrink();

    final score = (cat['score'] as num).toDouble();
    final Color colors = _catScoreColor(score);
    final Color bg = _catScoreBg(score);

    final diffs = diffEntry is Map<String, dynamic> ? diffEntry : <String, dynamic>{};

    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0x0D000000), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                child: Text('${score.toStringAsFixed(0)}점', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: colors)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation(colors),
              minHeight: 8,
            ),
          ),
          if (diffs.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...diffs.entries.where((e) => e.value != null).map((e) {
              final val = e.value;
              String diffText;
              if (val is num) {
                diffText = val.toStringAsFixed(1);
              } else if (val is bool || val is int) {
                diffText = val.toString();
              } else {
                diffText = val.toString();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(
                      width: 5, height: 5,
                      decoration: BoxDecoration(color: colors, borderRadius: BorderRadius.circular(3)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${e.key}: 차이 $diffText',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF4B5563)),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Color _scoreBg(double s) {
    if (s >= 80) return const Color(0xFFF0FDF4);
    if (s >= 60) return const Color(0xFFFFFBEB);
    return const Color(0xFFFEF2F2);
  }

  Color _scoreColor(double s) {
    if (s >= 80) return const Color(0xFF16A34A);
    if (s >= 60) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  Color _catScoreColor(double s) {
    if (s >= 80) return const Color(0xFF16A34A);
    if (s >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Color _catScoreBg(double s) {
    if (s >= 80) return const Color(0xFFDCFCE7);
    if (s >= 60) return const Color(0xFFFEF3C7);
    return const Color(0xFFFEE2E2);
  }
}
