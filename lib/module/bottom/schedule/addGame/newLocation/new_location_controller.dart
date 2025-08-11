import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class NewLocationController extends GetxController {
  TextEditingController locationController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController linkController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  var selectedLocation = Rxn<LocationData>();

  Future<void> addLocationApiCall() async {
    try {
      String address = addressController.value.text.trim();

      List<Location> locations;
      try {
        locations = await locationFromAddress(address);
      } catch (e) {
        AppToast.showAppToast("Invalid, Please check the address again");
        return;
      }

      if (locations.isEmpty) {
        AppToast.showAppToast("Invalid, Please check the address again");
        return;
      }

      Location location = locations.first;
      FormData formData = FormData.fromMap({
        "user_id": AppPref().userId,
        "location": locationController.value.text,
        "address": address,
        "link": linkController.value.text,
        "notes": notesController.value.text,
        "latitude": location.latitude.toString(),
        "longitude": location.longitude.toString(),
      });

      var response = await callApi(
        dio.post(
          ApiEndPoint.createLocation,
          data: formData,
        ),
        true,
      );
      if (response?.statusCode == 200) {
        var data = response?.data['data'];
        selectedLocation.value = LocationData.fromMap(data);
        AppToast.showAppToast(response?.data['ResponseMsg']);
        Get.back(result: selectedLocation.value);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
