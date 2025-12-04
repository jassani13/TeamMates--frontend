import 'dart:convert';

import 'package:base_code/components/socket_service.dart';
import 'package:base_code/data/network/dio_client.dart';
import 'package:base_code/module/bottom/chat/chat_controller.dart';
import 'package:base_code/package/config_packages.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../../../../utils/app_toast.dart';
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
  final RxBool sendingAttachment = false.obs;

  final ChatScreenController chatScreenController =
      Get.put(ChatScreenController());
  final ImagePicker _imagePicker = ImagePicker();

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

      final normalized = newReplies.toList();

      if (currentPage.value == 1) {
        replies.value = normalized;
      } else {
        replies.insertAll(0, normalized);
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
    final text = message.text.trim();
    if (text.isEmpty) return;

    socket.emit('send_thread_reply', {
      'parent_message_id': parentMessageId,
      'message': text,
      'msg_type': 'text',
    });

    totalReplies.value = totalReplies.value + 1;
  }

  void sendImageReply({required String fileUrl, required String fileName}) {
    final currentUser = AppPref().userModel;
    if (currentUser == null) return;

    final displayName = fileName.isNotEmpty ? fileName : 'image';

    socket.emit('send_thread_reply', {
      'parent_message_id': parentMessageId,
      'message': displayName,
      'msg_type': 'image',
      'file_url': fileUrl,
    });

    totalReplies.value = totalReplies.value + 1;
  }

  void sendFileReply({required String fileUrl, required String fileName}) {
    final currentUser = AppPref().userModel;
    if (currentUser == null) return;

    final displayName = fileName.isNotEmpty ? fileName : 'file';

    socket.emit('send_thread_reply', {
      'parent_message_id': parentMessageId,
      'message': displayName,
      'msg_type': 'file',
      'file_url': fileUrl,
    });

    totalReplies.value = totalReplies.value + 1;
  }

  Future<void> pickImageAttachment() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1440,
      );
      if (picked == null) return;
      await _uploadAndDispatchAttachment(
        file: picked,
        msgType: 'image',
        displayName: picked.name ?? p.basename(picked.path),
      );
    } catch (e) {
      AppToast.showAppToast('Unable to pick image');
    }
  }

  Future<void> pickDocumentAttachment() async {
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['pdf'],
      );
      if (res == null || res.files.isEmpty || res.files.single.path == null) {
        return;
      }
      final file = res.files.single;
      await _uploadAndDispatchAttachment(
        file: file,
        msgType: 'file',
        displayName: file.name,
      );
    } catch (e) {
      AppToast.showAppToast('Unable to pick file');
    }
  }

  Future<void> _uploadAndDispatchAttachment({
    required dynamic file,
    required String msgType,
    required String displayName,
  }) async {
    if (sendingAttachment.value) return;
    try {
      sendingAttachment.value = true;
      final uploaded =
          await chatScreenController.setMediaChatApiCall(result: file);
      if (uploaded.isEmpty) {
        AppToast.showAppToast('Upload failed. Please try again.');
        return;
      }
      if (msgType == 'image') {
        sendImageReply(fileUrl: uploaded, fileName: displayName);
      } else {
        sendFileReply(fileUrl: uploaded, fileName: displayName);
      }
    } catch (e) {
      AppToast.showAppToast('Unable to upload attachment');
    } finally {
      sendingAttachment.value = false;
    }
  }

  String _resolveFileUrl(String raw) {
    if (raw.isEmpty) return '';
    final trimmed = raw.trim();
    if (trimmed.toLowerCase().startsWith('http')) return trimmed;
    final normalized = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    return '$publicImageUrl$normalized';
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
      firstName: payload['sender_name']?.toString(),
      lastName: payload['sender_last_name']?.toString(),
      imageUrl: payload['sender_profile']?.toString(),
    );
    final id = payload['message_id']?.toString() ??
        'temp_${DateTime.now().millisecondsSinceEpoch}';
    final decodedMsg = _decodePayloadText(payload['msg']);

    String attachmentPath = '';
    if (rawType != 'text') {
      final candidate = (payload['file_url'] ?? '').toString();
      if (candidate.trim().isNotEmpty) {
        attachmentPath = candidate;
      } else if ((payload['msg'] ?? '').toString().trim().isNotEmpty) {
        attachmentPath = payload['msg'].toString();
      }
    }
    final resolvedUrl =
        attachmentPath.isNotEmpty ? _resolveFileUrl(attachmentPath) : '';

    final metadata = <String, dynamic>{
      'msg_type': rawType,
      'raw_msg': decodedMsg,
    };
    if (resolvedUrl.isNotEmpty) metadata['file_url'] = resolvedUrl;

    if (rawType == 'image' || rawType == 'media') {
      return types.ImageMessage(
        createdAt: createdAt,
        uri: resolvedUrl,
        author: author,
        id: id,
        size: 0,
        name: decodedMsg,
        height: 200,
        width: 200,
        metadata: metadata,
      );
    }

    if (rawType == 'file' || rawType == 'pdf') {
      return types.FileMessage(
        createdAt: createdAt,
        uri: resolvedUrl,
        author: author,
        id: id,
        name: decodedMsg.isNotEmpty ? decodedMsg : 'file',
        size: 0,
        metadata: metadata,
      );
    }

    return types.TextMessage(
      createdAt: createdAt,
      text: decodedMsg,
      author: author,
      id: id,
      metadata: metadata,
    );
  }

  String _decodePayloadText(dynamic raw) {
    if (raw == null) return '';
    final str = raw.toString();
    try {
      final bytes = latin1.encode(str);
      return utf8.decode(bytes);
    } catch (_) {
      return str;
    }
  }
}
