import 'package:base_code/model/chat_list_model.dart';
import 'package:base_code/module/bottom/chat/chat_screen.dart';
import 'package:base_code/module/bottom/chat/personalChat/personal_chat_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';

class PersonalChatScreen extends StatefulWidget {
  const PersonalChatScreen({super.key});

  @override
  State<PersonalChatScreen> createState() => _PersonalChatScreenState();
}

class _PersonalChatScreenState extends State<PersonalChatScreen> {
  List<types.Message> _messages = [];
  late ChatListData chatData;
  final personalChatController = Get.put(PersonalChatController());
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

  void _initializeChat() {
    socket.emit('getMessageList', [AppPref().userId, chatData.otherId ?? 0]);
    socket.on('setMessageList', _handleMessageList);
    socket.on('setNewMessage', _handleNewMessage);
  }

  void emitPersonalChatList() {
    if (kDebugMode) {
      print('<------------ EMIT - getChatUserList ------------>');
    }
    socket.emit('getChatUserList', AppPref().userId);
  }

  void _handleMessageList(dynamic data) {
    final List list = data['resData'];
    if (kDebugMode) print('<--- ON - setMessageList --->\n$list');
    setState(() {
      _messages.clear();
      _messages.addAll(
        list.map((e) {
          if (e['msg_type'] == 'media') {
            return types.ImageMessage(
              createdAt: DateTime.parse(e['created_at']).toUtc().millisecondsSinceEpoch,
              uri: e['msg'],
              author: types.User(id: e['sender_id'].toString()),
              id: e['chat_id'],
              name: 'media',
              size: 0,
              height: 200,
              width: 200,
              metadata: {
                'msg_type': e['msg_type'],
                'msg': e['msg'],
              },
            );
          } else if (e['msg_type'] == 'pdf') {
            return types.FileMessage(
              createdAt: DateTime.parse(e['created_at']).toUtc().millisecondsSinceEpoch,
              uri: e['msg'],
              name: 'pdf',
              author: types.User(id: e['sender_id'].toString()),
              id: e['chat_id'],
              size: 0,
              metadata: {
                'msg_type': e['msg_type'],
                'msg': e['msg'],
              },
            );
          } else {
            return types.TextMessage(
              createdAt: DateTime.parse(e['created_at']).toUtc().millisecondsSinceEpoch,
              text: e['msg'],
              metadata: {
                'msg': e['msg'],
                'msg_type': e['msg_type'],
              },
              author: types.User(id: e['sender_id'].toString()),
              id: e['chat_id'],
            );
          }
        }),
      );
      _messages = _messages.reversed.toList();
    });
  }

  void _handleNewMessage(dynamic data) {
    final msgData = data['resData'];
    if (kDebugMode) print('<--- ON - setNewMessage --->\n$msgData');

    setState(() {
      types.Message newMessage;

      if (msgData['msg_type'] == 'media') {
        newMessage = types.ImageMessage(
          createdAt: DateTime.parse(msgData['created_at']).toUtc().millisecondsSinceEpoch,
          uri: msgData['msg'],
          author: types.User(id: msgData['sender_id'].toString()),
          id: msgData['chat_id'],
          name: 'media',
          size: 0,
          height: 200,
          width: 200,
          metadata: {
            'msg_type': msgData['msg_type'],
            'msg': msgData['msg'],
          },
        );
      } else if (msgData['msg_type'] == 'pdf') {
        newMessage = types.FileMessage(
          createdAt: DateTime.parse(msgData['created_at']).toUtc().millisecondsSinceEpoch,
          uri: msgData['msg'],
          author: types.User(id: msgData['sender_id'].toString()),
          id: msgData['chat_id'],
          name: 'pdf',
          size: 0,
          metadata: {
            'msg_type': msgData['msg_type'],
            'msg': msgData['msg'],
          },
        );
      } else {
        newMessage = types.TextMessage(
          createdAt: DateTime.parse(msgData['created_at']).toUtc().millisecondsSinceEpoch,
          text: msgData['msg'],
          metadata: {
            'msg': msgData['msg'],
            'msg_type': msgData['msg_type'],
          },
          author: types.User(id: msgData['sender_id'].toString()),
          id: msgData['chat_id'],
        );
      }

      _messages.insert(0, newMessage);
    });
  }

  void _sendMessage(types.PartialText message) {
    final newMessage = types.TextMessage(
      author: user,
      id: Uuid().v4(),
      text: message.text,
      metadata: {
        'msg': message.text,
        'msg_type': 'text',
      },
      createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
    );
    _addMessage(newMessage);

    socket.emit('sendMessage', [
      message.text,
      AppPref().userId.toString(),
      chatData.otherId,
      DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc()),
      'text',
    ]);
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
        final url = await personalChatController.setMediaChatApiCall(result: result.files[0]);
        if (url.isNotEmpty) {
          final message = types.FileMessage(
            author: user,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: const Uuid().v4(),
            name: result.files.single.name,
            size: result.files.single.size,
            uri: result.files.single.path!,
            metadata: {
              'msg_type': 'pdf',
              'msg': 'http://3.84.37.74/TeamMates/public/chat/$url',
            },
          );
          _addMessage(message);
          socket.emit('sendMessage', [
            url,
            AppPref().userId.toString(),
            chatData.otherId,
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc()),
            'pdf',
          ]);
        }
      }
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
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
        final bytes = await result.readAsBytes();
        final image = await decodeImageFromList(bytes);

        final url = await personalChatController.setMediaChatApiCall(result: result);
        if (url.isNotEmpty) {
          final message = types.ImageMessage(
            author: user,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            height: image.height.toDouble(),
            id: const Uuid().v4(),
            name: result.name,
            size: bytes.length,
            uri: result.path,
            width: image.width.toDouble(),
            metadata: {
              'msg_type': 'media',
              'msg': 'http://3.84.37.74/TeamMates/public/chat/$url',
            },
          );
          _addMessage(message);
          socket.emit(
            'sendMessage',
            [
              url,
              AppPref().userId.toString(),
              chatData.otherId,
              DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc()),
              'media',
            ],
          );
        }
      }
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    socket.off('setMessageList', _handleMessageList);
    socket.off('setNewMessage', _handleNewMessage);
    emitPersonalChatList();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyboard(),
      child: Scaffold(
        appBar: AppBar(title: Text('${chatData.firstName} ${chatData.lastName}')),
        body: Stack(
          children: [
            Chat(
              dateIsUtc: true,
              messages: _messages,
              onSendPressed: _sendMessage,
              user: user,
              onAttachmentPressed: _handleAttachmentPressed,
              customDateHeaderText: (val) {
                return DateFormat("dd EEE, yyyy hh:mm").format(val);
              },
              bubbleBuilder: (Widget child, {required types.Message message, required bool nextMessageInGroup}) {
                bool isSentByMe = message.author.id == user.id;
                return Align(
                  alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.metadata?['msg_type'] == 'pdf') ...[
                        GestureDetector(
                          onTap: () => openPdf(message.metadata?['msg']),
                          child: Container(
                            width: 200,
                            margin: EdgeInsets.symmetric(vertical: 6),
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
                        ),
                      ] else if (message.metadata?['msg_type'] == 'media') ...[
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: getImageView(finalUrl: message.metadata?['msg'], height: 200, width: 200, fit: BoxFit.cover),
                          ),
                        )
                      ] else ...[
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                ],
                              ),
                            ],
                          ),
                        ),
                      ]
                    ],
                  ),
                );
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
}
