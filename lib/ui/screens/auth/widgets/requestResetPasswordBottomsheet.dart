import 'package:eschool/cubits/resetPasswordRequestCubit.dart';
import 'package:eschool/ui/screens/auth/widgets/customBottomsheet.dart';
import 'package:eschool/ui/widgets/customRoundedButton.dart';
import 'package:eschool/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool/utils/constants.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class RequestResetPasswordBottomsheet extends StatefulWidget {
  const RequestResetPasswordBottomsheet({Key? key}) : super(key: key);

  @override
  State<RequestResetPasswordBottomsheet> createState() =>
      _RequestResetPasswordBottomsheetState();
}

class _RequestResetPasswordBottomsheetState
    extends State<RequestResetPasswordBottomsheet> {
  final TextEditingController _grNumberTextEditingController =
      TextEditingController();
  final TextEditingController _schooolCodeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool hasPassword = false;
  bool userExist = false;

  DateTime? dateOfBirth;

  @override
  void dispose() {
    _grNumberTextEditingController.dispose();
    _schooolCodeController.dispose();
    super.dispose();
  }

  String _formatDateOfBirth() {
    return Utils.formatDate(dateOfBirth!);
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomsheet(
      titleLabelKey: forgotPasswordKey,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
        child: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            CustomTextFieldContainer(
              hideText: false,
              hintTextKey: grNumberKey,
              textEditingController: _grNumberTextEditingController,
            ),
            CustomTextFieldContainer(
              hideText: false,
              hintTextKey: "Code Ecole",
              textEditingController: _schooolCodeController,
            ),
            GestureDetector(
              onTap: () {
                showDatePicker(
                  locale: Locale('fr', 'FR'),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                              onPrimary:
                                  Theme.of(context).scaffoldBackgroundColor,
                            ),
                      ),
                      child: child!,
                    );
                  },
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(
                    DateTime.now().year - 50,
                  ),
                  lastDate: DateTime.now(),
                ).then((value) {
                  dateOfBirth = value;
                  setState(() {});
                });
              },
              child: Container(
                alignment: AlignmentDirectional.centerStart,
                width: MediaQuery.of(context).size.width,
                height: 50,
                margin: const EdgeInsets.only(bottom: 10.0),
                padding: const EdgeInsetsDirectional.only(
                  start: 20.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Utils.getColorScheme(context).secondary,
                  ),
                ),
                child: Text(
                  dateOfBirth == null
                      ? Utils.getTranslatedLabel(dateOfBirthKey)
                      : _formatDateOfBirth(),
                  style: TextStyle(
                    color: Utils.getColorScheme(context).secondary,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            userExist
                ? CustomTextFieldContainer(
                    hideText: false,
                    hintTextKey: "Nouveau mot de passe",
                    textEditingController: _passwordController,
                  )
                : SizedBox(),
            SizedBox(
              height: MediaQuery.of(context).size.height * (0.025),
            ),
            BlocConsumer<RequestResetPasswordCubit, RequestResetPasswordState>(
              listener: (context, state) {
                if (state is RequestResetPasswordFailure) {
                  Utils.showCustomSnackBar(
                    context: context,
                    errorMessage: Utils.getErrorMessageFromErrorCode(
                      context,
                      state.errorMessage,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  );
                } else if (state is RequestResetPasswordSuccess) {
                  if (hasPassword) {
                    Utils.showCustomSnackBar(
                      context: context,
                      errorMessage: Utils.getTranslatedLabel(
                        "Votre mot de passe a été modifier avec succès",
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    );
                    Get.back(result: {
                      "error": false,
                    });
                  } else {
                    setState(() {
                      userExist = true;
                    });
                  }
                }
              },
              builder: (context, state) {
                return PopScope(
                  canPop: context.read<RequestResetPasswordCubit>().state
                      is! RequestResetPasswordInProgress,
                  child: CustomRoundedButton(
                    onTap: () {
                      if (state is RequestResetPasswordInProgress) {
                        return;
                      }
                      FocusScope.of(context).unfocus();
                      if (_grNumberTextEditingController.text.trim().isEmpty) {
                        Utils.showCustomSnackBar(
                          context: context,
                          errorMessage: Utils.getTranslatedLabel(
                            enterGrNumberKey,
                          ),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        );
                        return;
                      }
                      if (_schooolCodeController.text.trim().isEmpty) {
                        Utils.showCustomSnackBar(
                          context: context,
                          errorMessage: Utils.getTranslatedLabel(
                            "Entrer le code de l'école",
                          ),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        );
                        return;
                      }
                      if (dateOfBirth == null) {
                        Utils.showCustomSnackBar(
                          context: context,
                          errorMessage: Utils.getTranslatedLabel(
                            selectDateOfBirthKey,
                          ),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        );
                        return;
                      }
                      if (userExist &&
                          _passwordController.text.trim().isEmpty) {
                        Utils.showCustomSnackBar(
                          context: context,
                          errorMessage: Utils.getTranslatedLabel(
                            "Veuillez entrer votre nouveau mot de passe",
                          ),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        );
                        return;
                      }
                      if (userExist && _passwordController.text.length < 8) {
                        Utils.showCustomSnackBar(
                          context: context,
                          errorMessage: Utils.getTranslatedLabel(
                            "Votre mot de passe est trop court",
                          ),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        );
                        return;
                      }
                      if (_passwordController.text.trim().isNotEmpty) {
                        setState(() {
                          hasPassword = true;
                        });
                      }

                      context
                          .read<RequestResetPasswordCubit>()
                          .requestResetPassword(
                            grNumber:
                                _grNumberTextEditingController.text.trim(),
                            schoolCode: _schooolCodeController.text.trim(),
                            dob: dateOfBirth!,
                            password: _passwordController.text.trim(),
                          );
                    },
                    height: 45,
                    textSize: 16.0,
                    widthPercentage: 0.55,
                    titleColor: Theme.of(context).scaffoldBackgroundColor,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    buttonTitle: Utils.getTranslatedLabel(
                      state is RequestResetPasswordInProgress
                          ? submittingKey
                          : submitKey,
                    ),
                    showBorder: false,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

}
