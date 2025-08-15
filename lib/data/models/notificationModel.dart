// To parse this JSON data, do
//
//     final notificationsModel = notificationsModelFromJson(jsonString);

import 'dart:convert';

List<NotificationsModel> notificationsModelFromJson(String str) =>
    List<NotificationsModel>.from(
        json.decode(str).map((x) => NotificationsModel.fromJson(x)));

String notificationsModelToJson(List<NotificationsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NotificationsModel {
  int? id;
  String? title;
  String? message;
  dynamic image;
  String? sendTo;
  int? sessionYearId;
  int? schoolId;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? users;

  NotificationsModel({
    this.id,
    this.title,
    this.message,
    this.image,
    this.sendTo,
    this.sessionYearId,
    this.schoolId,
    this.createdAt,
    this.updatedAt,
    this.users,
  });

  factory NotificationsModel.fromJson(Map<String, dynamic> json) =>
      NotificationsModel(
        id: json["id"],
        title: json["title"],
        message: json["message"],
        image: json["image"],
        sendTo: json["send_to"],
        sessionYearId: json["session_year_id"],
        schoolId: json["school_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        users: json["users"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "message": message,
        "image": image,
        "send_to": sendTo,
        "session_year_id": sessionYearId,
        "school_id": schoolId,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "users": users,
      };
}
