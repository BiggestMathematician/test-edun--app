class TaskModel {
  final int? id;
  final String? name;
  final String? duration;
  final String? endDate;
  final int? userId;
  final bool? isFinished;
  final String? createdAt;
  final String? updatedAt;

  TaskModel({
    this.id,
    this.name,
    this.duration,
    this.endDate,
    this.userId,
    this.isFinished,
    this.createdAt,
    this.updatedAt,
  });

  // Créer un objet TaskModel à partir d'un JSON
  TaskModel.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        name = json['name'] as String?,
        duration = json['duration'] as String?,
        endDate = json['end_date']
            as String?, // Vous pouvez convertir ceci en DateTime si nécessaire
        userId = json['user_id'] as int?,
        isFinished = json['is_finished'] == 1, // Conversion de l'1 ou 0 en bool
        createdAt = json['created_at'] as String?,
        updatedAt = json['updated_at'] as String?;

  // Convertir un objet TaskModel en une Map pour l'envoyer au backend ou l'utiliser avec une base de données
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
      'end_date': endDate,
      'user_id': userId,
      'is_finished': isFinished == true
          ? 1
          : 0, // Stockage comme 1 pour true et 0 pour false
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
