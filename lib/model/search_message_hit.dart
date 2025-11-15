class SearchMessageHit {
  final String messageId;
  final String conversationId;
  final String senderId;
  final String senderFirstName;
  final String senderLastName;
  final String senderProfile;
  final String msgType;
  final String text;
  final String fileUrl;
  final DateTime? createdAt;

  SearchMessageHit({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.senderFirstName,
    required this.senderLastName,
    required this.senderProfile,
    required this.msgType,
    required this.text,
    required this.fileUrl,
    required this.createdAt,
  });

  String get senderDisplayName {
    final first = senderFirstName.trim();
    final last = senderLastName.trim();
    final name = (first + ' ' + last).trim();
    return name.isEmpty ? 'User $senderId' : name;
  }

  factory SearchMessageHit.fromJson(Map<String, dynamic> json) {
    DateTime? dt;
    final createdStr = json['created_at']?.toString();
    if (createdStr != null && createdStr.isNotEmpty) {
      dt = DateTime.tryParse(createdStr.replaceFirst(' ', 'T'));
    }
    return SearchMessageHit(
      messageId: json['message_id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      senderFirstName: json['sender_first_name']?.toString() ?? '',
      senderLastName: json['sender_last_name']?.toString() ?? '',
      senderProfile: json['sender_profile']?.toString() ?? '',
      msgType: json['msg_type']?.toString() ?? 'text',
      text: json['msg']?.toString() ?? '',
      fileUrl: json['file_url']?.toString() ?? '',
      createdAt: dt,
    );
  }
}
