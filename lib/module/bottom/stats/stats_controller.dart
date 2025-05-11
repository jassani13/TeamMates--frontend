import 'package:base_code/model/challenge_model.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class StatsController extends GetxController{
  List statList = [
    if(AppPref().role!="coach")"Stats",
    "Challenges and Rewards",
  ];
  RxInt selectedMethod= 0.obs;
  AutoScrollController controller=AutoScrollController();
  final GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey<RefreshIndicatorState>();


  Rx<ChallengeModel> allChallengeDetail =ChallengeModel().obs;

  RxBool isShimmer = false.obs;

  Future<void> getChallengeApiCall() async {
    try {
      isShimmer.value = true;
      var data = {
        "user_id": AppPref().userId,
      };
      var res = await callApi(
        dio.post(
          ApiEndPoint.getChallengeList,
          data: data,
        ),
        false,
      );

      if (res?.statusCode == 200) {

        var jsonData = res?.data["data"];
        allChallengeDetail.value =ChallengeModel.fromJson(jsonData);
        isShimmer.value = false;
      }
      isShimmer.value = false;

    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      isShimmer.value = false;
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((val) async {
      await getChallengeApiCall();
    });
  }
}