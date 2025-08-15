class Weeklyannouncement {
  final int? id;
  final String? title;
  final String? description;
  final String? subDescription;
  final String? createdAt;
  final String? updatedAt;
  final String? cover;

  Weeklyannouncement({
    this.id,
    this.title,
    this.description,
    this.subDescription,
    this.cover,
    this.createdAt,
    this.updatedAt,
  });

  Weeklyannouncement.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        title = json['title'] as String?,
        description = json['description'] as String?,
        subDescription = json['sub_description'] as String?,
        cover = json['cover'] as String?,
        createdAt = json['created_at'] as String?,
        updatedAt = json['updated_at'] as String?;
}
