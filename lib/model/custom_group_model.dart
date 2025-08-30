import 'package:base_code/package/config_packages.dart';

class CustomGroupChat {
  String? groupId;
  String? groupName;
  String? groupIcon;
  String? groupDescription;
  String? createdBy;
  String? createdAt;
  String? updatedAt;
  List<GroupParticipant>? participants;
  String? lastMessage;
  String? lastMessageType;
  String? lastMessageTime;
  String? unreadCount;

  CustomGroupChat({
    this.groupId,
    this.groupName,
    this.groupIcon,
    this.groupDescription,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.participants,
    this.lastMessage,
    this.lastMessageType,
    this.lastMessageTime,
    this.unreadCount,
  });

  CustomGroupChat.fromJson(Map<String, dynamic> json) {
    groupId = json['group_id']?.toString();
    groupName = json['group_name'];
    groupIcon = json['group_icon'];
    groupDescription = json['group_description'];
    createdBy = json['created_by']?.toString();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    lastMessage = json['last_message'];
    lastMessageType = json['last_message_type'];
    lastMessageTime = json['last_message_time'];
    unreadCount = json['unread_count']?.toString();
    
    if (json['participants'] != null) {
      participants = <GroupParticipant>[];
      json['participants'].forEach((v) {
        participants!.add(GroupParticipant.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['group_id'] = groupId;
    data['group_name'] = groupName;
    data['group_icon'] = groupIcon;
    data['group_description'] = groupDescription;
    data['created_by'] = createdBy;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['last_message'] = lastMessage;
    data['last_message_type'] = lastMessageType;
    data['last_message_time'] = lastMessageTime;
    data['unread_count'] = unreadCount;
    
    if (participants != null) {
      data['participants'] = participants!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  // Helper methods
  bool get isAdmin => createdBy == getUserId();
  int get participantCount => participants?.length ?? 0;
  
  String getUserId() {
    return AppPref().userId.toString();
  }
}

class GroupParticipant {
  String? userId;
  String? firstName;
  String? lastName;
  String? profile;
  String? role; // 'admin', 'member'
  String? joinedAt;
  bool? isActive;

  GroupParticipant({
    this.userId,
    this.firstName,
    this.lastName,
    this.profile,
    this.role,
    this.joinedAt,
    this.isActive,
  });

  GroupParticipant.fromJson(Map<String, dynamic> json) {
    userId = json['user_id']?.toString();
    firstName = json['first_name'];
    lastName = json['last_name'];
    profile = json['profile'];
    role = json['role'] ?? 'member';
    joinedAt = json['joined_at'];
    isActive = json['is_active'] ?? true;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['profile'] = profile;
    data['role'] = role;
    data['joined_at'] = joinedAt;
    data['is_active'] = isActive;
    return data;
  }

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
  bool get isAdmin => role == 'admin';
}