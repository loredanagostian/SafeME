import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/screens/complete_profile_screen.dart';
import 'package:safe_me/widgets/custom_button.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  bool isEmailVerified = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser?.sendEmailVerification();
    timer =
        Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerified());
  }

  checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => const CompleteProfileScreen()),
          (route) => false);

      timer?.cancel();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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
                    AppStrings.verifyEmail,
                    style: AppStyles.titleStyle,
                  ),
                  const SizedBox(height: AppSizes.smallDistance),
                  Text(
                    AppStrings.sentVerificationEmail,
                    style: AppStyles.hintComponentStyle.copyWith(fontSize: 15),
                  ),
                  Text(
                    FirebaseAuth.instance.currentUser?.email ?? "",
                    style: AppStyles.textComponentStyle.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 2 * AppSizes.titleFieldDistance),
                  const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.mainBlue)),
                  const SizedBox(height: AppSizes.mediumDistance),
                  const Center(
                    child: Text(
                      AppStrings.verifyingEmail,
                      style: AppStyles.textComponentStyle,
                    ),
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.35),
                  CustomButton(
                      buttonColor: AppColors.mainBlue,
                      buttonText: AppStrings.resend,
                      // TODO resend
                      onTap: () async {}),
                ]),
          ),
        ),
      ),
    );
  }
}
