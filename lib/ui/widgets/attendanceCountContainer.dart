import 'dart:convert';

import 'package:eschool/data/models/attendance_count.dart';
import 'package:eschool/ui/widgets/roundedBackgroundContainer.dart';
import 'package:eschool/utils/api.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AttendanceCountContainer extends StatefulWidget {
  final int id;
  final int childId;
  const AttendanceCountContainer({Key? key, required this.id, required this.childId})
      : super(key: key);

  @override
  _AttendanceCountContainerState createState() =>
      _AttendanceCountContainerState();
}

class _AttendanceCountContainerState extends State<AttendanceCountContainer> {
  late Future<List<AttendanceCount>> attendances;

  @override
  void initState() {
    super.initState();
    attendances = fetchAttendanceCounts("");
  }

  Future<List<AttendanceCount>> fetchAttendanceCounts(classSectionId) async {
    try {
      final response = await Api.get(
          url: Api.getStudentAttendanceStatus,
          useAuthToken: true,
          queryParameters: {'student_id': widget.id, "child_id": widget.childId});

      // Vérifiez si la réponse est déjà une liste
      List<dynamic> jsonList = response['data'] is List
          ? response['data']
          : json.decode(response['data']);
      print("le resultat est ${jsonList}");
      return jsonList.map((json) => AttendanceCount.fromJson(json)).toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return RoundedBackgroundContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder<List<AttendanceCount>>(
                future: attendances,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // Affiche un loader pendant le chargement
                  } else if (snapshot.hasError) {
                    return Text(
                        'Erreur: ${snapshot.error}'); // Gère les erreurs
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text(
                        'Aucune donnée disponible.'); // Gère le cas sans données
                  } else {
                    // Préparer les données pour le pie chart
                    final attendanceCounts = snapshot.data!;
                    int absentCount = 0;
                    int presentCount = 0;
                    int lateCount = 0;

                    for (var attendance in attendanceCounts) {
                      switch (attendance.type) {
                        case 0:
                          absentCount +=
                              attendance.total; // Compter les absents
                          break;
                        case 1:
                          presentCount +=
                              attendance.total; // Compter les présents
                          break;
                        case 2:
                          lateCount += attendance.total; // Compter les retards
                          break;
                      }
                    }

                    // Données du pie chart
                    final pieChartData = [
                      PieChartSectionData(
                        value: absentCount.toDouble(),
                        color: Colors.red,
                        title: '$absentCount', // Affiche le nombre d'absents
                        titleStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.white), // Style du titre
                      ),
                      PieChartSectionData(
                        value: presentCount.toDouble(),
                        color: Colors.green,
                        title: '$presentCount', // Affiche le nombre de présents
                        titleStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.white), // Style du titre
                      ),
                      PieChartSectionData(
                        value: lateCount.toDouble(),
                        color: Colors.orange,
                        title: '$lateCount', // Affiche le nombre de retards
                        titleStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.white), // Style du titre
                      ),
                    ];

                    return SizedBox(
                      height: 200, // Hauteur du pie chart
                      width:
                          200, // Largeur du pie chart (ajuster si nécessaire)
                      child: PieChart(
                        PieChartData(
                          sections: pieChartData,
                          borderData: FlBorderData(show: false),
                          centerSpaceRadius: 40,
                          sectionsSpace: 0,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Légende
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(width: 20, height: 20, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text('Absents'),
                ],
              ),
              Row(
                children: [
                  Container(width: 20, height: 20, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text('Présents'),
                ],
              ),
              Row(
                children: [
                  Container(width: 20, height: 20, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Text('Retards'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
