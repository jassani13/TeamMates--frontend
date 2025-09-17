
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
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
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
        ? ScheduleData.fromJson(json['canceled_activity'])
        : null;
    if (json['upcoming_activities'] != null) {
      upcomingActivities = <ScheduleData>[];
      json['upcoming_activities'].forEach((v) {
        upcomingActivities!.add(ScheduleData.fromJson(v));
      });
    }
    if (json['challenges'] != null) {
      challenges = <Challenge>[];
      json['challenges'].forEach((v) {
        challenges!.add(Challenge.fromJson(v));
      });
    }
    if (json['news'] != null) {
      news = <News>[];
      json['news'].forEach((v) {
        news!.add(News.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (canceledActivity != null) {
      data['canceled_activity'] = canceledActivity!.toJson();
    }
    if (upcomingActivities != null) {
      data['upcoming_activities'] =
          upcomingActivities!.map((v) => v.toJson()).toList();
    }
    if (challenges != null) {
      data['challenges'] = challenges!.map((v) => v.toJson()).toList();
    }
    if (news != null) {
      data['news'] = news!.map((v) => v.toJson()).toList();
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['author'] = author;
    data['title'] = title;
    data['description'] = description;
    data['url'] = url;
    data['source'] = source;
    data['image'] = image;
    data['category'] = category;
    data['language'] = language;
    data['country'] = country;
    data['published_at'] = publishedAt;
    return data;
  }
}
