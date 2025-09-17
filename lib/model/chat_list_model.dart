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
    this.teamImage,this.teamIcon,this.senderName
  });

  ChatListData.fromJson(Map<String, dynamic> json) {
    chatId = json['chat_id'];
    teamChatId = json['team_chat_id'].toString();
    teamId = json['team_id'].toString();
    msg = json['msg'];
    senderId = json['sender_id'].toString();
    receiverId = json['receiver_id'];
    msgType = json['msg_type'];
    createdAt = json['created_at'];
    userId = json['user_id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    unreadCount = json['unread_count'].toString();
    otherId = json['other_id'];
    profile = json['profile'];
    teamName = json['team_name'];


    teamImage = json['team_image'];
    teamIcon = json['team_icon'];
    senderName = json['sender_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chat_id'] = chatId;
    data['team_chat_id'] = teamChatId;
    data['team_id'] = teamId;
    data['msg'] = msg;
    data['sender_id'] = senderId;
    data['receiver_id'] = receiverId;
    data['msg_type'] = msgType;
    data['created_at'] = createdAt;
    data['user_id'] = userId;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['unread_count'] = unreadCount;
    data['other_id'] = otherId;
    data['profile'] = profile;
    data['team_name'] = teamName;

    data['team_image'] = teamImage;
    data['team_icon'] = teamIcon;
    data['sender_name'] = senderName;
    return data;
  }
}
