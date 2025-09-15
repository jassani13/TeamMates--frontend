class ScoreModel {
  ScoreData? data;
  int? responseCode;
  String? responseMsg;
  String? result;
  String? serverTime;

  ScoreModel(
      {this.data,
        this.responseCode,
        this.responseMsg,
        this.result,
        this.serverTime});

  ScoreModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? ScoreData.fromJson(json['data']) : null;
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

class ScoreData {
  String? current;
  List<History>? history;

  ScoreData({this.current, this.history});

  ScoreData.fromJson(Map<String, dynamic> json) {
    current = json['current'];
    if (json['history'] != null) {
      history = <History>[];
      json['history'].forEach((v) {
        history!.add(History.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current'] = current;
    if (history != null) {
      data['history'] = history!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class History {
  int? scoreId;
  int? activityId;
  int? isCurrent;
  String? score;
  String? createdAt;
  String? updatedAt;

  History(
      {this.scoreId,
        this.activityId,
        this.isCurrent,
        this.score,
        this.createdAt,
        this.updatedAt});

  History.fromJson(Map<String, dynamic> json) {
    scoreId = json['score_id'];
    activityId = json['activity_id'];
    isCurrent = json['is_current'];
    score = json['score'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['score_id'] = scoreId;
    data['activity_id'] = activityId;
    data['is_current'] = isCurrent;
    data['score'] = score;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
