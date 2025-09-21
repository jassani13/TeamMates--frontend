import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class SearchChatController extends GetxController {
  RxBool isShimmer = false.obs;
  List chatList = ["Teams", "Players"];
  RxList<Roster> allRosterModelList = <Roster>[].obs;
  RxList<PlayerTeams> allPlayerModelList = <PlayerTeams>[].obs;
  RxList<String> selectedPlayersForChatGroup = <String>[].obs;
  var searchTeamQuery = ''.obs;
  var searchPlayerQuery = ''.obs;
  RxInt selectedChatMethod = 0.obs;
  AutoScrollController controller = AutoScrollController();
  TextEditingController searchTeamController = TextEditingController();
  TextEditingController searchPlayerController = TextEditingController();

  Future<void> getPlayerApiCall() async {
    isShimmer.value = true;
    try {
      var data = {
        "coach_id": AppPref().userId,
      };
      var res = await callApi(
        dio.post(
          ApiEndPoint.getTeamPlayers,
          data: data,
        ),
        false,
      );

      if (res?.statusCode == 200) {
        var jsonData = res?.data;

        var list = (jsonData['data']['player_teams'] as List).map((e) => PlayerTeams.fromJson(e)).toList();
        allPlayerModelList.assignAll(list);
        isShimmer.value = false;
      }
    } catch (e) {
      isShimmer.value = false;

      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> getTeamApiCall() async {
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
    WidgetsBinding.instance.addPostFrameCallback((val) async {
      getPlayerApiCall();
      getTeamApiCall();
    });

    super.onInit();
  }
}
