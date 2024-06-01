import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/paths.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/managers/authentication_manager.dart';
import 'package:safe_me/managers/firebase_manager.dart';
import 'package:safe_me/managers/user_info_provider.dart';
import 'package:safe_me/models/user_static_data.dart';
import 'package:safe_me/widgets/custom_button.dart';
import 'package:safe_me/widgets/custom_textfield.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  File? imageFile;
  bool _hasPressedChangePassword = false;

  @override
  void initState() {
    super.initState();
    firstNameController =
        TextEditingController(text: ref.read(userStaticDataProvider).firstName);
    lastNameController =
        TextEditingController(text: ref.read(userStaticDataProvider).lastName);
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    UserStaticData userInfo = ref.watch(userStaticDataProvider);

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
                        child: imageFile != null
                            ? CircleAvatar(
                                backgroundImage: FileImage(imageFile!))
                            : FirebaseAuth.instance.currentUser!.photoURL !=
                                    null
                                ? CircleAvatar(
                                    backgroundImage: FileImage(File(FirebaseAuth
                                        .instance.currentUser!.photoURL!)))
                                : CircleAvatar(
                                    backgroundImage: AssetImage(
                                        AppPaths.defaultProfilePicture),
                                    backgroundColor: AppColors.white,
                                  )),
                  ),
                ),
                const SizedBox(height: AppSizes.smallDistance),
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
                  isDone: true,
                ),
                const SizedBox(height: AppSizes.borders),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _hasPressedChangePassword = !_hasPressedChangePassword;
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        AppStrings.changePassword,
                        style: AppStyles.buttonTextStyle
                            .copyWith(color: AppColors.mainBlue),
                      ),
                      Icon(
                        _hasPressedChangePassword
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.mainBlue,
                        size: AppSizes.borders,
                      )
                    ],
                  ),
                ),
                Visibility(
                    visible: _hasPressedChangePassword,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.mediumDistance),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                        ],
                      ),
                    )),
                SizedBox(
                    height: _hasPressedChangePassword
                        ? AppSizes.mediumDistance
                        : MediaQuery.sizeOf(context).height * 0.2),
                CustomButton(
                    buttonColor: AppColors.mainBlue,
                    buttonText: AppStrings.saveChanges,
                    onTap: () async {
                      userInfo.firstName = firstNameController.text;
                      userInfo.lastName = lastNameController.text;
                      ref
                          .read(userStaticDataProvider.notifier)
                          .updateUserInfo(userInfo);

                      if (imageFile != null && imageFile!.path.isNotEmpty) {
                        if (await imageFile!.exists()) {
                          await AuthenticationManager.updateProfilePicture(
                              imageFile?.path);
                        }
                      }

                      if (_hasPressedChangePassword ||
                          (passwordController.text ==
                                  confirmPasswordController.text &&
                              passwordController.text.isNotEmpty)) {
                        FirebaseAuth.instance.currentUser!
                            .updatePassword(passwordController.text);
                      }

                      FirebaseManager.changeUserInformation(
                              firstNameController.text, lastNameController.text)
                          .then((value) {
                        Navigator.pop(context, true);
                      });
                    })
              ]),
        ),
      ),
    );
  }
}
