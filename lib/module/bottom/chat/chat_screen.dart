import 'package:base_code/main.dart';
import 'package:base_code/module/bottom/chat/chat_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../model/group_chat_model.dart';

late IO.Socket socket;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final chatController = Get.put<ChatScreenController>(ChatScreenController());

  // for android => http://10.0.2.2:3000 => for ios => http://127.0.0.1:3000
  void connectSocket() {
    debugPrint("inside=>connectSocket");
    socket = IO.io('http://127.0.0.1:3000', <String, dynamic>{
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
      joinGroupRooms();
      emitGroupChatList();
      if (kDebugMode) {
        print('<------------ CONNECTED TO SERVER ------------>');
      }
    });

    socket.onDisconnect((_) {
      if (kDebugMode) {
        print('<------------ DISCONNECTED TO SERVER ------------>');
      }
    });

    socket.onConnectError((data) {
      debugPrint('<------------ ⚠️ CONNECT ERROR ------------>');
      debugPrint('Error details: $data');
    });

    socket.onError((data) {
      debugPrint('<------------ ⚠️ SOCKET ERROR ------------>');
      debugPrint('Error details: $data');
    });
  }

  void joinGroupRooms() => socket.emit('joinGroupRooms', AppPref().userId);

  void emitGroupChatList() => socket.emit('getGroupChatList', AppPref().userId);

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
        print('<------------ ON - setChatUserList: $data ------------>');
      }
      chatController.chatListData = list
          .map((e) => ChatListData.fromJson(e))
          .toList()
          .cast<ChatListData>();
      if (mounted) {
        setState(() {});
      }
    });
  }

  void onTeamChatList() {
    socket.on('setTeamChatList', (data) {
      final list = data['resData'];

      if (kDebugMode) {
        print('<------------ ON - setTeamChatListL: $data ------------>');
      }
      chatController.teamChatListData = list
          .map((e) => ChatListData.fromJson(e))
          .toList()
          .cast<ChatListData>();
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
          (test.senderId == data.senderId &&
              test.receiverId == data.receiverId) ||
          (test.senderId == data.receiverId &&
              test.receiverId == data.senderId));
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
      int index = chatController.teamChatListData
          .indexWhere((test) => data.teamId == test.teamId);
      if (index != -1) {
        chatController.teamChatListData[index] = data;
        if (mounted) {
          setState(() {});
        }
      } else {
        chatController.teamChatListData.add(data);
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  void setGroupChatList() {
    debugPrint("setGroupChatList");
    socket.on('setGroupChatList', (data) {
      debugPrint("setGroupChatList: $data");
      List<GroupChatModel> items = GroupChatModel.listFromResData(data);
      chatController.groupChatList
        ..clear()
        ..addAll(items);

      if (mounted) setState(() {});
    });
  }

  void updateGroupChatList() {
    debugPrint("updateGroupChatList");
    socket.on('updateGroupChatList', (val) {
      debugPrint("updateGroupChatList:$val");
      final e = Map<String, dynamic>.from(val['resData'] ?? {});
      final item = GroupChatModel.fromJson(e);

      final list = chatController.groupChatList;
      final idx = list.indexWhere((x) => x.groupId == item.groupId);
      if (idx != -1) {
        list[idx] = item;
      } else {
        list.add(item);
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void initState() {
    connectSocket();
    onPersonalChatList();
    onTeamChatList();
    updateChatList();
    updateTeamChatList();
    setGroupChatList();
    updateGroupChatList();
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
              Gap(Platform.isAndroid
                  ? ScreenUtil().statusBarHeight + 20
                  : ScreenUtil().statusBarHeight + 10),
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
                      ] else if (chatController.selectedChatMethod.value ==
                          1) ...[
                        _personalChatList(),
                      ] else ...[
                        _groupChatList(),
                      ],
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
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 3.3),
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
                  Get.toNamed(
                    AppRouter.personalChat,
                    arguments: {
                      'chatData': chatData,
                    },
                  );
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
                          if (chatController.onlineUsers
                                  .containsKey(chatData.receiverId) ==
                              true)
                            Container(
                              height: 12,
                              width: 12,
                              decoration: BoxDecoration(
                                  color: AppColor.greenColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColor.white)),
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
                              chatData.msgType == 'text'
                                  ? chatData.msg ?? ""
                                  : "Sent a file",
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
                                padding: EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
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
    return chatController.teamChatListData.isEmpty
        ? SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 3.3),
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
            itemCount: chatController.teamChatListData.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final chatData = chatController.teamChatListData[index];
              return GestureDetector(
                onTap: () {
                  // if (AppPref().role == 'coach') {
                  //   if (AppPref().proUser == true) {
                  //     Get.toNamed(
                  //       AppRouter.grpChat,
                  //       arguments: {
                  //         'chatData': chatData,
                  //       },
                  //     );
                  //   } else {
                  //     Get.defaultDialog(
                  //       title: "Subscription Required",
                  //       titleStyle: TextStyle().normal20w500.textColor(AppColor.black12Color),
                  //       middleTextStyle: TextStyle().normal16w400.textColor(AppColor.grey4EColor),
                  //       middleText: "Buy a subscription to\naccess Team Chat.",
                  //       textConfirm: "Buy Now",
                  //       confirmTextColor: AppColor.white,
                  //       buttonColor: AppColor.black12Color,
                  //       cancelTextColor: AppColor.black12Color,
                  //       textCancel: "Cancel",
                  //       onConfirm: () {
                  //         Get.back();
                  //         Get.toNamed(AppRouter.subscription);
                  //       },
                  //     );
                  //   }
                  // } else {
                  Get.toNamed(
                    AppRouter.teamChat,
                    arguments: {
                      'chatData': chatData,
                    },
                  );
                  // }
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
                              finalUrl: (chatData.teamIcon ?? "").isEmpty
                                  ? chatData.teamImage ?? ""
                                  : chatData.teamIcon ?? "",
                            ),
                          ),
                          if (chatController.onlineUsers
                                  .containsKey(chatData.receiverId) ==
                              true)
                            Container(
                              height: 12,
                              width: 12,
                              decoration: BoxDecoration(
                                  color: AppColor.greenColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColor.white)),
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
                                padding: EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
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

  Widget _groupChatList() {
    final groups = chatController.groupChatList;
    return groups.isEmpty
        ? SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 3.3,
                  ),
                  child: Center(
                      child: buildNoData(text: "No Group Conversations")),
                ),
              ],
            ),
          )
        : ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: groups.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final item = groups[index];
              debugPrint("group_image: ${item.groupImage}");
              return GestureDetector(
                onTap: () {
                  Get.toNamed(
                    AppRouter.groupChat,
                    arguments: {
                      'groupData': item,
                    },
                  );
                  // Navigate to your group chat detail when ready
                  // Get.toNamed(AppRouter.groupChat, arguments: {'groupData': item});
                },
                behavior: HitTestBehavior.translucent,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: index == 0
                        ? null
                        : const Border(
                            top: BorderSide(color: AppColor.greyF6Color),
                          ),
                  ),
                  child: Row(
                    children: [
                      ClipOval(
                        child: getImageView(
                          fit: BoxFit.cover,
                          errorWidget:
                              const Icon(Icons.account_circle, size: 40),
                          finalUrl: item.groupImage ?? "",
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.groupName ?? 'Group',
                              style: TextStyle()
                                  .normal16w500
                                  .textColor(AppColor.black12Color),
                            ),
                            Text(
                              (item.msg ?? '').isEmpty
                                  ? 'No messages yet'
                                  : (item.msg!),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle()
                                  .normal14w500
                                  .textColor(AppColor.grey4EColor),
                            ),
                          ],
                        ),
                      ),
                      const Gap(16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item.createdAt == null ||
                                    (item.createdAt?.isEmpty ?? true)
                                ? ''
                                : DateUtilities.getTimeAgo(item.createdAt!),
                            style: TextStyle()
                                .normal14w500
                                .textColor(AppColor.grey4EColor),
                          ),
                          const Gap(4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColor.greyF6Color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${item.unreadCount ?? 0}',
                              style: TextStyle()
                                  .normal14w500
                                  .textColor(AppColor.black),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
