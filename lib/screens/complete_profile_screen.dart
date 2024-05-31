import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/managers/authentication_manager.dart';
import 'package:safe_me/screens/verify_phone_number_screen.dart';
import 'package:safe_me/widgets/custom_button.dart';
import 'package:safe_me/widgets/custom_snackbar.dart';
import 'package:safe_me/widgets/custom_textfield.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  String defaultURL = "lib/assets/images/default_account.png";
  File? imageFile;
  String? email;
  String? value;

  @override
  void initState() {
    super.initState();
    email = FirebaseAuth.instance.currentUser?.email;
    value = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.smallDistance),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.completeProfile,
                    style: AppStyles.titleStyle,
                  ),
                  const SizedBox(height: AppSizes.bigDistance),
                  Center(
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: Padding(
                          padding: const EdgeInsets.only(
                              right: AppSizes.smallDistance),
                          child: imageFile != null
                              ? CircleAvatar(
                                  backgroundImage: FileImage(imageFile!))
                              : CircleAvatar(
                                  backgroundImage: AssetImage(defaultURL),
                                  backgroundColor: AppColors.white,
                                )),
                    ),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        var image = await ImagePicker.platform
                            .getImageFromSource(source: ImageSource.gallery);

                        setState(() {
                          imageFile = File(image!.path);
                        });
                      },
                      child: Container(
                          height: 25,
                          width: 120,
                          decoration: BoxDecoration(
                              color: AppColors.mainBlue,
                              borderRadius:
                                  BorderRadius.circular(AppSizes.borders)),
                          child: const Center(
                            child: Text(
                              AppStrings.selectPicture,
                              style: AppStyles.buttonTextStyle,
                            ),
                          )),
                    ),
                  ),
                  const SizedBox(height: AppSizes.buttonHeight),
                  Text(
                    AppStrings.firstName,
                    style: AppStyles.buttonTextStyle
                        .copyWith(color: AppColors.mainDarkGray),
                  ),
                  CustomTextField(
                    controller: firstNameController,
                    hintText: AppStrings.firstName,
                  ),
                  const SizedBox(height: AppSizes.borders),
                  Text(
                    AppStrings.lastName,
                    style: AppStyles.buttonTextStyle
                        .copyWith(color: AppColors.mainDarkGray),
                  ),
                  CustomTextField(
                    controller: lastNameController,
                    hintText: AppStrings.lastName,
                  ),
                  const SizedBox(height: AppSizes.borders),
                  Text(
                    AppStrings.phoneNumber,
                    style: AppStyles.buttonTextStyle
                        .copyWith(color: AppColors.mainDarkGray),
                  ),
                  CustomTextField(
                    controller: phoneNumberController,
                    hintText: AppStrings.phoneNumber,
                    isPhoneNumber: true,
                    isDone: true,
                  ),
                  const SizedBox(height: AppSizes.titleFieldDistance),
                  CustomButton(
                      buttonColor: AppColors.mainBlue,
                      buttonText: AppStrings.saveChanges,
                      onTap: () async {
                        if (firstNameController.text.isNotEmpty &&
                            lastNameController.text.isNotEmpty &&
                            phoneNumberController.text.isNotEmpty) {
                          // final userDatas = <String, dynamic>{
                          //   "userId":
                          //       FirebaseAuth.instance.currentUser?.uid ?? "",
                          //   "email":
                          //       FirebaseAuth.instance.currentUser?.email ?? "",
                          //   "firstName": firstNameController.text,
                          //   "lastName": lastNameController.text,
                          //   "phoneNumber": phoneNumberController.text,
                          //   "imageURL": imageFile?.path ?? defaultURL,
                          //   "emergencySMS": AppStrings.defaultEmergencySMS,
                          //   "trackingSMS": AppStrings.defaultTrackingSMS,
                          //   "trackMeNow": false,
                          //   "userLastLatitude": 0.0,
                          //   "userLastLongitude": 0.0,
                          //   "deviceToken": NotificationManager.token,
                          //   "friends": [],
                          //   "friendRequests": [],
                          //   "notifications": [],
                          //   "emergencyContacts": [],
                          //   "history": [],
                          // };

                          // FirebaseFirestore.instance
                          //     .collection("users")
                          //     .doc(FirebaseAuth.instance.currentUser?.uid ?? "")
                          //     .set(userDatas)
                          //     .then((value) => Navigator.pushAndRemoveUntil(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (context) => const MainScreen()),
                          //         (route) => false));
                          AuthenticationManager.sendOtp(
                              phoneNumber: phoneNumberController.text,
                              errorStep: () {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: CustomSnackbarContent(
                                      snackBarMessage: AppStrings.otpError),
                                  backgroundColor: AppColors.mainRed,
                                ));
                              },
                              nextStep: () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => VerifyPhoneNumber(
                                              firstName:
                                                  firstNameController.text,
                                              lastName: lastNameController.text,
                                              phoneNumber:
                                                  phoneNumberController.text,
                                              imagePath:
                                                  imageFile?.path ?? defaultURL,
                                            )),
                                    (route) => false);
                              });
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: CustomSnackbarContent(
                                snackBarMessage:
                                    AppStrings.allFieldsMustBeCompleted),
                            backgroundColor: AppColors.mainRed,
                          ));
                        }
                      })
                ]),
          ),
        ),
      ),
    );
  }
}
