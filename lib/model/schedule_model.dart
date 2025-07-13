import 'package:base_code/package/config_packages.dart';
import 'event_tag_model.dart';

class ScheduleData {
  int? activityId;
  int? challengeId;
  String? activityType;
  String? weekDay;
  String? activityName;
  int? notifyTeam;
  int? isTimeTbd;
  int? isLive;
  String? eventDate;
  String? startTime;
  String? endTime;
  String? timeZone;
  String? locationDetails;
  String? assignments;
  String? duration;
  String? arriveEarly;
  String? extraLabel;
  String? areaType;
  String? uniform;
  String? flagColor;
  String? notes;
  int? standings;
  int? locationId;
  int? opponentId;
  int? userBy;
  int? teamId;
  String? status;
  String? reason;
  int? totalParticipate;
  String? activityUserStatus;
  List<EventTag>? tags;
  Team? team;
  OpponentModel? opponent;
  Locationn? location;

  ScheduleData({
    this.activityId,
    this.challengeId,
    this.activityType,
    this.activityName,
    this.notifyTeam,
    this.weekDay,
    this.isTimeTbd,
    this.isLive,
    this.eventDate,
    this.startTime,
    this.endTime,
    this.activityUserStatus,
    this.timeZone,
    this.locationDetails,
    this.assignments,
    this.duration,
    this.arriveEarly,
    this.extraLabel,
    this.areaType,
    this.uniform,
    this.flagColor,
    this.notes,
    this.standings,
    this.locationId,
    this.totalParticipate,
    this.opponentId,
    this.userBy,
    this.teamId,
    this.status,
    this.reason,
    this.tags,
    this.team,
    this.opponent,
    this.location,
  });

