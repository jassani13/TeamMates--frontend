import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class NewOpponentController extends GetxController {
  TextEditingController oNameController = TextEditingController();
  TextEditingController cNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  var selectedOpponent = Rxn<OpponentModel>();

  Future<void> addOpponentApi() async {
    try {
      FormData formData = FormData.fromMap({
        "user_id": AppPref().userId,
        "opponent_name": oNameController.value.text,
        "contact_name": cNameController.value.text,
        "phone_number": phoneController.value.text,
        "email": emailController.value.text,
        "notes": notesController.value.text,
      });

      var response = await callApi(
        dio.post(
          ApiEndPoint.createOpponent,
          data: formData,
        ),
        true,
      );
      if (response?.statusCode == 200) {
        var data = response?.data['data'];
        selectedOpponent.value = OpponentModel.fromJson(data);
        AppToast.showAppToast(response?.data['ResponseMsg']);
        Get.back(result: selectedOpponent.value);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
