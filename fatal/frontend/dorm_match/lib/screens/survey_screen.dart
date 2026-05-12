import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../models/profile.dart';
import '../widgets/sleep_wake_range_slider.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final _profileCtrl = Get.put(ProfileController());
  final _auth = Get.find<AuthController>();
  late Profile _profile;

  @override
  void initState() {
    super.initState();
    _profile = _profileCtrl.profile.value?.copy() ?? Profile();
    // Fill name/studentId from user so user sees them (read-only)
    final u = _auth.user.value;
    if (u != null) {
      _profile.name = u.name;
      _profile.studentId = u.studentId;
    }
  }

  void _save() async {
    // Ensure name/studentId are fresh from user (JWT auto-fills them backend)
    final u = _auth.user.value;
    if (u != null) {
      _profile.name = u.name;
      _profile.studentId = u.studentId;
    }
    final error = await _profileCtrl.saveProfile(_profile);
    if (error == null) {
      Get.snackbar(
        '저장 완료',
        '설문조사가 저장되었습니다.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFE3F2FD),
        colorText: const Color(0xFF1565C0),
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
      );
    } else {
      Get.snackbar(
        '저장 실패',
        error,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFFEBEE),
        colorText: const Color(0xFFB71C1C),
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설문조사'),
        actions: [
          Obx(() => _profileCtrl.isLoading.value
              ? const Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)),
                  ),
                )
              : TextButton(
                  onPressed: _save,
                  child: const Text('저장', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('기본 정보'),
            _card([
              _readOnlyTile('이름', _profile.name),
              _divider(),
              _readOnlyTile('학번', _profile.studentId),
              _divider(),
              _birthYearTile(),
              _divider(),
              _textTile('단과대학', _profile.college, (v) => _profile.college = v),
              _divider(),
              _textTile('학과', _profile.department, (v) => _profile.department = v),
              _divider(),
              _dormDurationTile(),
            ]),
            _sectionHeader('생활 습관'),
            _card([
              _sliderTile('귀가 주기(월)', _profile.homeVisitCycle, 1, 4, (v) => setState(() => _profile.homeVisitCycle = v)),
              _divider(),
              _switchTile('향수 사용', _profile.perfume == 1, (v) => setState(() => _profile.perfume = v ? 1 : 0)),
              _divider(),
              _sliderTile('실내 냄새 민감도', _profile.indoorScentSensitivity, 1, 5, (v) => setState(() => _profile.indoorScentSensitivity = v)),
              _divider(),
              _alcoholToleranceTile(),
              _divider(),
              _sliderTile('음주 빈도(주)', _profile.alcoholFrequency, 0, 7, (v) => setState(() => _profile.alcoholFrequency = v)),
              _divider(),
              _switchTile('주사 있음', _profile.drunkHabit == 1, (v) => setState(() => _profile.drunkHabit = v ? 1 : 0)),
              _divider(),
              _sliderTile('게임/인터넷 시간/주', _profile.gamingHoursPerWeek, 0, 40, (v) => setState(() => _profile.gamingHoursPerWeek = v)),
              _divider(),
              _switchTile('스피커 사용', _profile.speakerUse == 1, (v) => setState(() => _profile.speakerUse = v ? 1 : 0)),
              _divider(),
              _switchTile('규칙적 운동', _profile.exercise == 1, (v) => setState(() => _profile.exercise = v ? 1 : 0)),
            ]),
            _sectionHeader('수면 습관'),
            _card([
              _sleepWakeRangeTile(),
              _divider(),
              _switchTile('이버릇 있음', _profile.sleepHabit == 1, (v) => setState(() => _profile.sleepHabit = v ? 1 : 0)),
              _divider(),
              _sliderTile('잠귀(수면 예민도)', _profile.sleepSensitivity, 1, 5, (v) => setState(() => _profile.sleepSensitivity = v)),
              _divider(),
              _sliderTile('알람 잘 들음?', _profile.alarmStrength, 1, 5, (v) => setState(() => _profile.alarmStrength = v)),
              _divider(),
              _switchTile('수면등(불 켜고 잠)', _profile.sleepLight == 1, (v) => setState(() => _profile.sleepLight = v ? 1 : 0)),
              _divider(),
              _switchTile('코골이', _profile.snoring == 1, (v) => setState(() => _profile.snoring = v ? 1 : 0)),
            ]),
            _sectionHeader('위생 / 화장실'),
            _card([
              _showerDurationTile((v) => setState(() => _profile.showerDuration = v)),
              _divider(),
              _sliderTile('샤워 시각', _profile.showerTime, 0, 23, (v) => setState(() => _profile.showerTime = v)),
              _divider(),
              _showerCycleTile((v) => setState(() => _profile.showerCycle = v)),
              _divider(),
              _sliderTile('청소 주기(일)', _profile.cleaningCycle, 1, 30, (v) => setState(() => _profile.cleaningCycle = v)),
              _divider(),
              _sliderTile('환기 횟수(일)', _profile.ventilation.round(), 0, 5, (v) => setState(() => _profile.ventilation = v.toDouble())),
              _divider(),
              _switchTile('헤어드라이기 비치', _profile.hairdryerInBathroom == 1, (v) => setState(() => _profile.hairdryerInBathroom = v ? 1 : 0)),
              _divider(),
              _switchTile('휴지 공유', _profile.toiletPaperShare == 1, (v) => setState(() => _profile.toiletPaperShare = v ? 1 : 0)),
              _divider(),
              _switchTile('방안 취식', _profile.indoorEating == 1, (v) => setState(() => _profile.indoorEating = v ? 1 : 0)),
              _divider(),
              _switchTile('흡연', _profile.smoking == 1, (v) => setState(() => _profile.smoking = v ? 1 : 0)),
            ]),
            _sectionHeader('생활 태도'),
            _card([
              _sliderTile('온도 선호(1:추위 → 5:더위)', _profile.temperaturePref, 1, 5, (v) => setState(() => _profile.temperaturePref = v)),
              _divider(),
              _switchTile('방안 통화', _profile.indoorCall == 1, (v) => setState(() => _profile.indoorCall = v ? 1 : 0)),
              _divider(),
              _sliderTile('벌레 대응(1:무서움 → 5:못잡음)', _profile.bugHandling, 1, 5, (v) => setState(() => _profile.bugHandling = v)),
              _divider(),
              _sliderTile('빨래 주기(일)', _profile.laundryCycle, 1, 14, (v) => setState(() => _profile.laundryCycle = v)),
              _divider(),
              _switchTile('건조대 사용', _profile.dryingRack == 1, (v) => setState(() => _profile.dryingRack = v ? 1 : 0)),
              _divider(),
              _switchTile('냉장고 사용', _profile.fridgeUse == 1, (v) => setState(() => _profile.fridgeUse = v ? 1 : 0)),
              _divider(),
              _switchTile('방안 공부', _profile.studyInRoom == 1, (v) => setState(() => _profile.studyInRoom = v ? 1 : 0)),
              _divider(),
              _sliderTile('소음 민감도', _profile.noiseSensitivity, 1, 5, (v) => setState(() => _profile.noiseSensitivity = v)),
            ]),
            _sectionHeader('교류'),
            _card([
              _sliderTile('룸메이트 친밀도(1~5)', _profile.desiredIntimacy, 1, 5, (v) => setState(() => _profile.desiredIntimacy = v)),
              _divider(),
              _sliderTile('밥 같이', _profile.mealTogether, 1, 3, (v) => setState(() => _profile.mealTogether = v)),
              _divider(),
              _sliderTile('운동 같이', _profile.exerciseTogether, 1, 3, (v) => setState(() => _profile.exerciseTogether = v)),
              _divider(),
              _friendInviteTile((v) => setState(() => _profile.friendInvite = v)),
            ]),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                      onPressed: _profileCtrl.isLoading.value ? null : _save,
                      child: _profileCtrl.isLoading.value
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Text('설문 저장'),
                    )),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, top: 28, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D000000),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(children: children),
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFF3F4F6));
  }

  Widget _readOnlyTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF9CA3AF))),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _textTile(String label, String value, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        controller: TextEditingController(text: value),
        onChanged: onChanged,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
          labelStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
        ),
      ),
    );
  }

  Widget _sliderTile(String label, int value, int min, int max, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$value', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
              ),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            onChanged: (v) => onChanged(v.round()),
          ),
        ],
      ),
    );
  }

  Widget _switchTile(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _sleepWakeRangeTile() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: SleepWakeRangeSlider(
        bedtime: _profile.bedtime.clamp(0, 24),
        wakeTime: _profile.wakeTime.clamp(0, 24),
        onBedtimeChanged: (v) => setState(() => _profile.bedtime = v),
        onWakeTimeChanged: (v) => setState(() => _profile.wakeTime = v),
      ),
    );
  }

  static const List<int> _showerDurations = [10, 15, 20, 30, 31];
  static const List<String> _showerDurationLabels = ['10분', '15분', '20분', '30분', '30분+'];

  Widget _showerDurationTile(ValueChanged<int> onChanged) {
    final idx = _showerDurations.indexOf(_profile.showerDuration);
    final currentIdx = idx >= 0 ? idx : 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('샤워 시간', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_showerDurationLabels[currentIdx], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
              ),
            ],
          ),
          Slider(
            value: currentIdx.toDouble(),
            min: 0,
            max: _showerDurations.length - 1.0,
            divisions: _showerDurations.length - 1,
            onChanged: (v) => onChanged(_showerDurations[v.round()]),
          ),
        ],
      ),
    );
  }

  static const List<int> _showerCycles = [0, 1, 2, 3, 4];
  static const List<String> _showerCycleLabels = ['하루 2회이상', '하루 2회', '하루 1회', '2일 1회', '3일 1회미만'];

  Widget _showerCycleTile(ValueChanged<int> onChanged) {
    final idx = _showerCycles.indexOf(_profile.showerCycle);
    final currentIdx = idx >= 0 ? idx : 2;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('샤워 주기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_showerCycleLabels[currentIdx], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
              ),
            ],
          ),
          Slider(
            value: currentIdx.toDouble(),
            min: 0,
            max: _showerCycles.length - 1.0,
            divisions: _showerCycles.length - 1,
            onChanged: (v) => onChanged(_showerCycles[v.round()]),
          ),
        ],
      ),
    );
  }

  static const List<int> _friendInviteOpts = [0, 1, 2];
  static const List<String> _friendInviteLabels = ['X', '사전허락', '항상 OK'];

  // ── Birth Year (button style) ──
  Widget _birthYearTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('출생 연도', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Row(
            children: [
              _circleButton(Icons.remove, () => setState(() => _profile.birthYear = (_profile.birthYear - 1).clamp(1990, 2010))),
              const SizedBox(width: 12),
              Text('${_profile.birthYear}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              _circleButton(Icons.add, () => setState(() => _profile.birthYear = (_profile.birthYear + 1).clamp(1990, 2010))),
            ],
          ),
        ],
      ),
    );
  }

  // ── Dorm Duration (semester unit) ──
  static const List<int> _dormDurations = [0, 1, 2, 3, 4, 5, 6, 7, 8];
  static const List<String> _dormDurationLabels = [
    '거주 경험 없음', '1학기', '2학기', '3학기', '4학기',
    '5학기', '6학기', '7학기', '8학기 이상'
  ];

  Widget _dormDurationTile() {
    final idx = _dormDurations.indexOf(_profile.dormDuration);
    final currentIdx = idx >= 0 ? idx : 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('기숙사 거주 경험', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_dormDurationLabels[currentIdx], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
              ),
            ],
          ),
          Slider(
            value: currentIdx.toDouble(),
            min: 0,
            max: _dormDurations.length - 1.0,
            divisions: _dormDurations.length - 1,
            onChanged: (v) => setState(() => _profile.dormDuration = _dormDurations[v.round()]),
          ),
        ],
      ),
    );
  }

  // ── Alcohol Tolerance (bottle unit) ──
  static const List<double> _alcoholTolerances = [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0];
  static const List<String> _alcoholToleranceLabels = [
    '0병 (못마심)', '0.5병', '1병', '1.5병', '2병',
    '2.5병', '3병', '3.5병', '4병', '4.5병', '5병'
  ];

  Widget _alcoholToleranceTile() {
    final idx = _alcoholTolerances.indexOf(_profile.alcoholTolerance);
    final currentIdx = idx >= 0 ? idx : 5; // default 2.5
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('주량', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_alcoholToleranceLabels[currentIdx], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
              ),
            ],
          ),
          Slider(
            value: currentIdx.toDouble(),
            min: 0,
            max: _alcoholTolerances.length - 1.0,
            divisions: _alcoholTolerances.length - 1,
            onChanged: (v) => setState(() => _profile.alcoholTolerance = _alcoholTolerances[v.round()]),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: const Color(0xFF2563EB)),
      ),
    );
  }

  Widget _friendInviteTile(ValueChanged<int> onChanged) {
    final idx = _friendInviteOpts.indexOf(_profile.friendInvite);
    final currentIdx = idx >= 0 ? idx : 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('친구 방문', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_friendInviteLabels[currentIdx], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
              ),
            ],
          ),
          Slider(
            value: currentIdx.toDouble(),
            min: 0,
            max: _friendInviteOpts.length - 1.0,
            divisions: _friendInviteOpts.length - 1,
            onChanged: (v) => onChanged(_friendInviteOpts[v.round()]),
          ),
        ],
      ),
    );
  }
}
