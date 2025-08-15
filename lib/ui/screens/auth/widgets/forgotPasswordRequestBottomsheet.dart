import 'package:eschool/cubits/forgotPasswordRequestCubit.dart';
import 'package:eschool/ui/screens/auth/widgets/customBottomsheet.dart';
import 'package:eschool/ui/widgets/customRoundedButton.dart';
import 'package:eschool/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool/utils/constants.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class ForgotPasswordRequestBottomsheet extends StatefulWidget {
  const ForgotPasswordRequestBottomsheet({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordRequestBottomsheet> createState() =>
      _ForgotPasswordRequestBottomsheetState();
}

class _ForgotPasswordRequestBottomsheetState
    extends State<ForgotPasswordRequestBottomsheet> {
  final TextEditingController _emailTextEditingController =
      TextEditingController();
  final TextEditingController _schooolCodeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool hasPassword = false;
  bool userExist = false;

  @override
  void dispose() {
    _emailTextEditingController.dispose();
    _schooolCodeController.dispose();
    super.dispose();
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
              hintTextKey: emailKey,
              keyboardType: TextInputType.emailAddress,
              textEditingController: _emailTextEditingController,
            ),
            CustomTextFieldContainer(
              hideText: false,
              hintTextKey: "Code Ecole",
              textEditingController: _schooolCodeController,
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
            BlocConsumer<ForgotPasswordRequestCubit,
                ForgotPasswordRequestState>(
              listener: (context, state) {
                if (state is ForgotPasswordRequestFailure) {
                  Utils.showCustomSnackBar(
                    context: context,
                    errorMessage: Utils.getErrorMessageFromErrorCode(
                      context,
                      state.errorMessage,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  );
                } else if (state is ForgotPasswordRequestSuccess) {
                  if (hasPassword) {
                    Get.back(result: {
                      "error": false,
                      "email": _emailTextEditingController.text.trim()
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
                  canPop: context.read<ForgotPasswordRequestCubit>().state
                      is! ForgotPasswordRequestInProgress,
                  child: CustomRoundedButton(
                    onTap: () {
                      if (state is ForgotPasswordRequestInProgress) {
                        return;
                      }
                      FocusScope.of(context).unfocus();
                      if (_emailTextEditingController.text.trim().isEmpty) {
                        Utils.showCustomSnackBar(
                          context: context,
                          errorMessage: Utils.getTranslatedLabel(
                            pleaseEnterEmailKey,
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
                          .read<ForgotPasswordRequestCubit>()
                          .requestforgotPassword(
                            email: _emailTextEditingController.text.trim(),
                            schoolCode: _schooolCodeController.text.trim(),
                            password: _passwordController.text.trim(),
                          );
                    },
                    height: 40,
                    textSize: 16.0,
                    widthPercentage: 0.45,
                    titleColor: Theme.of(context).scaffoldBackgroundColor,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    buttonTitle: Utils.getTranslatedLabel(
                      state is ForgotPasswordRequestInProgress
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
