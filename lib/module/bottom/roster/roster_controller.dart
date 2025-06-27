import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class RoasterController extends GetxController {
  RxList<Roster> allRosterModelList = <Roster>[].obs;
  final GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey<RefreshIndicatorState>();
  TextEditingController searchController = TextEditingController();
  RxBool isShimmer = false.obs;
  var searchQuery = ''.obs;

  Future<void> getRosterApiCall() async {
    try {
      isShimmer.value = true;
      var data = {
        "user_id": AppPref().userId,
      };
      var res = await callApi(
        dio.post(
          ApiEndPoint.getRosterList,
          data: data,
        ),
        false,
      );

      if (res?.statusCode == 200) {
        var jsonData = res?.data;
        var list = (jsonData['data'] as List).map((e) => Roster.fromJson(e)).toList();
        allRosterModelList.assignAll(list);
        isShimmer.value = false;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      isShimmer.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((val) async {
      await getRosterApiCall();
      
      // Refresh subscription status when roster screen is loaded
      try {
        final purchaseController = Get.find<InAppPurchaseController>();
        await purchaseController.refreshSubscriptionStatus();
        if (kDebugMode) {
          print("Roster screen - Subscription status refreshed - proUser: ${AppPref().proUser}");
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error refreshing subscription in roster screen: $e");
        }
      }
    });
  }
}
