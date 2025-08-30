import 'custom_group_model.dart';

class ChatListData {
  String? chatId;
  String? teamChatId;
  String? teamId;
  String? msg;
  String? senderId;
  String? receiverId;
  String? msgType;
  String? createdAt;
  String? userId;
  String? firstName;
  String? teamName;
  String? lastName;
  String? unreadCount;
  String? otherId;
  String? profile;

  String? teamImage;
  String? teamIcon;
  String? senderName;
  
  // Custom group fields
  String? groupId;
  String? groupName;
  String? groupIcon;
  String? groupChatId;
  String? chatType; // 'team', 'custom_group', 'personal'
  List<GroupParticipant>? participants;

  ChatListData({
    this.chatId,
    this.teamChatId,
    this.teamId,
    this.msg,
    this.senderId,
    this.receiverId,
    this.msgType,
    this.createdAt,
    this.userId,
    this.firstName,
    this.lastName,
    this.unreadCount,
    this.teamName,
    this.otherId,
    this.profile,
    this.teamImage,
    this.teamIcon,
    this.senderName,
    this.groupId,
    this.groupName,
    this.groupIcon,
    this.groupChatId,
    this.chatType,
    this.participants,
  });

  ChatListData.fromJson(Map<String, dynamic> json) {
    chatId = json['chat_id'];
    teamChatId = json['team_chat_id']?.toString();
    teamId = json['team_id']?.toString();
    msg = json['msg'];
    senderId = json['sender_id']?.toString();
    receiverId = json['receiver_id'];
    msgType = json['msg_type'];
    createdAt = json['created_at'];
    userId = json['user_id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    unreadCount = json['unread_count']?.toString();
    otherId = json['other_id'];
    profile = json['profile'];
    teamName = json['team_name'];

    teamImage = json['team_image'];
    teamIcon = json['team_icon'];
    senderName = json['sender_name'];
    
    // Custom group fields
    groupId = json['group_id']?.toString();
    groupName = json['group_name'];
    groupIcon = json['group_icon'];
    groupChatId = json['group_chat_id']?.toString();
    chatType = json['chat_type'] ?? (teamId != null ? 'team' : (groupId != null ? 'custom_group' : 'personal'));
    
    if (json['participants'] != null) {
      participants = <GroupParticipant>[];
      json['participants'].forEach((v) {
        participants!.add(GroupParticipant.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['chat_id'] = this.chatId;
    data['team_chat_id'] = this.teamChatId;
    data['team_id'] = this.teamId;
    data['msg'] = this.msg;
    data['sender_id'] = this.senderId;
    data['receiver_id'] = this.receiverId;
    data['msg_type'] = this.msgType;
    data['created_at'] = this.createdAt;
    data['user_id'] = this.userId;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['unread_count'] = this.unreadCount;
    data['other_id'] = this.otherId;
    data['profile'] = this.profile;
    data['team_name'] = this.teamName;

    data['team_image'] = this.teamImage;
    data['team_icon'] = this.teamIcon;
    data['sender_name'] = this.senderName;
    
    // Custom group fields
    data['group_id'] = this.groupId;
    data['group_name'] = this.groupName;
    data['group_icon'] = this.groupIcon;
    data['group_chat_id'] = this.groupChatId;
    data['chat_type'] = this.chatType;
    
    if (this.participants != null) {
      data['participants'] = this.participants!.map((v) => v.toJson()).toList();
    }
    
    return data;
  }
  
  // Helper methods
  bool get isCustomGroup => chatType == 'custom_group';
  bool get isTeamChat => chatType == 'team';
  bool get isPersonalChat => chatType == 'personal';
  
  String get displayName => isCustomGroup 
    ? (groupName ?? 'Group Chat')
    : isTeamChat 
      ? (teamName ?? 'Team Chat')
      : '${firstName ?? ''} ${lastName ?? ''}'.trim();
      
  String get displayImage => isCustomGroup 
    ? (groupIcon ?? '')
    : isTeamChat 
      ? ((teamIcon ?? '').isNotEmpty ? teamIcon! : teamImage ?? '')
      : (profile ?? '');
      
  String get chatIdentifier => isCustomGroup 
    ? (groupId ?? '')
    : isTeamChat 
      ? (teamId ?? '')
      : (otherId ?? '');
}
}
