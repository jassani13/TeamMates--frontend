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
    data = json['data'] != null ? new ChallengeModel.fromJson(json['data']) : null;
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

class ChallengeModel {
  Score? score;
  List<Challenge>? list;

  ChallengeModel({this.score, this.list});

  ChallengeModel.fromJson(Map<String, dynamic> json) {
    score = json['score'] != null ? new Score.fromJson(json['score']) : null;
    if (json['list'] != null) {
      list = <Challenge>[];
      json['list'].forEach((v) {
        list!.add(new Challenge.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.score != null) {
      data['score'] = this.score!.toJson();
    }
    if (this.list != null) {
      data['list'] = this.list!.map((v) => v.toJson()).toList();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['grade'] = this.grade;
    data['score_number'] = this.scoreNumber;
    data['percentage'] = this.percentage;
    data['total_participate'] = this.totalParticipate;
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
        participates!.add(new Participates.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['challenge_id'] = this.challengeId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['start_at'] = this.startAt;
    data['end_at'] = this.endAt;
    data['notes'] = this.notes;
    data['notify_team'] = this.notifyTeam;
    data['user_id'] = this.userId;
    data['participate_count'] = this.participateCount;
    data['participate_status'] = this.participateStatus;
    data['attendance_percentage'] = this.attendancePercentage;
    data['time_status'] = this.timeStatus;
    data['per_challenge_score'] = this.perChallengeScore;
    if (this.participates != null) {
      data['participates'] = this.participates!.map((v) => v.toJson()).toList();
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
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cp_id'] = this.cpId;
    data['challenge_id'] = this.challengeId;
    data['user_id'] = this.userId;
    data['status'] = this.status;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['profile'] = this.profile;
    data['gender'] = this.gender;
    return data;
  }
}

