import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../models/profile.dart';

class ProfileController extends GetxController {
  final ApiService _api = ApiService();
  final Rx<Profile?> profile = Rx<Profile?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<bool> fetchProfile() async {
    isLoading.value = true;
    error.value = '';
    try {
      final res = await _api.getProfile();
      if (res.statusCode == 200) {
        profile.value = Profile.fromJson(res.data);
        return true;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        error.value = '설문조사를 먼저 작성해주세요.';
      } else {
        error.value = e.response?.data?['error'] ?? '프로필 조회 실패';
      }
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  Future<String?> saveProfile(Profile p) async {
    isLoading.value = true;
    error.value = '';
    try {
      final res = await _api.saveProfile(p.toJson());
      if (res.statusCode == 200) {
        profile.value = Profile.fromJson(res.data);
        return null;
      }
      return '저장 실패';
    } on DioException catch (e) {
      return e.response?.data?['error'] ?? '저장 중 오류 발생';
    } finally {
      isLoading.value = false;
    }
  }
}
