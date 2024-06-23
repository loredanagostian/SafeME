import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/managers/authentication_manager.dart';
import 'package:safe_me/screens/onboarding_screens/login_screen.dart';
import 'package:safe_me/screens/onboarding_screens/verify_email_screen.dart';
import 'package:safe_me/widgets/custom_button.dart';
import 'package:safe_me/widgets/custom_snackbar.dart';
import 'package:safe_me/widgets/custom_textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Future<Map<String, String>> signUpUser(String email, String password) async {
    AuthenticationManager authManager = AuthenticationManager();
    return await authManager.signUpUser(email, password);
  }

  Future<String> validateFields(
      String email, String password, String confirmPassword) async {
    Map<String, String> message;
    if (email.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        password == confirmPassword) {
      message = await signUpUser(email, password);
      if (message.values.first == '') {
        return message.keys.first;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                CustomSnackbarContent(snackBarMessage: message.values.first),
            backgroundColor: AppColors.mainRed,
          ));
        }
      }
    } else {
      if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: CustomSnackbarContent(
              snackBarMessage: AppStrings.allFieldsMustBeCompleted),
          backgroundColor: AppColors.mainRed,
        ));
      else
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: CustomSnackbarContent(
              snackBarMessage: AppStrings.invalidCredentials),
          backgroundColor: AppColors.mainRed,
        ));
    }
    return '';
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
                    AppStrings.signupTitle,
                    style: AppStyles.titleStyle,
                  ),
                  const SizedBox(height: AppSizes.buttonHeight),
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
                  ),
                  const SizedBox(height: AppSizes.bigDistance),
                  Text(
                    AppStrings.confirmPassword,
                    style: AppStyles.buttonTextStyle
                        .copyWith(color: AppColors.mainDarkGray),
                  ),
                  CustomTextField(
                    controller: confirmPasswordController,
                    hintText: AppStrings.confirmPassword,
                    isPassword: true,
                    isDone: true,
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.25),
                  CustomButton(
                      buttonColor: AppColors.mainBlue,
                      buttonText: AppStrings.signupTitle,
                      // REGISTER to Firebase function
                      onTap: () async {
                        String success = await validateFields(
                            emailController.text,
                            passwordController.text,
                            confirmPasswordController.text);

                        if (success != '') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VerifyEmail()));
                        }
                      }),
                  const SizedBox(height: AppSizes.bigDistance),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${AppStrings.alreadyHaveAccount} ",
                        style: AppStyles.buttonTextStyle
                            .copyWith(color: AppColors.darkGray),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen())),
                        child: Text(
                          AppStrings.signin,
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
