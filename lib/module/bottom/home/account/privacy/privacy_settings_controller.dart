import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class PrivacySettingsController extends GetxController {
  final RxBool readReceiptsEnabled = true.obs; // default ON
  final RxBool loading = false.obs;
  final RxBool saving = false.obs; // distinct flag for save operations

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPrivacy();
    });
  }

  Future<void> _fetchPrivacy() async {
    try {
      loading.value = true;
      // Fetch via POST to fit app conventions and include user_id
      final body = FormData.fromMap({'user_id': AppPref().userId});
      final res =
          await callApi(dio.post(ApiEndPoint.readReceiptsPrivacy, data: body));
      debugPrint("Privacy_fetch_response: ${res}");
      loading.value = false;
      if (res?.statusCode == 200) {
        final data = res?.data;
        // Expecting { data: { read_receipts: 0|1|true|false } }
        final val = (data?['data']?['read_receipts'] ?? true);
        if (val is bool) {
          readReceiptsEnabled.value = val;
        } else if (val is num) {
          readReceiptsEnabled.value = val != 0;
        } else if (val is String) {
          readReceiptsEnabled.value =
              (val.toLowerCase() == 'true' || val == '1');
        }
      }
    } catch (e) {
      loading.value = false;
      // Leave default true on error; optionally show a snackbar
    }
  }

  void setReadReceipts(bool value) async {
    if (saving.value) return;
    saving.value = true;
    readReceiptsEnabled.value = value;
    try {
      final body = FormData.fromMap({
        'user_id': AppPref().userId,
        'read_receipts': value ? 1 : 0,
      });
      final res = await callApi(
          dio.post(ApiEndPoint.readReceiptsPrivacy, data: body),false);
      if (res?.statusCode == 200) {
        Get.snackbar(
            'Privacy', 'Read receipts ${value ? 'enabled' : 'disabled'}',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Privacy', 'Could not update setting',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint('error->setReadReceipts: $e');
      Get.snackbar('Privacy', 'Error saving setting',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      saving.value = false;
    }
  }
}
