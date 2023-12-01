import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/screens/forgot_password_screen.dart';
import 'package:safe_me/screens/friends_screen.dart';
import 'package:safe_me/screens/home_screen.dart';
import 'package:safe_me/screens/signup_screen.dart';
import 'package:safe_me/widgets/custom_button.dart';
import 'package:safe_me/widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
                      onTap: () => Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const FriendsScreen()),
                          (Route<dynamic> route) => false)),
                  const SizedBox(height: AppSizes.mediumDistance),
                  CustomButton(
                    buttonColor: AppColors.mainBlue,
                    buttonText: AppStrings.loginWithGoogle,
                    onTap: () {},
                    isGoogle: true,
                  ),
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
                        onTap: () => Navigator.push(
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
