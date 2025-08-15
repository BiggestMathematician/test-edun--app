// To parse this JSON data, do
//
//     final punitionModel = punitionModelFromJson(jsonString);

import 'dart:convert';

PunitionModel punitionModelFromJson(String str) =>
    PunitionModel.fromJson(json.decode(str));

String punitionModelToJson(PunitionModel data) => json.encode(data.toJson());

class PunitionModel {
  int? id;
  String? title;
  String? description;
  int? teacherId;
  int? studentId;
  int? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  Student? student;
  Student? teacher;

  PunitionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.teacherId,
    required this.studentId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.student,
    required this.teacher,
  });

  factory PunitionModel.fromJson(Map<String, dynamic> json) => PunitionModel(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        teacherId: json["teacher_id"],
        studentId: json["student_id"],
        status: json["status"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        student: Student.fromJson(json["student"]),
        teacher: Student.fromJson(json["teacher"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "teacher_id": teacherId,
        "student_id": studentId,
        "status": status,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "student": student!.toJson(),
        "teacher": teacher!.toJson(),
      };
}

class Student {
  int? id;
  String? firstName;
  String? lastName;
  String? mobile;
  String? email;
  String? gender;
  String? image;
  DateTime dob;
  String? currentAddress;
  String? permanentAddress;
  dynamic occupation;
  int? status;
  int? resetRequest;
  String? fcmId;
  int? schoolId;
  String? language;
  dynamic emailVerifiedAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  String? fullName;
  String? schoolNames;
  String? role;

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.mobile,
    required this.email,
    required this.gender,
    required this.image,
    required this.dob,
    required this.currentAddress,
    required this.permanentAddress,
    required this.occupation,
    required this.status,
    required this.resetRequest,
    required this.fcmId,
    required this.schoolId,
    required this.language,
    required this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.fullName,
    required this.schoolNames,
    required this.role,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        mobile: json["mobile"],
        email: json["email"],
        gender: json["gender"],
        image: json["image"],
        dob: DateTime.parse(json["dob"]),
        currentAddress: json["current_address"],
        permanentAddress: json["permanent_address"],
        occupation: json["occupation"],
        status: json["status"],
        resetRequest: json["reset_request"],
        fcmId: json["fcm_id"],
        schoolId: json["school_id"],
        language: json["language"],
        emailVerifiedAt: json["email_verified_at"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        fullName: json["full_name"],
        schoolNames: json["school_names"],
        role: json["role"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "mobile": mobile,
        "email": email,
        "gender": gender,
        "image": image,
        "dob":
            "${dob.year.toString().padLeft(4, '0')}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}",
        "current_address": currentAddress,
        "permanent_address": permanentAddress,
        "occupation": occupation,
        "status": status,
        "reset_request": resetRequest,
        "fcm_id": fcmId,
        "school_id": schoolId,
        "language": language,
        "email_verified_at": emailVerifiedAt,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "deleted_at": deletedAt,
        "full_name": fullName,
        "school_names": schoolNames,
        "role": role,
      };
}
