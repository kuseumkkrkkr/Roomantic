import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/auth_controller.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _loginIdCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _pwConfirmCtrl = TextEditingController();
  final _studentIdCtrl = TextEditingController();

  final ApiService _api = ApiService();

  bool _isEnrolled = true;
  bool _loading = false;
  bool _obscure = true;

  int? _selectedBirthYear;
  String _selectedGender = '';
  String _selectedRegion = '';
  String _selectedSchool = '';
  String _selectedCollege = '';
  String _selectedDepartment = '';

  List<Map<String, dynamic>> _schoolItems = const [];

  static const List<String> _regions = [
    '서울',
    '인천',
    '경기북부',
    '경기남부',
    '강원',
    '충북',
    '충남',
    '세종',
    '대전',
    '전북',
    '전남',
    '광주',
    '경북',
    '경남',
    '대구',
    '울산',
    '부산',
    '제주',
  ];

  static const Map<String, LatLng> _regionLatLng = {
    // 수도권: 겹침 완화
    '서울': LatLng(37.63, 127.02),
    '인천': LatLng(37.48, 126.52),
    '경기북부': LatLng(37.98, 127.15),
    '경기남부': LatLng(37.12, 127.18),

    '강원': LatLng(37.72, 128.35),

    // 충청권: 서로 간격 확보
    '충북': LatLng(36.72, 127.75),
    '충남': LatLng(36.36, 126.92),
    '세종': LatLng(36.56, 127.27),
    '대전': LatLng(36.31, 127.43),

    '전북': LatLng(35.72, 127.03),
    '전남': LatLng(34.86, 126.58),
    '광주': LatLng(35.15, 126.86),

    '경북': LatLng(36.43, 128.72),
    '경남': LatLng(35.37, 128.25),

    '대구': LatLng(35.90, 128.58),
    '울산': LatLng(35.60, 129.28),
    '부산': LatLng(35.20, 129.08),

    '제주': LatLng(33.39, 126.52),
  };

  static final LatLngBounds _koreaBounds = LatLngBounds(
    const LatLng(32.7, 124.5),
    const LatLng(39.9, 131.9),
  );

  @override
  void initState() {
    super.initState();
    _loadSchools();
  }

  @override
  void dispose() {
    _loginIdCtrl.dispose();
    _nameCtrl.dispose();
    _pwCtrl.dispose();
    _pwConfirmCtrl.dispose();
    _studentIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSchools() async {
    try {
      final res = await _api.getSchools();
      final list = List<Map<String, dynamic>>.from(res['schools'] ?? const []);
      if (!mounted) return;
      setState(() => _schoolItems = list);
    } catch (_) {}
  }

  List<String> get _schools => _schoolItems
      .map((e) => (e['name'] ?? '').toString())
      .where((e) => e.isNotEmpty)
      .toList();

  List<Map<String, dynamic>> get _selectedSchoolColleges {
    final school = _schoolItems
        .where((e) => (e['name'] ?? '') == _selectedSchool)
        .toList();
    if (school.isEmpty) return const [];
    return List<Map<String, dynamic>>.from(
      school.first['colleges'] ?? const [],
    );
  }

  List<String> get _collegeNames => _selectedSchoolColleges
      .map((e) => (e['name'] ?? '').toString())
      .where((e) => e.isNotEmpty)
      .toList();

  List<String> get _departmentNames {
    final selected = _selectedSchoolColleges
        .where((e) => (e['name'] ?? '') == _selectedCollege)
        .toList();
    if (selected.isEmpty) return const [];
    final deps = List<Map<String, dynamic>>.from(
      selected.first['departments'] ?? const [],
    );
    return deps
        .map((e) => (e['name'] ?? '').toString())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  void _pickBirthYear() {
    final nowYear = DateTime.now().year;
    final years = List<int>.generate(nowYear - 1900 + 1, (i) => nowYear - i);
    int temp =
        _selectedBirthYear ??
        years[(nowYear - 2000).clamp(0, years.length - 1)];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final initialIndex = years.indexOf(temp).clamp(0, years.length - 1);
        return Container(
          height: 320,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  '생년 선택',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(
                    initialItem: initialIndex,
                  ),
                  onSelectedItemChanged: (index) => temp = years[index],
                  children: years
                      .map(
                        (y) => Center(
                          child: Text(
                            '$y년',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('취소'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(temp),
                        child: const Text('선택'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ).then((value) {
      if (value is int) setState(() => _selectedBirthYear = value);
    });
  }

  void _pickRegion() {
    String? temp = _selectedRegion.isEmpty ? null : _selectedRegion;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(
                      '거주 지역 선택',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: const LatLng(36.2, 127.8),
                        initialZoom: 7.0,
                        minZoom: 6.6,
                        maxZoom: 8.8,
                        cameraConstraint: CameraConstraint.contain(
                          bounds: _koreaBounds,
                        ),
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.roomantic',
                        ),
                        MarkerLayer(
                          markers: _regions.map((region) {
                            final latLng = _regionLatLng[region]!;
                            final isSelected = temp == region;
                            return Marker(
                              point: latLng,
                              width: 44,
                              height: 44,
                              child: GestureDetector(
                                onTap: () => setSheetState(() => temp = region),
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF2563EB)
                                        : Colors.white.withValues(alpha: 0.92),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF2563EB)
                                          : Colors.grey.shade300,
                                      width: isSelected ? 1.8 : 1.0,
                                    ),
                                  ),
                                  child: Text(
                                    region,
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF374151),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 120),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _regions.map((region) {
                          final isSelected = temp == region;
                          return ChoiceChip(
                            label: Text(region),
                            selected: isSelected,
                            onSelected: (_) =>
                                setSheetState(() => temp = region),
                            selectedColor: const Color(0xFFDBEAFE),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF2563EB)
                                  : Colors.grey.shade300,
                            ),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? const Color(0xFF1D4ED8)
                                  : const Color(0xFF374151),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('취소'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: temp == null
                                ? null
                                : () => Navigator.of(ctx).pop(temp),
                            child: const Text('선택'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((value) {
      if (value is String) setState(() => _selectedRegion = value);
    });
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;

    if (_pwCtrl.text != _pwConfirmCtrl.text) {
      Get.snackbar('오류', '비밀번호가 일치하지 않습니다.');
      return;
    }
    if (_selectedBirthYear == null) {
      Get.snackbar('오류', '생년을 선택해주세요.');
      return;
    }
    if (_selectedGender.isEmpty) {
      Get.snackbar('오류', '성별을 선택해주세요.');
      return;
    }
    if (_selectedRegion.isEmpty) {
      Get.snackbar('오류', '거주 지역을 선택해주세요.');
      return;
    }
    if (_isEnrolled && _selectedSchool.isEmpty) {
      Get.snackbar('오류', '학교를 선택해주세요.');
      return;
    }
    if (_isEnrolled && _selectedCollege.isEmpty) {
      Get.snackbar('오류', '단과대를 선택해주세요.');
      return;
    }
    if (_isEnrolled && _selectedDepartment.isEmpty) {
      Get.snackbar('오류', '학과를 선택해주세요.');
      return;
    }

    setState(() => _loading = true);

    final error = await Get.find<AuthController>().register(
      loginId: _loginIdCtrl.text.trim(),
      password: _pwCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      birthYear: _selectedBirthYear!,
      studentId: _isEnrolled ? _studentIdCtrl.text.trim() : '',
      isEnrolled: _isEnrolled,
      schoolName: _isEnrolled ? _selectedSchool : '',
      college: _isEnrolled ? _selectedCollege : '',
      department: _isEnrolled ? _selectedDepartment : '',
      regionName: _selectedRegion,
      gender: _selectedGender,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (error == null) {
      Get.offAllNamed('/home');
    } else {
      Get.snackbar('회원가입 실패', error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _loginIdCtrl,
                decoration: const InputDecoration(
                  labelText: '아이디',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? '아이디를 입력해주세요.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: '이름',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? '이름을 입력해주세요.' : null,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickBirthYear,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: '생년',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedBirthYear == null
                        ? '스크롤로 생년 선택'
                        : '${_selectedBirthYear!}년',
                    style: TextStyle(
                      color: _selectedBirthYear == null
                          ? Colors.grey.shade600
                          : Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pwCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.length < 4) ? '비밀번호 4자 이상 입력' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pwConfirmCtrl,
                obscureText: _obscure,
                decoration: const InputDecoration(
                  labelText: '비밀번호 확인',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? '비밀번호 확인을 입력해주세요.' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedGender.isEmpty ? null : _selectedGender,
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('남')),
                  DropdownMenuItem(value: 'female', child: Text('여')),
                ],
                onChanged: (v) => setState(() => _selectedGender = v ?? ''),
                decoration: const InputDecoration(
                  labelText: '성별',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? '성별을 선택해주세요.' : null,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickRegion,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: '거주 지역',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedRegion.isEmpty ? '지역 선택' : _selectedRegion,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _isEnrolled,
                onChanged: (v) => setState(() => _isEnrolled = v),
                title: const Text('재학생 여부'),
                contentPadding: EdgeInsets.zero,
              ),
              if (_isEnrolled) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedSchool.isEmpty
                      ? null
                      : _selectedSchool,
                  items: _schools
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() {
                    _selectedSchool = v ?? '';
                    _selectedCollege = '';
                    _selectedDepartment = '';
                  }),
                  decoration: const InputDecoration(
                    labelText: '학교',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? '학교를 선택해주세요.' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCollege.isEmpty
                      ? null
                      : _selectedCollege,
                  items: _collegeNames
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() {
                    _selectedCollege = v ?? '';
                    _selectedDepartment = '';
                  }),
                  decoration: const InputDecoration(
                    labelText: '단과대학',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? '단과대학을 선택해주세요.' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedDepartment.isEmpty
                      ? null
                      : _selectedDepartment,
                  items: _departmentNames
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _selectedDepartment = v ?? ''),
                  decoration: const InputDecoration(
                    labelText: '학과',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? '학과를 선택해주세요.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _studentIdCtrl,
                  decoration: const InputDecoration(
                    labelText: '학번',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? '학번을 입력해주세요.' : null,
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('가입하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
