import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/match_controller.dart';
import 'match_detail_screen.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> with SingleTickerProviderStateMixin {
  final _matchCtrl = Get.put(MatchController());
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _matchCtrl.fetchTopMatches();
    _matchCtrl.fetchPairs();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('매칭 결과'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabCtrl,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 2))],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: const Color(0xFF1D4ED8),
              unselectedLabelColor: const Color(0xFF9CA3AF),
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              dividerHeight: 0,
              tabs: const [
                Tab(text: '내 매칭'),
                Tab(text: '전체 최적'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          Obx(() => _buildList(_matchCtrl.topMatches, isTopMatch: true)),
          Obx(() => _buildPairsList()),
        ],
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items, {required bool isTopMatch}) {
    if (_matchCtrl.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }
    if (items.isEmpty) {
      return _emptyState();
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _matchCard(items[i], isTopMatch: isTopMatch),
    );
  }

  Widget _buildPairsList() {
    if (_matchCtrl.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }
    final pairs = _matchCtrl.pairs;
    if (pairs.isEmpty) {
      return _emptyState();
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: pairs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final p = pairs[i];
        final a = p['A'] ?? {};
        final b = p['B'] ?? {};
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: const Color(0x0D000000), blurRadius: 16, offset: const Offset(0, 4)),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              _pairAvatar(a['name']?.toString() ?? '?', Colors.blue.shade100, Colors.blue.shade900),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${a['name'] ?? '?'} & ${b['name'] ?? '?'}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text('매칭 점수 ${_fmtScore(p['score'])}', style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _matchCard(Map<String, dynamic> m, {required bool isTopMatch}) {
    final score = (m['score'] as num?)?.toDouble() ?? 0;
    final block = m['hard_block'] == true || m['hard_block'] == 1;
    final name = m['name']?.toString() ?? '이름 없음';
    final dept = m['department']?.toString() ?? m['college']?.toString() ?? '';
    final year = m['birth_year']?.toString() ?? '';

    return GestureDetector(
      onTap: () => Get.to(() => MatchDetailScreen(matchData: m)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: const Color(0x0D000000), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            _pairAvatar(name.substring(0, 1), const Color(0xFFE0E7FF), const Color(0xFF1E3A8A)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      if (block)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8)),
                          child: const Text('Hard Block', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFDC2626))),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    [if (year.isNotEmpty) year, dept].join(' · '),
                    style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _scoreBg(score),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text('${_fmtScore(score)} 점', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _scoreColor(score))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          const Text('아직 매칭 결과가 없습니다.', style: TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          const Text('설문조사를 먼저 완료해 주세요.', style: TextStyle(color: Color(0xFFB0B5BD), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _pairAvatar(String letter, Color bg, Color fg) {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      alignment: Alignment.center,
      child: Text(letter, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: fg)),
    );
  }

  String _fmtScore(score) {
    if (score == null) return '0';
    final v = score is num ? score.toDouble() : 0.0;
    return v.toStringAsFixed(1);
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
}
