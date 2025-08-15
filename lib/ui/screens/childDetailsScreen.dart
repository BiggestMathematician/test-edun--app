import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/noticeBoardCubit.dart';
import 'package:eschool/cubits/resultsCubit.dart';
import 'package:eschool/cubits/schoolConfigurationCubit.dart';
import 'package:eschool/cubits/schoolGalleryCubit.dart';
import 'package:eschool/cubits/studentSubjectAndSlidersCubit.dart';
import 'package:eschool/data/models/result.dart';
import 'package:eschool/data/models/school_moddel.dart';
import 'package:eschool/data/models/student.dart';
import 'package:eschool/data/models/subjectMark.dart';
import 'package:eschool/data/models/weeklyAnnouncement.dart';
import 'package:eschool/data/repositories/schoolRepository.dart';
import 'package:eschool/ui/screens/curveSlider.dart';
import 'package:eschool/ui/styles/colors.dart';
import 'package:eschool/ui/widgets/attendanceCountContainer.dart';
import 'package:eschool/ui/widgets/borderedProfilePictureContainer.dart';
import 'package:eschool/ui/widgets/contentTitleWithViewmoreButton.dart';
import 'package:eschool/ui/widgets/customBackButton.dart';
import 'package:eschool/ui/widgets/customShimmerContainer.dart';
import 'package:eschool/ui/widgets/errorContainer.dart';
import 'package:eschool/ui/widgets/latestNoticesContainer.dart';
import 'package:eschool/ui/widgets/noDataContainer.dart';
import 'package:eschool/ui/widgets/roundedBackgroundContainer.dart';
import 'package:eschool/ui/widgets/schoolGalleryContainer.dart';
import 'package:eschool/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoaders/announcementShimmerLoadingContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoaders/subjectsShimmerLoadingContainer.dart';
import 'package:eschool/ui/widgets/shimmerLoadingContainer.dart';
import 'package:eschool/ui/widgets/studentSubjectsContainer.dart';
import 'package:eschool/ui/widgets/weeklySliderContainer.dart';
import 'package:eschool/utils/api.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/systemModules.dart';
import 'package:eschool/utils/utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ChildDetailsScreen extends StatefulWidget {
  final Student student;
  const ChildDetailsScreen({Key? key, required this.student}) : super(key: key);

  @override
  State<ChildDetailsScreen> createState() => _ChildDetailsScreenState();

  static Widget routeInstance() {
    return BlocProvider(
      create: (context) => SchoolGalleryCubit(SchoolRepository()),
      child: ChildDetailsScreen(
        student: Get.arguments as Student,
      ),
    );
  }
}

