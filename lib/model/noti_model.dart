import 'package:base_code/package/config_packages.dart';


class NotificationModel {
  int? newsId;
  int? userId;
  int? modelId;
  String? modelType;
  String? notifyType;
  String? message;
  int? isRead;
  String? createdAt;
  ScheduleData? details;

  NotificationModel({this.newsId, this.userId, this.modelId, this.modelType, this.notifyType, this.message, this.isRead, this.createdAt, this.details});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    newsId = json['news_id'];
    userId = json['user_id'];
    modelId = json['model_id'];
    modelType = json['model_type'];
    notifyType = json['notify_type'];
    message = json['message'];
    isRead = json['is_read'];
    createdAt = json['created_at'];
    details = json['details'] != null ? ScheduleData.fromJson(json['details']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['news_id'] = newsId;
    data['user_id'] = userId;
    data['model_id'] = modelId;
    data['model_type'] = modelType;
    data['notify_type'] = notifyType;
    data['message'] = message;
    data['is_read'] = isRead;
    data['created_at'] = createdAt;
    if (details != null) {
      data['details'] = details!.toJson();
    }
    return data;
  }
}


