import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/managers/authentication_manager.dart';
import 'package:safe_me/managers/firebase_manager.dart';
import 'package:safe_me/managers/notification_manager.dart';
import 'package:safe_me/managers/user_info_provider.dart';
import 'package:safe_me/models/user_static_data.dart';
import 'package:safe_me/screens/main_screen.dart';
import 'package:safe_me/widgets/custom_button.dart';
import 'package:safe_me/widgets/custom_snackbar.dart';
import 'package:safe_me/widgets/custom_textfield.dart';

class VerifyPhoneNumber extends ConsumerStatefulWidget {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final File? file;
  const VerifyPhoneNumber(
      {super.key,
      required this.firstName,
      required this.lastName,
      required this.phoneNumber,
      required this.file});

  @override
  ConsumerState<VerifyPhoneNumber> createState() => _VerifyPhoneNumberState();
}

class _VerifyPhoneNumberState extends ConsumerState<VerifyPhoneNumber> {
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
                    isDone: true,
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
                          ref
                              .read(userStaticDataProvider.notifier)
                              .updateUserInfo(UserStaticData(
                                  email: userEmail,
                                  firstName: widget.firstName,
                                  lastName: widget.lastName,
                                  phoneNumber: widget.phoneNumber,
                                  emergencySMS: "",
                                  trackingSMS: "",
                                  friends: [],
                                  friendsRequest: [],
                                  userId: userId,
                                  emergencyContacts: [],
                                  deviceToken: NotificationManager.token,
                                  history: [],
                                  notifications: []));

                          String? imageUrl;
                          if (widget.file != null) {
                            FirebaseStorage storage = FirebaseStorage.instance;
                            Reference ref = storage
                                .ref()
                                .child(FirebaseAuth.instance.currentUser!.uid);

                            UploadTask uploadTask = ref.putFile(widget.file!);
                            await uploadTask.whenComplete(() async {
                              var url = await ref.getDownloadURL();
                              imageUrl = url.toString();
                            }).catchError((onError) {
                              print(onError);
                            });

                            await AuthenticationManager.updateProfilePicture(
                                imageUrl);
                          }

                          final userDatas = <String, dynamic>{
                            "userId": userId,
                            "email": userEmail,
                            "firstName": widget.firstName,
                            "lastName": widget.lastName,
                            "phoneNumber": widget.phoneNumber,
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
                            "emergencyContacts": [],
                            "history": [],
                            "imageURL": imageUrl
                          };

                          FirebaseManager.uploadNewUserData(userDatas).then(
                              (value) => Navigator.pushAndRemoveUntil(
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
                      GestureDetector(
                        onTap: () async {
                          await AuthenticationManager.sendOtp(
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
