import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/resultsCubit.dart';
import 'package:eschool/cubits/schoolConfigurationCubit.dart';
import 'package:eschool/data/models/punition.dart';
import 'package:eschool/data/models/result.dart';
import 'package:eschool/data/models/subject.dart';
import 'package:eschool/data/models/subjectMark.dart';
import 'package:eschool/ui/screens/curveSlider.dart';
import 'package:eschool/ui/styles/colors.dart';
import 'package:eschool/ui/widgets/customBackButton.dart';
import 'package:eschool/ui/widgets/customRefreshIndicator.dart';
import 'package:eschool/ui/widgets/customShimmerContainer.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/noDataContainer.dart';
import 'package:eschool/ui/widgets/roundedBackgroundContainer.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoadingContainer.dart';
import 'package:eschool/utils/constants.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class GraphiqueContainer extends StatefulWidget {
  final int? childId;
  final String? childFullName;
  final List<Subject>? subjects;
  const GraphiqueContainer(
      {Key? key, this.childId, this.childFullName, this.subjects})
      : super(key: key);

  @override
  GraphiqueContainerState createState() => GraphiqueContainerState();

  static Widget routeInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return GraphiqueContainer(
      childId: arguments['childId'],
      childFullName: arguments['childFullName'],
    );
  }
}

class GraphiqueContainerState extends State<GraphiqueContainer> {
  late Future<List<PunitionModel>> punitions;

  @override
  void initState() {
    super.initState();
    fetchResults();
  }

  List<FlSpot> _getChartData(List<Result> results) {
    List<FlSpot> spots = [];
    spots.add(FlSpot((0).toDouble(), 0));
    for (int i = 0; i < results.length; i++) {
      double average =
          (results[i].obtainedMark / results[i].subjectMarks.length);
      spots.add(FlSpot((i + 1).toDouble(), average));
    }
    //spots.add(FlSpot((2).toDouble(), 10));
    //spots.add(FlSpot((3).toDouble(), 13));
    //spots.add(FlSpot((4).toDouble(), 9));

    print("spots $spots");
    return spots;
  }

  void fetchResults() {
    context.read<ResultsCubit>().fetchResults(
          useParentApi: context.read<AuthCubit>().isParent(),
          childId: context.read<AuthCubit>().getStudentDetails().id,
        );
  }

  TextStyle _getExamDetailsLabelTextStyle({required BuildContext context}) {
    return TextStyle(
      color: Utils.getColorScheme(context).onSurface,
      fontSize: 15,
      fontWeight: FontWeight.bold,
    );
  }

