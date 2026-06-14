import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/match_controller.dart';
import '../utils/match_ui_helper.dart';
import 'chat_threads_screen.dart';
import 'match_detail_screen.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final _matchCtrl = Get.find<MatchController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('매칭 시작'),
        actions: [
          IconButton(
            tooltip: '채팅 목록',
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => Get.to(() => const ChatThreadsScreen()),
          ),
          IconButton(
            tooltip: '새로고침',
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _matchCtrl.refreshPool();
              await _matchCtrl.fetchThreads();
              await _matchCtrl.fetchActiveSessions();
            },
          ),
        ],
      ),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: () async {
            await _matchCtrl.refreshPool();
            await _matchCtrl.fetchThreads();
            await _matchCtrl.fetchActiveSessions();
            await _matchCtrl.fetchCooldown();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _statusPanel(),
              const SizedBox(height: 14),
              if (_matchCtrl.isInCooldown) _cooldownPanel(),
              if (_matchCtrl.isInCooldown) const SizedBox(height: 14),
              if (_matchCtrl.isLoading.value &&
                  _matchCtrl.poolCandidates.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_matchCtrl.poolCandidates.isEmpty)
                _emptyPoolState()
              else
                ..._matchCtrl.poolCandidates.map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _poolCard(c),
                  );
                }),
            ],
          ),
        );
      }),
    );
  }

  Widget _statusPanel() {
    final openCount = _matchCtrl.chatThreads
        .where((t) => (t['status']?.toString() ?? 'open') == 'open')
        .length;
    final closedCount = _matchCtrl.chatThreads.length - openCount;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _badge(
            '진행 중 대화 $openCount개',
            const Color(0xFFDCFCE7),
            const Color(0xFF166534),
          ),
          _badge(
            '종료된 대화 $closedCount개',
            const Color(0xFFF3F4F6),
            const Color(0xFF4B5563),
          ),
          if (_matchCtrl.canRematch)
            _badge('재매칭 가능', const Color(0xFFFFF7ED), const Color(0xFF9A3412)),
          if (_matchCtrl.isInCooldown)
            _badge(
              '쿨다운 진행 중',
              const Color(0xFFEEF2FF),
              const Color(0xFF3730A3),
            ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  Widget _cooldownPanel() {
    final until = _matchCtrl.cooldownUntil.value;
    final remain = until?.difference(DateTime.now());
    final remainHours = remain == null ? 0 : remain.inHours;
    final retryAt = until == null ? '시간 정보 없음' : _formatLocalTime(until);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC7D2FE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: Color(0xFF4338CA)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              remainHours > 0
                  ? '재시도 가능 시각: $retryAt (약 $remainHours시간 후)'
                  : '재시도 가능 시각: $retryAt',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF312E81),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyPoolState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 54),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.group_off, size: 46, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          const Text(
            '현재 매칭 후보가 비어 있습니다.',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '아래로 당겨 새로고침해 주세요.',
            style: TextStyle(color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  Widget _poolCard(Map<String, dynamic> item) {
    final candidateType = item['candidate_type']?.toString() ?? 'individual';
    final isRoom = candidateType == 'room';
    final profile = (item['profile'] is Map<String, dynamic>)
        ? item['profile'] as Map<String, dynamic>
        : <String, dynamic>{};
    final memberNames = List<String>.from(item['member_names'] ?? const []);

    final displayName = isRoom
        ? (item['display_name']?.toString() ?? '${memberNames.join(', ')}의 방')
        : (profile['name']?.toString() ?? '상대 사용자');
    final summary = MatchUiHelper.summaryFrom(item);

    return GestureDetector(
      onTap: () => Get.to(() => MatchDetailScreen(matchData: item)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRoom ? const Color(0xFF1E3A8A) : const Color(0xFFE5E7EB),
            width: isRoom ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _avatar(displayName),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _candidateTypeChip(isRoom),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        summary.grade.label,
                        style: TextStyle(
                          color: summary.grade.foreground,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        summary.subtitle,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _reasonBlock('잘 맞는 점', summary.strengths, const Color(0xFFEFF6FF)),
            const SizedBox(height: 8),
            _reasonBlock('미리 조율할 점', summary.cautions, const Color(0xFFFFF7ED)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    Get.to(() => MatchDetailScreen(matchData: item)),
                icon: const Icon(Icons.person_search_outlined, size: 18),
                label: const Text('프로필 보기'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  foregroundColor: const Color(0xFF1D4ED8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _candidateTypeChip(bool isRoom) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isRoom ? const Color(0xFFDBEAFE) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        MatchUiHelper.candidateLabel(isRoom),
        style: TextStyle(
          fontSize: 11,
          color: isRoom ? const Color(0xFF1D4ED8) : const Color(0xFF4B5563),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _reasonBlock(String title, List<String> lines, Color background) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '- $line',
                style: const TextStyle(
                  color: Color(0xFF4B5563),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(String name) {
    final letter = name.isNotEmpty ? name.substring(0, 1) : '?';
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E3A8A),
        ),
      ),
    );
  }

  String _formatLocalTime(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$month/$day $hour:$minute';
  }
}
