import 'package:base_code/components/socket_service.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../chat_screen.dart';

class ThreadController extends GetxController {
  final int parentMessageId;
  final types.Message parentMessage;
  final int initialRepliesCount;

  final RxList<types.Message> replies = <types.Message>[].obs;
  final RxBool loading = false.obs;
  final RxBool hasMore = false.obs;
  final RxInt totalReplies = 0.obs;
  final RxInt currentPage = 1.obs;

  ThreadController({
    required this.parentMessageId,
    required this.parentMessage,
    this.initialRepliesCount = 0,
  });

  @override
  void onInit() {
    super.onInit();
    totalReplies.value = initialRepliesCount;
    _setupSocketListeners();
    loadThreadReplies();
  }

  @override
  void onClose() {
    _removeSocketListeners();
    super.onClose();
  }

  void _setupSocketListeners() {
    // Listen for thread replies response
    socket.on('thread_replies', _handleThreadReplies);

    // Listen for new thread replies from other users
    socket.on('new_thread_reply', _handleNewThreadReply);

    // Listen for confirmation of sent reply
    socket.on('thread_reply_sent', _handleReplySent);
  }

  void _removeSocketListeners() {
    socket.off('thread_replies');
    socket.off('new_thread_reply');
    socket.off('thread_reply_sent');
  }

  void _handleThreadReplies(dynamic data) {
    if (data == null) return;

    try {
      final List repliesList = data['replies'] ?? [];
      totalReplies.value = data['total_replies'] ?? 0;
      hasMore.value = data['has_more'] ?? false;

      final newReplies = repliesList
          .whereType<Map>()
          .map((e) => _buildThreadMessage(Map<String, dynamic>.from(e)))
          .toList();

      if (currentPage.value == 1) {
        replies.value = newReplies;
      } else {
        replies.addAll(newReplies);
      }

      loading.value = false;
    } catch (e) {
      print('Error parsing thread replies: $e');
      loading.value = false;
    }
  }

  void _handleNewThreadReply(dynamic data) {
    if (data == null) return;

    try {
      final parentId =
          int.tryParse(data['parent_message_id']?.toString() ?? '');
      if (parentId != parentMessageId) return; // Not for this thread

      final messageData = data['message'];
      if (messageData == null) return;

      final newReply =
          _buildThreadMessage(Map<String, dynamic>.from(messageData as Map));

      replies.insert(0, newReply);
      totalReplies.value =
          data['parent_replies_count'] ?? (totalReplies.value + 1);
    } catch (e) {
      debugPrint('Error handling new thread reply: $e');
    }
  }

  void _handleReplySent(dynamic data) {
    // Reply confirmation already handled by _handleNewThreadReply
    debugPrint('Thread reply sent successfully');
  }

  void loadThreadReplies({int page = 1}) {
    if (loading.value) return;

    loading.value = true;
    currentPage.value = page;

    socket.emit('get_thread_replies', {
      'parent_message_id': parentMessageId,
      'page': page,
      'per_page': 20,
    });
  }

  void loadMoreReplies() {
    if (!hasMore.value || loading.value) return;
    loadThreadReplies(page: currentPage.value + 1);
  }

  void sendThreadReply(types.PartialText message) {
    final currentUser = AppPref().userModel;
    if (currentUser == null) return;

    socket.emit('send_thread_reply', {
      'parent_message_id': parentMessageId,
      'message': message.text,
      'msg_type': 'text',
    });

    // Optimistically add to UI
    // final optimisticReply = types.TextMessage(
    //   author: types.User(
    //     id: currentUser.userId.toString(),
    //     firstName: currentUser.firstName,
    //     lastName: currentUser.lastName,
    //     imageUrl: currentUser.profile,
    //   ),
    //   createdAt: DateTime.now().millisecondsSinceEpoch,
    //   id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
    //   text: message.text,
    // );

    //replies.insert(0, optimisticReply);
  }

  void sendImageReply(String imageUrl) {
    final currentUser = AppPref().userModel;
    if (currentUser == null) return;

    socket.emit('send_thread_reply', {
      'parent_message_id': parentMessageId,
      'message': imageUrl,
      'msg_type': 'image',
    });

    // Optimistically add to UI
    final optimisticReply = types.ImageMessage(
      author: types.User(
        id: currentUser.userId.toString(),
        firstName: currentUser.firstName,
        lastName: currentUser.lastName,
        imageUrl: currentUser.profile,
      ),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      uri: imageUrl,
      name: 'image',
      size: 0,
      height: 200,
      width: 200,
    );

    replies.insert(0, optimisticReply);
  }

  void sendFileReply(String fileUrl, String fileName) {
    final currentUser = AppPref().userModel;
    if (currentUser == null) return;

    socket.emit('send_thread_reply', {
      'parent_message_id': parentMessageId,
      'message': fileName,
      'msg_type': 'file',
      'file_url': fileUrl,
    });

    // Optimistically add to UI
    final optimisticReply = types.FileMessage(
      author: types.User(
        id: currentUser.userId.toString(),
        firstName: currentUser.firstName,
        lastName: currentUser.lastName,
        imageUrl: currentUser.profile,
      ),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      uri: fileUrl,
      name: fileName,
      size: 0,
    );

    replies.insert(0, optimisticReply);
  }

  types.Message _buildThreadMessage(Map<String, dynamic> payload) {
    final rawType = (payload['msg_type'] ?? 'text').toString().toLowerCase();
    final createdAtStr = payload['created_at']?.toString();
    final createdAt = createdAtStr != null
        ? DateTime.tryParse(createdAtStr)?.toUtc().millisecondsSinceEpoch ??
            DateTime.now().millisecondsSinceEpoch
        : DateTime.now().millisecondsSinceEpoch;
    final author = types.User(
      id: payload['sender_id']?.toString() ?? '',
      firstName: payload['sender_name'],
      lastName: payload['sender_last_name'],
      imageUrl: payload['sender_profile'],
    );
    final id = payload['message_id']?.toString() ??
        'temp_${DateTime.now().millisecondsSinceEpoch}';
    final resource = payload['file_url'] ?? payload['msg'] ?? '';

    if (rawType == 'image' || rawType == 'media') {
      return types.ImageMessage(
        createdAt: createdAt,
        uri: resource,
        author: author,
        id: id,
        size: 0,
        name: '',
        height: 200,
        width: 200,
      );
    }

    if (rawType == 'file' || rawType == 'pdf') {
      return types.FileMessage(
        createdAt: createdAt,
        uri: resource,
        author: author,
        id: id,
        name: payload['msg']?.toString() ?? 'file',
        size: 0,
      );
    }

    return types.TextMessage(
      createdAt: createdAt,
      text: payload['msg']?.toString() ?? '',
      author: author,
      id: id,
    );
  }
}
