import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/paths.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/managers/authentication_manager.dart';
import 'package:safe_me/screens/onboarding_screens/verify_phone_number_screen.dart';
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
                      height: 150,
                      width: 150,
                      child: Padding(
                          padding: const EdgeInsets.only(
                              right: AppSizes.smallDistance),
                          child: imageFile != null
                              ? CircleAvatar(
                                  backgroundImage: FileImage(imageFile!))
                              : CircleAvatar(
                                  backgroundImage: AssetImage(
                                      AppPaths.defaultProfilePicture),
                                  backgroundColor: AppColors.white,
                                )),
                    ),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        var image = await ImagePicker.platform
                            .getImageFromSource(source: ImageSource.gallery);

                        if (image != null) {
                          setState(() {
                            imageFile = File(image.path);
                          });
                        }
                      },
                      child: Container(
                          height: 35,
                          width: 130,
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
                  const SizedBox(height: AppSizes.buttonHeight),
                  CustomButton(
                      buttonColor: AppColors.mainBlue,
                      buttonText: AppStrings.saveChanges,
                      onTap: () async {
                        if (firstNameController.text.isNotEmpty &&
                            lastNameController.text.isNotEmpty &&
                            phoneNumberController.text.isNotEmpty) {
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
                                              file: imageFile,
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
