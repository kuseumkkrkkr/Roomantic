import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AuthController extends GetxController {
  final ApiService _api = Get.put(ApiService());
  final Rxn<User> user = Rxn<User>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  String _sha256(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  Future<bool> checkAuth() async {
    final token = await _api.getToken();
    if (token != null) {
      try {
        final me = await _api.getMe();
        user.value = User.fromJson(me);
        return true;
      } catch (_) {
        await _api.clearToken();
        user.value = null;
      }
    }
    return false;
  }

  Future<void> loadUser() async {
    final token = await _api.getToken();
    if (token != null) {
      try {
        final me = await _api.getMe();
        user.value = User.fromJson(me);
      } catch (_) {
        await _api.clearToken();
        user.value = null;
      }
    }
  }

  Future<String?> register({
    required String loginId,
    required String password,
    required String name,
    required int birthYear,
    String studentId = '',
    bool isEnrolled = true,
    String schoolName = '',
    String college = '',
    String department = '',
    String regionName = '',
    String gender = '',
  }) async {
    isLoading.value = true;
    try {
      // SHA-256 단방향 암호화: 비밀번호 및 학번 (민감 정보)
      final hashedPassword = _sha256(password.trim());

      final data = await _api.register({
        'login_id': loginId.trim(),
        'password': hashedPassword,
        'name': name.trim(),
        'birth_year': birthYear,
        'student_id': studentId.trim(),
        'is_enrolled': isEnrolled ? 1 : 0,
        'school_name': schoolName.trim(),
        'college': college.trim(),
        'department': department.trim(),
        'region_name': regionName.trim(),
        'gender': gender.trim(),
      });
      user.value = User.fromJson(data['user']);
      await _api.setToken(data['token']);
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> login(String loginId, String password) async {
    isLoading.value = true;
    try {
      final hashedPassword = _sha256(password.trim());
      final data = await _api.login({
        'login_id': loginId.trim(),
        'password': hashedPassword,
      });
      user.value = User.fromJson(data['user']);
      await _api.setToken(data['token']);
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _api.clearToken();
    user.value = null;
  }
}
