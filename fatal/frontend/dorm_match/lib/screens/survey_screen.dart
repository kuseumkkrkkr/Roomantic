import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../models/profile.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final _profileCtrl = Get.put(ProfileController());
  late Profile _profile;

  @override
  void initState() {
    super.initState();
    _profile = _profileCtrl.profile.value?.copy() ?? Profile();
  }

  void _save() async {
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
              _textTile('이름', _profile.name, (v) => _profile.name = v),
              _divider(),
              _textTile('학번', _profile.studentId, (v) => _profile.studentId = v),
              _divider(),
              _sliderTile('출생 연도', _profile.birthYear, 1990, 2010, (v) => setState(() => _profile.birthYear = v)),
              _divider(),
              _sliderTile('기숙사 거주학기', _profile.dormDuration, 1, 8, (v) => setState(() => _profile.dormDuration = v)),
            ]),
            _sectionHeader('생활 습관'),
            _card([
              _sliderTile('귀가 주기', _profile.homeVisitCycle, 1, 4, (v) => setState(() => _profile.homeVisitCycle = v)),
              _divider(),
              _switchTile('향수 사용', _profile.perfume == 1, (v) => setState(() => _profile.perfume = v ? 1 : 0)),
              _divider(),
              _sliderTile('향 민감도', _profile.indoorScentSensitivity, 1, 5, (v) => setState(() => _profile.indoorScentSensitivity = v)),
              _divider(),
              _sliderTile('주량(1~5)', _profile.alcoholTolerance.round(), 1, 5, (v) => setState(() => _profile.alcoholTolerance = v.toDouble())),
              _divider(),
              _sliderTile('음주 빈도', _profile.alcoholFrequency, 1, 5, (v) => setState(() => _profile.alcoholFrequency = v)),
              _divider(),
              _switchTile('주사 있음', _profile.drunkHabit == 1, (v) => setState(() => _profile.drunkHabit = v ? 1 : 0)),
              _divider(),
              _sliderTile('게임/스크린(시간)', _profile.gamingHoursPerWeek, 0, 40, (v) => setState(() => _profile.gamingHoursPerWeek = v)),
              _divider(),
              _switchTile('스피커 사용', _profile.speakerUse == 1, (v) => setState(() => _profile.speakerUse = v ? 1 : 0)),
              _divider(),
              _switchTile('운동함', _profile.exercise == 1, (v) => setState(() => _profile.exercise = v ? 1 : 0)),
            ]),
            _sectionHeader('수면 습관'),
            _card([
              _bedtimeSliderTile((v) => setState(() => _profile.bedtime = v)),
              _divider(),
              _sliderTile('기상 시각', _profile.wakeTime, 0, 23, (v) => setState(() => _profile.wakeTime = v)),
              _divider(),
              _switchTile('잠버릇 있음', _profile.sleepHabit == 1, (v) => setState(() => _profile.sleepHabit = v ? 1 : 0)),
              _divider(),
              _sliderTile('수면 예민도', _profile.sleepSensitivity, 1, 5, (v) => setState(() => _profile.sleepSensitivity = v)),
              _divider(),
              _sliderTile('알람 세기', _profile.alarmStrength, 1, 5, (v) => setState(() => _profile.alarmStrength = v)),
              _divider(),
              _switchTile('불 켜고 잠', _profile.sleepLight == 1, (v) => setState(() => _profile.sleepLight = v ? 1 : 0)),
              _divider(),
              _switchTile('코골이', _profile.snoring == 1, (v) => setState(() => _profile.snoring = v ? 1 : 0)),
            ]),
            _sectionHeader('위생 / 욕실'),
            _card([
              _sliderTile('샤워 시간(분)', _profile.showerDuration, 5, 30, (v) => setState(() => _profile.showerDuration = v)),
              _divider(),
              _sliderTile('샤워 시각', _profile.showerTime, 0, 23, (v) => setState(() => _profile.showerTime = v)),
              _divider(),
              _sliderTile('샤워 주기(일)', _profile.showerCycle, 1, 5, (v) => setState(() => _profile.showerCycle = v)),
              _divider(),
              _sliderTile('청소 주기(일)', _profile.cleaningCycle, 1, 30, (v) => setState(() => _profile.cleaningCycle = v)),
              _divider(),
              _switchTile('드라이기 비치', _profile.hairdryerInBathroom == 1, (v) => setState(() => _profile.hairdryerInBathroom = v ? 1 : 0)),
              _divider(),
              _switchTile('휴지 공유', _profile.toiletPaperShare == 1, (v) => setState(() => _profile.toiletPaperShare = v ? 1 : 0)),
              _divider(),
              _switchTile('방안 식사', _profile.indoorEating == 1, (v) => setState(() => _profile.indoorEating = v ? 1 : 0)),
              _divider(),
              _switchTile('흡연', _profile.smoking == 1, (v) => setState(() => _profile.smoking = v ? 1 : 0)),
            ]),
            _sectionHeader('생활 편의'),
            _card([
              _sliderTile('온도 선호', _profile.temperaturePref, 1, 5, (v) => setState(() => _profile.temperaturePref = v)),
              _divider(),
              _switchTile('방안 통화', _profile.indoorCall == 1, (v) => setState(() => _profile.indoorCall = v ? 1 : 0)),
              _divider(),
              _sliderTile('벌레 대응', _profile.bugHandling, 1, 5, (v) => setState(() => _profile.bugHandling = v)),
              _divider(),
              _sliderTile('빨래 주기(일)', _profile.laundryCycle, 1, 14, (v) => setState(() => _profile.laundryCycle = v)),
              _divider(),
              _switchTile('건조대 사용', _profile.dryingRack == 1, (v) => setState(() => _profile.dryingRack = v ? 1 : 0)),
              _divider(),
              _switchTile('냉장고 사용', _profile.fridgeUse == 1, (v) => setState(() => _profile.fridgeUse = v ? 1 : 0)),
              _divider(),
              _switchTile('방공부', _profile.studyInRoom == 1, (v) => setState(() => _profile.studyInRoom = v ? 1 : 0)),
              _divider(),
              _sliderTile('소음 민감도', _profile.noiseSensitivity, 1, 5, (v) => setState(() => _profile.noiseSensitivity = v)),
            ]),
            _sectionHeader('교류'),
            _card([
              _sliderTile('친밀도 선호', _profile.desiredIntimacy, 1, 5, (v) => setState(() => _profile.desiredIntimacy = v)),
              _divider(),
              _sliderTile('밥 같이', _profile.mealTogether, 1, 3, (v) => setState(() => _profile.mealTogether = v)),
              _divider(),
              _sliderTile('운동 같이', _profile.exerciseTogether, 1, 3, (v) => setState(() => _profile.exerciseTogether = v)),
              _divider(),
              _sliderTile('친구 방문', _profile.friendInvite, 1, 5, (v) => setState(() => _profile.friendInvite = v)),
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

  Widget _bedtimeSliderTile(ValueChanged<int> onChanged) {
    final value = _profile.bedtime;
    final displayValue = value == 24 ? '미정' : '$value시';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('취침 시각', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(displayValue, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
              ),
            ],
          ),
          Slider(
            value: value.clamp(0, 24).toDouble(),
            min: 0,
            max: 24,
            divisions: 24,
            onChanged: (v) => onChanged(v.round()),
          ),
        ],
      ),
    );
  }
}
