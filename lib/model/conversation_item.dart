import 'package:intl/intl.dart';

class ConversationItem {
  final String? conversationId;
  final String? ownerId;
  final String? type; // 'personal','team','group'
  final String? title;
  final String? image;
  final String? lastMessage;
  final String? lastMessageFileUrl;
  final String? lastReadMessageId;
  final String? msgType;
  final DateTime? createdAt;
  final int? unreadCount;
  final String? lastMessageSenderName;
  final String? lastMessageSenderId;

  ConversationItem({
    required this.conversationId,
    this.ownerId,
    required this.type,
    required this.title,
    required this.image,
    required this.lastMessage,
    required this.lastMessageFileUrl,
    required this.lastReadMessageId,
    required this.msgType,
    required this.createdAt,
    required this.unreadCount,
    this.lastMessageSenderName,
    this.lastMessageSenderId,
  });

  factory ConversationItem.fromJson(dynamic j) {
    return ConversationItem(
      conversationId: (j['conversation_id'] ?? '').toString(),
      ownerId: (j['owner_id'] ?? '').toString(),
      type: (j['type'] ?? '').toString(),
      title: (j['title'] ?? '').toString(),
      image: (j['image'] ?? '').toString(),
      lastMessage: (j['last_message'] ?? '').toString(),
      lastMessageFileUrl: (j['last_message_file_url'] ?? '').toString(),
      lastReadMessageId: (j['last_read_message_id'] ?? '').toString(),
      msgType: (j['msg_type'] ?? 'text').toString(),
      createdAt: _parseServerTimestamp(j['created_at']),
      unreadCount: int.tryParse((j['unread_count'] ?? '0').toString()) ?? 0,
      lastMessageSenderName: (j['last_message_sender_name'] ?? '').toString(),
      lastMessageSenderId: (j['last_message_sender_id'] ?? '').toString(),
    );
  }
}

DateTime? _parseServerTimestamp(dynamic raw) {
  final value = raw?.toString().trim();
  if (value == null || value.isEmpty) return null;

  final normalized = value.contains('T') ? value : value.replaceAll(' ', 'T');
  final hasTimezone = RegExp(r'(Z)$|([+\-]\d{2}:?\d{2}$)', caseSensitive: false)
      .hasMatch(normalized);

  if (hasTimezone) {
    final parsed = DateTime.tryParse(normalized);
    return parsed?.toLocal();
  }

  try {
    final containsT = normalized.contains('T');
    final fmt = containsT
        ? DateFormat("yyyy-MM-dd'T'HH:mm:ss")
        : DateFormat('yyyy-MM-dd HH:mm:ss');
    final source = containsT ? normalized : normalized.replaceAll('T', ' ');
    final parsedUtc = fmt.parse(source, true);
    return parsedUtc.toLocal();
  } catch (_) {
    try {
      return DateTime.tryParse(normalized)?.toLocal();
    } catch (_) {
      return null;
    }
  }
}
