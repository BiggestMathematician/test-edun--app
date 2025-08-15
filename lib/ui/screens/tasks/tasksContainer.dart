import 'dart:async';
import 'dart:convert';
import 'package:eschool/app/routes.dart';
import 'package:eschool/data/models/subject.dart';
import 'package:eschool/data/models/task.dart';
import 'package:eschool/ui/widgets/customBackButton.dart';
import 'package:eschool/ui/widgets/customTabBarContainer.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/utils/api.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TasksContainer extends StatefulWidget {
  final int? childId;
  final List<Subject>? subjects;
  const TasksContainer({Key? key, this.childId, this.subjects})
      : super(key: key);

  @override
  TasksContainerState createState() => TasksContainerState();

  static Widget routeInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return TasksContainer(
      childId: arguments['childId'],
      subjects: arguments['subjects'],
    );
  }
}

class TasksContainerState extends State<TasksContainer> with SingleTickerProviderStateMixin {
  late Future<List<TaskModel>> tasks;
  late Timer _timer;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), _updateRemainingTime);
    _tabController = TabController(length: 3, vsync: this);
    tasks = fetchTaks();
  }

    void _updateRemainingTime(Timer timer) {
    setState(() {}); // Rebuild le widget à chaque tick du timer
  }

  // Méthodes pour filtrer les tâches selon leur état
  List<TaskModel> getFinishedTasks(List<TaskModel> tasks) {
    return tasks.where((task) => task.isFinished == true).toList();
  }

  List<TaskModel> getUnfinishedTasks(List<TaskModel> tasks) {
    return tasks.where((task) => task.isFinished == false).toList();
  }

  String getRemainingTime(DateTime endDate) {
    final now = DateTime.now();
    final duration =
        endDate.isAfter(now) ? endDate.difference(now) : Duration.zero;

    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    return '$days jours, $hours heures, $minutes minutes, $seconds secondes';
  }

  @override
  void dispose() {
    _timer.cancel();
    _tabController.dispose();
    super.dispose();
  }


  // Récupérer les tâches TaskModel
  Future<List<TaskModel>> fetchTaks() async {
    try {
      final response = await Api.get(url: Api.getTasks, useAuthToken: true);
      List<dynamic> jsonList = response['data'] is List
          ? response['data']
          : json.decode(response['data']);

      return jsonList.map((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<TaskModel>> checkTask(taskId) async {
    try {
      final response = await Api.post(
          url: Api.changeTasksStatus,
          useAuthToken: true,
          body: {'task_id': taskId});
      List<dynamic> jsonList = response['data'] is List
          ? response['data']
          : json.decode(response['data']);

      Utils.showSnackBar(
          message: "Tâche terminée avec succès", context: context);

      return jsonList.map((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<TaskModel>> deleteTask(taskId) async {
    try {
      final response = await Api.post(
          url: Api.deleteTasks, useAuthToken: true, body: {'task_id': taskId});
      List<dynamic> jsonList = response['data'] is List
          ? response['data']
          : json.decode(response['data']);

      Utils.showSnackBar(
          message: "Tâche supprimée avec succès", context: context);

      return jsonList.map((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Widget _buildAppBar() {
    return ScreenTopBackgroundContainer(
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Stack(
            clipBehavior: Clip.none,
            children: [widget.childId != null ? const CustomBackButton() : const Center(),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  alignment: Alignment.topCenter,
                  width: boxConstraints.maxWidth * (0.5),
                  child: Text(
                    "Mes tâches",
                    style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      fontSize: Utils.screenTitleFontSize,
                    ),
                  ),
                ),
              ),
              AnimatedAlign(
                curve: Utils.tabBackgroundContainerAnimationCurve,
                duration: Utils.tabBackgroundContainerAnimationDuration,
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  margin: EdgeInsets.only(
                    left: boxConstraints.maxWidth * (0.1),
                    right: boxConstraints.maxWidth * (0.1),
                    top: boxConstraints.maxHeight * (0.125),
                  ),
                  height: boxConstraints.maxHeight * (0.325),
                  width: boxConstraints.maxWidth * (0.375),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              CustomTabBarContainer(
                boxConstraints: boxConstraints,
                alignment: AlignmentDirectional.center,
                isSelected: true,
                onTap: () {
                  Get.toNamed(Routes.addTask);
                },
                titleKey: "Ajouter une tâche",
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTaskList(List<TaskModel> tasksList) {
    return ListView.builder(
      itemCount: tasksList.length,
      itemBuilder: (context, index) {
        TaskModel task = tasksList[index];
        bool isCompleted = task.isFinished!;

        // Formatage de la date
        String formattedDate = DateFormat('d MMMM yyyy', 'fr')
            .format(DateTime.parse(task.endDate!));

        // Durée de la tâche
        String duration =
            task.duration != null ? task.duration.toString() : 'N/A';
        // Calcul du temps restant
        String remainingTime = getRemainingTime(DateTime.parse(task.endDate!));

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: isCompleted ? Colors.green.shade100 : Colors.red.shade100,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.name!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              // Affichage du statut (réalisé/non réalisé)
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  isCompleted ? 'Terminé' : 'Non terminé',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Durée: $duration',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Date limite $formattedDate",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 10),
              !task.isFinished!
                  ? Text(
                      "Temps restant: $remainingTime",
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54),
                    )
                  : const SizedBox(),
              const SizedBox(width: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  !isCompleted
                      ? IconButton(
                          tooltip: "Terminer",
                          icon: const Icon(
                            Icons.check,
                            size: 18,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            setState(() {
                              tasks = checkTask(task.id);
                            });
                          },
                        )
                      : const SizedBox(),
                  IconButton(
                    tooltip: "Modifier",
                    icon: const Icon(
                      Icons.edit,
                      size: 18,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      Get.toNamed(Routes.editTask, arguments: task);
                    },
                  ),
                  IconButton(
                    tooltip: "Supprimer",
                    icon: const Icon(
                      Icons.delete,
                      size: 18,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      setState(() {
                        tasks = deleteTask(task.id);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight+100), // Hauteur de l'AppBar
        child: Align(
          alignment: Alignment.topCenter,
          child: _buildAppBar(), // Votre AppBar personnalisée
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(
            top: 0), // On laisse de l'espace pour l'AppBar
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Toutes'),
                Tab(text: 'Terminées'),
                Tab(text: 'Non terminées'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Afficher toutes les tâches
                  FutureBuilder<List<TaskModel>>(
                    future: tasks,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return Text('Erreur : ${snapshot.error}');
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('Aucune tâche disponible');
                      }

                      return _buildTaskList(snapshot.data!);
                    },
                  ),

                  // Afficher les tâches terminées
                  FutureBuilder<List<TaskModel>>(
                    future: tasks,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return Text('Erreur : ${snapshot.error}');
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('Aucune tâche disponible');
                      }

                      return _buildTaskList(getFinishedTasks(snapshot.data!));
                    },
                  ),

                  // Afficher les tâches non terminées
                  FutureBuilder<List<TaskModel>>(
                    future: tasks,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (snapshot.hasError) {
                        return Text('Erreur : ${snapshot.error}');
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('Aucune tâche disponible');
                      }

                      return _buildTaskList(getUnfinishedTasks(snapshot.data!));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
