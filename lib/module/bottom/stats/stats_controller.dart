import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class StatsController extends GetxController {
  RxInt selectedMethod = 0.obs;
  RxBool isShimmer = false.obs;
  Rx<ChallengeModel> allChallengeDetail = ChallengeModel().obs;

  final AutoScrollController scrollController = AutoScrollController();
  final GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey<RefreshIndicatorState>();

  List<String> get statList => [
    if (AppPref().role != "coach") "Stats",
    "Challenges and Rewards",
  ];

  Future<void> getChallengeApiCall() async {
    isShimmer.value = true;

    try {
      final data = {
        "user_id": AppPref().userId,
      };

      final response = await callApi(
        dio.post(ApiEndPoint.getChallengeList, data: data),
        false,
      );

      if (response?.statusCode == 200) {
        final jsonData = response?.data["data"];
        allChallengeDetail.value = ChallengeModel.fromJson(jsonData);
        allChallengeDetail.refresh();
      }
    } catch (e) {
      if (kDebugMode) print('Error in getChallengeApiCall: $e');
    } finally {
      isShimmer.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getChallengeApiCall();
    });
  }
}
