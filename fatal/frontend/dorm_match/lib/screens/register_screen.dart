import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

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
  bool _isEnrolled = true;
  String _selectedSchool = '';
  String _selectedRegion = '';
  bool _loading = false;
  bool _obscure = true;

  final List<String> _schools = const ['고려대학교'];

  final List<String> _regions = const [
    '서울', '부산', '대구', '인천', '광주', '대전', '울산', '세종',
    '경기', '강원', '충북', '충남', '전북', '전남', '경북', '경남', '제주',
  ];

  // 한반도 대략적 위치 (Stack 기준 280x380 좌표)
  final Map<String, Offset> _regionPositions = const {
    '서울': Offset(60, 30),
    '인천': Offset(15, 50),
    '경기': Offset(90, 50),
    '강원': Offset(175, 10),
    '세종': Offset(100, 105),
    '충북': Offset(155, 100),
    '충남': Offset(70, 130),
    '대전': Offset(115, 140),
    '전북': Offset(70, 185),
    '경북': Offset(175, 155),
    '광주': Offset(40, 245),
    '대구': Offset(165, 205),
    '울산': Offset(200, 225),
    '전남': Offset(55, 290),
    '경남': Offset(155, 265),
    '부산': Offset(195, 260),
    '제주': Offset(55, 345),
  };

  void _pickRegion() {
    showDialog(
      context: context,
      builder: (ctx) {
        String? temp = _selectedRegion.isEmpty ? null : _selectedRegion;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('거주 지역 선택', textAlign: TextAlign.center),
              content: SizedBox(
                width: 300,
                height: 420,
                child: Stack(
                  children: [
                    // 배경 - 한반도 대략적 형태
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    // 지역 버튼들
                    ..._regions.map((region) {
                      final pos = _regionPositions[region] ?? Offset.zero;
                      final isSelected = temp == region;
                      return Positioned(
                        left: pos.dx,
                        top: pos.dy,
                        child: GestureDetector(
                          onTap: () => setDialogState(() => temp = region),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF2563EB) : Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(
                                color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              region,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : const Color(0xFF374151),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: temp == null
                      ? null
                      : () {
                          Navigator.of(ctx).pop(temp);
                        },
                  child: const Text('선택'),
                ),
              ],
            );
          },
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() => _selectedRegion = value as String);
      }
    });
  }

  void _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_pwCtrl.text != _pwConfirmCtrl.text) {
      Get.snackbar('오류', '비밀번호가 일치하지 않습니다.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_isEnrolled && _selectedSchool.isEmpty) {
      Get.snackbar('오류', '학교를 선택해 주세요.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_selectedRegion.isEmpty) {
      Get.snackbar('오류', '거주 지역을 선택해 주세요.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() => _loading = true);
    final error = await Get.find<AuthController>().register(
      loginId: _loginIdCtrl.text.trim(),
      password: _pwCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      studentId: _isEnrolled ? _studentIdCtrl.text.trim() : '',
      isEnrolled: _isEnrolled,
      schoolName: _isEnrolled ? _selectedSchool : '',
      regionName: _selectedRegion,
    );
    setState(() => _loading = false);
    if (error == null) {
      Get.offAllNamed('/home');
    } else {
      Get.snackbar('회원가입 실패', error, snackPosition: SnackPosition.BOTTOM);
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
              const Text(
                'Roomantic',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
              ),
              const SizedBox(height: 8),
              Text(
                '회원정보를 입력해 주세요',
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),

              // 아이디
              TextFormField(
                controller: _loginIdCtrl,
                decoration: const InputDecoration(
                  labelText: '아이디 (로그인용)',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                validator: (v) => (v == null || v.isEmpty) ? '아이디를 입력하세요' : null,
              ),
              const SizedBox(height: 14),

              // 이름
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: '이름',
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                validator: (v) => (v == null || v.isEmpty) ? '이름을 입력하세요' : null,
              ),
              const SizedBox(height: 14),

              // 비밀번호
              TextFormField(
                controller: _pwCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                validator: (v) => (v == null || v.length < 4) ? '4자 이상 입력하세요' : null,
              ),
              const SizedBox(height: 14),

              // 비밀번호 확인
              TextFormField(
                controller: _pwConfirmCtrl,
                obscureText: _obscure,
                decoration: const InputDecoration(
                  labelText: '비밀번호 확인',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                validator: (v) => (v == null || v.isEmpty) ? '비밀번호를 다시 입력하세요' : null,
              ),
              const SizedBox(height: 18),

              // 재학 여부 스위치
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.school, color: Color(0xFF2563EB)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('재학 여부', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    ),
                    Switch(
                      value: _isEnrolled,
                      onChanged: (v) => setState(() => _isEnrolled = v),
                    ),
                    Text(_isEnrolled ? '재학중' : '대학생이 아니에요', style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 학교 선택 (재학중일 때만)
              if (_isEnrolled) ...[
                DropdownButtonFormField<String>(
                  initialValue: _selectedSchool.isEmpty ? null : _selectedSchool,
                  hint: const Text('학교 선택'),
                  decoration: const InputDecoration(
                    labelText: '학교',
                    prefixIcon: Icon(Icons.apartment_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  items: _schools
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedSchool = v ?? ''),
                  validator: (v) => (v == null || v.isEmpty) ? '학교를 선택하세요' : null,
                ),
                const SizedBox(height: 14),

                // 학번
                TextFormField(
                  controller: _studentIdCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '학번',
                    prefixIcon: Icon(Icons.school_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? '학번을 입력하세요' : null,
                ),
                const SizedBox(height: 14),
              ],

              // 지역 선택
              InkWell(
                onTap: _pickRegion,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: '거주 지역',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                  ),
                  child: Text(
                    _selectedRegion.isEmpty ? '지역을 선택하세요' : _selectedRegion,
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedRegion.isEmpty ? Colors.grey.shade600 : const Color(0xFF374151),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('가입하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
