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
  bool? canSendNudge; // Whether coach can send nudge
  String? lastNudgeSent; // When last nudge was sent
  List<EventTag>? tags;
  Team? team;
  OpponentModel? opponent;
  Locationn? location;
  int? isMultiDay; // Boolean flag (0 or 1)
  String? startDate; // Start date for multi-day events
  String? endDate; // End date for multi-day events
  String? maxCreateDate; // Frequency end date for recurring events

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
    this.team,
    this.opponent,
    this.location,
    this.isMultiDay,
    this.startDate,
    this.endDate,
    this.maxCreateDate,
    this.canSendNudge,
    this.lastNudgeSent,
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
    canSendNudge = json['can_send_nudge'];
    lastNudgeSent = json['last_nudge_sent'];
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
    maxCreateDate = json['max_create_date'];
    isMultiDay = json['is_multi_day'];
    startDate = json['start_date'];
    endDate = json['end_date'];

    if (json['tags'] != null) {
      tags = <EventTag>[];
      json['tags'].forEach((tagJson) {
        tags!.add(EventTag.fromJson(tagJson));
      });
    }

    team = json['team'] != null ? Team.fromJson(json['team']) : null;
    location = json['location'] != null
        ? Locationn.fromJson(json['location'])
        : null;
    opponent = json['opponent'] != null
        ? OpponentModel.fromJson(json['opponent'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['week_day'] = weekDay;
    data['challenge_id'] = challengeId;
    data['activity_id'] = activityId;
    data['activity_type'] = activityType;
    data['activity_name'] = activityName;
    data['notify_team'] = notifyTeam;
    data['is_time_tbd'] = isTimeTbd;
    data['is_live'] = isLive;
    data['event_date'] = eventDate;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['time_zone'] = timeZone;
    data['location_details'] = locationDetails;
    data['assignments'] = assignments;
    data['activity_user_status'] = activityUserStatus;
    data['duration'] = duration;
    data['arrive_early'] = arriveEarly;
    data['extra_label'] = extraLabel;
    data['area_type'] = areaType;
    data['uniform'] = uniform;
    data['flag_color'] = flagColor;
    data['notes'] = notes;
    data['standings'] = standings;
    data['location_id'] = locationId;
    data['total_participate'] = totalParticipate;
    data['opponent_id'] = opponentId;
    data['user_by'] = userBy;
    data['team_id'] = teamId;
    data['status'] = status;
    data['reason'] = reason;


    data['is_multi_day'] = isMultiDay;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['max_create_date'] = maxCreateDate;

    if (tags != null) {
      data['tags'] = tags!.map((tag) => tag.toJson()).toList();
    }


    if (team != null) {
      data['team'] = team?.toJson();
    }
    if (location != null) {
      data['team'] = location?.toJson();
    }
    if (opponent != null) {
      data['opponent'] = opponent?.toJson();
    }
    if (canSendNudge != null) {
      data['can_send_nudge'] = canSendNudge;
    }
    if (lastNudgeSent != null) {
      data['last_nudge_sent'] = lastNudgeSent;
    }
    return data;
  }


  // Multi-day helper methods

  /// Check if this is a multi-day event
  bool get isMultiDayEvent => isMultiDay == 1;

  /// Get the effective start date (backward compatible)
  String? get effectiveStartDate {
    return isMultiDayEvent ? startDate : eventDate;
  }

  /// Get the effective end date (backward compatible)
  String? get effectiveEndDate {
    return isMultiDayEvent ? endDate : eventDate;
  }

  /// Get formatted date range string for display
  String get dateRangeDisplay {
    if (isMultiDayEvent && startDate != null && endDate != null) {
      // Format: "Dec 15 - Dec 18, 2024" or "Dec 15 - Jan 2" (cross-month)
      try {
        final start = DateTime.parse(startDate!);
        final end = DateTime.parse(endDate!);

        final startFormatted = DateFormat('MMM d').format(start);
        final endFormatted = start.year == end.year && start.month == end.month
            ? DateFormat('d, y').format(end)
            : DateFormat('MMM d, y').format(end);

        return '$startFormatted - $endFormatted';
      } catch (e) {
        return '$startDate - $endDate';
      }
    } else if (eventDate != null) {
      // Single day event
      try {
        final date = DateTime.parse(eventDate!);
        return DateFormat('MMM d, y').format(date);
      } catch (e) {
        return eventDate!;
      }
    }
    return 'No date';
  }

  /// Get duration in days for multi-day events
  int get durationInDays {
    if (isMultiDayEvent && startDate != null && endDate != null) {
      try {
        final start = DateTime.parse(startDate!);
        final end = DateTime.parse(endDate!);
        return end.difference(start).inDays +
            1; // +1 to include both start and end days
      } catch (e) {
        return 1;
      }
    }
    return 1; // Single day events have duration of 1 day
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
        json['data'] != null ? ScheduleData.fromJson(json['data']) : null;
    responseCode = json['ResponseCode'];
    responseMsg = json['ResponseMsg'];
    result = json['Result'];
    serverTime = json['ServerTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['ResponseCode'] = responseCode;
    data['ResponseMsg'] = responseMsg;
    data['Result'] = result;
    data['ServerTime'] = serverTime;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['location_id'] = locationId;
    data['user_by'] = userBy;
    data['location'] = location;
    data['address'] = address;
    data['link'] = link;
    data['notes'] = notes;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['opponent_id'] = opponentId;
    data['user_by'] = userBy;
    data['opponent_name'] = opponentName;
    data['contact_name'] = contactName;
    data['phone_number'] = phoneNumber;
    data['email'] = email;
    data['notes'] = notes;
    return data;
  }
}