class _ChildDetailsScreenState extends State<ChildDetailsScreen> {
  SchoolModel? school;
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      fetchChildSchoolDetails();
    });
    super.initState();
    getLeaveRequests();
  }

  List<Weeklyannouncement> annonces = [];
  bool wekAnnLoading = true;

  Future<List<Weeklyannouncement>> getLeaveRequests() async {
    try {
      final result =
          await Api.get(url: Api.getWeeklyAnnouncement, useAuthToken: true);

      wekAnnLoading = false;
      annonces = ((result['data']['announcements'] ?? []) as List)
          .map((leaveRequest) =>
              Weeklyannouncement.fromJson(Map.from(leaveRequest ?? {})))
          .toList();
      var schoolfromapi = result['data']['school'];
        school = SchoolModel.fromJson(schoolfromapi);

      // Retourner la variable annonces
      return annonces;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  void fetchChildSchoolDetails() {
    context.read<SchoolConfigurationCubit>().fetchSchoolConfiguration(
        useParentApi: true, childId: widget.student.id ?? 0);
  }

  void fetchChildSubjectAndSliders() {
    context.read<StudentSubjectsAndSlidersCubit>().fetchSubjectsAndSliders(
        isSliderModuleEnable: Utils.isModuleEnabled(
            context: context, moduleId: sliderManagementModuleId.toString()),
        useParentApi: true,
        childId: widget.student.id ?? 0);
  }

  void fetchNoticeBoardDetails() {
    if (Utils.isModuleEnabled(
        context: context,
        moduleId: announcementManagementModuleId.toString())) {
      context.read<NoticeBoardCubit>().fetchNoticeBoardDetails(
          useParentApi: true, childId: widget.student.id);
    }
  }

  void fetchGalleryDetails() {
    if (Utils.isModuleEnabled(
        context: context, moduleId: galleryManagementModuleId.toString())) {
      context.read<SchoolGalleryCubit>().fetchSchoolGallery(
          useParentApi: true,
          childId: widget.student.id,
          sessionYearId: context
                  .read<SchoolConfigurationCubit>()
                  .getSchoolConfiguration()
                  .sessionYear
                  .id ??
              0);
    }
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

  List<FlSpot> _getChartData(List<Result> results) {
    List<FlSpot> spots = [];
    spots.add(FlSpot((0).toDouble(), 0));
    for (int i = 0; i < results.length; i++) {
      double average = (results[i].obtainedMark /
          results[i]
              .subjectMarks
              .length);
      spots.add(FlSpot((i + 1).toDouble(), average));
    }
    //spots.add(FlSpot((2).toDouble(), 10));
    //spots.add(FlSpot((3).toDouble(), 13));
    //spots.add(FlSpot((4).toDouble(), 9));

    print("spots $spots");
    return spots;
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
          /*_buildResultValueDetailsContainer(
            value: subjectMark.avarageClass.toInt().toString(),
            boxConstraints: boxConstraints,
            isSubject: false,
            buildContext: context,
          ),
          _buildResultValueDetailsContainer(
            value: subjectMark.grade,
            boxConstraints: boxConstraints,
            isSubject: false,
            buildContext: context,
          ),*/
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
                arguments: {"childId": widget.student.id, "result": result},
              );
            },
            child: _buildDetailsBackgroundContainer(
              context: context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  const Center(
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
                      return SizedBox(
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

  void fetchResults() {
    context.read<ResultsCubit>().fetchResults(
          useParentApi: context.read<AuthCubit>().isParent(),
          childId: widget.student.id,
        );
  }

  void schoolConfigurationCubitListener(
      BuildContext context, SchoolConfigurationState state) {
    if (state is SchoolConfigurationFetchSuccess) {
      fetchChildSubjectAndSliders();
      fetchNoticeBoardDetails();
      fetchGalleryDetails();
      fetchResults();
    }
  }

  Widget _buildAppBar() {
    return Align(
      alignment: Alignment.topCenter,
      child: ScreenTopBackgroundContainer(
        padding: EdgeInsets.zero,
        heightPercentage: Utils.appBarBiggerHeightPercentage,
        child: LayoutBuilder(
          builder: (context, boxConstraints) {
            return Stack(
              children: [
                //Bordered circles
                PositionedDirectional(
                  top: MediaQuery.of(context).size.width * (-0.15),
                  start: MediaQuery.of(context).size.width * (-0.225),
                  child: Container(
                    padding: const EdgeInsetsDirectional.only(
                      end: 20.0,
                      bottom: 20.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context)
                            .scaffoldBackgroundColor
                            .withOpacity(0.1),
                      ),
                      shape: BoxShape.circle,
                    ),
                    width: MediaQuery.of(context).size.width * (0.6),
                    height: MediaQuery.of(context).size.width * (0.6),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context)
                              .scaffoldBackgroundColor
                              .withOpacity(0.1),
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                //bottom fill circle
                PositionedDirectional(
                  bottom: MediaQuery.of(context).size.width * (-0.15),
                  end: MediaQuery.of(context).size.width * (-0.15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .scaffoldBackgroundColor
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    width: MediaQuery.of(context).size.width * (0.4),
                    height: MediaQuery.of(context).size.width * (0.4),
                  ),
                ),
                CustomBackButton(
                  topPadding: MediaQuery.of(context).padding.top +
                      Utils.appBarContentTopPadding,
                ),
                Align(
                  alignment: AlignmentDirectional.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                      left: 10,
                      right: 10.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BorderedProfilePictureContainer(
                          onTap: () {
                            Get.toNamed(
                              Routes.studentProfile,
                              arguments: widget.student.id,
                            );
                          },
                          heightAndWidth: boxConstraints.maxWidth * (0.16),
                          imageUrl:
                              widget.student.childUserDetails?.image ?? "",
                        ),
                        SizedBox(
                          height: boxConstraints.maxHeight * (0.045),
                        ),
                        Text(
                          widget.student.getFullName(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 15.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: boxConstraints.maxHeight * (0.0125),
                        ),
                        Text(
                          "${Utils.getTranslatedLabel(classKey)} - ${widget.student.classSection?.fullName}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 11.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                BlocBuilder<StudentSubjectsAndSlidersCubit,
                    StudentSubjectsAndSlidersState>(
                  builder: (context, state) {
                    if (state is StudentSubjectsAndSlidersFetchSuccess) {
                      return Align(
                        alignment: AlignmentDirectional.topEnd,
                        child: Column(
                          children: [
                            IconButton(
                              color: Theme.of(context).colorScheme.surface,
                              padding: EdgeInsets.only(
                                top: MediaQuery.of(context).padding.top +
                                    Utils.appBarContentTopPadding,
                              ),
                              onPressed: () {
                                Get.toNamed(
                                  Routes.parentMenu,
                                  arguments: {
                                    "student": widget.student,
                                    "subjectsForFilter": context
                                        .read<StudentSubjectsAndSlidersCubit>()
                                        .getSubjectsForAssignmentContainer()
                                  },
                                );
                              },
                              icon: const Icon(Icons.school),
                            ),
                            IconButton(
                              color: Theme.of(context).colorScheme.surface,
                              padding: const EdgeInsets.only(
                                top: 0,
                              ),
                              onPressed: () {
                                Get.toNamed(
                                  Routes.notifications,
                                  arguments: {
                                    "student": widget.student,
                                    "subjectsForFilter": context
                                        .read<StudentSubjectsAndSlidersCubit>()
                                        .getSubjectsForAssignmentContainer()
                                  },
                                );
                              },
                              icon: const Icon(Icons.notifications_on_outlined),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDataLoadingContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerLoadingContainer(
          child: CustomShimmerContainer(
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * (0.075),
            ),
            width: MediaQuery.of(context).size.width,
            borderRadius: 25,
            height: MediaQuery.of(context).size.height *
                Utils.appBarBiggerHeightPercentage,
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * (0.025),
        ),
        const SubjectsShimmerLoadingContainer(),
        SizedBox(
          height: MediaQuery.of(context).size.height * (0.025),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * (0.075),
          ),
          child: Column(
            children: List.generate(2, (index) => index)
                .map(
                  (e) => const AnnouncementShimmerLoadingContainer(),
                )
                .toList(),
          ),
        )
      ],
    );
  }

  Widget _buildSubjectsAndInformationsContainer() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: Utils.getScrollViewTopPadding(
          context: context,
          appBarHeightPercentage: Utils.appBarBiggerHeightPercentage,
        ),
      ),
      child: BlocBuilder<StudentSubjectsAndSlidersCubit,
          StudentSubjectsAndSlidersState>(
        builder: (context, state) {
          if (state is StudentSubjectsAndSlidersFetchSuccess) {
            return Column(
              children: [
                if (annonces.isNotEmpty)
                  Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width *
                            Utils.screenContentHorizontalPaddingInPercentage,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Annonce de la semaine',
                          style: TextStyle(
                            color: Utils.getColorScheme(context).secondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.0,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      )),
                const SizedBox(
                  height: 5,
                ),
                WeeklySliderContainer(sliders: annonces),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ContentTitleWithViewMoreButton(
                    contentTitleKey: "Dernières notes obtenu",
                    showViewMoreButton: true,
                    viewMoreOnTap: () {
                      Get.toNamed(Routes.childResults,
                          arguments: {"childId": widget.student.id});
                    },
                  ),
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
                                  result: state.results.last,
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
                              child: NoDataContainer(
                                  titleKey: noResultPublishedKey),
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
                                  const Center(
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
                                            border: const Border(
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
                                          titlesData: const FlTitlesData(
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
                                              spots:
                                                  _getChartData(state.results),
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
                              child: NoDataContainer(
                                  titleKey: noResultPublishedKey),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ContentTitleWithViewMoreButton(
                    contentTitleKey: "Retard et absence",
                    showViewMoreButton: true,
                    viewMoreOnTap: () {
                      Get.toNamed(Routes.childAttendance,
                          arguments: widget.student.id);
                    },
                  ),
                ),
                AttendanceCountContainer(
                    id: widget.student.userId!, childId: widget.student.id!),
                StudentSubjectsContainer(
                  subjects: context
                      .read<StudentSubjectsAndSlidersCubit>()
                      .getSubjects(),
                  subjectsTitleKey: subjectsKey,
                  childId: widget.student.id,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * (0.025),
                ),
                Utils.isModuleEnabled(
                        context: context,
                        moduleId: announcementManagementModuleId.toString())
                    ? LatestNoticiesContainer(
                        childId: widget.student.id,
                      )
                    : const SizedBox(),
                Utils.isModuleEnabled(
                        context: context,
                        moduleId: galleryManagementModuleId.toString())
                    ? SchoolGalleryContainer(
                        student: widget.student,
                      )
                    : const SizedBox(),
              ],
            );
          }
          if (state is StudentSubjectsAndSlidersFetchFailure) {
            return Center(
              child: ErrorContainer(
                errorMessageCode: state.errorMessage,
                onTapRetry: () {
                  fetchChildSubjectAndSliders();
                },
              ),
            );
          }
          return _buildDataLoadingContainer();
        },
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
                  return _buildSubjectsAndInformationsContainer();
                }
                if (state is SchoolConfigurationFetchFailure) {
                  return Center(
                    child: ErrorContainer(
                      errorMessageCode: state.errorMessage,
                      onTapRetry: () {
                        fetchChildSchoolDetails();
                      },
                    ),
                  );
                }

                return _buildDataLoadingContainer();
              }),
          _buildAppBar(),
        ],
      ),
    );
  }
}
