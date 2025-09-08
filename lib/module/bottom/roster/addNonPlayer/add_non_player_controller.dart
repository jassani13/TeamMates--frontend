import 'package:base_code/module/bottom/roster/allPlayer/all_player_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

import '../roster_controller.dart';
import 'package:flutter/foundation.dart';

class AddNonPlayerController extends GetxController {
  RxList<PlayerDetailModel> playerList = <PlayerDetailModel>[].obs;

  // Statically define the staff roles
  final List<String> staffRoles = [
    'Team Manager',
    'Coach',
    'Assistant Coach',
    'Trainer',
    'Analyst'
  ];

  void addNonPlayer() {
    playerList.add(
      PlayerDetailModel(
        fNameController: TextEditingController(),
        lNameController: TextEditingController(),
        emailControllers: [TextEditingController()],
        fNameFocusNode: FocusNode(),
        lNameFocusNode: FocusNode(),
        emailFocusNodes: [FocusNode()],
        userIdentity: "non_player",
        // Assign the first role by default
        staff_role: staffRoles.first,
      ),
    );
  }

  void addEmailField(int playerIndex) {
    playerList[playerIndex].emailControllers.add(TextEditingController());
    playerList[playerIndex].emailFocusNodes.add(FocusNode());
    playerList.refresh();
  }

  void removeEmailField(int playerIndex, int emailIndex) {
    if (playerList[playerIndex].emailControllers.length > 1) {
      playerList[playerIndex].emailControllers.removeAt(emailIndex);
      playerList[playerIndex].emailFocusNodes.removeAt(emailIndex);
      playerList.refresh();
    }
  }

  Future<void> addMembersToTeam() async {
    try {
      final arg = Get.arguments;
      if (arg == null || arg.length < 2) {
        AppToast.showAppToast('Invalid arguments provided');
        return;
      }

      AppLoader().showLoader();

      var formData = FormData();
      formData.fields.add(MapEntry('team_id', arg[0].toString()));

      for (int i = 0; i < playerList.length; i++) {
        List<String> userEmails = [];
        for (int j = 0; j < playerList[i].emailControllers.length; j++) {
          String email = playerList[i].emailControllers[j].text.trim();
          if (email.isNotEmpty) {
            userEmails.add(email);
          }
        }

        if (userEmails.isEmpty) {
          continue;
        }

        formData.fields.addAll([
          MapEntry("list[$i][first_name]", playerList[i].fNameController.text.trim()),
          MapEntry("list[$i][last_name]", playerList[i].lNameController.text.trim()),
          MapEntry("list[$i][email]", userEmails[0]),
          MapEntry("list[$i][user_identity]", playerList[i].userIdentity),
          MapEntry("list[$i][staff_role]", playerList[i].staff_role!),
        ]);

        for (String email in userEmails) {
          formData.fields.add(MapEntry("list[$i][user_emails][]", email));
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
          AppToast.showAppToast("Players added successfully");
        } else {
          Get.find<RoasterController>().getRosterApiCall();
          await Get.find<AllPlayerController>().getRosterApiCall(teamId: arg[0]);
          AppLoader().dismissLoader();
          Get.back();
          AppToast.showAppToast("Players added successfully");
        }
      }
    } catch (e) {
      AppLoader().dismissLoader();

      if (e is DioException && e.response?.statusCode == 422) {
        final message = e.response?.data['ResponseMsg'] ?? 'Something went wrong.';
        AppToast.showAppToast(message);
      } else {
        print("AddMembers Error: $e");
        AppToast.showAppToast('Failed to add players. Please try again.');
      }

      if (kDebugMode) {
        print("AddMembers Error: $e");
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    addNonPlayer();
  }
}

class PlayerDetailModel {
  int? id;
  TextEditingController fNameController;
  TextEditingController lNameController;
  List<TextEditingController> emailControllers;
  FocusNode fNameFocusNode;
  FocusNode lNameFocusNode;
  List<FocusNode> emailFocusNodes;
  String userIdentity;
  // Add a new property for the staff role
  String? staff_role;

  PlayerDetailModel({
    this.id,
    required this.fNameController,
    required this.lNameController,
    required this.emailControllers,
    required this.fNameFocusNode,
    required this.lNameFocusNode,
    required this.emailFocusNodes,
    required this.userIdentity,
    this.staff_role, // Make the role property optional
  });
}