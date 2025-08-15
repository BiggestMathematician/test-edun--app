import 'dart:convert';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/data/models/punition.dart';
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

class PunitionContainer extends StatefulWidget {
  final int? childId;
  final String? childFullName;
  final List<Subject>? subjects;
  const PunitionContainer({Key? key, this.childId, this.childFullName, this.subjects})
      : super(key: key);

  @override
  PunitionContainerState createState() => PunitionContainerState();

  static Widget routeInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return PunitionContainer(
      childId: arguments['childId'],
      childFullName: arguments['childFullName'],
    );
  }
}

class PunitionContainerState extends State<PunitionContainer> {
  late Future<List<PunitionModel>> punitions;

  @override
  void initState() {
    super.initState();
    punitions = fetchPunitions();
  }

  // Récupérer les tâches PunitionModel
  Future<List<PunitionModel>> fetchPunitions() async {
    try {
      final response =
          await Api.post(url: Api.studentPunitions, useAuthToken: true, body: {"childId": widget.childId});
      print("le resultat des punitions $response");
      List<dynamic> jsonList = response['data'] is List
          ? response['data']
          : json.decode(response['data']);

      return jsonList.map((json) => PunitionModel.fromJson(json)).toList();
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
                    widget.childFullName != null
                        ? "Les punitions de ${widget.childFullName}"
                        : "Mes punitions",
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
        punitions = fetchPunitions();
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
              FutureBuilder<List<PunitionModel>>(
                future: punitions,
                builder: (BuildContext context,
                    AsyncSnapshot<List<PunitionModel>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur : ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: const Text('Aucune punition trouvée'));
                  }

                  List<PunitionModel> punitionsList = snapshot.data!;

                  return Table(
                    border: TableBorder.all(),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey[200]),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Punition',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ),
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
                              'Statut',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 8),
                            ),
                          ),
                        ],
                      ),

                      // Lignes des données
                      ...punitionsList.map((punition) {
                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(punition.title!),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(punition.description!),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(punition.teacher!.fullName!),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  punition.status == 0
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.dangerous,
                                            size: 15,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {},
                                        )
                                      : IconButton(
                                          icon: const Icon(
                                            Icons.check,
                                            size: 15,
                                            color: Colors.green,
                                          ),
                                          onPressed: () {},
                                        ),
                                ],
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
