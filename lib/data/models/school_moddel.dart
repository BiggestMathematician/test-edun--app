// To parse this JSON data, do
//
//     final schoolModel = schoolModelFromJson(jsonString);

import 'dart:convert';

SchoolModel schoolModelFromJson(String str) => SchoolModel.fromJson(json.decode(str));

String schoolModelToJson(SchoolModel data) => json.encode(data.toJson());

class SchoolModel {
    int? id;
    String? name;
    String? address;
    String? supportPhone;
    String? supportEmail;
    String? tagline;
    String? logo;
    dynamic adminId;
    dynamic status;
    String? domain;
    String? code;
    DateTime? createdAt;
    DateTime? updatedAt;
    dynamic deletedAt;

    SchoolModel({
        this.id,
        this.name,
        this.address,
        this.supportPhone,
        this.supportEmail,
        this.tagline,
        this.logo,
        this.adminId,
        this.status,
        this.domain,
        this.code,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
    });

    factory SchoolModel.fromJson(Map<String, dynamic> json) => SchoolModel(
        id: json["id"],
        name: json["name"],
        address: json["address"],
        supportPhone: json["support_phone"],
        supportEmail: json["support_email"],
        tagline: json["tagline"],
        logo: json["logo"],
        adminId: json["admin_id"],
        status: json["status"],
        domain: json["domain"],
        code: json["code"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "address": address,
        "support_phone": supportPhone,
        "support_email": supportEmail,
        "tagline": tagline,
        "logo": logo,
        "admin_id": adminId,
        "status": status,
        "domain": domain,
        "code": code,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "deleted_at": deletedAt,
    };
}
