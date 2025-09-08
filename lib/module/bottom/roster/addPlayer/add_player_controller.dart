import 'package:base_code/module/bottom/roster/allPlayer/all_player_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../roster_controller.dart';

class AddPlayerController extends GetxController {
  RxList<PlayerDetailModel> playerList = <PlayerDetailModel>[].obs;

  void addPlayer() {
    playerList.add(
      PlayerDetailModel(
        fNameController: TextEditingController(),
        lNameController: TextEditingController(),
        emailControllers: [TextEditingController()],
        relationshipControllers: [], // Start empty for primary email
        fNameFocusNode: FocusNode(),
        lNameFocusNode: FocusNode(),
        emailFocusNodes: [FocusNode()],
        userIdentity: "player",
      ),
    );
  }

  void addEmailField(int playerIndex) {
    playerList[playerIndex].emailControllers.add(TextEditingController());
    // Add relationship controller for this additional email
    playerList[playerIndex].relationshipControllers.add(TextEditingController());
    playerList[playerIndex].emailFocusNodes.add(FocusNode());
    playerList.refresh();
  }

  void removeEmailField(int playerIndex, int emailIndex) {
    if (playerList[playerIndex].emailControllers.length > 1) {
      playerList[playerIndex].emailControllers.removeAt(emailIndex);
      playerList[playerIndex].emailFocusNodes.removeAt(emailIndex);

      // Remove the corresponding relationship controller
      // For primary email (index 0), there's no relationship controller
      // For additional emails (index > 0), remove at index-1
      if (emailIndex > 0) {
        playerList[playerIndex].relationshipControllers.removeAt(emailIndex - 1);
      }
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
        // Get all non-empty emails with their relationships
        List<Map<String, String>> userEmails = [];

        // Primary email (always index 0)
        final primaryEmail = playerList[i].emailControllers[0].text.trim();
        if (primaryEmail.isNotEmpty) {
          userEmails.add({
            'email': primaryEmail,
            'relationship': "Primary" // Primary email always has "Primary" relationship
          });
        }

        // Additional emails (starting from index 1)
        for (int j = 1; j < playerList[i].emailControllers.length; j++) {
          String email = playerList[i].emailControllers[j].text.trim();
          if (email.isNotEmpty) {
            // Get relationship from the corresponding controller (index j-1)
            String relationship = "";
            if (j - 1 < playerList[i].relationshipControllers.length) {
              relationship = playerList[i].relationshipControllers[j - 1].text.trim();
            }
            userEmails.add({
              'email': email,
              'relationship': relationship.isEmpty ? "Contact" : relationship
            });
          }
        }

        // If no emails, skip this player
        if (userEmails.isEmpty) {
          continue;
        }

        formData.fields.addAll([
          MapEntry("list[$i][first_name]", playerList[i].fNameController.text.trim()),
          MapEntry("list[$i][last_name]", playerList[i].lNameController.text.trim()),
          MapEntry("list[$i][email]", userEmails[0]['email']!), // Primary email
          MapEntry("list[$i][user_identity]", playerList[i].userIdentity),
        ]);

        // Add all emails with relationships to the FormData
        for (int j = 0; j < userEmails.length; j++) {
          formData.fields.add(MapEntry("list[$i][user_emails][$j][email]", userEmails[j]['email']!));
          formData.fields.add(MapEntry("list[$i][user_emails][$j][relationship]", userEmails[j]['relationship']!));
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
    addPlayer();
  }
}

class PlayerDetailModel {
  int? id;
  TextEditingController fNameController;
  TextEditingController lNameController;
  List<TextEditingController> emailControllers;
  List<TextEditingController> relationshipControllers; // For additional emails only
  FocusNode fNameFocusNode;
  FocusNode lNameFocusNode;
  List<FocusNode> emailFocusNodes;
  String userIdentity;

  PlayerDetailModel({
    this.id,
    required this.fNameController,
    required this.lNameController,
    required this.emailControllers,
    required this.relationshipControllers,
    required this.fNameFocusNode,
    required this.lNameFocusNode,
    required this.emailFocusNodes,
    required this.userIdentity,
  });
}