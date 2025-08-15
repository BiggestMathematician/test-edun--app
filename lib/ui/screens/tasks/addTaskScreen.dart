import 'package:eschool/cubits/applyLeaveCubit.dart';
import 'package:eschool/cubits/leaveSettingsCubit.dart';
import 'package:eschool/ui/widgets/customAppbar.dart';
import 'package:eschool/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool/ui/widgets/customRoundedButton.dart';
import 'package:eschool/ui/widgets/customTextContainer.dart';
import 'package:eschool/ui/widgets/customTextareaFieldContainer.dart';
import 'package:eschool/utils/constants.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class Addtaskscreen extends StatefulWidget {
  const Addtaskscreen({super.key});

  static Widget routeInstance() => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ApplyLeaveCubit(),
          ),
          BlocProvider(
            create: (context) => LeaveSettingsAndSessionYearsCubit(),
          ),
        ],
        child: const Addtaskscreen(),
      );

  @override
  State<Addtaskscreen> createState() => _AddtaskscreenState();
}

class _AddtaskscreenState extends State<Addtaskscreen> {
  late final TextEditingController _textEditingController =
      TextEditingController();
  late final TextEditingController _durationEditingController =
      TextEditingController();

  DateTime? _selectedToDate;

  Widget _buildBackgroundContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
          ),
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(5)),
      padding: EdgeInsets.symmetric(
          horizontal: appContentHorizontalPadding, vertical: 5),
      child: child,
    );
  }

  @override
  void initState() {
    super.initState();
    _durationEditingController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    String text = _durationEditingController.text;

    // Ajouter le deux-points automatiquement après les 2 premiers chiffres
    if (text.length == 2 && !text.contains(':')) {
      _durationEditingController.text = "$text:";
      _durationEditingController.selection = TextSelection.collapsed(
          offset: _durationEditingController.text.length);
    }
  }

  bool _isValidDurationFormat(String text) {
    RegExp regExp = RegExp(r'^([01]?[0-9]|2[0-3]):([0-5]?[0-9])$');
    return regExp.hasMatch(text);
  }

  void onTapToDate() async {
    final selectedDate = await showDatePicker(
      locale: Locale('fr'),
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(
          DateTime.now().year + 3, DateTime.now().month, DateTime.now().day),
    );
    if (selectedDate != null) {
      _selectedToDate = selectedDate;
      setState(() {});
    }
  }

  Widget _buildAssignmentDetailsContainer() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: Utils.getScrollViewBottomPadding(context),
        top: Utils.getScrollViewTopPadding(
          context: context,
          appBarHeightPercentage: Utils.appBarSmallerHeightPercentage,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).colorScheme.surface,
                padding: EdgeInsets.all(appContentHorizontalPadding),
                child: Column(
                  children: [
                    CustomTextAreaFieldContainer(
                      borderColor: Colors.grey,
                      textEditingController: _textEditingController,
                      maxLines: 5,
                      hintTextKey: "nom de la tâche",
                    ),
                    _buildBackgroundContainer(
                        child: GestureDetector(
                      onTap: onTapToDate,
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.transparent)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            CustomTextContainer(
                                textKey: _selectedToDate != null
                                    ? ""
                                    : "date d'échéance"),
                            const SizedBox(
                              width: 10,
                            ),
                            _selectedToDate != null
                                ? CustomTextContainer(
                                    textKey: Utils.formatDate(_selectedToDate!))
                                : const SizedBox()
                          ],
                        ),
                      ),
                    )),
                    CustomTextAreaFieldContainer(
                      textEditingController: _durationEditingController,
                      maxLines: 1,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: false),
                      hintTextKey: "Durée (à consacrer à la tâche)",
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                        LengthLimitingTextInputFormatter(5),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              _buildSubmitLeaveContainer()
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSubmitLeaveContainer() {
    return BlocConsumer<ApplyLeaveCubit, ApplyLeaveState>(
      listener: (context, state) {
        if (state is ApplyLeaveSuccess) {
          _textEditingController.clear();
          _durationEditingController.clear();
          _selectedToDate = null;
          setState(() {});
          Utils.showSnackBar(
              message: "Tâche ajouter avec succès", context: context);
        } else if (state is ApplyLeaveFailure) {
          Utils.showSnackBar(message: state.errorMessage, context: context);
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: state is! ApplyLeaveInProgress,
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            color: Theme.of(context).colorScheme.surface,
            child: CustomRoundedButton(
              height: 35,
              widthPercentage: 1.0,
              backgroundColor: Theme.of(context).colorScheme.primary,
              buttonTitle: "Soumettre",
              radius: 5,
              textSize: 16.0,
              fontWeight: FontWeight.w500,
              showBorder: false,
              child: state is ApplyLeaveInProgress
                  ? const CustomCircularProgressIndicator()
                  : null,
              onTap: () {
                if (state is ApplyLeaveInProgress) {
                  return;
                }

                if (_textEditingController.text.trim().isEmpty) {
                  Utils.showSnackBar(
                      message: "Veuillez ajouter le nom de la tâche",
                      context: context);
                  return;
                }

                if (_selectedToDate == null) {
                  Utils.showSnackBar(
                      message: "Veuillez ajouter la date d'échéance",
                      context: context);
                  return;
                }

                String text = _durationEditingController.text.trim();
                if (text.isEmpty) {
                  Utils.showSnackBar(
                      message: "Veuillez ajouter la durée", context: context);
                  return;
                } else if (!_isValidDurationFormat(text)) {
                  Utils.showSnackBar(
                      message: "Format incorrect, veuillez utiliser hh:mm",
                      context: context);
                  return;
                }

                context.read<ApplyLeaveCubit>().submitTask(
                    name: _textEditingController.text.trim(),
                    endDate: _selectedToDate!,
                    duration: _durationEditingController.text.trim());
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildAssignmentDetailsContainer(),
          CustomAppBar(
            title: "Ajouter une tâche",
            onPressBackButton: () {
              ///TOOD: [Check here the issue with back button]
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
