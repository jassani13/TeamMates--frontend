import 'package:base_code/model/chat_list_model.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:flutter/foundation.dart';

class ChatScreenController extends GetxController{
  List chatList = [
    "Group",
    "Individual Chats",
  ];
  RxInt selectedChatMethod= 0.obs;
  AutoScrollController controller=AutoScrollController();
  List<ChatListData> chatListData = <ChatListData>[];
  List<ChatListData> grpChatListData = <ChatListData>[];
  Map<String,dynamic> onlineUsers = {};

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((val) async {
      // Refresh subscription status when chat screen is loaded
      try {
        final purchaseController = Get.find<InAppPurchaseController>();
        await purchaseController.refreshSubscriptionStatus();
        if (kDebugMode) {
          print("Chat screen - Subscription status refreshed - proUser: ${AppPref().proUser}");
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error refreshing subscription in chat screen: $e");
        }
      }
    });
  }
}