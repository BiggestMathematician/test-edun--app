import 'dart:convert';
import 'package:eschool/app/routes.dart';
import 'package:eschool/data/models/classSection.dart';
import 'package:eschool/data/models/task.dart';
import 'package:eschool/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoteContainer extends StatefulWidget {
  const NoteContainer({Key? key}) : super(key: key);

  @override
  _NoteContainerState createState() => _NoteContainerState();
}

class _NoteContainerState extends State<NoteContainer> {
  late Future<List<TaskModel>> tasks;

  List<ClassSection> classes = [];
  ClassSection? selectedClass;
  int? classId;

  @override
  void initState() {
    super.initState();
    tasks = fetchTaks();
  }

  Future<List<TaskModel>> fetchTaks() async {
    try {
      final response =
          await Api.get(url: Api.getDadhboardTasks, useAuthToken: true);

      // Vérifiez si la réponse est déjà une liste
      List<dynamic> jsonList = response['data'] is List
          ? response['data']
          : json.decode(response['data']);

      return jsonList.map((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: InkWell(
        onTap: () {
          Get.toNamed(
            Routes.taskPage,
            arguments: {
              "childId": 1,
              "subject": 1
            },
          );
          //TasksContainer();
          print('aller voir les taches');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 16.0,
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 16.0,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Mes tâches',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14, // Taille du texte réduite
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<List<TaskModel>>(
                          future: tasks,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<TaskModel>> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }

                            if (snapshot.hasError) {
                              return Text('Erreur : ${snapshot.error}');
                            }

                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Text('Aucune tâche disponible');
                            }

                            // Si les données sont disponibles, on les affiche
                            List<TaskModel> tasksList = snapshot.data!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: tasksList.map((task) {
                                bool? isCompleted = task.isFinished;
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 10), // Padding entre les éléments
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 5,
                                        backgroundColor: isCompleted!
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(task.name!),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
