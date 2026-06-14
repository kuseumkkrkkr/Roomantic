import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../models/profile.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  static const Color _primary = Color(0xFF2563EB);
  static const List<int> _sleepHours = <int>[
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
    1,
    2,
  ];

  final _profileCtrl = Get.find<ProfileController>();
  final _auth = Get.find<AuthController>();
  late Profile _profile;
  late bool _wakeOnStartThumb;
  bool _isPreparing = true;

  @override
  void initState() {
    super.initState();
    _profile = _profileCtrl.profile.value?.copy() ?? Profile();
    _syncReadonlyIdentity();
    _wakeOnStartThumb =
        _sleepIndexFromHour(_profile.wakeTime) <=
        _sleepIndexFromHour(_profile.bedtime);
    _isPreparing = false;
    if (_profileCtrl.profile.value == null) {
      _prepareProfile();
    }
  }

  Future<void> _prepareProfile() async {
    if (mounted) {
      setState(() => _isPreparing = true);
    }
    try {
      await _profileCtrl.fetchProfile().timeout(const Duration(seconds: 12));
      if (!mounted) return;
      setState(() {
        _profile = _profileCtrl.profile.value?.copy() ?? Profile();
        _syncReadonlyIdentity();
        _wakeOnStartThumb =
            _sleepIndexFromHour(_profile.wakeTime) <=
            _sleepIndexFromHour(_profile.bedtime);
      });
    } catch (_) {
      if (!mounted) return;
      _syncReadonlyIdentity();
    } finally {
      if (mounted) {
        setState(() => _isPreparing = false);
      }
    }
  }

  void _syncReadonlyIdentity() {
    final u = _auth.user.value;
    if (u == null) return;
    _profile.name = u.name;
    _profile.studentId = u.studentId;
    _profile.birthYear = u.birthYear;
    _profile.college = u.college;
    _profile.department = u.department;
  }

  Future<void> _save() async {
    _syncReadonlyIdentity();
    final err = await _profileCtrl.saveProfile(_profile);
    if (err == null) {
      await _profileCtrl.fetchProfile();
      Get.snackbar('저장 완료', '설문이 저장되었습니다.');
      if (mounted) {
        Get.back(result: true);
      }
    } else {
      Get.snackbar('저장 실패', err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설문지 편집'),
        actions: [TextButton(onPressed: _save, child: const Text('저장'))],
      ),
      body: _isPreparing
          ? const Center(child: CircularProgressIndicator())
          : DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF8F9FE), Color(0xFFF2F5FF)],
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _sectionTitle('기본 정보'),
                  _readonlyTile('이름', _profile.name),
                  _readonlyTile('학번', _profile.studentId),
                  _readonlyTile('출생년도', _profile.birthYear.toString()),
                  _readonlyTile('단과대', _profile.college),
                  _readonlyTile('학과', _profile.department),

                  _sectionTitle('생활 습관'),
                  _optionSlider(
                    label: '본가 방문 주기',
                    options: const ['매주', '2주 1회', '월 1회', '거의 안감'],
                    selectedIndex: (_profile.homeVisitCycle - 1).clamp(0, 3),
                    onChanged: (i) =>
                        setState(() => _profile.homeVisitCycle = i + 1),
                  ),
                  _boolSwitch(
                    label: '향수 사용',
                    value: _profile.perfume == 1,
                    onChanged: (v) =>
                        setState(() => _profile.perfume = v ? 1 : 0),
                  ),
                  _sliderInt(
                    label: '실내 냄새 민감도',
                    value: _profile.indoorScentSensitivity,
                    min: 1,
                    max: 5,
                    onChanged: (v) =>
                        setState(() => _profile.indoorScentSensitivity = v),
                  ),
                  _optionSlider(
                    label: '주량',
                    options: const ['못마심', '반병', '1병', '1.5병', '2병이상'],
                    selectedIndex: _alcoholToleranceIndex(),
                    onChanged: (i) => setState(
                      () => _profile.alcoholTolerance = const [
                        0.0,
                        0.5,
                        1.0,
                        1.5,
                        2.0,
                      ][i],
                    ),
                  ),
                  _optionSlider(
                    label: '음주 빈도',
                    options: const ['주 3회 이상', '주 1회', '2주 1회', '1달 1회 이하'],
                    selectedIndex: _alcoholFrequencyIndex(),
                    onChanged: (i) => setState(
                      () => _profile.alcoholFrequency = const [3, 2, 1, 0][i],
                    ),
                  ),
                  _boolSwitch(
                    label: '주사 있음',
                    value: _profile.drunkHabit == 1,
                    onChanged: (v) =>
                        setState(() => _profile.drunkHabit = v ? 1 : 0),
                  ),
                  _optionSlider(
                    label: '게임/인터넷 시간(일)',
                    options: const ['8시간 이상', '5시간', '3시간', '1시간', '거의안함'],
                    selectedIndex: _gamingHoursIndex(),
                    onChanged: (i) => setState(
                      () => _profile.gamingHoursPerWeek = const [
                        56,
                        35,
                        21,
                        7,
                        0,
                      ][i],
                    ),
                  ),
                  _boolSwitch(
                    label: '스피커 사용',
                    value: _profile.speakerUse == 1,
                    onChanged: (v) =>
                        setState(() => _profile.speakerUse = v ? 1 : 0),
                  ),
                  _boolSwitch(
                    label: '규칙적 운동',
                    value: _profile.exercise == 1,
                    onChanged: (v) =>
                        setState(() => _profile.exercise = v ? 1 : 0),
                  ),

                  _sectionTitle('수면'),
                  _sleepTimeSlider(),
                  _boolSwitch(
                    label: '잠버릇 있음',
                    value: _profile.sleepHabit == 1,
                    onChanged: (v) =>
                        setState(() => _profile.sleepHabit = v ? 1 : 0),
                  ),
                  _sliderInt(
                    label: '수면 민감도',
                    value: _profile.sleepSensitivity,
                    min: 1,
                    max: 5,
                    onChanged: (v) =>
                        setState(() => _profile.sleepSensitivity = v),
                  ),
                  _sliderInt(
                    label: '알람 강도',
                    value: _profile.alarmStrength,
                    min: 1,
                    max: 5,
                    onChanged: (v) =>
                        setState(() => _profile.alarmStrength = v),
                  ),
                  _boolSwitch(
                    label: '불 켜고 잠',
                    value: _profile.sleepLight == 1,
                    onChanged: (v) =>
                        setState(() => _profile.sleepLight = v ? 1 : 0),
                  ),
                  _boolSwitch(
                    label: '코골이',
                    value: _profile.snoring == 1,
                    onChanged: (v) =>
                        setState(() => _profile.snoring = v ? 1 : 0),
                  ),

                  _sectionTitle('위생'),
                  _optionSlider(
                    label: '샤워 주기',
                    options: const [
                      '일 3회이상',
                      '일 2회',
                      '일 1회',
                      '2일1회',
                      '2일 1회 미만',
                    ],
                    selectedIndex: _showerCycleIndex(),
                    onChanged: (i) => setState(
                      () => _profile.showerCycle = const [4, 3, 2, 1, 0][i],
                    ),
                  ),
                  _optionSlider(
                    label: '샤워 시간',
                    options: const ['5분', '10분', '15분', '30분', '30분이상'],
                    selectedIndex: _showerDurationIndex(),
                    onChanged: (i) => setState(
                      () => _profile.showerDuration = const [
                        5,
                        10,
                        15,
                        30,
                        45,
                      ][i],
                    ),
                  ),
                  _sliderInt(
                    label: '샤워 시각',
                    value: _profile.showerTime,
                    min: 0,
                    max: 23,
                    onChanged: (v) => setState(() => _profile.showerTime = v),
                  ),
                  _optionSlider(
                    label: '청소 주기',
                    options: const ['매일', '3일', '1주일', '1달', '안함'],
                    selectedIndex: _cleaningCycleIndex(),
                    onChanged: (i) => setState(
                      () => _profile.cleaningCycle = const [1, 3, 7, 30, 60][i],
                    ),
                  ),
                  _optionSlider(
                    label: '환기 횟수(일)',
                    options: const ['안함', '1회', '2회이상'],
                    selectedIndex: _ventilationIndex(),
                    onChanged: (i) => setState(
                      () => _profile.ventilation = const [0.0, 1.0, 2.0][i],
                    ),
                  ),
                  _boolSwitch(
                    label: '드라이기 화장실 보관',
                    value: _profile.hairdryerInBathroom == 1,
                    onChanged: (v) => setState(
                      () => _profile.hairdryerInBathroom = v ? 1 : 0,
                    ),
                  ),
                  _boolSwitch(
                    label: '휴지 공유',
                    value: _profile.toiletPaperShare == 1,
                    onChanged: (v) =>
                        setState(() => _profile.toiletPaperShare = v ? 1 : 0),
                  ),
                  _boolSwitch(
                    label: '방 안 취식',
                    value: _profile.indoorEating == 1,
                    onChanged: (v) =>
                        setState(() => _profile.indoorEating = v ? 1 : 0),
                  ),
                  _boolSwitch(
                    label: '흡연',
                    value: _profile.smoking == 1,
                    onChanged: (v) =>
                        setState(() => _profile.smoking = v ? 1 : 0),
                  ),

                  _sectionTitle('생활 선호'),
                  _sliderInt(
                    label: '온도 선호(1~5)',
                    value: _profile.temperaturePref,
                    min: 1,
                    max: 5,
                    onChanged: (v) =>
                        setState(() => _profile.temperaturePref = v),
                  ),
                  _boolSwitch(
                    label: '실내 통화',
                    value: _profile.indoorCall == 1,
                    onChanged: (v) =>
                        setState(() => _profile.indoorCall = v ? 1 : 0),
                  ),
                  _sliderInt(
                    label: '벌레 대처(1~5)',
                    value: _profile.bugHandling,
                    min: 1,
                    max: 5,
                    onChanged: (v) => setState(() => _profile.bugHandling = v),
                  ),
                  _optionSlider(
                    label: '빨래 주기',
                    options: const ['매일', '3일1회', '매주', '1달', '안함'],
                    selectedIndex: _laundryCycleIndex(),
                    onChanged: (i) => setState(
                      () => _profile.laundryCycle = const [1, 3, 7, 30, 60][i],
                    ),
                  ),
                  _boolSwitch(
                    label: '건조대 사용',
                    value: _profile.dryingRack == 1,
                    onChanged: (v) =>
                        setState(() => _profile.dryingRack = v ? 1 : 0),
                  ),
                  _boolSwitch(
                    label: '냉장고 사용',
                    value: _profile.fridgeUse == 1,
                    onChanged: (v) =>
                        setState(() => _profile.fridgeUse = v ? 1 : 0),
                  ),
                  _boolSwitch(
                    label: '방 안 공부',
                    value: _profile.studyInRoom == 1,
                    onChanged: (v) =>
                        setState(() => _profile.studyInRoom = v ? 1 : 0),
                  ),
                  _sliderInt(
                    label: '소음 민감도',
                    value: _profile.noiseSensitivity,
                    min: 1,
                    max: 5,
                    onChanged: (v) =>
                        setState(() => _profile.noiseSensitivity = v),
                  ),

                  _sectionTitle('교류'),
                  _sliderInt(
                    label: '친밀도(1~5)',
                    value: _profile.desiredIntimacy,
                    min: 1,
                    max: 5,
                    onChanged: (v) =>
                        setState(() => _profile.desiredIntimacy = v),
                  ),
                  _sliderInt(
                    label: '같이 밥',
                    value: _profile.mealTogether,
                    min: 1,
                    max: 3,
                    onChanged: (v) => setState(() => _profile.mealTogether = v),
                  ),
                  _sliderInt(
                    label: '같이 운동',
                    value: _profile.exerciseTogether,
                    min: 1,
                    max: 3,
                    onChanged: (v) =>
                        setState(() => _profile.exerciseTogether = v),
                  ),
                  _sliderInt(
                    label: '친구 초대',
                    value: _profile.friendInvite,
                    min: 0,
                    max: 2,
                    onChanged: (v) => setState(() => _profile.friendInvite = v),
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: _save, child: const Text('설문 저장')),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  int _alcoholToleranceIndex() {
    if (_profile.alcoholTolerance >= 2.0) return 4;
    if (_profile.alcoholTolerance >= 1.5) return 3;
    if (_profile.alcoholTolerance >= 1.0) return 2;
    if (_profile.alcoholTolerance >= 0.5) return 1;
    return 0;
  }

  int _alcoholFrequencyIndex() {
    if (_profile.alcoholFrequency >= 3) return 0;
    if (_profile.alcoholFrequency == 2) return 1;
    if (_profile.alcoholFrequency == 1) return 2;
    return 3;
  }

  int _gamingHoursIndex() {
    if (_profile.gamingHoursPerWeek >= 56) return 0;
    if (_profile.gamingHoursPerWeek >= 35) return 1;
    if (_profile.gamingHoursPerWeek >= 21) return 2;
    if (_profile.gamingHoursPerWeek >= 7) return 3;
    return 4;
  }

  int _showerCycleIndex() {
    if (_profile.showerCycle >= 4) return 0;
    if (_profile.showerCycle == 3) return 1;
    if (_profile.showerCycle == 2) return 2;
    if (_profile.showerCycle == 1) return 3;
    return 4;
  }

  int _showerDurationIndex() {
    if (_profile.showerDuration >= 45) return 4;
    if (_profile.showerDuration >= 30) return 3;
    if (_profile.showerDuration >= 15) return 2;
    if (_profile.showerDuration >= 10) return 1;
    return 0;
  }

  int _cleaningCycleIndex() {
    if (_profile.cleaningCycle <= 1) return 0;
    if (_profile.cleaningCycle <= 3) return 1;
    if (_profile.cleaningCycle <= 7) return 2;
    if (_profile.cleaningCycle <= 30) return 3;
    return 4;
  }

  int _ventilationIndex() {
    if (_profile.ventilation >= 2) return 2;
    if (_profile.ventilation >= 1) return 1;
    return 0;
  }

  int _laundryCycleIndex() {
    if (_profile.laundryCycle <= 1) return 0;
    if (_profile.laundryCycle <= 3) return 1;
    if (_profile.laundryCycle <= 7) return 2;
    if (_profile.laundryCycle <= 30) return 3;
    return 4;
  }

  int _sleepHourToDisplay(int hour) => hour == 0 ? 24 : hour;

  int _displayToSleepHour(int hour) => hour == 24 ? 0 : hour;

  int _sleepIndexFromHour(int hour) {
    final idx = _sleepHours.indexOf(_sleepHourToDisplay(hour));
    return idx < 0 ? 0 : idx;
  }

  Widget _sleepTimeSlider() {
    final wakeIdx = _sleepIndexFromHour(_profile.wakeTime);
    final bedIdx = _sleepIndexFromHour(_profile.bedtime);
    final start = _wakeOnStartThumb ? wakeIdx.toDouble() : bedIdx.toDouble();
    final end = _wakeOnStartThumb ? bedIdx.toDouble() : wakeIdx.toDouble();

    return _iosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 24,
                inactiveTrackColor: const Color(0xFF111827),
                activeTrackColor: const Color(0xFF87CEEB),
                thumbColor: Colors.white,
                overlayColor: _primary.withValues(alpha: 0.10),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 13),
              ),
              child: RangeSlider(
                values: RangeValues(start, end),
                min: 0,
                max: (_sleepHours.length - 1).toDouble(),
                divisions: _sleepHours.length - 1,
                onChanged: (values) {
                  setState(() {
                    if (_wakeOnStartThumb) {
                      _profile.wakeTime = _displayToSleepHour(
                        _sleepHours[values.start.round()],
                      );
                      _profile.bedtime = _displayToSleepHour(
                        _sleepHours[values.end.round()],
                      );
                    } else {
                      _profile.wakeTime = _displayToSleepHour(
                        _sleepHours[values.end.round()],
                      );
                      _profile.bedtime = _displayToSleepHour(
                        _sleepHours[values.start.round()],
                      );
                    }
                  });
                },
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Text(
                      '기상',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${_sleepHours[_sleepIndexFromHour(_profile.wakeTime)]}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      '취침',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${_sleepHours[_sleepIndexFromHour(_profile.bedtime)]}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
    ),
  );

  Widget _iosCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _readonlyTile(String label, String value) => _iosCard(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
        ),
        Text(
          value.isEmpty ? '-' : value,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );

  Widget _sliderInt({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    final v = value.clamp(min, max);
    return _iosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: $v',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          Slider(
            value: v.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            onChanged: (x) => onChanged(x.round()),
          ),
        ],
      ),
    );
  }

  Widget _optionSlider({
    required String label,
    required List<String> options,
    required int selectedIndex,
    required ValueChanged<int> onChanged,
  }) {
    final idx = selectedIndex.clamp(0, options.length - 1);
    return _iosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            options[idx],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _primary,
            ),
          ),
          Slider(
            value: idx.toDouble(),
            min: 0,
            max: (options.length - 1).toDouble(),
            divisions: options.length - 1,
            onChanged: (x) => onChanged(x.round()),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  options.first,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
              Expanded(
                child: Text(
                  options.last,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _boolSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return _iosCard(
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        activeThumbColor: _primary,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
