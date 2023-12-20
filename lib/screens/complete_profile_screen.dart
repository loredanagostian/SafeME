import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/screens/home_screen.dart';
import 'package:safe_me/widgets/custom_button.dart';
import 'package:safe_me/widgets/custom_textfield.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String email;
  final String value;
  const CompleteProfileScreen(
      {super.key, required this.email, required this.value});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  String defaultURL = "lib/assets/images/default_account.png";
  File? imageFile;

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
                  const SizedBox(height: AppSizes.mediumDistance),
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
                  const SizedBox(height: AppSizes.titleFieldDistance),
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
                  ),
                  const SizedBox(height: AppSizes.titleFieldDistance),
                  CustomButton(
                      buttonColor: AppColors.mainBlue,
                      buttonText: AppStrings.saveChanges,
                      onTap: () async {
                        if (firstNameController.text.isNotEmpty &&
                            lastNameController.text.isNotEmpty &&
                            phoneNumberController.text.isNotEmpty) {
                          final userDatas = <String, dynamic>{
                            "email": widget.email,
                            "firstName": firstNameController.text,
                            "lastName": lastNameController.text,
                            "phoneNumber": phoneNumberController.text,
                            "imageURL": imageFile != null
                                ? imageFile!.path
                                : defaultURL,
                            "emergencySMS": "Emergency! Track me, please!",
                            "emergencyGroup": [],
                            "trackingSMS": "I'm tracking you! You're safe!",
                          };

                          FirebaseFirestore.instance
                              .collection("users")
                              .doc(widget.value)
                              .set(userDatas)
                              .then((value) => Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomeScreen()),
                                  (route) => false));
                        } else {
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
                                  AppStrings.allFieldsMustBeCompleted,
                                  style: AppStyles.bottomItemStyle
                                      .copyWith(color: AppColors.white),
                                )
                              ]),
                            ),
                            backgroundColor: AppColors.mainRed,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      })
                ]),
          ),
        ),
      ),
    );
  }
}
