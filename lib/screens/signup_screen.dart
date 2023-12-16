import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/screens/home_screen.dart';
import 'package:safe_me/screens/login_screen.dart';
import 'package:safe_me/widgets/custom_button.dart';
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

  @override
  Widget build(BuildContext context) {
    String snackBarMessage;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.mainDarkGray,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                  ),
                  const SizedBox(height: AppSizes.buttonHeight),
                  CustomButton(
                      buttonColor: AppColors.mainBlue,
                      buttonText: AppStrings.signupTitle,
                      // REGISTER to Firebase function
                      onTap: () async {
                        if (passwordController.text ==
                                confirmPasswordController.text &&
                            RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(emailController.text)) {
                          try {
                            await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                  email: emailController.text,
                                  password: passwordController.text,
                                )
                                .then((value) => Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const HomeScreen()),
                                    (route) => false));
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'weak-password') {
                              snackBarMessage = AppStrings.passwordTooWeak;
                            } else if (e.code == 'email-already-in-use') {
                              snackBarMessage = AppStrings.emailAlreadyExists;
                            }
                          } catch (e) {
                            snackBarMessage = e.toString();
                          }
                        } else {
                          snackBarMessage = AppStrings.invalidCredentials;

                          final SnackBar snackBar = SnackBar(
                            content: SizedBox(
                              height: AppSizes.bigDistance,
                              child: Row(children: [
                                const Icon(
                                  Icons.priority_high,
                                  color: AppColors.white,
                                ),
                                const SizedBox(width: AppSizes.smallDistance),
                                Text(
                                  snackBarMessage,
                                  style: AppStyles.bottomItemStyle
                                      .copyWith(color: AppColors.white),
                                )
                              ]),
                            ),
                            backgroundColor: AppColors.mainRed,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      }),
                  const SizedBox(height: AppSizes.mediumDistance),
                  CustomButton(
                    buttonColor: AppColors.mainBlue,
                    buttonText: AppStrings.signupWithGoogle,
                    // REGISTER with Google
                    onTap: () async {
                      final GoogleSignInAccount? googleUser =
                          await GoogleSignIn().signIn();

                      final GoogleSignInAuthentication? googleAuth =
                          await googleUser?.authentication;

                      final credential = GoogleAuthProvider.credential(
                        accessToken: googleAuth?.accessToken,
                        idToken: googleAuth?.idToken,
                      );

                      return await FirebaseAuth.instance
                          .signInWithCredential(credential)
                          .then((value) => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomeScreen()),
                              (route) => false));
                    },
                    isGoogle: true,
                  ),
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