  ScheduleData.fromJson(Map<String, dynamic> json) {
    weekDay = json['week_day'];
    challengeId = json['challenge_id'];
    activityId = json['activity_id'];
    activityType = json['activity_type'];
    activityName = json['activity_name'];
    notifyTeam = json['notify_team'];
    isTimeTbd = json['is_time_tbd'];
    isLive = json['is_live'];
    eventDate = json['event_date'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    timeZone = json['time_zone'];
    totalParticipate = json['total_participate'];
    activityUserStatus = json['activity_user_status'];
    locationDetails = json['location_details'];
    assignments = json['assignments'];
    duration = json['duration'];
    arriveEarly = json['arrive_early'];
    extraLabel = json['extra_label'];
    areaType = json['area_type'];
    uniform = json['uniform'];
    flagColor = json['flag_color'];
    notes = json['notes'];
    standings = json['standings'];
    locationId = json['location_id'];
    opponentId = json['opponent_id'];
    userBy = json['user_by'];
    teamId = json['team_id'];
    status = json['status'];
    reason = json['reason'];

    if (json['tags'] != null) {
      tags = <EventTag>[];
      json['tags'].forEach((tagJson) {
        tags!.add(EventTag.fromJson(tagJson));
      });
    }

    team = json['team'] != null ? new Team.fromJson(json['team']) : null;
    location = json['location'] != null
        ? new Locationn.fromJson(json['location'])
        : null;
    opponent = json['opponent'] != null
        ? new OpponentModel.fromJson(json['opponent'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['week_day'] = this.weekDay;
    data['challenge_id'] = this.challengeId;
    data['activity_id'] = this.activityId;
    data['activity_type'] = this.activityType;
    data['activity_name'] = this.activityName;
    data['notify_team'] = this.notifyTeam;
    data['is_time_tbd'] = this.isTimeTbd;
    data['is_live'] = this.isLive;
    data['event_date'] = this.eventDate;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['time_zone'] = this.timeZone;
    data['location_details'] = this.locationDetails;
    data['assignments'] = this.assignments;
    data['activity_user_status'] = this.activityUserStatus;
    data['duration'] = this.duration;
    data['arrive_early'] = this.arriveEarly;
    data['extra_label'] = this.extraLabel;
    data['area_type'] = this.areaType;
    data['uniform'] = this.uniform;
    data['flag_color'] = this.flagColor;
    data['notes'] = this.notes;
    data['standings'] = this.standings;
    data['location_id'] = this.locationId;
    data['total_participate'] = this.totalParticipate;
    data['opponent_id'] = this.opponentId;
    data['user_by'] = this.userBy;
    data['team_id'] = this.teamId;
    data['status'] = this.status;
    data['reason'] = this.reason;

    if (this.tags != null) {
      data['tags'] = this.tags!.map((tag) => tag.toJson()).toList();
    }

    if (this.team != null) {
      data['team'] = this.team?.toJson();
    }
    if (this.location != null) {
      data['team'] = this.location?.toJson();
    }
    if (this.opponent != null) {
      data['opponent'] = this.opponent?.toJson();
    }
    return data;
  }

  /// Get tag names as a comma-separated string
  String get tagNames {
    if (tags == null || tags!.isEmpty) return '';
    return tags!.map((tag) => tag.displayName).join(', ');
  }

  /// Get the first tag's color (for backward compatibility)
  String? get primaryTagColor {
    if (tags != null && tags!.isNotEmpty) {
      return tags!.first.tagColor;
    }
    return flagColor; // Fallback to existing flag_color
  }

  /// Check if activity has any tags
  bool get hasTags => tags != null && tags!.isNotEmpty;

  /// Get tag colors as a list
  List<Color> get tagColors {
    if (tags == null || tags!.isEmpty) return [];
    return tags!.map((tag) => tag.color).toList();
  }

  /// Get tag IDs as comma-separated string (for API calls)
  String get tagIdsString {
    if (tags == null || tags!.isEmpty) return '';
    return tags!.map((tag) => tag.tagId.toString()).join(',');
  }
}

class ActivityDetailsModel {
  ScheduleData? data;
  int? responseCode;
  String? responseMsg;
  String? result;
  String? serverTime;

  ActivityDetailsModel(
      {this.data,
      this.responseCode,
      this.responseMsg,
      this.result,
      this.serverTime});

  ActivityDetailsModel.fromJson(Map<String, dynamic> json) {
    data =
        json['data'] != null ? new ScheduleData.fromJson(json['data']) : null;
    responseCode = json['ResponseCode'];
    responseMsg = json['ResponseMsg'];
    result = json['Result'];
    serverTime = json['ServerTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['ResponseCode'] = this.responseCode;
    data['ResponseMsg'] = this.responseMsg;
    data['Result'] = this.result;
    data['ServerTime'] = this.serverTime;
    return data;
  }
}

class Locationn {
  int? locationId;
  int? userBy;
  String? location;
  String? address;
  String? link;
  String? notes;
  String? latitude;
  String? longitude;

  Locationn(
      {this.locationId,
      this.userBy,
      this.location,
      this.address,
      this.link,
      this.notes,
      this.latitude,
      this.longitude});

  Locationn.fromJson(Map<String, dynamic> json) {
    locationId = json['location_id'];
    userBy = json['user_by'];
    location = json['location'];
    address = json['address'];
    link = json['link'];
    notes = json['notes'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['location_id'] = this.locationId;
    data['user_by'] = this.userBy;
    data['location'] = this.location;
    data['address'] = this.address;
    data['link'] = this.link;
    data['notes'] = this.notes;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }
}

class Opponent {
  int? opponentId;
  int? userBy;
  String? opponentName;
  String? contactName;
  String? phoneNumber;
  String? email;
  String? notes;

  Opponent(
      {this.opponentId,
      this.userBy,
      this.opponentName,
      this.contactName,
      this.phoneNumber,
      this.email,
      this.notes});

  Opponent.fromJson(Map<String, dynamic> json) {
    opponentId = json['opponent_id'];
    userBy = json['user_by'];
    opponentName = json['opponent_name'];
    contactName = json['contact_name'];
    phoneNumber = json['phone_number'];
    email = json['email'];
    notes = json['notes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['opponent_id'] = this.opponentId;
    data['user_by'] = this.userBy;
    data['opponent_name'] = this.opponentName;
    data['contact_name'] = this.contactName;
    data['phone_number'] = this.phoneNumber;
    data['email'] = this.email;
    data['notes'] = this.notes;
    return data;
  }
}
