import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/managers/authentication_manager.dart';
import 'package:safe_me/managers/notification_manager.dart';
import 'package:safe_me/screens/main_screen.dart';
import 'package:safe_me/widgets/custom_button.dart';
import 'package:safe_me/widgets/custom_snackbar.dart';
import 'package:safe_me/widgets/custom_textfield.dart';

class VerifyPhoneNumber extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String imagePath;
  const VerifyPhoneNumber({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.imagePath,
  });

  @override
  State<VerifyPhoneNumber> createState() => _VerifyPhoneNumberState();
}

class _VerifyPhoneNumberState extends State<VerifyPhoneNumber> {
  final TextEditingController codeController = TextEditingController();

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
                    AppStrings.verifyPhoneNumber,
                    style: AppStyles.titleStyle,
                  ),
                  const SizedBox(height: AppSizes.smallDistance),
                  Text(
                    AppStrings.enterCodeBelow,
                    style: AppStyles.hintComponentStyle.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: AppSizes.titleFieldDistance),
                  Text(
                    AppStrings.code,
                    style: AppStyles.buttonTextStyle
                        .copyWith(color: AppColors.mainDarkGray),
                  ),
                  CustomTextField(
                    controller: codeController,
                    hintText: AppStrings.code,
                    isPhoneNumber: true,
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.45),
                  CustomButton(
                      buttonColor: AppColors.mainBlue,
                      buttonText: AppStrings.validate,
                      // Validate phone number
                      onTap: () async {
                        String result =
                            await AuthenticationManager.loginWithOtp(
                                otp: codeController.text);

                        String userId =
                            FirebaseAuth.instance.currentUser?.uid ?? "";
                        String userEmail =
                            FirebaseAuth.instance.currentUser?.email ?? "";

                        if (result.isEmpty) {
                          final userDatas = <String, dynamic>{
                            "userId": userId,
                            "email": userEmail,
                            "firstName": widget.firstName,
                            "lastName": widget.lastName,
                            "phoneNumber": widget.phoneNumber,
                            "imageURL": widget.imagePath,
                            "emergencySMS": AppStrings.defaultEmergencySMS,
                            "trackingSMS": AppStrings.defaultTrackingSMS,
                            "trackMeNow": false,
                            "userLastLatitude": 0.0,
                            "userLastLongitude": 0.0,
                            "deviceToken": NotificationManager.token,
                            "emergencyGroup": [],
                            "friends": [],
                            "friendRequests": [],
                            "notifications": [],
                            "emergencyContact": "",
                          };

                          FirebaseFirestore.instance
                              .collection("users")
                              .doc(userId)
                              .set(userDatas)
                              .then((value) => Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const MainScreen()),
                                  (route) => false));
                        }
                      }),
                  const SizedBox(height: AppSizes.bigDistance),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${AppStrings.haventReceivedCode} ",
                        style: AppStyles.buttonTextStyle
                            .copyWith(color: AppColors.darkGray),
                      ),
                      // TODO resend
                      GestureDetector(
                        onTap: () {
                          AuthenticationManager.sendOtp(
                              phoneNumber: widget.phoneNumber,
                              errorStep: () {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: CustomSnackbarContent(
                                      snackBarMessage: AppStrings.otpError),
                                  backgroundColor: AppColors.mainRed,
                                ));
                              },
                              nextStep: () {
                                setState(() {});
                              });
                        },
                        child: Text(
                          AppStrings.resend,
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
