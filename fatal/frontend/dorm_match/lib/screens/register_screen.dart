import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _studentId = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _auth = Get.find<AuthController>();

  void _register() async {
    FocusScope.of(context).unfocus();
    if (_studentId.text.isEmpty || _password.text.isEmpty || _name.text.isEmpty) {
      Get.snackbar('입력 필요', '모든 항목을 입력해주세요.');
      return;
    }
    final error = await _auth.register(
      _studentId.text.trim(),
      _password.text,
      _name.text.trim(),
    );
    if (error == null) {
      Get.snackbar('환영합니다!', '회원가입이 완료되었습니다.');
      Get.offAllNamed('/home');
    } else {
      Get.snackbar(
        '회원가입 실패',
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '새 계정 만들기',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '간단한 정보 입력으로 시작하세요.',
                style: TextStyle(fontSize: 16, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 40),
              _buildTextField('이름', _name, Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField('학번', _studentId, Icons.badge_outlined,
                  type: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField('비밀번호', _password, Icons.lock_outline,
                  obscure: true),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                      onPressed: _auth.isLoading.value ? null : _register,
                      child: _auth.isLoading.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text('회원가입'),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType type = TextInputType.text,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      obscureText: obscure,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF)),
      ),
    );
  }
}
