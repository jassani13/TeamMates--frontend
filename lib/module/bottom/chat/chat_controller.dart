import 'package:base_code/model/chat_list_model.dart';
import 'package:base_code/package/config_packages.dart';

import '../../../model/group_chat_model.dart';

class ChatScreenController extends GetxController{
  List chatList = [
    "Team Chats",
    "Individual Chats",
    "Group Chats",
  ];
  RxInt selectedChatMethod= 0.obs;
  AutoScrollController controller=AutoScrollController();
  List<ChatListData> chatListData = <ChatListData>[];
  List<ChatListData> teamChatListData = <ChatListData>[];
  List<GroupChatModel> groupChatList = <GroupChatModel>[];
  Map<String,dynamic> onlineUsers = {};
}