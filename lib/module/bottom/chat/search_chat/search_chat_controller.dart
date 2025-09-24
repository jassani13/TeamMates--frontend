import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:path/path.dart';
import '../chat_screen.dart';

class SearchChatController extends GetxController {
  RxBool isShimmer = false.obs;
  List chatList = ["Teams", "Players"];
  RxList<Roster> allRosterModelList = <Roster>[].obs;
  RxList<PlayerTeams> allPlayerModelList = <PlayerTeams>[].obs;
  var searchTeamQuery = ''.obs;
  var searchPlayerQuery = ''.obs;
  RxInt selectedChatMethod = 0.obs;
  AutoScrollController controller = AutoScrollController();
  TextEditingController searchTeamController = TextEditingController();
  TextEditingController searchPlayerController = TextEditingController();
  Rx<String> groupImagePath = "".obs;

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

        var list = (jsonData['data']['player_teams'] as List)
            .map((e) => PlayerTeams.fromJson(e))
            .toList();
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
        var list =
            (jsonData['data'] as List).map((e) => Roster.fromJson(e)).toList();
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

  Future<String?> createPersonalChat(String playerId) async {
    try {
      final Map<String, dynamic> payload = {
        "user_a": AppPref().userId,
        "user_b": playerId,
      };

      var res = await callApi(
        dio.post(
          ApiEndPoint.createPersonalChat,
          data: payload,
        ),
        true,
      );
      debugPrint("createPersonalChat response: $res");
      if (res?.statusCode == 200) {
        //socket.emit('getChatList', AppPref().userId);
        var jsonData = res?.data;
        String conversationId = jsonData['data']['conversation_id'].toString();
        return conversationId;
      }
    } catch (e) {
      debugPrint("Exception - chat_controller.dart - createPersonalChat(): $e");
    }
    return null;
  }

  Future<String?> createTeamChat(String teamId) async {
    try {
      final Map<String, dynamic> payload = {
        "owner_id": AppPref().userId,
        "team_id": teamId,
      };

      var res = await callApi(
        dio.post(
          ApiEndPoint.createTeamChat,
          data: payload,
        ),
        true,
      );
      debugPrint("createTeamChat response: $res");
      if (res?.statusCode == 200) {
        //socket.emit('getChatList', AppPref().userId);
        var jsonData = res?.data;
        String conversationId = jsonData['data']['conversation_id'].toString();
        return conversationId;
      }
    } catch (e) {
      debugPrint("Exception - chat_controller.dart - createTeamChat(): $e");
    }
    return null;
  }

  Future<String?> createGroupChat(
      List<String> selectedPlayers, String groupName) async {
    try {
      final Map<String, dynamic> payload = {
        "owner_id": AppPref().userId,
        "title": groupName,
      };
      for (int i = 0; i < selectedPlayers.length; i++) {
        payload["member_ids[$i]"] = selectedPlayers[i];
      }
      final data = FormData.fromMap({
        ...payload,
        if (groupImagePath.value.isNotEmpty) // make sure it's a String path
          'image': await MultipartFile.fromFile(
            groupImagePath.value,
            filename: basename(groupImagePath.value),
          ),
      });
      var res = await callApi(
        dio.post(
          ApiEndPoint.createGroupChat,
          data: data,
        ),
        true,
      );
      debugPrint("createGroupChat response: $res");
      if (res?.statusCode == 200) {
        socket.emit('getGroupChatList', AppPref().userId);
        var jsonData = res?.data;
        String conversationId = jsonData['data']['conversation_id'].toString();
        return conversationId;
      }
    } catch (e) {
      debugPrint(
          "Exception - group_chat_controller.dart - createGroupChat(): $e");
    }
    return null;
  }
}
