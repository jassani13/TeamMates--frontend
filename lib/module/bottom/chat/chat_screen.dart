import 'package:base_code/module/bottom/chat/chat_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

late IO.Socket socket;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final chatController = Get.put<ChatScreenController>(ChatScreenController());

  void connectSocket() {
    socket = IO.io('http://35.175.243.150:8080', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'forceNew': true,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 2000,
    });

    socket.connect();

    socket.onConnect((_) {
      emitPersonalChatList();
      emitTeamChatList();
      if (kDebugMode) {
        print('<------------ CONNECTED TO SERVER ------------>');
      }
    });
    socket.onDisconnect((_) {
      if (kDebugMode) {
        print('<------------ DISCONNECTED TO SERVER ------------>');
      }
    });
  }

  void emitPersonalChatList() {
    if (kDebugMode) {
      print('<------------ EMIT - getChatUserList ------------>');
    }
    socket.emit('getChatUserList', AppPref().userId);
  }

  void emitTeamChatList() {
    if (kDebugMode) {
      print('<------------ EMIT - getTeamChatList ------------>');
    }
    socket.emit('getTeamChatList', AppPref().userId);
  }

  void onPersonalChatList() {
    socket.on('setChatUserList', (data) {
      final list = data['resData'];
      if (kDebugMode) {
        print('<------------ ON - setChatUserList ------------>');
      }
      chatController.chatListData = list.map((e) => ChatListData.fromJson(e)).toList().cast<ChatListData>();
      if (mounted) {
        setState(() {});
      }
    });
  }

  void onTeamChatList() {
    socket.on('setTeamChatList', (data) {
      final list = data['resData'];

      if (kDebugMode) {
        print('<------------ ON - setTeamChatList ------------>');
      }
      chatController.grpChatListData = list.map((e) => ChatListData.fromJson(e)).toList().cast<ChatListData>();
      if (mounted) {
        setState(() {});
      }
    });
  }

  void userOnline() {
    socket.emit('userOnline', [AppPref().userId]);
  }

  void updateUserStatus() {
    socket.on('updateUserStatus', (data) {
      chatController.onlineUsers = data;
      if (mounted) {
        setState(() {});
      }
    });
  }

  void updateChatList() {
    if (kDebugMode) {
      print('<------------ ON - updateChatList ------------>');
    }
    socket.on('updateChatList', (val) {
      final data = ChatListData.fromJson(val['resData']);
      if (kDebugMode) {
        print('<------------ ON - updateChatList $data ------------>');
      }
      int index = chatController.chatListData.indexWhere((test) =>
          (test.senderId == data.senderId && test.receiverId == data.receiverId) ||
          (test.senderId == data.receiverId && test.receiverId == data.senderId));
      if (index != -1) {
        chatController.chatListData[index] = data;
        if (mounted) {
          setState(() {});
        }
      } else {
        chatController.chatListData.add(data);
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  void updateTeamChatList() {
    if (kDebugMode) {
      print('<------------ ON - updateTeamChatList ------------>');
    }
    socket.on('updateTeamChatList', (val) {
      final data = ChatListData.fromJson(val['resData']);
      if (kDebugMode) {
        print('<------------ ON - updateTeamChatList $data ------------>');
      }
      int index = chatController.grpChatListData.indexWhere((test) => data.teamId == test.teamId);
      if (index != -1) {
        chatController.grpChatListData[index] = data;
        if (mounted) {
          setState(() {});
        }
      } else {
        chatController.grpChatListData.add(data);
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  void initState() {
    connectSocket();

    onPersonalChatList();
    onTeamChatList();
    updateChatList();
    updateTeamChatList();
    userOnline();
    updateUserStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SvgPicture.asset(
            AppImage.bottomBg,
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
          Column(
            children: [
              Gap(Platform.isAndroid ? ScreenUtil().statusBarHeight + 20 : ScreenUtil().statusBarHeight + 10),
              Row(
                children: [
                  Gap(16),
                  CommonTitleText(text: "Chat"),
                  Spacer(),
                  Visibility(
                    visible: AppPref().role == 'coach',
                    child: CommonIconButton(
                      image: AppImage.plus,
                      onTap: () {
                        Get.toNamed(AppRouter.searchChatScreen);
                      },
                    ),
                  ),
                  Gap(16),
                ],
              ),
              Gap(24),
              Container(
                height: 63,
                width: double.infinity,
                padding: EdgeInsets.all(
                  16,
                ),
                margin: EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColor.greyF6Color,
                  borderRadius: BorderRadius.circular(
                    8,
                  ),
                ),
                child: HorizontalSelectionList(
                  items: chatController.chatList,
                  selectedIndex: chatController.selectedChatMethod,
                  controller: chatController.controller,
                  onItemSelected: (index) {
                    chatController.selectedChatMethod.value = index;
                  },
                ),
              ),
              Gap(24),
              Obx(
                () => Expanded(
                  child: Column(
                    children: [
                      if (chatController.selectedChatMethod.value == 0) ...[
                        _tamChatList(),
                      ] else ...[
                        _personalChatList(),
                      ]
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _personalChatList() {
    return chatController.chatListData.isEmpty
        ? SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3.3),
                  child: Center(
                      child: buildNoData(
                    text: "No Conversations Yet",
                  )),
                ),
              ],
            ),
          )
        : ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: chatController.chatListData.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final chatData = chatController.chatListData[index];
              return GestureDetector(
                onTap: () {
                  if (AppPref().proUser == false) {
                    Get.toNamed(
                      AppRouter.personalChat,
                      arguments: {
                        'chatData': chatData,
                      },
                    );
                  } else {
                    Get.defaultDialog(
                      title: "Subscription Required",
                      titleStyle: TextStyle().normal20w500.textColor(AppColor.black12Color),
                      middleTextStyle: TextStyle().normal16w400.textColor(AppColor.grey4EColor),
                      middleText: "Buy a subscription to access Personal Chat.",
                      textConfirm: "Buy Now",
                      confirmTextColor: AppColor.white,
                      buttonColor: AppColor.black12Color,
                      cancelTextColor: AppColor.black12Color,
                      textCancel: "Cancel",
                      onConfirm: () {
                        Get.back();
                        Get.toNamed(AppRouter.subscription);
                      },
                    );
                  }
                },
                behavior: HitTestBehavior.translucent,
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: 14,
                    top: 14,
                  ),
                  decoration: BoxDecoration(
                    border: index == 0
                        ? null
                        : Border(
                            top: BorderSide(
                              color: AppColor.greyF6Color,
                            ),
                          ),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipOval(
                            child: getImageView(
                                errorWidget: Icon(
                                  Icons.account_circle,
                                  size: 40,
                                ),
                                finalUrl: chatData.profile ?? "",
                                fit: BoxFit.cover),
                          ),
                          if (chatController.onlineUsers.containsKey(chatData.receiverId) == true)
                            Container(
                              height: 12,
                              width: 12,
                              decoration:
                                  BoxDecoration(color: AppColor.greenColor, shape: BoxShape.circle, border: Border.all(color: AppColor.white)),
                            ),
                        ],
                      ),
                      Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${chatData.firstName} ${chatData.lastName}',
                              style: TextStyle().normal16w500.textColor(
                                    AppColor.black12Color,
                                  ),
                            ),
                            Text(
                              chatData.msgType == 'text' ? chatData.msg ?? "" : "Sent a file",
                              style: TextStyle().normal14w500.textColor(
                                    AppColor.grey4EColor,
                                  ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      Gap(16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            DateUtilities.getTimeAgo(chatData.createdAt ?? ""),
                            style: TextStyle().normal14w500.textColor(
                                  AppColor.grey4EColor,
                                ),
                          ),
                          Column(
                            children: [
                              Gap(4),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColor.greyF6Color,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  chatData.unreadCount ?? "0",
                                  style: TextStyle().normal14w500.textColor(
                                        AppColor.black,
                                      ),
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            });
  }

  Widget _tamChatList() {
    return chatController.grpChatListData.isEmpty
        ? SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3.3),
                  child: Center(
                      child: buildNoData(
                    text: "No Conversations Yet",
                  )),
                ),
              ],
            ),
          )
        : ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: chatController.grpChatListData.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final chatData = chatController.grpChatListData[index];
              return GestureDetector(
                onTap: () {
                  if (AppPref().proUser == false) {
                    Get.toNamed(
                      AppRouter.grpChat,
                      arguments: {
                        'chatData': chatData,
                      },
                    );
                  } else {
                    Get.defaultDialog(
                      title: "Subscription Required",
                      titleStyle: TextStyle().normal20w500.textColor(AppColor.black12Color),
                      middleTextStyle: TextStyle().normal16w400.textColor(AppColor.grey4EColor),
                      middleText: "Buy a subscription to\naccess Team Chat.",
                      textConfirm: "Buy Now",
                      confirmTextColor: AppColor.white,
                      buttonColor: AppColor.black12Color,
                      cancelTextColor: AppColor.black12Color,
                      textCancel: "Cancel",
                      onConfirm: () {
                        Get.back();
                        Get.toNamed(AppRouter.subscription);
                      },
                    );
                  }
                },
                behavior: HitTestBehavior.translucent,
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: 14,
                    top: 14,
                  ),
                  decoration: BoxDecoration(
                    border: index == 0
                        ? null
                        : Border(
                            top: BorderSide(
                              color: AppColor.greyF6Color,
                            ),
                          ),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipOval(
                            child: getImageView(
                              fit: BoxFit.cover,
                              errorWidget: Icon(
                                Icons.account_circle,
                                size: 40,
                              ),
                              finalUrl: (chatData.teamIcon ?? "").isEmpty ? chatData.teamImage ?? "" : chatData.teamIcon ?? "",
                            ),
                          ),
                          if (chatController.onlineUsers.containsKey(chatData.receiverId) == true)
                            Container(
                              height: 12,
                              width: 12,
                              decoration:
                                  BoxDecoration(color: AppColor.greenColor, shape: BoxShape.circle, border: Border.all(color: AppColor.white)),
                            ),
                        ],
                      ),
                      Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${chatData.teamName}',
                              style: TextStyle().normal16w500.textColor(
                                    AppColor.black12Color,
                                  ),
                            ),
                            Text(
                              chatData.msg ?? "",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle().normal14w500.textColor(
                                    AppColor.grey4EColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Gap(16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            DateUtilities.getTimeAgo(chatData.createdAt ?? ""),
                            style: TextStyle().normal14w500.textColor(
                                  AppColor.grey4EColor,
                                ),
                          ),
                          Column(
                            children: [
                              Gap(4),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColor.greyF6Color,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  chatData.unreadCount ?? "0",
                                  style: TextStyle().normal14w500.textColor(
                                        AppColor.black,
                                      ),
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            });
  }
}
