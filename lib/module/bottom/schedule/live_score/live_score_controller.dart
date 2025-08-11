import 'package:base_code/model/score_model.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class LiveScoreController extends GetxController {
  Rx<ScheduleData> activityDetails = ScheduleData().obs;

  TextEditingController teamAController = TextEditingController();
  TextEditingController teamBController = TextEditingController();
  RxList<History> scoreHistoryList = <History>[].obs;
  var latestScore = {}.obs; // Make it an observable map

  Future<void> getScoreApi() async {
    try {
      scoreHistoryList.clear();
      var data = {
        "activity_id": activityDetails.value.activityId,
      };
      var res = await callApi(
        dio.post(
          ApiEndPoint.getScoreList,
          data: data,
        ),
        false,
      );

      if (res?.statusCode == 200) {
        var jsonData = res?.data;
        var list = (jsonData['data']['history'] as List).map((e) => History.fromJson(e)).toList();
        scoreHistoryList.assignAll(list);
        if (scoreHistoryList.isNotEmpty) {
          latestScore.value = jsonDecode(scoreHistoryList.last.score ?? "{}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> createScore({required Map<String, dynamic> score}) async {
    try {
      var data = FormData.fromMap({
        "activity_id": activityDetails.value.activityId,
        "is_current": "0",
        "score": jsonEncode(score),
      });
      var res = await callApi(
        dio.post(
          ApiEndPoint.createScore,
          data: data,
        ),
        true,
      );

      if (res?.statusCode == 200) {
        scoreHistoryList.add(History.fromJson(res?.data['data']));
        if (scoreHistoryList.isNotEmpty) {
          latestScore.value = jsonDecode(scoreHistoryList.last.score ?? "{}");
        }
        scoreHistoryList.refresh();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  void onInit() {
    if (Get.arguments != null) {
      activityDetails.value = Get.arguments['activity_data'];
    }
    getScoreApi();
    super.onInit();
  }
}
