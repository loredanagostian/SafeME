import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/managers/authentication_manager.dart';
import 'package:safe_me/screens/forgot_password_screen.dart';
import 'package:safe_me/screens/main_screen.dart';
import 'package:safe_me/screens/signup_screen.dart';
import 'package:safe_me/widgets/custom_bottom_tab_navigator.dart';
import 'package:safe_me/widgets/custom_button.dart';
import 'package:safe_me/widgets/custom_snackbar.dart';
import 'package:safe_me/widgets/custom_textfield.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<bool> validateFields(String email, String password) async {
    AuthenticationManager authManager = AuthenticationManager();
    String message = '';

    if (email.isNotEmpty && password.isNotEmpty) {
      if (RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(email)) {
        message = await authManager.logInUser(email, password);
        if (message == '') {
          return true;
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: CustomSnackbarContent(snackBarMessage: message),
              backgroundColor: AppColors.mainRed,
            ));
          }
        }
      } else {
        message = AppStrings.invalidEmail;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: CustomSnackbarContent(snackBarMessage: message),
          backgroundColor: AppColors.mainRed,
        ));
      }
    } else {
      message = AppStrings.allFieldsMustBeCompleted;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: CustomSnackbarContent(snackBarMessage: message),
        backgroundColor: AppColors.mainRed,
      ));
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.mediumDistance),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.login,
                    style: AppStyles.titleStyle,
                  ),
                  const SizedBox(height: AppSizes.titleFieldDistance),
                  Text(
                    AppStrings.email,
                    style: AppStyles.buttonTextStyle
                        .copyWith(color: AppColors.mainDarkGray),
                  ),
                  CustomTextField(
                    controller: emailController,
                    hintText: AppStrings.email,
                    isEmail: true,
                  ),
                  const SizedBox(height: AppSizes.bigDistance),
                  Text(
                    AppStrings.password,
                    style: AppStyles.buttonTextStyle
                        .copyWith(color: AppColors.mainDarkGray),
                  ),
                  CustomTextField(
                    controller: passwordController,
                    hintText: AppStrings.password,
                    isPassword: true,
                    isDone: true,
                  ),
                  const SizedBox(height: AppSizes.smallDistance),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ForgotPasswordScreen())),
                      child: Text(
                        AppStrings.forgotPassword,
                        style: AppStyles.sectionTitleStyle.copyWith(
                            color: AppColors.mainBlue.withOpacity(0.8)),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.titleFieldDistance),
                  CustomButton(
                      buttonColor: AppColors.mainBlue,
                      buttonText: AppStrings.login,
                      // LOGIN with Firebase
                      onTap: () async {
                        bool shouldLogin = await validateFields(
                            emailController.text, passwordController.text);

                        if (shouldLogin && mounted) {
                          ref
                              .read(bottomNavigatorIndex.notifier)
                              .update((state) => 1);
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MainScreen()),
                              (route) => false);
                        }
                      }),
                  const SizedBox(height: AppSizes.bigDistance),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${AppStrings.dontHaveAccount} ",
                        style: AppStyles.buttonTextStyle
                            .copyWith(color: AppColors.darkGray),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignupScreen())),
                        child: Text(
                          AppStrings.signup,
                          style: AppStyles.buttonTextStyle.copyWith(
                              color: AppColors.mainBlue,
                              fontWeight: FontWeight.w600),
                        ),
                      )
                    ],
                  )
                ]),
          ),
        ),
      ),
    );
  }
}
