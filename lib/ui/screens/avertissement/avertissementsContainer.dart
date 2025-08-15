import 'dart:convert';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/data/models/avertissement.dart';
import 'package:eschool/data/models/subject.dart';
import 'package:eschool/ui/widgets/customBackButton.dart';
import 'package:eschool/ui/widgets/customRefreshIndicator.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/utils/api.dart';
import 'package:eschool/utils/constants.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class AvertissementContainer extends StatefulWidget {
  final int? childId;
  final String? childFullName;
  final List<Subject>? subjects;
  const AvertissementContainer(
      {Key? key, this.childId, this.childFullName, this.subjects})
      : super(key: key);

  @override
  AvertissementContainerState createState() => AvertissementContainerState();

  static Widget routeInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return AvertissementContainer(
      childId: arguments['childId'],
      childFullName: arguments['childFullName'],
    );
  }
}


class AvertissementContainerState extends State<AvertissementContainer> {
  late Future<List<AvertissementModel>> tasks;

  @override
  void initState() {
    super.initState();
    tasks = fetchAvertissements();
  }

  // Récupérer les tâches AvertissementModel
  Future<List<AvertissementModel>> fetchAvertissements() async {
    try {
      final response =
          await Api.post(url: Api.studentAvertissement, useAuthToken: true, body: {"childId": widget.childId});
      List<dynamic> jsonList = response['data'] is List
          ? response['data']
          : json.decode(response['data']);

      return jsonList.map((json) => AvertissementModel.fromJson(json)).toList();
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
            children: [
              context.read<AuthCubit>().isParent()
                  ? const CustomBackButton()
                  : const SizedBox(),
              Align(
                alignment: Alignment.center,
                child: Container(
                  alignment: Alignment.center,
                  width: boxConstraints.maxWidth,
                  child: Text(
                    widget.childFullName != null ? "Les avertissements de ${widget.childFullName}" : "Mes avertissements",
                    style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      fontSize: Utils.screenTitleFontSize,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMySubjects() {
    return CustomRefreshIndicator(
      displacment: Utils.getScrollViewTopPadding(
          context: context,
          appBarHeightPercentage: Utils.appBarSmallerHeightPercentage),
      onRefreshCallback: () async {
        tasks = fetchAvertissements();
        setState(() {});
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: Utils.getScrollViewTopPadding(
            context: context,
            appBarHeightPercentage: Utils.appBarSmallerHeightPercentage,
          ),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).colorScheme.surface,
          padding: EdgeInsets.all(appContentHorizontalPadding),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * (0.035),
              ),
              FutureBuilder<List<AvertissementModel>>(
                future: tasks,
                builder: (BuildContext context,
                    AsyncSnapshot<List<AvertissementModel>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur : ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: const Text('Aucun avertissement disponible'));
                  }

                  List<AvertissementModel> avertisementsList = snapshot.data!;

                  return Table(
                    border: TableBorder.all(),
                    columnWidths: const {
                      0: FlexColumnWidth(2.5),
                      1: FlexColumnWidth(2.5),
                      2: FlexColumnWidth(2.5),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey[200]),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Description',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Enseignant',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Niveau',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      ...avertisementsList.map((avertissemnt) {
                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(avertissemnt.description),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(avertissemnt.teacher.fullName!),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "${avertissemnt.percentage} %",
                                style: TextStyle(
                                  color: avertissemnt.percentage < 50
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return (context.read<AuthCubit>().isParent())
        ? Scaffold(
            body: Stack(
              children: [
                _buildMySubjects(),
                Align(
                  alignment: Alignment.topCenter,
                  child: _buildAppBar(),
                ),
              ],
            ),
          )
        : Stack(
            children: [
              _buildMySubjects(),
              Align(
                alignment: Alignment.topCenter,
                child: _buildAppBar(),
              ),
            ],
          );
  }
}
