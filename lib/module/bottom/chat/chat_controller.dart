import 'package:base_code/model/chat_list_model.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:path/path.dart';

import '../../../data/network/api_client.dart';
import '../../../data/network/dio_client.dart';
import '../../../data/network/end_point.dart';
import '../../../model/conversation_item.dart';
import '../../../package/screen_packages.dart';

class ChatScreenController extends GetxController {
  List chatList = [
    "Group",
    "Individual Chats",
  ];
  RxInt selectedChatMethod = 0.obs;
  AutoScrollController controller = AutoScrollController();
  List<ChatListData> chatListData = <ChatListData>[];
  List<ChatListData> grpChatListData = <ChatListData>[];
  final RxList<ConversationItem> conversations = <ConversationItem>[].obs;

  //final RxInt selectedTab = 0.obs; // 0 = all/team, 1 = personal maybe adapt
  final Map<String, int> unreadByConversation = {};
  Map<dynamic, dynamic> onlineUsers = {};

  void setConversations(List<dynamic> raw) {
    final list = raw.map((e) => ConversationItem.fromJson(e)).toList();
    conversations.assignAll(list);
  }

  List<ConversationItem> get filtered {
    if (selectedChatMethod.value == 0) {
      return conversations.where((c) => c.type != 'personal').toList();
    } else {
      return conversations.where((c) => c.type == 'personal').toList();
    }
  }

  void updateOrInsert(ConversationItem item) {
    final idx = conversations
        .indexWhere((c) => c.conversationId == item.conversationId);
    if (idx >= 0) {
      conversations[idx] = item;
    } else {
      conversations.insert(0, item);
    }
  }

  void markConversationRead(String conversationId) {
    final idx =
        conversations.indexWhere((c) => c.conversationId == conversationId);
    if (idx >= 0) {
      final c = conversations[idx];
      conversations[idx] = ConversationItem(
          conversationId: c.conversationId,
          type: c.type,
          title: c.title,
          image: c.image,
          lastMessage: c.lastMessage,
          lastMessageFileUrl: c.lastMessageFileUrl,
          msgType: c.msgType,
          createdAt: c.createdAt,
          unreadCount: 0,
          lastReadMessageId: null);
    }
  }

  void patchConversation({
    required String convId,
    required String lastMessage,
    required String msgType,
    required String fileUrl,
    String? type,
    String? ownerId,
    String? title,
    String? image,
    String? createdAt,
    String? lastReadMessageId,
    int? unreadCount,
  }) {
    final idx = conversations.indexWhere((c) => c.conversationId == convId);
    DateTime? parsedCreatedAt;
    if (createdAt != null && createdAt.isNotEmpty) {
      parsedCreatedAt = DateTime.tryParse(createdAt) ?? parsedCreatedAt;
    }
    final bool isText = (msgType == 'text');
    final String normalizedLastMessage = isText ? (lastMessage) : msgType;
    final String normalizedFileUrl =
        isText ? '' : (fileUrl.isNotEmpty ? fileUrl : '');

    if (idx == -1) {
      final item = ConversationItem(
        conversationId: convId,
        type: type ?? 'personal',
        title: title ?? '',
        image: image ?? '',
        lastMessage: normalizedLastMessage,
        lastMessageFileUrl: normalizedFileUrl,
        msgType: msgType,
        createdAt: parsedCreatedAt ?? DateTime.now(),
        unreadCount: unreadCount ?? 0,
        ownerId: ownerId,
        lastReadMessageId: lastReadMessageId
      );
      conversations.add(item);
    } else {
      final old = conversations[idx];
      final updated = ConversationItem(
        conversationId: old.conversationId,
        type: old.type,
        title: title ?? old.title,
        image: image ?? old.image,
        lastMessage: normalizedLastMessage,
        lastMessageFileUrl: normalizedFileUrl,
        msgType: msgType,
        createdAt: parsedCreatedAt ?? old.createdAt,
        unreadCount: unreadCount ?? old.unreadCount,
        lastReadMessageId: lastReadMessageId??old.lastReadMessageId
      );
      conversations[idx] = updated;
    }

    // Move to top
    conversations.sort((a, b) {
      final at = a.createdAt?.millisecondsSinceEpoch ?? 0;
      final bt = b.createdAt?.millisecondsSinceEpoch ?? 0;
      return bt.compareTo(at);
    });
  }

  Future<String> setMediaChatApiCall({
    required result,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'media': [
          await MultipartFile.fromFile(
            result?.path ?? "",
            filename: basename(result?.path ?? ""),
          ),
        ]
      });
      var res = await callApi(
        dio.post(
          ApiEndPoint.setChatMedia,
          data: formData,
        ),
        false,
      );
      if (res?.statusCode == 200) {
        return res?.data["data"]["media_name"];
      }
      return "";
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return "";
    } finally {}
  }
}
