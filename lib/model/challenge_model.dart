class AllChallengeModel {
  ChallengeModel? data;
  int? responseCode;
  String? responseMsg;
  String? result;
  String? serverTime;

  AllChallengeModel(
      {this.data,
        this.responseCode,
        this.responseMsg,
        this.result,
        this.serverTime});

  AllChallengeModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? ChallengeModel.fromJson(json['data']) : null;
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

class ChallengeModel {
  Score? score;
  List<Challenge>? list;

  ChallengeModel({this.score, this.list});

  ChallengeModel.fromJson(Map<String, dynamic> json) {
    score = json['score'] != null ? Score.fromJson(json['score']) : null;
    if (json['list'] != null) {
      list = <Challenge>[];
      json['list'].forEach((v) {
        list!.add(Challenge.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (score != null) {
      data['score'] = score!.toJson();
    }
    if (list != null) {
      data['list'] = list!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Score {
  String? grade;
  int? scoreNumber;
  String? percentage;
  int? totalParticipate;

  Score({this.grade, this.scoreNumber, this.percentage,this.totalParticipate});

  Score.fromJson(Map<String, dynamic> json) {
    grade = json['grade'];
    scoreNumber = json['score_number'];
    percentage = json['percentage'].toString();
    totalParticipate=json['total_participate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['grade'] = grade;
    data['score_number'] = scoreNumber;
    data['percentage'] = percentage;
    data['total_participate'] = totalParticipate;
    return data;
  }
}

class Challenge {
  int? challengeId;
  String? name;
  String? description;
  String? startAt;
  String? endAt;
  String? notes;
  int? notifyTeam;
  int? userId;
  String? participateCount;
  String? participateStatus;
  String? attendancePercentage;
  String? timeStatus;
  String? perChallengeScore;
  List<Participates>? participates;


  Challenge(
      {this.challengeId,
        this.name,
        this.description,
        this.startAt,
        this.endAt,
        this.notes,
        this.notifyTeam,
        this.userId,
        this.participateCount,
        this.participateStatus,
        this.attendancePercentage,
        this.timeStatus,
  this.participates,
        this.perChallengeScore});

  Challenge.fromJson(Map<String, dynamic> json) {
    challengeId = json['challenge_id'];
    name = json['name'];
    description = json['description'];
    startAt = json['start_at'];
    endAt = json['end_at'];
    notes = json['notes'];
    notifyTeam = json['notify_team'];
    userId = json['user_id'];
    participateCount = json['participate_count'];
    participateStatus = json['participate_status'];
    attendancePercentage = json['attendance_percentage'].toString();
    timeStatus = json['time_status'];
    perChallengeScore = json['per_challenge_score'].toString();
    if (json['participates'] != null) {
      participates = <Participates>[];
      json['participates'].forEach((v) {
        participates!.add(Participates.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['challenge_id'] = challengeId;
    data['name'] = name;
    data['description'] = description;
    data['start_at'] = startAt;
    data['end_at'] = endAt;
    data['notes'] = notes;
    data['notify_team'] = notifyTeam;
    data['user_id'] = userId;
    data['participate_count'] = participateCount;
    data['participate_status'] = participateStatus;
    data['attendance_percentage'] = attendancePercentage;
    data['time_status'] = timeStatus;
    data['per_challenge_score'] = perChallengeScore;
    if (participates != null) {
      data['participates'] = participates!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
class Participates {
  int? cpId;
  int? challengeId;
  int? userId;
  String? status;
  User? user;

  Participates(
      {this.cpId, this.challengeId, this.userId, this.status, this.user});

  Participates.fromJson(Map<String, dynamic> json) {
    cpId = json['cp_id'];
    challengeId = json['challenge_id'];
    userId = json['user_id'];
    status = json['status'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cp_id'] = cpId;
    data['challenge_id'] = challengeId;
    data['user_id'] = userId;
    data['status'] = status;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}
class User {
  int? userId;
  String? firstName;
  String? lastName;
  String? profile;
  String? gender;

  User({this.userId, this.firstName, this.lastName, this.profile, this.gender});

  User.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    profile = json['profile'];
    gender = json['gender'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['profile'] = profile;
    data['gender'] = gender;
    return data;
  }
}

