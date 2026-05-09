import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AuthController extends GetxController {
  final ApiService _api = ApiService();
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;

  bool get isLoggedIn => user.value != null;

  Future<bool> checkAuth() async {
    try {
      final res = await _api.getMe();
      if (res.statusCode == 200) {
        user.value = User.fromJson(res.data);
        return true;
      }
    } catch (e) {
      // not logged in
    }
    user.value = null;
    return false;
  }

  Future<String?> register(String studentId, String password, String name) async {
    isLoading.value = true;
    try {
      final res = await _api.register({
        'student_id': studentId,
        'password': password,
        'name': name,
      });
      if (res.statusCode == 201) {
        final token = res.data['token'];
        await _api.setToken(token);
        user.value = User.fromJson(res.data['user']);
        return null;
      }
      return '회원가입 실패';
    } on DioException catch (e) {
      return e.response?.data?['error'] ?? '회원가입 중 오류 발생';
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> login(String studentId, String password) async {
    isLoading.value = true;
    try {
      final res = await _api.login({
        'student_id': studentId,
        'password': password,
      });
      if (res.statusCode == 200) {
        final token = res.data['token'];
        await _api.setToken(token);
        user.value = User.fromJson(res.data['user']);
        return null;
      }
      return '로그인 실패';
    } on DioException catch (e) {
      return e.response?.data?['error'] ?? '로그인 중 오류 발생';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _api.clearToken();
    user.value = null;
  }
}
