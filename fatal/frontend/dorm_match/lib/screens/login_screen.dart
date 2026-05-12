import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginId = TextEditingController();
  final _password = TextEditingController();
  final _auth = Get.find<AuthController>();

  void _login() async {
    FocusScope.of(context).unfocus();
    final error = await _auth.login(_loginId.text.trim(), _password.text);
    if (error == null) {
      Get.offAllNamed('/home');
    } else {
      Get.snackbar(
        '로그인 실패',
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                '반가워요!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '아이디로 로그인하고\n나와 꼭 맞는 룸메이트를 찾아보세요',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 48),
              _buildTextField('아이디', _loginId, TextInputType.text),
              const SizedBox(height: 16),
              _buildTextField('비밀번호', _password, TextInputType.text, obscure: true),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                      onPressed: _auth.isLoading.value ? null : _login,
                      child: _auth.isLoading.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text('로그인'),
                    )),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => Get.toNamed('/register'),
                  child: RichText(
                    text: const TextSpan(
                      text: '계정이 없으신가요?  ',
                      style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                      children: [
                        TextSpan(
                          text: '회원가입',
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
    TextInputType type, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      obscureText: obscure,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          label == '아이디' ? Icons.person_outline : Icons.lock_outline,
          color: const Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}
