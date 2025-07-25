class RosterDetailModel {
  List<RosterDetails>? data;
  int? responseCode;
  String? responseMsg;
  String? result;
  String? serverTime;

  RosterDetailModel(
      {this.data,
      this.responseCode,
      this.responseMsg,
      this.result,
      this.serverTime});

  RosterDetailModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <RosterDetails>[];
      json['data'].forEach((v) {
        data!.add(new RosterDetails.fromJson(v));
      });
    }
    responseCode = json['ResponseCode'];
    responseMsg = json['ResponseMsg'];
    result = json['Result'];
    serverTime = json['ServerTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['ResponseCode'] = this.responseCode;
    data['ResponseMsg'] = this.responseMsg;
    data['Result'] = this.result;
    data['ServerTime'] = this.serverTime;
    return data;
  }
}

class RosterDetails {
  int? teamId;
  int? userBy;
  int? icon;
  String? name;
  String? zipcode;
  String? country;
  String? sports;
  int? teamCode;
  String? iconImage;
  List<PlayerTeams>? playerTeams;

  RosterDetails(
      {this.teamId,
      this.userBy,
      this.icon,
      this.name,
      this.zipcode,
      this.country,
      this.sports,
      this.teamCode,
      this.iconImage,
      this.playerTeams});

  RosterDetails.fromJson(Map<String, dynamic> json) {
    teamId = json['team_id'];
    userBy = json['user_by'];
    icon = json['icon'];
    name = json['name'];
    zipcode = json['zipcode'];
    country = json['country'];
    sports = json['sports'];
    teamCode = json['team_code'];
    iconImage = json['icon_image'];
    if (json['player_teams'] != null) {
      playerTeams = <PlayerTeams>[];
      json['player_teams'].forEach((v) {
        playerTeams!.add(new PlayerTeams.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['team_id'] = this.teamId;
    data['user_by'] = this.userBy;
    data['icon'] = this.icon;
    data['name'] = this.name;
    data['zipcode'] = this.zipcode;
    data['country'] = this.country;
    data['sports'] = this.sports;
    data['team_code'] = this.teamCode;
    data['icon_image'] = this.iconImage;
    if (this.playerTeams != null) {
      data['player_teams'] = this.playerTeams!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PlayerTeams {
  int? userId;
  String? allergy;
  String? firstName;
  String? lastName;
  String? email;
  String? role;
  int? playerCode;
  String? profile;
  String? dob;
  String? gender;
  String? jerseyNumber;
  String? position;
  String? phoneNumber;
  String? address;
  String? latitude;
  String? longitude;
  String? city;
  String? state;
  String? zipcode;
  String? fcmToken;
  String? activityUserStatus;
  String? activityUserNote;
  Pivot? pivot;

  PlayerTeams(
      {this.userId,
      this.allergy,
      this.firstName,
      this.lastName,
      this.email,
      this.role,
      this.playerCode,
      this.profile,
      this.dob,
      this.gender,
      this.jerseyNumber,
      this.position,
      this.activityUserStatus,
      this.activityUserNote,
      this.phoneNumber,
      this.address,
      this.latitude,
      this.longitude,
      this.city,
      this.state,
      this.zipcode,
      this.fcmToken,
      this.pivot});

  PlayerTeams.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    allergy = json['allergy'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    role = json['role'];
    playerCode = json['player_code'];
    profile = json['profile'];
    dob = json['dob'];
    gender = json['gender'];
    jerseyNumber = json['jersey_number'];
    position = json['position'];
    phoneNumber = json['phone_number'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    city = json['city'];
    state = json['state'];
    activityUserStatus = json['activity_user_status'];
    activityUserNote = json['activity_user_note'];

    zipcode = json['zipcode'];
    fcmToken = json['fcm_token'];
    pivot = json['pivot'] != null ? new Pivot.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['allergy'] = this.allergy;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['email'] = this.email;
    data['role'] = this.role;
    data['player_code'] = this.playerCode;
    data['profile'] = this.profile;
    data['dob'] = this.dob;
    data['gender'] = this.gender;
    data['jersey_number'] = this.jerseyNumber;
    data['position'] = this.position;
    data['phone_number'] = this.phoneNumber;
    data['address'] = this.address;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['activity_user_status'] = this.activityUserStatus;
    data['activity_user_note'] = this.activityUserNote;
    data['city'] = this.city;
    data['state'] = this.state;
    data['zipcode'] = this.zipcode;
    data['fcm_token'] = this.fcmToken;
    if (this.pivot != null) {
      data['pivot'] = this.pivot!.toJson();
    }
    return data;
  }
}

class Pivot {
  int? teamId;
  int? userId;

  Pivot({this.teamId, this.userId});

  Pivot.fromJson(Map<String, dynamic> json) {
    teamId = json['team_id'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['team_id'] = this.teamId;
    data['user_id'] = this.userId;
    return data;
  }
}
