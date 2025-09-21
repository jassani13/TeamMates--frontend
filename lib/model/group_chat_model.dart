class GroupChatModel {
  final String? groupId;
  final String? groupName;
  final String? groupImage;
  final String? groupChatId;
  final String? senderId;
  final String? msg;
  final String? msgType;
  final String? createdAt; // 'YYYY-MM-DD HH:mm:ss'
  final int? unreadCount;
  final String? senderName;

  const GroupChatModel({
    this.groupId,
    this.groupName,
    this.groupImage,
    this.groupChatId,
    this.senderId,
    this.msg,
    this.msgType,
    this.createdAt,
    this.unreadCount,
    this.senderName,
  });

  factory GroupChatModel.fromJson(Map<String, dynamic> json) {
    String? _asString(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      return s.isEmpty ? null : s;
    }

    int? _asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      return int.tryParse(s);
    }

    return GroupChatModel(
      groupId: _asString(json['group_id']),
      groupName: _asString(json['group_name']),
      groupImage: _asString(json['group_image']),
      groupChatId: _asString(json['group_chat_id']),
      senderId: _asString(json['sender_id']),
      msg: _asString(json['msg']),
      msgType: _asString(json['msg_type']),
      createdAt: _asString(json['created_at']),
      unreadCount: _asInt(json['unread_count']) ?? 0,
      senderName: _asString(json['sender_name']),
    );
  }

  Map<String, dynamic> toJson() => {
        'group_id': groupId,
        'group_name': groupName,
        'group_image': groupImage,
        'group_chat_id': groupChatId,
        'sender_id': senderId,
        'msg': msg,
        'msg_type': msgType,
        'created_at': createdAt,
        'unread_count': unreadCount,
        'sender_name': senderName,
      };

  GroupChatModel copyWith({
    String? groupId,
    String? groupName,
    String? groupImage,
    String? groupChatId,
    String? senderId,
    String? msg,
    String? msgType,
    String? createdAt,
    int? unreadCount,
    String? senderName,
  }) {
    return GroupChatModel(
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      groupImage: groupImage ?? this.groupImage,
      groupChatId: groupChatId ?? this.groupChatId,
      senderId: senderId ?? this.senderId,
      msg: msg ?? this.msg,
      msgType: msgType ?? this.msgType,
      createdAt: createdAt ?? this.createdAt,
      unreadCount: unreadCount ?? this.unreadCount,
      senderName: senderName ?? this.senderName,
    );
  }

  DateTime? get createdAtDate {
    if (createdAt == null || createdAt!.isEmpty) return null;
    // Expecting 'YYYY-MM-DD HH:mm:ss'
    try {
      final norm = createdAt!.replaceFirst(' ', 'T');
      return DateTime.tryParse(norm);
    } catch (_) {
      return null;
    }
  }

  bool get hasUnread => (unreadCount ?? 0) > 0;

  @override
  String toString() =>
      'GroupChatItem(groupId: $groupId, groupName: $groupName, unread: $unreadCount)';

  static List<GroupChatModel> listFromResData(dynamic response) {
    if (response is Map && response['resData'] is List) {
      return (response['resData'] as List)
          .map((e) => GroupChatModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (response is List) {
      return response
          .map((e) => GroupChatModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const [];
  }
}
