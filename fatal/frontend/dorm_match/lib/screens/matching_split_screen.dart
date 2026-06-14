import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/api_service.dart';
import 'match_screen.dart';

class MatchingSplitScreen extends StatefulWidget {
  const MatchingSplitScreen({super.key});

  @override
  State<MatchingSplitScreen> createState() => _MatchingSplitScreenState();
}

class _MatchingSplitScreenState extends State<MatchingSplitScreen> {
  final ApiService _api = ApiService();
  bool _loading = true;
  bool _saving = false;
  String _phase = 'closed';
  int _maxSelectable = 0;
  List<Map<String, dynamic>> _dorms = const [];
  final List<String> _selected = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await _api.getMatchingOptions();
      final selected = List<String>.from(res['selected_halls'] ?? const []);
      setState(() {
        _phase = (res['phase'] ?? 'closed').toString();
        _maxSelectable = (res['max_selectable'] ?? 0) as int;
        _dorms = List<Map<String, dynamic>>.from(
          res['visible_dorms'] ?? const [],
        );
        _selected
          ..clear()
          ..addAll(selected);
      });
    } catch (e) {
      Get.snackbar('오류', '매칭 정보를 불러오지 못했습니다: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _start() async {
    if (_selected.isEmpty) {
      Get.snackbar('알림', '선호 관을 선택해주세요.');
      return;
    }
    setState(() => _saving = true);
    try {
      await _api.saveMatchingPreferences(_selected);
      if (!mounted) return;
      Get.to(() => const MatchScreen());
    } catch (e) {
      Get.snackbar('오류', '저장 실패: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('매칭나누기')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _phase == 'preliminary'
                        ? '예비 매칭 기간'
                        : _phase == 'main'
                        ? '메인 매칭 기간'
                        : '매칭 기간 외',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '선택 가능 관 수: $_maxSelectable개',
                    style: const TextStyle(color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _dorms.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final d = _dorms[i];
                        final name = (d['name'] ?? '').toString();
                        final selected = _selected.contains(name);
                        final genderText = d['gender'] == 'male'
                            ? '남'
                            : d['gender'] == 'female'
                            ? '여'
                            : '남여';
                        return GestureDetector(
                          onTap: _phase == 'closed'
                              ? null
                              : () {
                                  setState(() {
                                    if (selected) {
                                      _selected.remove(name);
                                      return;
                                    }
                                    if (_selected.length >= _maxSelectable) {
                                      Get.snackbar(
                                        '알림',
                                        '최대 $_maxSelectable개까지 선택할 수 있습니다.',
                                      );
                                      return;
                                    }
                                    _selected.add(name);
                                  });
                                },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFFE5E7EB),
                                width: selected ? 2 : 1,
                              ),
                              boxShadow: selected
                                  ? const [
                                      BoxShadow(
                                        color: Color(0x332563EB),
                                        blurRadius: 14,
                                        offset: Offset(0, 6),
                                      ),
                                    ]
                                  : const [],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: selected
                                              ? const Color(0xFF1D4ED8)
                                              : const Color(0xFF111827),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$genderText 기숙사',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  selected
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: selected
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFF9CA3AF),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_phase == 'closed' || _saving)
                          ? null
                          : _start,
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('매칭 시작'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
