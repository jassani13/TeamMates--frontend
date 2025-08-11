import 'package:base_code/model/home_model.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class HomeController extends GetxController {
  Rxn<HomeModel> homeModel = Rxn<HomeModel>();
  RxBool isShimmer = false.obs;
  RxString contact = "".obs;
  final GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey<RefreshIndicatorState>();

  Future<void> getHomeDetailsApiCall() async {
    try {
      isShimmer.value = true;
      var data = {
        "user_id": AppPref().userId,
      };
      var res = await callApi(
        dio.post(
          ApiEndPoint.homeDetails,
          data: data,
        ),
        false,
      );

      if (res?.statusCode == 200) {
        var jsonData = res?.data;
        homeModel.value = HomeModel.fromJson(jsonData);
        isShimmer.value = false;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      isShimmer.value = false;
    }
  }
  Future<void> getCoachApiCall() async {
    try {
      var data = {
        "user_id": AppPref().userId,
      };
      var res = await callApi(
        dio.post(
          ApiEndPoint.getMyCoachDetails,
          data: data,
        ),
        false,
      );

      if (res?.statusCode == 200) {
        var jsonData = res?.data;
        contact.value=jsonData["data"]["emergency_contact"] ?? "Not Added yet";
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    getHomeDetailsApiCall();
    if(AppPref().role=="team"){
      getCoachApiCall();

    }
  }
}
