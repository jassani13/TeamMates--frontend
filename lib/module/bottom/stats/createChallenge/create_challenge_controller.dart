import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class CreateChallengeController extends GetxController {
  final cNameController = TextEditingController();
  final cDescriptionController = TextEditingController();
  final notesController = TextEditingController();
  final startTimeController = TextEditingController().obs;
  final endTimeController = TextEditingController().obs;

  final nameFocus = FocusNode();
  final descFocus = FocusNode();
  final notesFocus = FocusNode();

  final isNotify = false.obs;

  Future<void> addChallengeApi() async {
    try {
      final formData = FormData.fromMap({
        "user_id": AppPref().userId,
        "name": cNameController.text.trim(),
        "description": cDescriptionController.text.trim(),
        "start_at": startTimeController.value.text.trim(),
        "end_at": endTimeController.value.text.trim(),
        "notes": notesController.text.trim(),
        "notify_team": isNotify.value ? 1 : 0,
      });

      final response = await callApi(dio.post(ApiEndPoint.createChallenge, data: formData));

      if (response?.statusCode == 200) {
        AppToast.showAppToast(response?.data['ResponseMsg']);
        final challenge = Challenge.fromJson(response?.data['data']);
        Get.find<HomeController>().refreshKey.currentState?.show();
        Get.back(result: challenge);
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }
}
