import 'package:get/get.dart';
import '../models/profile.dart';
import '../services/api_service.dart';

class ProfileController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final Rxn<Profile> profile = Rxn<Profile>();
  final RxString persona = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final data = await _api.getProfile();
      if (data.containsKey('error')) {
        profile.value = null;
        persona.value = '';
      } else {
        profile.value = Profile.fromJson(data);
        persona.value = data['persona'] ?? '';
      }
    } catch (_) {
      profile.value = null;
      persona.value = '';
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> saveProfile(Profile p) async {
    isLoading.value = true;
    try {
      await _api.saveProfile(p.toJson());
      profile.value = p;
      final personaData = await _api.getPersona();
      persona.value = personaData['persona'] ?? '';
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
