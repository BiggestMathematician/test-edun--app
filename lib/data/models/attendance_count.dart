class AttendanceCount {
  final int type;
  final int total;

  AttendanceCount({required this.type, required this.total});

  // Méthode pour créer un objet à partir d'un JSON
  factory AttendanceCount.fromJson(Map<String, dynamic> json) {
    return AttendanceCount(
      type: json['type'],
      total: json['total'],
    );
  }

  // Méthode pour convertir l'objet en JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'total': total,
    };
  }
}
