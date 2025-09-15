import 'package:base_code/package/config_packages.dart';

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
}