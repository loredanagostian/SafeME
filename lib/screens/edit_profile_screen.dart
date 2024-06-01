import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
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
  File? imageFile;

  @override
  void initState() {
    super.initState();
    firstNameController =
        TextEditingController(text: ref.read(userStaticDataProvider).firstName);
    lastNameController =
        TextEditingController(text: ref.read(userStaticDataProvider).lastName);
  }

  @override
  Widget build(BuildContext context) {
    UserStaticData userInfo = ref.read(userStaticDataProvider);

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
                                : File(userInfo.imageURL)))),
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
                  isDone: true,
                ),
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.25),
                CustomButton(
                    buttonColor: AppColors.mainBlue,
                    buttonText: AppStrings.saveChanges,
                    onTap: () {
                      userInfo.firstName = firstNameController.text;
                      userInfo.lastName = lastNameController.text;
                      userInfo.imageURL = imageFile!.path;
                      ref
                          .read(userStaticDataProvider.notifier)
                          .updateUserInfo(userInfo);

                      FirebaseManager.changeUserInformation(
                              firstNameController.text,
                              lastNameController.text,
                              userInfo.imageURL)
                          .then((value) {
                        Navigator.pop(context);
                      });
                    })
              ]),
        ),
      ),
    );
  }
}