  Widget _buildResultValueContainer({
    required BuildContext context,
    required BoxConstraints boxConstraints,
    required SubjectMark subjectMark,
  }) {
    final String subjectName = '${subjectMark.subjectName}';
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        bottom: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildResultSubjectNameValueDetailsContainer(
            value: subjectName,
            boxConstraints: boxConstraints,
            isSubject: true,
            buildContext: context,
          ),
          _buildResultValueDetailsContainer(
            value: subjectMark.obtainedMarks.toInt().toString(),
            boxConstraints: boxConstraints,
            isSubject: false,
            buildContext: context,
          ),
        ],
      ),
    );
  }

  Widget _buildResultSubjectNameValueDetailsContainer({
    required String value,
    required BoxConstraints boxConstraints,
    required bool isSubject,
    required BuildContext buildContext,
  }) {
    return SizedBox(
      width: boxConstraints.maxWidth * (0.35),
      child: Text(
        value,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.start,
        style: TextStyle(
          color: Theme.of(buildContext).colorScheme.secondary,
          fontWeight: FontWeight.w400,
          fontSize: 12.0,
        ),
      ),
    );
  }

  Widget _buildResultValueDetailsContainer({
    required String value,
    required BoxConstraints boxConstraints,
    required bool isSubject,
    required BuildContext buildContext,
  }) {
    return SizedBox(
      width: boxConstraints.maxWidth * (0.35),
      child: Text(
        value,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.end,
        style: TextStyle(
          color: isSubject
              ? subjectColor
              : Theme.of(buildContext).colorScheme.secondary,
          fontWeight: FontWeight.w400,
          fontSize: 12.0,
        ),
      ),
    );
  }

  Widget _buildResultDetailsShimmerLoadingContainer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.5),
      width: MediaQuery.of(context).size.width * (0.85),
      height: 80.0,
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerLoadingContainer(
                child: CustomShimmerContainer(
                  width: boxConstraints.maxWidth * (0.7),
                ),
              ),
              SizedBox(
                height: boxConstraints.maxHeight * (0.25),
              ),
              ShimmerLoadingContainer(
                child: CustomShimmerContainer(
                  width: boxConstraints.maxWidth * (0.5),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailsBackgroundContainer({
    required Widget child,
    required BuildContext context,
  }) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 30),
        width: MediaQuery.of(context).size.width * (0.85),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        decoration: BoxDecoration(
          color: Utils.getColorScheme(context).surface,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: child,
      ),
    );
  }

  Widget _buildResultDetailsContainer({
    required Result result,
    required int index,
    required int totalResults,
    required bool hasMoreResults,
    required bool hasMoreResultsInProgress,
    required bool fetchMoreResultsFailure,
  }) {
    return Column(
      children: [
        LayoutBuilder(builder: (context, boxConstraints) {
          return GestureDetector(
            onTap: () {
              Get.toNamed(
                Routes.result,
                arguments: {
                  "childId": context.read<AuthCubit>().getStudentDetails().id,
                  "result": result
                },
              );
            },
            child: _buildDetailsBackgroundContainer(
              context: context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(child: Text(result.examName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),),
                  const SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Matière",
                        style: _getExamDetailsLabelTextStyle(context: context),
                      ),
                      const Spacer(),
                      Text(
                        'Note',
                        style: _getExamDetailsLabelTextStyle(context: context),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ...result.subjectMarks
                      .map(
                        (subjectMark) => _buildResultValueContainer(
                          context: context,
                          boxConstraints: boxConstraints,
                          subjectMark: subjectMark,
                        ),
                      )
                      .toList(),
                  const SizedBox(
                    height: 5,
                  ),
                  Center(
                    child: Text(
                      "Moyenne par domaine",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Wrap(
                    spacing: 20.0,
                    runSpacing: 10.0,
                    children: result.subjectMarks.map((subjectMark) {
                      return Container(
                        width: (MediaQuery.of(context).size.width) / 5,
                        child: CurvedSlider(subjectMark: subjectMark),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        })
      ],
    );
  }

  void schoolConfigurationCubitListener(
      BuildContext context, SchoolConfigurationState state) {
    if (state is SchoolConfigurationFetchSuccess) {
      fetchResults();
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
                    "Notes et grahique",
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
        fetchResults();
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
              BlocBuilder<ResultsCubit, ResultsState>(
                builder: (context, state) {
                  if (state is ResultsFetchSuccess) {
                    return state.results.isNotEmpty
                        ? Column(
                            children: List.generate(
                              state.results.length,
                              (index) => index,
                            ).map((index) {
                              return _buildResultDetailsContainer(
                                result: state.results[index],
                                index: index,
                                totalResults: state.results.length,
                                hasMoreResults:
                                    context.read<ResultsCubit>().hasMore(),
                                hasMoreResultsInProgress:
                                    state.fetchMoreResultsInProgress,
                                fetchMoreResultsFailure:
                                    state.moreResultsFetchError,
                              );
                            }).toList(),
                          )
                        : const Center(
                            child:
                                NoDataContainer(titleKey: noResultPublishedKey),
                          );
                  }
                  return Column(
                    children: List.generate(
                      Utils.defaultShimmerLoadingContentCount,
                      (index) => _buildResultDetailsShimmerLoadingContainer(),
                    ),
                  );
                },
              ),

              BlocBuilder<ResultsCubit, ResultsState>(
                builder: (context, state) {
                  if (state is ResultsFetchSuccess) {
                    return state.results.isNotEmpty
                        ? RoundedBackgroundContainer(
                            child: Column(
                              children: [
                                Center(
                                  child: Text(
                                    "Evolution de la moyenne générale par examen",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                    height: 200,
                                    child: LineChart(
                                      LineChartData(
                                        borderData: FlBorderData(
                                          show: true,
                                          border: Border(
                                            top: BorderSide
                                                .none,
                                            right: BorderSide
                                                .none,
                                            bottom:
                                                BorderSide(),
                                            left:
                                                BorderSide(),
                                          ),
                                        ),
                                        titlesData: FlTitlesData(
                                          show: true,
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                                showTitles:
                                                    true),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                                showTitles:
                                                    true),
                                          ),
                                          topTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                                showTitles:
                                                    false),
                                          ),
                                          rightTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                                showTitles:
                                                    false),
                                          ),
                                        ),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: _getChartData(state.results),
                                            isCurved: true,
                                            color: Colors.blue,
                                            belowBarData: BarAreaData(
                                                show:
                                                    false),
                                          ),
                                        ],
                                        /*minX: 0, // Valeur minimale de l'axe X
                                        maxX: 100, // Valeur maximale de l'axe X
                                        minY: 0, // Valeur minimale de l'axe Y
                                        maxY: 100, // Valeur maximale de l'axe Y*/
                                      ),
                                    )),
                              ],
                            ),
                          )
                        : const Center(
                            child:
                                NoDataContainer(titleKey: noResultPublishedKey),
                          );
                  }
                  return Column(
                    children: List.generate(
                      Utils.defaultShimmerLoadingContentCount,
                      (index) => _buildResultDetailsShimmerLoadingContainer(),
                    ),
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
    return Scaffold(
      body: Stack(
        children: [
          BlocConsumer<SchoolConfigurationCubit, SchoolConfigurationState>(
              listener: schoolConfigurationCubitListener,
              builder: (context, state) {
                if (state is SchoolConfigurationFetchSuccess) {
                  return _buildMySubjects();
                }
                if (state is SchoolConfigurationFetchFailure) {
                  return Center(
                    child: ErrorContainer(
                      errorMessageCode: state.errorMessage,
                      onTapRetry: () {
                        fetchResults();
                      },
                    ),
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              }),
          _buildAppBar(),
        ],
      ),
    );
  }
}
