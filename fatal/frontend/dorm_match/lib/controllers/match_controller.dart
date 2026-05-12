import 'package:get/get.dart';
import '../services/api_service.dart';

class MatchController extends GetxController {
  final _api = ApiService();
  final topMatches = <Map<String, dynamic>>[].obs;
  final pairs = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  Future<void> fetchTopMatches() async {
    isLoading.value = true;
    try {
      final res = await _api.getTopMatches();
      topMatches.assignAll(List<Map<String, dynamic>>.from(res['matches'] ?? []));
    } catch (e) {
      Get.snackbar('오류', '매칭 결과를 불러오지 못했습니다: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPairs() async {
    isLoading.value = true;
    try {
      final res = await _api.getPairs();
      pairs.assignAll(List<Map<String, dynamic>>.from(res));
    } catch (e) {
      Get.snackbar('오류', '페어 결과를 불러오지 못했습니다: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
