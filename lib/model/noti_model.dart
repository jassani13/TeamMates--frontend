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
    details = json['details'] != null ? new ScheduleData.fromJson(json['details']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['news_id'] = this.newsId;
    data['user_id'] = this.userId;
    data['model_id'] = this.modelId;
    data['model_type'] = this.modelType;
    data['notify_type'] = this.notifyType;
    data['message'] = this.message;
    data['is_read'] = this.isRead;
    data['created_at'] = this.createdAt;
    if (this.details != null) {
      data['details'] = this.details!.toJson();
    }
    return data;
  }
}


