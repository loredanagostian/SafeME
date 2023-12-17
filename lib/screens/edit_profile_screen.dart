import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/screens/more_screen.dart';
import 'package:safe_me/widgets/custom_button.dart';
import 'package:safe_me/widgets/custom_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneNumberController;
  File? imageFile;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.user["firstName"]);
    lastNameController = TextEditingController(text: widget.user["lastName"]);
    phoneNumberController =
        TextEditingController(text: widget.user["phoneNumber"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          AppStrings.editProfile,
          style: AppStyles.titleStyle,
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.mainDarkGray,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.smallDistance),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: Padding(
                        padding: const EdgeInsets.only(
                            right: AppSizes.smallDistance),
                        child: CircleAvatar(
                            backgroundImage: FileImage(imageFile != null
                                ? imageFile!
                                : File(widget.user["imageURL"])))),
                  ),
                ),
                const SizedBox(height: AppSizes.smallDistance),
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
                            AppStrings.changePicture,
                            style: AppStyles.buttonTextStyle,
                          ),
                        )),
                  ),
                ),
                const SizedBox(height: AppSizes.buttonHeight),
                Text(
                  AppStrings.changeFirstName,
                  style: AppStyles.buttonTextStyle
                      .copyWith(color: AppColors.mainDarkGray),
                ),
                CustomTextField(
                  controller: firstNameController,
                ),
                const SizedBox(height: AppSizes.borders),
                Text(
                  AppStrings.changeLastName,
                  style: AppStyles.buttonTextStyle
                      .copyWith(color: AppColors.mainDarkGray),
                ),
                CustomTextField(
                  controller: lastNameController,
                ),
                const SizedBox(height: AppSizes.borders),
                Text(
                  AppStrings.changePhoneNumber,
                  style: AppStyles.buttonTextStyle
                      .copyWith(color: AppColors.mainDarkGray),
                ),
                CustomTextField(
                  controller: phoneNumberController,
                  isPhoneNumber: true,
                ),
                const SizedBox(height: AppSizes.buttonHeight),
                CustomButton(
                    buttonColor: AppColors.mainBlue,
                    buttonText: AppStrings.saveChanges,
                    onTap: () {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({
                        "firstName": firstNameController.text,
                        "lastName": lastNameController.text,
                        "phoneNumber": phoneNumberController.text
                      }).then((value) {
                        Navigator.pop(context);
                      });
                    })
              ]),
        ),
      ),
    );
  }
}
