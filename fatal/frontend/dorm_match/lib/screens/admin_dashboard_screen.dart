import 'package:flutter/material.dart';

import '../services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ApiService _api = ApiService();
  bool _loading = true;
  List<Map<String, dynamic>> _schools = const [];
  final _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await _api.getSchools();
      setState(() => _schools = List<Map<String, dynamic>>.from(res['schools'] ?? const []));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addSchool() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    await _api.createSchool({'name': _nameCtrl.text.trim()});
    _nameCtrl.clear();
    await _load();
  }

  Future<void> _editDorms(Map<String, dynamic> school) async {
    final dorms = List<Map<String, dynamic>>.from(school['dormitories'] ?? const []);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${school['name']} 기숙사 편집'),
        content: SizedBox(
          width: 420,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...dorms.map((d) => Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: (d['name'] ?? '').toString(),
                              onChanged: (v) => d['name'] = v,
                              decoration: const InputDecoration(labelText: '관 이름'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: (d['gender'] ?? 'coed').toString(),
                            items: const [
                              DropdownMenuItem(value: 'male', child: Text('남')),
                              DropdownMenuItem(value: 'female', child: Text('여')),
                              DropdownMenuItem(value: 'coed', child: Text('남여')),
                            ],
                            onChanged: (v) => setModalState(() => d['gender'] = v ?? 'coed'),
                          ),
                        ],
                      )),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => setModalState(() => dorms.add({'name': '', 'gender': 'coed'})),
                      child: const Text('관 추가'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          ElevatedButton(
            onPressed: () async {
              await _api.updateSchoolDorms(school['id'] as int, dorms);
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              _load();
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  Future<void> _editSchedule(Map<String, dynamic> school) async {
    final startCtrl = TextEditingController(text: (school['recruitment_start'] ?? '').toString());
    final endCtrl = TextEditingController(text: (school['recruitment_end'] ?? '').toString());
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${school['name']} 모집 일정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: startCtrl, decoration: const InputDecoration(labelText: '모집 시작일 (YYYY-MM-DD)')),
            const SizedBox(height: 8),
            TextField(controller: endCtrl, decoration: const InputDecoration(labelText: '모집 마감일 (YYYY-MM-DD)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          ElevatedButton(
            onPressed: () async {
              await _api.updateSchoolSchedule(
                school['id'] as int,
                {'recruitment_start': startCtrl.text.trim(), 'recruitment_end': endCtrl.text.trim()},
              );
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              _load();
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  Future<void> _openNoticesEditor() async {
    List<Map<String, dynamic>> notices = const [];
    String? loadError;
    try {
      notices = await _api.getAdminNotices();
    } catch (e) {
      loadError = e.toString();
    }

    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    bool pinned = false;
    int? editingId;
    bool saving = false;

    Future<void> refresh(StateSetter setModalState) async {
      try {
        final list = await _api.getAdminNotices();
        setModalState(() {
          notices = list;
          loadError = null;
        });
      } catch (e) {
        setModalState(() => loadError = e.toString());
      }
    }

    void bind(Map<String, dynamic> n, StateSetter setModalState) {
      setModalState(() {
        editingId = n['id'] as int;
        titleCtrl.text = (n['title'] ?? '').toString();
        bodyCtrl.text = (n['body'] ?? '').toString();
        pinned = n['is_pinned'] == true;
      });
    }

    void clearEditor(StateSetter setModalState) {
      setModalState(() {
        editingId = null;
        titleCtrl.clear();
        bodyCtrl.clear();
        pinned = false;
      });
    }

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('공지함 편집'),
        content: SizedBox(
          width: 760,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text('공지 목록'),
                      const Spacer(),
                      TextButton(
                        onPressed: () => clearEditor(setModalState),
                        child: const Text('새 공지'),
                      ),
                      TextButton(
                        onPressed: () => refresh(setModalState),
                        child: const Text('새로고침'),
                      ),
                    ],
                  ),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 230),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: loadError != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(loadError!, textAlign: TextAlign.center),
                            ),
                          )
                        : notices.isEmpty
                            ? const Center(child: Text('등록된 공지가 없습니다.'))
                            : ListView.builder(
                                itemCount: notices.length,
                                itemBuilder: (_, i) {
                                  final n = notices[i];
                                  final selected = editingId == n['id'];
                                  return ListTile(
                                    selected: selected,
                                    title: Text((n['title'] ?? '').toString()),
                                    subtitle: Text(
                                      (n['updated_at'] ?? '').toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    leading: n['is_pinned'] == true
                                        ? const Icon(Icons.push_pin, size: 18)
                                        : const SizedBox(width: 18),
                                    onTap: () => bind(n, setModalState),
                                    trailing: IconButton(
                                      tooltip: '삭제',
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () async {
                                        final id = n['id'] as int;
                                        await _api.deleteNotice(id);
                                        await refresh(setModalState);
                                        if (editingId == id) clearEditor(setModalState);
                                      },
                                    ),
                                  );
                                },
                              ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: '제목'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: bodyCtrl,
                    minLines: 4,
                    maxLines: 8,
                    decoration: const InputDecoration(labelText: '내용'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: pinned,
                        onChanged: (v) => setModalState(() => pinned = v ?? false),
                      ),
                      const Text('상단 고정'),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('닫기')),
          StatefulBuilder(
            builder: (context, setActionState) {
              return ElevatedButton(
                onPressed: saving
                    ? null
                    : () async {
                        final title = titleCtrl.text.trim();
                        final body = bodyCtrl.text.trim();
                        if (title.isEmpty || body.isEmpty) return;
                        setActionState(() => saving = true);
                        try {
                          if (editingId == null) {
                            await _api.createNotice({
                              'title': title,
                              'body': body,
                              'is_pinned': pinned,
                            });
                          } else {
                            await _api.updateNotice(editingId!, {
                              'title': title,
                              'body': body,
                              'is_pinned': pinned,
                            });
                          }
                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);
                          if (mounted) _openNoticesEditor();
                        } finally {
                          if (context.mounted) {
                            setActionState(() => saving = false);
                          }
                        }
                      },
                child: Text(editingId == null ? '공지 등록' : '공지 저장'),
              );
            },
          ),
        ],
      ),
    );
    titleCtrl.dispose();
    bodyCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('관리자 대시보드')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('별도 URL(/admin)에서 학교/기숙사/매칭 일정을 관리하는 화면입니다.'),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: _openNoticesEditor,
                      icon: const Icon(Icons.campaign_outlined),
                      label: const Text('공지함 편집'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(labelText: '학교명 추가'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(onPressed: _addSchool, child: const Text('추가')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _schools.length,
                      itemBuilder: (_, i) {
                        final s = _schools[i];
                        return Card(
                          child: ListTile(
                            title: Text((s['name'] ?? '').toString()),
                            subtitle: Text('매칭 상태: ${s['matching_phase']}'),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                TextButton(onPressed: () => _editDorms(s), child: const Text('기숙사 편집')),
                                TextButton(onPressed: () => _editSchedule(s), child: const Text('일정 편집')),
                                Switch(
                                  value: (s['matching_enabled'] ?? true) == true,
                                  onChanged: (v) async {
                                    await _api.toggleSchoolMatching(s['id'] as int, v);
                                    _load();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

