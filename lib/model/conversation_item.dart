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
      createdAt: (j['created_at'] ?? '').toString().isEmpty
          ? null
          : DateTime.tryParse(j['created_at']),
      unreadCount: int.tryParse((j['unread_count'] ?? '0').toString()) ?? 0,
    );
  }
}