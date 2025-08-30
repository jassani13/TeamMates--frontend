import 'package:base_code/model/chat_list_model.dart';
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
  List<ChatListData> customGroupChatData = <ChatListData>[];
  Map<String,dynamic> onlineUsers = {};
}