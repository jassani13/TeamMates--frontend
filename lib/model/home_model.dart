import 'package:base_code/model/challenge_model.dart';

import '../package/config_packages.dart';

class HomeModel {
  Data? data;
  int? responseCode;
  String? responseMsg;
  String? result;
  String? serverTime;

  HomeModel(
      {this.data,
      this.responseCode,
      this.responseMsg,
      this.result,
      this.serverTime});

  HomeModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
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

class Data {
  ScheduleData? canceledActivity;
  List<ScheduleData>? upcomingActivities;
  List<Challenge>? challenges;
  List<News>? news;

  Data(
      {this.canceledActivity,
      this.upcomingActivities,
      this.challenges,
      this.news});

  Data.fromJson(Map<String, dynamic> json) {
    canceledActivity = json['canceled_activity'] != null
        ? new ScheduleData.fromJson(json['canceled_activity'])
        : null;
    if (json['upcoming_activities'] != null) {
      upcomingActivities = <ScheduleData>[];
      json['upcoming_activities'].forEach((v) {
        upcomingActivities!.add(new ScheduleData.fromJson(v));
      });
    }
    if (json['challenges'] != null) {
      challenges = <Challenge>[];
      json['challenges'].forEach((v) {
        challenges!.add(new Challenge.fromJson(v));
      });
    }
    if (json['news'] != null) {
      news = <News>[];
      json['news'].forEach((v) {
        news!.add(new News.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.canceledActivity != null) {
      data['canceled_activity'] = this.canceledActivity!.toJson();
    }
    if (this.upcomingActivities != null) {
      data['upcoming_activities'] =
          this.upcomingActivities!.map((v) => v.toJson()).toList();
    }
    if (this.challenges != null) {
      data['challenges'] = this.challenges!.map((v) => v.toJson()).toList();
    }
    if (this.news != null) {
      data['news'] = this.news!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class News {
  String? author;
  String? title;
  String? description;
  String? url;
  String? source;
  String? image;
  String? category;
  String? language;
  String? country;
  String? publishedAt;

  News(
      {this.author,
      this.title,
      this.description,
      this.url,
      this.source,
      this.image,
      this.category,
      this.language,
      this.country,
      this.publishedAt});

  News.fromJson(Map<String, dynamic> json) {
    author = json['author'];
    title = json['title'];
    description = json['description'];
    url = json['url'];
    source = json['source'];
    image = json['image'];
    category = json['category'];
    language = json['language'];
    country = json['country'];
    publishedAt = json['published_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['author'] = this.author;
    data['title'] = this.title;
    data['description'] = this.description;
    data['url'] = this.url;
    data['source'] = this.source;
    data['image'] = this.image;
    data['category'] = this.category;
    data['language'] = this.language;
    data['country'] = this.country;
    data['published_at'] = this.publishedAt;
    return data;
  }
}
