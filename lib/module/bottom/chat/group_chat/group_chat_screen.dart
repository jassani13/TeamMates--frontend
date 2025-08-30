import 'package:base_code/module/bottom/chat/chat_screen.dart';
import 'package:base_code/module/bottom/chat/group_chat/group_chat_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_chat_reactions/flutter_chat_reactions.dart';
import 'package:flutter_chat_reactions/utilities/hero_dialog_route.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  List<types.Message> _messages = [];
  late ChatListData chatData;
  final groupChatController = Get.put(GroupChatController());
  final user = types.User(id: AppPref().userId.toString());
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      chatData = Get.arguments['chatData'];
      _initializeChat();
    }
  }

  void _emitReaction({
    required String messageId,
    required dynamic reaction,
    bool convertToUnicode = false,
  }) {
    final userId = AppPref().userId.toString();

    final reactionData = convertToUnicode ? reaction.runes.map((e) => 'U+${e.toRadixString(16).toUpperCase()}').join(' ') : reaction;

    if (kDebugMode) {
      print('<------------ EMIT - _emitReaction ------------>');
      print([messageId, userId, chatData.isCustomGroup ? chatData.groupId : chatData.teamId, reactionData]);
    }

    if (chatData.isCustomGroup) {
      socket.emit('addCustomGroupReaction', [messageId, userId, chatData.groupId, reactionData]);
    } else {
      socket.emit('addTeamReaction', [messageId, userId, chatData.teamId, reactionData]);
    }
  }

  void _initializeChat() {
    if (chatData.isCustomGroup) {
      // Custom group chat initialization
      socket.emit('getCustomGroupMessageList', [AppPref().userId, chatData.groupId ?? 0]);
      socket.on('setCustomGroupMessageList', _handleMessageList);
      socket.on('setNewCustomGroupMessage', _handleNewMessage);
      socket.on('customGroupReactionUpdated', _handleReactionUpdate);
    } else {
      // Team chat initialization (existing logic)
      socket.emit('getTeamMessageList', [AppPref().userId, chatData.teamId ?? 0]);
      socket.on('setTeamMessageList', _handleMessageList);
      socket.on('setNewTeamMessage', _handleNewMessage);
      socket.on('teamReactionUpdated', _handleReactionUpdate);
    }
  }

  void _handleReactionUpdate(dynamic data) {
    final chatId = data['teamChatId'].toString();
    final newReactions = List<Map<String, dynamic>>.from(data['reactions'] ?? []);
    final index = _messages.indexWhere((msg) => msg.id == chatId);
    if (index != -1) {
      final updatedMessage = _copyMessageWithNewMetadata(
        _messages[index],
        {...?_messages[index].metadata, 'reaction': newReactions},
      );
      setState(() => _messages[index] = updatedMessage);
    }
  }

  types.Message _copyMessageWithNewMetadata(types.Message message, Map<String, dynamic> newMetadata) {
    if (message is types.TextMessage) return message.copyWith(metadata: newMetadata);
    if (message is types.ImageMessage) return message.copyWith(metadata: newMetadata);
    if (message is types.FileMessage) return message.copyWith(metadata: newMetadata);
    throw Exception("Unsupported message type: ${message.runtimeType}");
  }

  void _handleMessageList(dynamic data) {
    final List list = data['resData'];
    if (kDebugMode) print('<--- ON - setTeamMessageList --->\n$list');
    if (mounted) {
      setState(() {
        _messages.clear();
        _messages.addAll(
          list.map((e) {
            if (e['msg_type'] == 'media') {
              return types.ImageMessage(
                createdAt: DateTime.parse(e['created_at']).toUtc().millisecondsSinceEpoch,
                uri: e['msg'],
                author: types.User(
                  id: e['sender_id'].toString(),
                  firstName: e['sender_name'].toString(),
                  imageUrl: e['sender_profile'].toString(),
                ),
                id: e['team_chat_id'].toString(),
                name: 'media',
                size: 0,
                height: 200,
                width: 200,
                metadata: {
                  'msg_type': e['msg_type'],
                  'msg': e['msg'],
                  'reaction': e['reactions'],
                },
              );
            } else if (e['msg_type'] == 'pdf') {
              return types.FileMessage(
                createdAt: DateTime.parse(e['created_at']).toUtc().millisecondsSinceEpoch,
                uri: e['msg'],
                author: types.User(
                  id: e['sender_id'].toString(),
                  firstName: e['sender_name'].toString(),
                  imageUrl: e['sender_profile'].toString(),
                ),
                id: e['team_chat_id'].toString(),
                name: 'pdf',
                size: 0,
                metadata: {
                  'msg_type': e['msg_type'],
                  'msg': e['msg'],
                  'reaction': e['reactions'],
                },
              );
            } else {
              return types.TextMessage(
                createdAt: DateTime.parse(e['created_at']).toUtc().millisecondsSinceEpoch,
                text: e['msg'],
                metadata: {
                  'msg': e['msg'],
                  'msg_type': e['msg_type'],
                  'reaction': e['reactions'],
                },
                author: types.User(
                  id: e['sender_id'].toString(),
                  firstName: e['sender_name'].toString(),
                  imageUrl: e['sender_profile'].toString(),
                ),
                id: e['team_chat_id'].toString(),
              );
            }
          }),
        );
        _messages = _messages.reversed.toList();
      });
    }
  }

  void _handleNewMessage(dynamic data) {
    final msgData = data['resData'];
    if (kDebugMode) print('<--- ON - setNewTeamMessage --->\n$msgData');

    setState(() {
      types.Message newMessage;

      if (msgData['msg_type'] == 'media') {
        newMessage = types.ImageMessage(
          createdAt: DateTime.parse(msgData['created_at']).toUtc().millisecondsSinceEpoch,
          uri: msgData['msg'],
          author: types.User(
            id: msgData['sender_id'].toString(),
            firstName: msgData['sender_name'].toString(),
            imageUrl: msgData['sender_profile'].toString(),
          ),
          id: msgData['team_chat_id'].toString(),
          name: 'media',
          size: 0,
          height: 200,
          width: 200,
          metadata: {
            'msg_type': msgData['msg_type'],
            'msg': msgData['msg'],
            'reaction': msgData['reactions'],
          },
        );
      } else if (msgData['msg_type'] == 'pdf') {
        newMessage = types.FileMessage(
          createdAt: DateTime.parse(msgData['created_at']).toUtc().millisecondsSinceEpoch,
          uri: msgData['msg'],
          author: types.User(
            id: msgData['sender_id'].toString(),
            firstName: msgData['sender_name'].toString(),
            imageUrl: msgData['sender_profile'].toString(),
          ),
          id: msgData['team_chat_id'].toString(),
          name: 'pdf',
          size: 0,
          metadata: {
            'msg_type': msgData['msg_type'],
            'msg': msgData['msg'],
            'reaction': msgData['reactions'],
          },
        );
      } else {
        newMessage = types.TextMessage(
          createdAt: DateTime.parse(msgData['created_at']).toUtc().millisecondsSinceEpoch,
          text: msgData['msg'],
          author: types.User(
            id: msgData['sender_id'].toString(),
            firstName: msgData['sender_name'].toString(),
            imageUrl: msgData['sender_profile'].toString(),
          ),
          id: msgData['team_chat_id'].toString(),
          metadata: {
            'msg': msgData['msg'],
            'msg_type': msgData['msg_type'],
            'reaction': msgData['reactions'],
          },
        );
      }

      _messages.insert(0, newMessage);
    });
  }

  void _sendMessage(types.PartialText message) {
    if (chatData.isCustomGroup) {
      socket.emit('sendCustomGroupMessage', [
        message.text,
        AppPref().userId.toString(),
        chatData.groupId,
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc()),
        'text',
      ]);
    } else {
      socket.emit('sendTeamMessage', [
        message.text,
        AppPref().userId.toString(),
        chatData.teamId,
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc()),
        'text',
      ]);
    }
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Gap(4),
            TextButton(
              onPressed: () {
                Get.back();
                _handleImageSelection();
              },
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'Photo',
                  style: TextStyle().normal14w500.textColor(AppColor.black12Color),
                ),
              ),
            ),
            Gap(4),
            TextButton(
              onPressed: () {
                Get.back();
                _handleFileSelection();
              },
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'File',
                  style: TextStyle().normal14w500.textColor(AppColor.black12Color),
                ),
              ),
            ),
            Gap(4),
          ],
        ),
      ),
    );
  }

  void _handleFileSelection() async {
    try {
      setState(() => isLoading = true);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final url = await groupChatController.setMediaChatApiCall(result: result.files[0]);
        if (url.isNotEmpty) {
          if (chatData.isCustomGroup) {
            socket.emit('sendCustomGroupMessage', [
              url,
              AppPref().userId.toString(),
              chatData.groupId,
              DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc()),
              'pdf',
            ]);
          } else {
            socket.emit('sendTeamMessage', [
              url,
              AppPref().userId.toString(),
              chatData.teamId,
              DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc()),
              'pdf',
            ]);
          }
        }
      }
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _handleImageSelection() async {
    try {
      setState(() => isLoading = true);

      final result = await ImagePicker().pickImage(
        imageQuality: 70,
        maxWidth: 1440,
        source: ImageSource.gallery,
      );

      if (result != null) {
        final url = await groupChatController.setMediaChatApiCall(result: result);
        if (url.isNotEmpty) {
          if (chatData.isCustomGroup) {
            socket.emit(
              'sendCustomGroupMessage',
              [
                url,
                AppPref().userId.toString(),
                chatData.groupId,
                DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc()),
                'media',
              ],
            );
          } else {
            socket.emit(
              'sendTeamMessage',
              [
                url,
                AppPref().userId.toString(),
                chatData.teamId,
                DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc()),
                'media',
              ],
            );
          }
        }
      }
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void emitTeamChatList() {
    if (kDebugMode) {
      print('<------------ EMIT - getTeamChatList ------------>');
    }
    socket.emit('getTeamChatList', AppPref().userId);
  }

  @override
  void dispose() {
    if (chatData.isCustomGroup) {
      socket.off('setCustomGroupMessageList', _handleMessageList);
      socket.off('setNewCustomGroupMessage', _handleNewMessage);
      socket.off('customGroupReactionUpdated', _handleReactionUpdate);
      emitCustomGroupChatList();
    } else {
      socket.off('setTeamMessageList', _handleMessageList);
      socket.off('setNewTeamMessage', _handleNewMessage);
      socket.off('teamReactionUpdated', _handleReactionUpdate);
      emitTeamChatList();
    }
    super.dispose();
  }
  
  void emitCustomGroupChatList() {
    if (kDebugMode) {
      print('<------------ EMIT - getCustomGroupChatList ------------>');
    }
    socket.emit('getCustomGroupChatList', AppPref().userId);
  }
  
  void _showGroupInfo() {
    Get.toNamed(AppRouter.groupManagement, arguments: {'chatData': chatData});
  }
  
  void _showGroupSettings() {
    Get.toNamed(AppRouter.groupManagement, arguments: {'chatData': chatData});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyboard(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(chatData.displayName),
          actions: chatData.isCustomGroup ? [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'info') {
                  _showGroupInfo();
                } else if (value == 'settings') {
                  _showGroupSettings();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'info',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20),
                      Gap(8),
                      Text('Group Info'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, size: 20),
                      Gap(8),
                      Text('Group Settings'),
                    ],
                  ),
                ),
              ],
            ),
          ] : null,
        ),
        body: Stack(
          children: [
            Chat(
              dateIsUtc: true,
              messages: _messages,
              onSendPressed: _sendMessage,
              onMessageLongPress: (v, message) {
                Navigator.of(context).push(
                  HeroDialogRoute(
                    builder: (context) {
                      return ReactionsDialogWidget(
                        reactions: ['👍', '❤️', '😂', '😮', '😢', '👏'],
                        menuItems: [],
                        id: message.id,
                        messageWidget: const SizedBox.shrink(),
                        onReactionTap: (reaction) {
                          _emitReaction(messageId: message.id, reaction: reaction, convertToUnicode: true);
                        },
                        onContextMenuTap: (menuItem) {},
                      );
                    },
                  ),
                );
              },
              user: user,
              onAttachmentPressed: _handleAttachmentPressed,
              customDateHeaderText: (val) {
                return DateFormat("dd EEE, yyyy hh:mm").format(val);
              },
              bubbleBuilder: (Widget child, {required types.Message message, required bool nextMessageInGroup}) {
                bool isSentByMe = message.author.id == user.id;

                return _buildMessage(message, isSentByMe);
              },
            ),
            if (isLoading)
              Container(
                color: Colors.white10,
                child: Center(
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppColor.grey50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColor.black12Color,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Hero _buildMessage(types.Message message, bool isSentByMe) {
    return Hero(
      tag: message.id,
      child: _buildReaction(isSentByMe, message),
    );
  }

  Align _buildReaction(
    bool isSentByMe,
    types.Message message,
  ) {
    List reactions = message.metadata?['reaction'] ?? [];
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isSentByMe)
            ClipOval(
              child: getImageView(
                height: 30,
                width: 30,
                finalUrl: message.author.imageUrl ?? "",
                fit: BoxFit.cover,
                errorWidget: Icon(
                  Icons.account_circle,
                  size: 30,
                ),
              ),
            ),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isSentByMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, right: 6, left: 6),
                    child: Text(
                      message.author.firstName ?? "",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (message.metadata?['msg_type'] == 'pdf') ...[
                      GestureDetector(
                        onTap: () => openPdf(
                          message.metadata?['msg'],
                        ),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 200,
                              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              decoration: BoxDecoration(
                                color: AppColor.greyF6Color,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Document",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppColor.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildChatReaction(reactions, message)
                          ],
                        ),
                      ),
                    ] else if (message.metadata?['msg_type'] == 'media') ...[
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: getImageView(
                                finalUrl: message.metadata?['msg'],
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          _buildChatReaction(reactions, message)
                        ],
                      )
                    ] else ...[
                      Flexible(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: AppColor.greyF6Color,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(Get.context!).size.width * 0.7,
                                ),
                                child: Column(
                                  crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.end,
                                  children: [
                                    DefaultTextStyle(
                                      style: TextStyle().normal16w400.textColor(
                                            AppColor.black12Color,
                                          ),
                                      child: Text(
                                        message.metadata?['msg'] ?? "",
                                        textAlign: TextAlign.start,
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            _buildChatReaction(reactions, message)
                          ],
                        ),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Visibility _buildChatReaction(List<dynamic> reactions, types.Message message) {
    return Visibility(
      visible: reactions.isNotEmpty,
      child: GestureDetector(
        onTap: () => _showReactionDetailsSheet(
          oppositeUserName: '${message.author.firstName ?? ""} ${message.author.lastName ?? ""}',
          reactions: reactions,
          currentUserId: AppPref().userId.toString(),
          messageId: message.id,
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: 6.0),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4.0,
            children: () {
              final maxVisible = 2;
              final displayedReactions = reactions.take(maxVisible).toList();
              final remainingCount = reactions.length - maxVisible;

              List<Widget> children = displayedReactions.map((reaction) {
                final reactionString = reaction['reaction'].toString();
                final codePoints = reactionString
                    .split(' ')
                    .map((e) {
                      try {
                        return int.parse(e.replaceFirst('U+', ''), radix: 16);
                      } catch (_) {
                        return null;
                      }
                    })
                    .where((e) => e != null)
                    .cast<int>()
                    .toList();

                return Text(
                  String.fromCharCodes(codePoints),
                  style: const TextStyle(fontSize: 12),
                );
              }).toList();

              if (remainingCount > 0) {
                children.add(
                  Text(
                    '+$remainingCount',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColor.black12Color,
                    ),
                  ),
                );
              }

              return children;
            }(),
          ),
        ),
      ),
    );
  }

  void _showReactionDetailsSheet({
    required List reactions,
    required String currentUserId,
    required String messageId,
    required String oppositeUserName,
  }) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Reactions",
              style: TextStyle().normal16w400.textColor(AppColor.black),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              itemCount: reactions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final reaction = reactions[index];
                final codePoints = reaction['reaction'].toString().split(' ').map((e) => int.parse(e.replaceFirst('U+', ''), radix: 16)).toList();
                final emoji = String.fromCharCodes(codePoints);
                final userId = reaction['user_id'].toString();
                final isMine = userId == currentUserId;
                final userName = isMine ? "You" : oppositeUserName;

                return ListTile(
                  leading: Text(emoji, style: TextStyle(fontSize: 20)),
                  title: Text(
                    userName,
                    style: TextStyle().normal16w400.textColor(AppColor.black12Color),
                  ),
                  trailing: isMine
                      ? TextButton(
                          onPressed: () {
                            _emitReaction(messageId: messageId, reaction: reaction['reaction'], convertToUnicode: false);
                            Get.back();
                          },
                          child: Text(
                            "Remove",
                            style: TextStyle().normal16w400.textColor(AppColor.red10Color),
                          ),
                        )
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
