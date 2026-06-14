import 'dart:convert';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import 'notices_screen.dart';
import 'persona_detail_screen.dart';
import 'survey_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final profileCtrl = Get.find<ProfileController>();
    final user = auth.user.value;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '프로필',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.to(() => const NoticesScreen()),
                      icon: const Icon(
                        Icons.campaign_outlined,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _EditableAvatar(
                      displayName: user?.name ?? 'U',
                      userUid: user?.userUid ?? '',
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? '사용자',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.schoolName ?? '학교 정보 미등록',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => Get.to(() => const SurveyScreen()),
                      icon: const Icon(Icons.edit_note_rounded, size: 18),
                      label: const Text('설문지 편집'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        foregroundColor: const Color(0xFF334155),
                        textStyle: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: const Text(
                  '나의 유형',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Obx(() {
                  if (profileCtrl.isLoading.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (profileCtrl.profile.value == null) {
                    return _surveyAlertCard();
                  }
                  return GestureDetector(
                    onTap: () {
                      final profile = profileCtrl.profile.value;
                      if (profile != null) {
                        Get.to(() => PersonaDetailScreen(profile: profile));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: _cardDecoration(),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEEFFB),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.psychology_alt_rounded,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '유형 상세보기',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '8가지 유형과 나의 생활 성향을 비교해보세요',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Color(0xFF9CA3AF),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: const Text(
                  '간편 기능',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: _QuickFunctionsSection(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: const Text(
                  '매칭 이력 및 통계',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _statCard(
                      icon: Icons.favorite_outline,
                      title: '내가 선호하는 룸메 유형',
                      subtitle: '실시간으로 업데이트되는 매칭 통계 데이터',
                      color: const Color(0xFFEC4899),
                    ),
                    const SizedBox(height: 12),
                    _statCard(
                      icon: Icons.send_outlined,
                      title: '내가 자주 매칭 요청을 보낸 유형',
                      subtitle: '나의 매칭 패턴 분석 결과',
                      color: const Color(0xFF2563EB),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: const Text(
                  '내가 받은 후기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: _cardDecoration(),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.rate_review_outlined,
                        size: 48,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '아직 받은 후기가 없어요',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '매칭이 완료되면 상대방의 후기를 확인할 수 있어요',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  static BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D000000),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  Widget _surveyAlertCard() {
    return GestureDetector(
      onTap: () => Get.to(() => const SurveyScreen()),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFCD34D)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.pending_actions_rounded,
              color: Color(0xFFD97706),
              size: 28,
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '설문지를 아직 작성하지 않으셨어요',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '클릭해서 지금 작성해보세요',
                    style: TextStyle(fontSize: 13, color: Color(0xFFB45309)),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Color(0xFFD97706),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.lock_outline, size: 18, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }
}

class _EditableAvatar extends StatefulWidget {
  const _EditableAvatar({required this.displayName, required this.userUid});

  final String displayName;
  final String userUid;

  @override
  State<_EditableAvatar> createState() => _EditableAvatarState();
}

class _EditableAvatarState extends State<_EditableAvatar> {
  static const List<IconData> _iconChoices = [
    Icons.self_improvement,
    Icons.sports_basketball,
    Icons.music_note,
    Icons.menu_book,
    Icons.coffee,
    Icons.code,
    Icons.pets,
    Icons.local_cafe,
    Icons.flight_takeoff,
    Icons.palette,
    Icons.movie,
    Icons.camera_alt,
    Icons.restaurant,
    Icons.sports_esports,
    Icons.park,
    Icons.hiking,
    Icons.nightlight,
    Icons.school,
    Icons.psychology,
    Icons.wb_sunny,
  ];

  String? _photoBase64;
  Uint8List? _photoBytes;
  int? _selectedIconCodePoint;
  bool _isLoading = true;

  String get _scope => widget.userUid.isEmpty ? 'guest' : widget.userUid;
  String get _photoKey => 'profile_avatar_photo_base64_$_scope';
  String get _iconKey => 'profile_avatar_icon_codepoint_$_scope';

  @override
  void initState() {
    super.initState();
    _loadAvatarSettings();
  }

  @override
  void didUpdateWidget(covariant _EditableAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userUid != widget.userUid) {
      _loadAvatarSettings();
    }
  }

  Future<void> _loadAvatarSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPhoto = prefs.getString(_photoKey);
    final savedCodePoint = prefs.getInt(_iconKey);

    setState(() {
      _photoBase64 = savedPhoto;
      _photoBytes = savedPhoto != null ? base64Decode(savedPhoto) : null;
      _selectedIconCodePoint = savedCodePoint;
      _isLoading = false;
    });
  }

  Future<void> _saveAvatarSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (_photoBase64 == null) {
      await prefs.remove(_photoKey);
    } else {
      await prefs.setString(_photoKey, _photoBase64!);
    }
    if (_selectedIconCodePoint == null) {
      await prefs.remove(_iconKey);
    } else {
      await prefs.setInt(_iconKey, _selectedIconCodePoint!);
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    setState(() {
      _photoBytes = bytes;
      _photoBase64 = base64Encode(bytes);
      _selectedIconCodePoint = null;
    });
    await _saveAvatarSettings();
    if (mounted) {
      Get.snackbar('프로필 설정', '프로필 사진이 적용되었습니다.');
    }
  }

  Future<void> _setIcon(IconData icon) async {
    setState(() {
      _selectedIconCodePoint = icon.codePoint;
      _photoBytes = null;
      _photoBase64 = null;
    });
    await _saveAvatarSettings();
  }

  Future<void> _clearAvatar() async {
    setState(() {
      _selectedIconCodePoint = null;
      _photoBase64 = null;
      _photoBytes = null;
    });
    await _saveAvatarSettings();
  }

  Future<void> _openAvatarSettings() async {
    if (_isLoading) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            Future<void> syncFromState(Future<void> Function() action) async {
              await action();
              setLocalState(() {});
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '프로필 설정',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _avatarContainer(size: 60),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _photoBytes != null
                                  ? '사진 프로필 사용 중'
                                  : _selectedIconCodePoint != null
                                  ? '아이콘 프로필 사용 중'
                                  : '기본 프로필 사용 중',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => syncFromState(_pickPhoto),
                              icon: const Icon(Icons.photo_library_outlined),
                              label: const Text('사진 선택'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => syncFromState(_clearAvatar),
                              icon: const Icon(Icons.refresh),
                              label: const Text('기본으로'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        '아이콘 선택 (20종)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _iconChoices.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                            ),
                        itemBuilder: (context, index) {
                          final icon = _iconChoices[index];
                          final selected =
                              _selectedIconCodePoint == icon.codePoint;
                          return InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => syncFromState(() => _setIcon(icon)),
                            child: Container(
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFFDBEAFE)
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: selected
                                      ? const Color(0xFF1D4ED8)
                                      : const Color(0xFFD1D5DB),
                                ),
                              ),
                              child: Icon(
                                icon,
                                color: selected
                                    ? const Color(0xFF1D4ED8)
                                    : const Color(0xFF4B5563),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _avatarContainer({double size = 72}) {
    final borderRadius = BorderRadius.circular(size / 3);
    final iconData = _selectedIconCodePoint == null
        ? Icons.person
        : IconData(_selectedIconCodePoint!, fontFamily: 'MaterialIcons');

    return GestureDetector(
      onTap: _openAvatarSettings,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
              ),
              borderRadius: borderRadius,
            ),
            clipBehavior: Clip.antiAlias,
            child: _photoBytes != null
                ? Image.memory(_photoBytes!, fit: BoxFit.cover)
                : Icon(iconData, color: Colors.white, size: size * 0.5),
          ),
          Positioned(
            right: -4,
            bottom: -4,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Icon(Icons.edit, size: 14, color: Color(0xFF374151)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _avatarContainer();
  }
}

class _QuickFunctionsSection extends StatefulWidget {
  const _QuickFunctionsSection();

  @override
  State<_QuickFunctionsSection> createState() => _QuickFunctionsSectionState();
}

class _QuickFunctionsSectionState extends State<_QuickFunctionsSection> {
  static const List<String> _days = ['월', '화', '수', '목', '금', '토', '일'];
  static const String _weeklyKey = 'quick_functions_weekly_selected';
  static const String _showAllHoursKey = 'quick_functions_show_all_hours';
  static const String _calendarLinkedKey = 'quick_functions_calendar_linked';
  static const String _monthlyMemoKey = 'quick_functions_monthly_memo';
  static const String _dailyExpandedKey = 'quick_functions_daily_expanded';
  static const String _monthlyExpandedKey = 'quick_functions_monthly_expanded';

  final Set<int> _weeklySelected = <int>{};
  final Map<String, String> _monthlyMemos = <String, String>{};

  bool _showAllHours = false;
  bool _calendarLinked = false;
  bool _dailyExpanded = false;
  bool _monthlyExpanded = false;
  bool _isLoading = true;
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDay = DateUtils.dateOnly(DateTime.now());

  bool? _dragValue;
  final Set<int> _dragTouched = <int>{};

  int get _startHour => _showAllHours ? 0 : 7;
  int get _endHour => _showAllHours ? 24 : 23;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final weeklyRaw = prefs.getString(_weeklyKey);
    final monthlyRaw = prefs.getString(_monthlyMemoKey);

    if (weeklyRaw != null) {
      final decoded = jsonDecode(weeklyRaw);
      if (decoded is List) {
        for (final value in decoded) {
          if (value is int && value >= 0 && value < 168) {
            _weeklySelected.add(value);
          }
        }
      }
    }
    if (monthlyRaw != null) {
      final decoded = jsonDecode(monthlyRaw);
      if (decoded is Map) {
        for (final entry in decoded.entries) {
          if (entry.key is String && entry.value is String) {
            _monthlyMemos[entry.key.toString()] = entry.value.toString();
          }
        }
      }
    }

    setState(() {
      _showAllHours = prefs.getBool(_showAllHoursKey) ?? false;
      _calendarLinked = prefs.getBool(_calendarLinkedKey) ?? false;
      _dailyExpanded = prefs.getBool(_dailyExpandedKey) ?? false;
      _monthlyExpanded = prefs.getBool(_monthlyExpandedKey) ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveWeekly() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _weeklyKey,
      jsonEncode(_weeklySelected.toList()..sort()),
    );
  }

  Future<void> _saveMonthly() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_monthlyMemoKey, jsonEncode(_monthlyMemos));
  }

  Future<void> _toggleShowAllHours(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showAllHoursKey, value);
    setState(() => _showAllHours = value);
  }

  Future<void> _toggleCalendarLinked(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_calendarLinkedKey, value);
    setState(() => _calendarLinked = value);
  }

  Future<void> _toggleDailyExpanded() async {
    final prefs = await SharedPreferences.getInstance();
    final next = !_dailyExpanded;
    await prefs.setBool(_dailyExpandedKey, next);
    setState(() => _dailyExpanded = next);
  }

  Future<void> _toggleMonthlyExpanded() async {
    final prefs = await SharedPreferences.getInstance();
    final next = !_monthlyExpanded;
    await prefs.setBool(_monthlyExpandedKey, next);
    setState(() => _monthlyExpanded = next);
  }

  String _keyFromDate(DateTime day) {
    return '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
  }

  DateTime _weekStart(DateTime day) =>
      day.subtract(Duration(days: day.weekday - 1));

  int _slotIndex(int dayIndex, int hour) => dayIndex * 24 + hour;

  TimeOfDay _toTimeOfDay(int hour) => TimeOfDay(hour: hour, minute: 0);

  String _hourLabel(int hour) {
    final tod = _toTimeOfDay(hour);
    final suffix = tod.period == DayPeriod.am ? '오전' : '오후';
    final hour12 = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
    return '$suffix $hour12';
  }

  void _handleDragStart(int dayIndex, int hour) {
    final index = _slotIndex(dayIndex, hour);
    _dragValue = !_weeklySelected.contains(index);
    _dragTouched.clear();
    _setSlot(index, _dragValue!);
  }

  void _handleDragMove(int dayIndex, int hour) {
    final index = _slotIndex(dayIndex, hour);
    if (_dragValue == null || _dragTouched.contains(index)) return;
    _setSlot(index, _dragValue!);
  }

  void _setSlot(int index, bool enabled) {
    setState(() {
      if (enabled) {
        _weeklySelected.add(index);
      } else {
        _weeklySelected.remove(index);
      }
      _dragTouched.add(index);
    });
  }

  Future<void> _handleDragEnd() async {
    _dragValue = null;
    _dragTouched.clear();
    await _saveWeekly();
  }

  int _visibleSelectedCount() {
    var count = 0;
    for (final day in List<int>.generate(7, (i) => i)) {
      for (int hour = _startHour; hour < _endHour; hour++) {
        if (_weeklySelected.contains(_slotIndex(day, hour))) count++;
      }
    }
    return count;
  }

  String _monthTitle(DateTime month) => '${month.year}년 ${month.month}월';

  int _daysInMonth(DateTime month) =>
      DateUtils.getDaysInMonth(month.year, month.month);

  int _leadingBlanks(DateTime month) =>
      DateTime(month.year, month.month, 1).weekday - 1;

  void _changeMonth(int delta) {
    setState(
      () => _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + delta,
      ),
    );
  }

  Future<void> _editMemo(DateTime day) async {
    if (_calendarLinked) return;

    final key = _keyFromDate(day);
    final controller = TextEditingController(text: _monthlyMemos[key] ?? '');
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${day.month}월 ${day.day}일 일정',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: '예: 19시 팀플 미팅',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop('__delete__'),
                      child: const Text('삭제'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () =>
                          Navigator.of(ctx).pop(controller.text.trim()),
                      child: const Text('저장'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (result == null) return;
    setState(() {
      if (result == '__delete__' || result.isEmpty) {
        _monthlyMemos.remove(key);
      } else {
        _monthlyMemos[key] = result;
      }
      _selectedDay = day;
    });
    await _saveMonthly();
  }

  Future<void> _syncSelectedDayToDeviceCalendar() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      Get.snackbar('지원 불가', '기기 캘린더 연동은 Android/iOS에서만 지원됩니다.');
      return;
    }

    final key = _keyFromDate(_selectedDay);
    final memo = (_monthlyMemos[key] ?? '').trim();
    final startDate = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      9,
    );
    final endDate = startDate.add(const Duration(hours: 1));

    final event = Event(
      title: memo.isNotEmpty ? memo : '룸메이트 일정',
      description: '프로필 > 간편 기능 > 월간일정에서 등록한 일정',
      startDate: startDate,
      endDate: endDate,
      allDay: false,
      iosParams: const IOSParams(reminder: Duration(minutes: 30)),
      androidParams: const AndroidParams(emailInvites: <String>[]),
    );

    await Add2Calendar.addEvent2Cal(event);
    Get.snackbar(
      '연동 완료',
      '${_selectedDay.month}월 ${_selectedDay.day}일 일정이 추가되었습니다.',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final weekStart = _weekStart(DateUtils.dateOnly(DateTime.now()));
    final visibleSelected = _visibleSelectedCount();

    return Column(
      children: [
        _buildExpandableShell(
          title: '나의하루',
          subtitle: 'when2meet처럼 주간 가능 시간을 드래그로 입력',
          icon: Icons.schedule,
          iconColor: const Color(0xFF15803D),
          iconBg: const Color(0xFFDCFCE7),
          expanded: _dailyExpanded,
          onToggle: _toggleDailyExpanded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '이번 주 가능 시간: $visibleSelected칸',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _toggleShowAllHours(!_showAllHours),
                    icon: Icon(
                      _showAllHours ? Icons.compress : Icons.expand,
                      size: 16,
                    ),
                    label: Text(_showAllHours ? '기본 시간대 보기' : '24시간 전체 보기'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _WeeklyDragGrid(
                days: _days,
                startHour: _startHour,
                endHour: _endHour,
                selected: _weeklySelected,
                hourLabelBuilder: _hourLabel,
                slotIndexBuilder: _slotIndex,
                onStart: _handleDragStart,
                onMove: _handleDragMove,
                onEnd: _handleDragEnd,
              ),
              const SizedBox(height: 8),
              Text(
                '${weekStart.month}/${weekStart.day} ~ ${weekStart.add(const Duration(days: 6)).month}/${weekStart.add(const Duration(days: 6)).day}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildExpandableShell(
          title: '월간일정',
          subtitle: '캘린더 미연동 시 앱 내 월간 일정표 작성',
          icon: Icons.calendar_month,
          iconColor: const Color(0xFF1D4ED8),
          iconBg: const Color(0xFFDBEAFE),
          expanded: _monthlyExpanded,
          onToggle: _toggleMonthlyExpanded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _calendarLinked,
                title: const Text(
                  'Android / iOS 캘린더 연동',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  _calendarLinked ? '연동됨: 기기 캘린더 중심으로 관리' : '미연동: 앱 내 일정 작성 가능',
                  style: const TextStyle(fontSize: 12.5),
                ),
                onChanged: _toggleCalendarLinked,
              ),
              const SizedBox(height: 8),
              _MonthlyCalendarGrid(
                month: _currentMonth,
                selectedDay: _selectedDay,
                memoKeys: _monthlyMemos.keys.toSet(),
                isDisabled: _calendarLinked,
                onPrevMonth: () => _changeMonth(-1),
                onNextMonth: () => _changeMonth(1),
                onSelectDay: (day) async {
                  setState(() => _selectedDay = day);
                  if (!_calendarLinked) await _editMemo(day);
                },
                monthTitle: _monthTitle(_currentMonth),
                daysInMonth: _daysInMonth(_currentMonth),
                leadingBlanks: _leadingBlanks(_currentMonth),
              ),
              const SizedBox(height: 10),
              if (_calendarLinked)
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _syncSelectedDayToDeviceCalendar,
                    icon: const Icon(Icons.sync_alt, size: 18),
                    label: const Text('선택일 캘린더에 추가'),
                  ),
                )
              else
                const Text(
                  '날짜를 탭하면 월간 일정을 작성하거나 수정할 수 있어요.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableShell({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required bool expanded,
    required Future<void> Function() onToggle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: ProfileScreen._cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onToggle,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  color: const Color(0xFF6B7280),
                ),
              ],
            ),
          ),
          if (expanded) ...[const SizedBox(height: 12), child],
        ],
      ),
    );
  }
}

class _WeeklyDragGrid extends StatefulWidget {
  const _WeeklyDragGrid({
    required this.days,
    required this.startHour,
    required this.endHour,
    required this.selected,
    required this.hourLabelBuilder,
    required this.slotIndexBuilder,
    required this.onStart,
    required this.onMove,
    required this.onEnd,
  });

  final List<String> days;
  final int startHour;
  final int endHour;
  final Set<int> selected;
  final String Function(int hour) hourLabelBuilder;
  final int Function(int dayIndex, int hour) slotIndexBuilder;
  final void Function(int dayIndex, int hour) onStart;
  final void Function(int dayIndex, int hour) onMove;
  final Future<void> Function() onEnd;

  @override
  State<_WeeklyDragGrid> createState() => _WeeklyDragGridState();
}

class _WeeklyDragGridState extends State<_WeeklyDragGrid> {
  static const double _dayLabelWidth = 44;
  static const double _headerHeight = 30;
  static const double _rowHeight = 30;

  (int dayIndex, int hour)? _positionToSlot(
    Offset localPosition,
    double maxWidth,
  ) {
    final usableWidth = maxWidth - _dayLabelWidth;
    if (usableWidth <= 0 || localPosition.dy < _headerHeight) return null;
    final cellWidth = usableWidth / 7;
    final x = localPosition.dx - _dayLabelWidth;
    if (x < 0) return null;
    final dayIndex = (x / cellWidth).floor();
    final row = ((localPosition.dy - _headerHeight) / _rowHeight).floor();
    if (dayIndex < 0 || dayIndex > 6) return null;
    final hour = widget.startHour + row;
    if (hour < widget.startHour || hour >= widget.endHour) return null;
    return (dayIndex, hour);
  }

  @override
  Widget build(BuildContext context) {
    final rowCount = widget.endHour - widget.startHour;
    final totalHeight = _headerHeight + rowCount * _rowHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final usableWidth = constraints.maxWidth - _dayLabelWidth;
        final cellWidth = usableWidth / 7;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) {
            final slot = _positionToSlot(
              details.localPosition,
              constraints.maxWidth,
            );
            if (slot == null) return;
            widget.onStart(slot.$1, slot.$2);
          },
          onPanUpdate: (details) {
            final slot = _positionToSlot(
              details.localPosition,
              constraints.maxWidth,
            );
            if (slot == null) return;
            widget.onMove(slot.$1, slot.$2);
          },
          onPanEnd: (_) => widget.onEnd(),
          onPanCancel: widget.onEnd,
          onTapDown: (details) {
            final slot = _positionToSlot(
              details.localPosition,
              constraints.maxWidth,
            );
            if (slot == null) return;
            widget.onStart(slot.$1, slot.$2);
            widget.onEnd();
          },
          child: Container(
            height: totalHeight,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Stack(
              children: [
                for (int i = 0; i < widget.days.length; i++)
                  Positioned(
                    left: _dayLabelWidth + (i * cellWidth),
                    top: 0,
                    width: cellWidth,
                    height: _headerHeight,
                    child: Center(
                      child: Text(
                        widget.days[i],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ),
                for (int row = 0; row < rowCount; row++)
                  Positioned(
                    left: 0,
                    top: _headerHeight + (row * _rowHeight),
                    width: _dayLabelWidth,
                    height: _rowHeight,
                    child: Center(
                      child: Text(
                        widget.hourLabelBuilder(widget.startHour + row),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                for (int row = 0; row < rowCount; row++)
                  for (int day = 0; day < 7; day++)
                    Positioned(
                      left: _dayLabelWidth + (day * cellWidth),
                      top: _headerHeight + (row * _rowHeight),
                      width: cellWidth,
                      height: _rowHeight,
                      child: Container(
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color:
                              widget.selected.contains(
                                widget.slotIndexBuilder(
                                  day,
                                  widget.startHour + row,
                                ),
                              )
                              ? const Color(0xFFBBF7D0)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _WeeklyGridLinesPainter(
                        dayLabelWidth: _dayLabelWidth,
                        headerHeight: _headerHeight,
                        rowHeight: _rowHeight,
                        rows: rowCount,
                        columns: 7,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WeeklyGridLinesPainter extends CustomPainter {
  _WeeklyGridLinesPainter({
    required this.dayLabelWidth,
    required this.headerHeight,
    required this.rowHeight,
    required this.rows,
    required this.columns,
  });

  final double dayLabelWidth;
  final double headerHeight;
  final double rowHeight;
  final int rows;
  final int columns;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;

    final cellWidth = (size.width - dayLabelWidth) / columns;

    canvas.drawLine(
      Offset(0, headerHeight),
      Offset(size.width, headerHeight),
      line,
    );
    canvas.drawLine(
      Offset(dayLabelWidth, 0),
      Offset(dayLabelWidth, size.height),
      line,
    );

    for (int c = 1; c < columns; c++) {
      final x = dayLabelWidth + cellWidth * c;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }

    for (int r = 1; r <= rows; r++) {
      final y = headerHeight + rowHeight * r;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyGridLinesPainter oldDelegate) {
    return oldDelegate.rows != rows ||
        oldDelegate.columns != columns ||
        oldDelegate.dayLabelWidth != dayLabelWidth ||
        oldDelegate.headerHeight != headerHeight ||
        oldDelegate.rowHeight != rowHeight;
  }
}

class _MonthlyCalendarGrid extends StatelessWidget {
  const _MonthlyCalendarGrid({
    required this.month,
    required this.selectedDay,
    required this.memoKeys,
    required this.isDisabled,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onSelectDay,
    required this.monthTitle,
    required this.daysInMonth,
    required this.leadingBlanks,
  });

  final DateTime month;
  final DateTime selectedDay;
  final Set<String> memoKeys;
  final bool isDisabled;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDay;
  final String monthTitle;
  final int daysInMonth;
  final int leadingBlanks;

  @override
  Widget build(BuildContext context) {
    final totalCells = ((leadingBlanks + daysInMonth + 6) ~/ 7) * 7;
    const weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onPrevMonth,
              icon: const Icon(Icons.chevron_left),
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: Text(
                monthTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              onPressed: onNextMonth,
              icon: const Icon(Icons.chevron_right),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final day in weekdayLabels)
              Expanded(
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: totalCells,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.02,
          ),
          itemBuilder: (context, index) {
            if (index < leadingBlanks || index >= leadingBlanks + daysInMonth) {
              return const SizedBox.shrink();
            }

            final dayNumber = index - leadingBlanks + 1;
            final day = DateTime(month.year, month.month, dayNumber);
            final key =
                '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
            final hasMemo = memoKeys.contains(key);
            final isSelected = DateUtils.isSameDay(day, selectedDay);

            return GestureDetector(
              onTap: () => onSelectDay(day),
              child: Opacity(
                opacity: isDisabled ? 0.7 : 1,
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isSelected
                        ? const Color(0xFFDBEAFE)
                        : const Color(0xFFF8FAFC),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF1D4ED8)
                              : const Color(0xFF374151),
                        ),
                      ),
                      if (hasMemo) ...[
                        const SizedBox(height: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
