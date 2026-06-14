import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/api_service.dart';
import 'match_history_detail_screen.dart';

class MatchHistoryScreen extends StatefulWidget {
  const MatchHistoryScreen({super.key});

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  final _api = ApiService();
  final _items = <Map<String, dynamic>>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    try {
      final rows = await _api.getSessionHistory();
      _items
        ..clear()
        ..addAll(List<Map<String, dynamic>>.from(rows));
    } catch (e) {
      Get.snackbar('오류', '매칭 이력을 불러오지 못했습니다: $e');
      _items.clear();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('매칭')),
      body: RefreshIndicator(
        onRefresh: _fetchHistory,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _separatedNotice(),
            const SizedBox(height: 14),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_items.isEmpty)
              _emptyState()
            else
              ..._items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _historyCard(item),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _separatedNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Text(
        '이 화면은 매칭 이력 전용 페이지입니다.\n"현재 매칭중인 기숙사 찾기 → 매칭나누기 → 매칭 시작" 흐름과는 별개입니다.',
        style: TextStyle(
          color: Color(0xFF1E3A8A),
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 56),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 44, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          const Text(
            '아직 시작된 매칭이 없습니다.',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyCard(Map<String, dynamic> item) {
    final kind = _matchKindLabel(item['match_kind']?.toString());
    final createdAt = _formatDate(item['created_at']?.toString());
    final status = _statusLabel(item['ui_status']?.toString());
    final statusColor = _statusColor(status);
    final statusBg = _statusBackground(status);

    return InkWell(
      onTap: () => Get.to(() => MatchHistoryDetailScreen(session: item)),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 12,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.history,
                color: Color(0xFF1D4ED8),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kind,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    createdAt,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _matchKindLabel(String? raw) {
    switch (raw) {
      case 'one_room':
        return '자취방';
      case 'share_house':
        return '쉐어하우스';
      case 'dormitory':
      default:
        return '기숙사';
    }
  }

  String _statusLabel(String? raw) {
    if (raw == 'match_success') return '매칭 성공';
    if (raw == 'on_hold') return '보류중';
    if (raw == 'rejected') return '거절됨';
    return raw == 'in_progress' ? '진행중' : '기간종료';
  }

  Color _statusColor(String status) {
    if (status == '매칭 성공') return const Color(0xFF065F46);
    if (status == '보류중') return const Color(0xFF92400E);
    if (status == '거절됨') return const Color(0xFFB91C1C);
    if (status == '진행중') return const Color(0xFF16A34A);
    return const Color(0xFF6B7280);
  }

  Color _statusBackground(String status) {
    if (status == '매칭 성공') return const Color(0xFFD1FAE5);
    if (status == '보류중') return const Color(0xFFFEF3C7);
    if (status == '거절됨') return const Color(0xFFFEE2E2);
    if (status == '진행중') return const Color(0xFFDCFCE7);
    return const Color(0xFFF3F4F6);
  }

  String _formatDate(String? iso) {
    final dt = DateTime.tryParse(iso ?? '');
    if (dt == null) return '-';
    return '${dt.year}.${_two(dt.month)}.${_two(dt.day)} ${_two(dt.hour)}:${_two(dt.minute)}';
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}

