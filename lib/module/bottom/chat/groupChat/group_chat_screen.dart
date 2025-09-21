import 'package:base_code/main.dart';
import 'package:base_code/model/group_chat_model.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../chat_screen.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final user = types.User(id: AppPref().userId.toString());
  late GroupChatModel group;
  List<types.Message> _messages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      group = Get.arguments['groupData'] as GroupChatModel;
      _initializeChat();
    }
  }

  void _initializeChat() {
    // Load history
    socket
        .emit('getGroupMessageList', [AppPref().userId, group.groupId ?? '0']);

    // History listener
    socket.on('setGroupMessageList', _handleMessageList);

    // Live new messages
    socket.on('setNewGroupMessage', _handleNewMessage);
  }

  @override
  void dispose() {
    socket.off('setGroupMessageList', _handleMessageList);
    socket.off('setNewGroupMessage', _handleNewMessage);
    // Refresh list on exit (optional)
    socket.emit('getGroupChatList', AppPref().userId);
    super.dispose();
  }

  void _handleMessageList(dynamic data) {
    final list = (data['resData'] as List?) ?? [];
    if (!mounted) return;
    setState(() {
      _messages
        ..clear()
        ..addAll(list.map<types.Message>((e) {
          final type = (e['msg_type'] ?? 'text').toString();
          final createdAt = e['created_at'] != null
              ? DateTime.parse(e['created_at']).toUtc().millisecondsSinceEpoch
              : DateTime.now().toUtc().millisecondsSinceEpoch;

          if (type == 'media') {
            return types.ImageMessage(
              id: (e['group_chat_id'] ?? '').toString(),
              uri: (e['msg'] ?? '').toString(),
              createdAt: createdAt,
              height: 200,
              width: 200,
              size: 0,
              author: types.User(
                id: (e['sender_id'] ?? '').toString(),
                firstName: (e['sender_name'] ?? '').toString(),
                imageUrl: (e['sender_profile'] ?? '').toString(),
              ),
              metadata: {
                'msg_type': type,
                'msg': e['msg'],
                'reactions': e['reactions'],
              },
              name: 'name_NA',
            );
          } else if (type == 'pdf') {
            return types.FileMessage(
              id: (e['group_chat_id'] ?? '').toString(),
              uri: (e['msg'] ?? '').toString(),
              name: 'pdf',
              size: 0,
              createdAt: createdAt,
              author: types.User(
                id: (e['sender_id'] ?? '').toString(),
                firstName: (e['sender_name'] ?? '').toString(),
                imageUrl: (e['sender_profile'] ?? '').toString(),
              ),
              metadata: {
                'msg_type': type,
                'msg': e['msg'],
                'reactions': e['reactions'],
              },
            );
          } else {
            return types.TextMessage(
              id: (e['group_chat_id'] ?? '').toString(),
              text: (e['msg'] ?? '').toString(),
              createdAt: createdAt,
              author: types.User(
                id: (e['sender_id'] ?? '').toString(),
                firstName: (e['sender_name'] ?? '').toString(),
                imageUrl: (e['sender_profile'] ?? '').toString(),
              ),
              metadata: {
                'msg_type': type,
                'msg': e['msg'],
                'reactions': e['reactions'],
              },
            );
          }
        }));
      _messages = _messages.reversed.toList();
    });
  }

  void _handleNewMessage(dynamic data) {
    debugPrint("_handleNewMessage:$data");
    final e = Map<String, dynamic>.from(data['resData'] ?? {});
    // Only insert if belongs to this group
    if ((e['group_id'] ?? '').toString() != (group.groupId ?? '')) return;
    debugPrint("_handleNewMessage:belongs to this group");

    final type = (e['msg_type'] ?? 'text').toString();
    final createdAt = e['created_at'] != null
        ? DateTime.parse(e['created_at']).toUtc().millisecondsSinceEpoch
        : DateTime.now().toUtc().millisecondsSinceEpoch;

    types.Message newMessage;
    if (type == 'media') {
      newMessage = types.ImageMessage(
        id: (e['group_chat_id'] ?? '').toString(),
        uri: (e['msg'] ?? '').toString(),
        createdAt: createdAt,
        author: types.User(
          id: (e['sender_id'] ?? '').toString(),
          firstName: (e['sender_name'] ?? '').toString(),
          imageUrl: (e['sender_profile'] ?? '').toString(),
        ),
        height: 200,
        width: 200,
        size: 0,
        metadata: {
          'msg_type': type,
          'msg': e['msg'],
          'reactions': e['reactions'],
        },
        name: 'name_NA',
      );
    } else if (type == 'pdf') {
      newMessage = types.FileMessage(
        id: (e['group_chat_id'] ?? '').toString(),
        uri: (e['msg'] ?? '').toString(),
        createdAt: createdAt,
        author: types.User(
          id: (e['sender_id'] ?? '').toString(),
          firstName: (e['sender_name'] ?? '').toString(),
          imageUrl: (e['sender_profile'] ?? '').toString(),
        ),
        name: 'pdf',
        size: 0,
        metadata: {
          'msg_type': type,
          'msg': e['msg'],
          'reactions': e['reactions'],
        },
      );
    } else {
      newMessage = types.TextMessage(
        id: (e['group_chat_id'] ?? '').toString(),
        text: (e['msg'] ?? '').toString(),
        createdAt: createdAt,
        author: types.User(
          id: (e['sender_id'] ?? '').toString(),
          firstName: (e['sender_name'] ?? '').toString(),
          imageUrl: (e['sender_profile'] ?? '').toString(),
        ),
        metadata: {
          'msg_type': type,
          'msg': e['msg'],
          'reactions': e['reactions'],
        },
      );
    }

    debugPrint("_messages:${_messages.length}");
    setState(() {
      _messages.insert(0, newMessage);
    });
    debugPrint("_messages:${_messages.length}");
  }

  void _sendMessage(types.PartialText message) {
    final nowUtc =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc());
    socket.emit('sendGroupMessage', [
      message.text,
      AppPref().userId.toString(),
      group.groupId,
      nowUtc,
      'text',
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyboard(),
      child: Scaffold(
        appBar: AppBar(title: Text(group.groupName ?? 'Group')),
        body: Stack(
          children: [
            Chat(
              dateIsUtc: true,
              messages: _messages,
              onSendPressed: _sendMessage,
              user: user,
              customDateHeaderText: (val) =>
                  DateFormat('dd EEE, yyyy hh:mm').format(val),
              bubbleBuilder: (Widget child,
                  {required types.Message message,
                  required bool nextMessageInGroup}) {
                final isSentByMe = message.author.id == user.id;
                return _buildBubble(message, isSentByMe);
              },
            ),
            if (isLoading)
              Center(
                  child:
                      CircularProgressIndicator(color: AppColor.black12Color)),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(types.Message message, bool isMine) {
    final type = message.metadata?['msg_type'];
    final reactions = message.metadata?['reactions'] ?? [];
    Widget content;

    if (type == 'pdf') {
      content = GestureDetector(
        onTap: () => openPdf(message.metadata?['msg']),
        child: Container(
          width: 200,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
              color: AppColor.greyF6Color,
              borderRadius: BorderRadius.circular(10)),
          child: Row(children: const [
            Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
            SizedBox(width: 10),
            Expanded(
                child: Text('Document',
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
        ),
      );
    } else if (type == 'media') {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: getImageView(
          finalUrl: message.metadata?['msg'],
          height: 200,
          width: 200,
          fit: BoxFit.cover,
        ),
      );
    } else {
      content = Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
            color: AppColor.greyF6Color,
            borderRadius: BorderRadius.circular(10)),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(Get.context!).size.width * 0.7),
        child: Text(message.metadata?['msg'] ?? '',style: TextStyle(color: AppColor.black12Color),),
      );
    }

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            content,
            // reactions UI placeholder; you can mirror your team/personal version here
            if ((reactions as List).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: Wrap(
                    children: (reactions as List).map<Widget>((r) {
                  final cp = r['reaction']
                      .toString()
                      .split(' ')
                      .map(
                          (e) => int.parse(e.replaceFirst('U+', ''), radix: 16))
                      .toList();
                  return Text(String.fromCharCodes(cp),
                      style: const TextStyle(fontSize: 12));
                }).toList()),
              ),
          ],
        ),
      ),
    );
  }
}
