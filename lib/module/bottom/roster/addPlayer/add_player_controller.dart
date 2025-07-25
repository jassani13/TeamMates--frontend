import 'package:base_code/module/bottom/roster/allPlayer/all_player_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

import '../roster_controller.dart';

class AddPlayerController extends GetxController {
  RxList<PlayerDetailModel> playerList = <PlayerDetailModel>[].obs;

  void addPlayer() {
    playerList.add(
      PlayerDetailModel(
        fNameController: TextEditingController(),
        lNameController: TextEditingController(),
        emailControllers: [TextEditingController()],
        fNameFocusNode: FocusNode(),
        lNameFocusNode: FocusNode(),
        emailFocusNodes: [FocusNode()],
      ),
    );
  }

  void addEmailField(int playerIndex) {
    playerList[playerIndex].emailControllers.add(TextEditingController());
    playerList[playerIndex].emailFocusNodes.add(FocusNode());
    playerList.refresh(); // Trigger UI update
  }

  void removeEmailField(int playerIndex, int emailIndex) {
    if (playerList[playerIndex].emailControllers.length > 1) {
      playerList[playerIndex].emailControllers.removeAt(emailIndex);
      playerList[playerIndex].emailFocusNodes.removeAt(emailIndex);
      playerList.refresh();
    }
  }

  final arg = Get.arguments;

  Future<void> addMembersToTeam() async {
    try {
      AppLoader().showLoader();
      FormData formData = FormData.fromMap({
        "team_id": arg[0].toString(),
      });

      // Adding players dynamically
      for (int i = 0; i < playerList.length; i++) {
        formData.fields.addAll([
          MapEntry("list[$i][first_name]",
              playerList[i].fNameController.text.trim()),
          MapEntry(
              "list[$i][last_name]", playerList[i].lNameController.text.trim()),
          MapEntry(
              "list[$i][email]", playerList[i].emailControllers[0].text.trim()),
        ]);

        // Add all emails as array
        for (int j = 0; j < playerList[i].emailControllers.length; j++) {
          formData.fields.add(MapEntry("list[$i][user_emails][$j]",
              playerList[i].emailControllers[j].text.trim()));
        }
      }

      var response = await dio.post(
        ApiEndPoint.addMemberToTeam,
        data: formData,
      );
      if (response.statusCode == 200) {
        if (arg[1] == false) {
          Get.find<RoasterController>().getRosterApiCall();
          AppLoader().dismissLoader();
          Get.back();
          AppToast.showAppToast("Players add successfully");
        } else {
          Get.find<RoasterController>().getRosterApiCall();
          await Get.find<AllPlayerController>()
              .getRosterApiCall(teamId: arg[0]);
          AppLoader().dismissLoader();
          Get.back();
          AppToast.showAppToast("Players add successfully");
        }
      }
    } catch (e) {
      AppLoader().dismissLoader();

      if (e is DioException && e.response?.statusCode == 422) {
        final message =
            e.response?.data['ResponseMsg'] ?? 'Something went wrong.';
        AppToast.showAppToast(message);
      } else {
        AppToast.showAppToast('Failed to add players. Please try again.');
      }

      if (kDebugMode) {
        print("AddMembers Error: $e");
      }
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    addPlayer();
  }
}

class PlayerDetailModel {
  int? id;
  TextEditingController fNameController;
  TextEditingController lNameController;
  List<TextEditingController> emailControllers;
  FocusNode fNameFocusNode;
  FocusNode lNameFocusNode;
  List<FocusNode> emailFocusNodes; // Changed from single to list

  PlayerDetailModel({
    this.id,
    required this.fNameController,
    required this.lNameController,
    required this.emailControllers,
    required this.fNameFocusNode,
    required this.lNameFocusNode,
    required this.emailFocusNodes,
  });
}
