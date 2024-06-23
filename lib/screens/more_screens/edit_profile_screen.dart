import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
import 'package:safe_me/screens/onboarding_screens/login_screen.dart';
import 'package:safe_me/widgets/custom_alert_dialog.dart';
import 'package:safe_me/widgets/custom_button.dart';
import 'package:safe_me/widgets/custom_snackbar.dart';
import 'package:safe_me/widgets/custom_textfield.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController oldPasswordController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  File? imageFile;
  bool _hasPressedChangePassword = false;
  bool shouldRefresh = false;

  void _showChangePasswordDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: AppStrings.changePassword,
            message: AppStrings.changePasswordLogoutMessage,
            firstButtonLabel: AppStrings.ok.toUpperCase(),
            firstButtonAction: () async {
              await FirebaseAuth.instance.signOut().then((value) =>
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                      (route) => false));
            },
          );
        });
  }

  @override
  void initState() {
    super.initState();
    firstNameController =
        TextEditingController(text: ref.read(userStaticDataProvider).firstName);
    lastNameController =
        TextEditingController(text: ref.read(userStaticDataProvider).lastName);
    oldPasswordController = TextEditingController();
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
          onPressed: () => Navigator.pop(context, shouldRefresh),
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
                    height: 150,
                    width: 150,
                    child: Padding(
                        padding: const EdgeInsets.only(
                            right: AppSizes.smallDistance),
                        child: imageFile != null
                            ? CircleAvatar(
                                backgroundImage: FileImage(imageFile!))
                            : FirebaseAuth.instance.currentUser!.photoURL !=
                                    null
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(FirebaseAuth
                                        .instance.currentUser!.photoURL!))
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
                        height: 35,
                        width: 130,
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
                            AppStrings.oldPassword,
                            style: AppStyles.buttonTextStyle
                                .copyWith(color: AppColors.mainDarkGray),
                          ),
                          CustomTextField(
                            controller: oldPasswordController,
                            hintText: AppStrings.password,
                            isPassword: true,
                          ),
                          const SizedBox(height: AppSizes.mediumDistance),
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
                          const SizedBox(height: AppSizes.mediumDistance),
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
                        ? AppSizes.bigDistance
                        : MediaQuery.sizeOf(context).height * 0.10),
                CustomButton(
                    buttonColor: AppColors.mainBlue,
                    buttonText: AppStrings.saveChanges,
                    onTap: () async {
                      if (userInfo.firstName != firstNameController.text) {
                        userInfo.firstName = firstNameController.text;
                        shouldRefresh = true;
                      }

                      if (userInfo.lastName != lastNameController.text) {
                        userInfo.lastName = lastNameController.text;
                        shouldRefresh = true;
                      }

                      if (shouldRefresh) {
                        ref
                            .read(userStaticDataProvider.notifier)
                            .updateUserInfo(userInfo);
                        await FirebaseManager.changeUserInformation(
                            firstNameController.text, lastNameController.text);
                      }

                      String? imageUrl;
                      if (imageFile != null) {
                        FirebaseStorage storage = FirebaseStorage.instance;
                        Reference ref = storage
                            .ref()
                            .child(FirebaseAuth.instance.currentUser!.uid);

                        UploadTask uploadTask = ref.putFile(imageFile!);
                        await uploadTask.whenComplete(() async {
                          var url = await ref.getDownloadURL();
                          imageUrl = url.toString();
                        }).catchError((onError) {
                          print(onError);
                        });

                        await AuthenticationManager.updateProfilePicture(
                            imageUrl);

                        shouldRefresh = true;
                      }

                      if (_hasPressedChangePassword) {
                        if (passwordController.text ==
                                confirmPasswordController.text &&
                            passwordController.text.isNotEmpty &&
                            oldPasswordController.text.isNotEmpty) {
                          AuthCredential credential =
                              EmailAuthProvider.credential(
                                  email:
                                      FirebaseAuth.instance.currentUser!.email!,
                                  password: oldPasswordController.text);
                          try {
                            await FirebaseAuth.instance.currentUser!
                                .reauthenticateWithCredential(credential);
                            FirebaseAuth.instance.currentUser!
                                .updatePassword(passwordController.text)
                                .then((value) => _showChangePasswordDialog());
                          } on FirebaseAuthException catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: CustomSnackbarContent(
                                  snackBarMessage:
                                      AppStrings.oldPasswordNotCorrect),
                              backgroundColor: AppColors.mainRed,
                            ));
                            return;
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: CustomSnackbarContent(
                                snackBarMessage:
                                    passwordController.text.isNotEmpty
                                        ? AppStrings.invalidCredentials
                                        : AppStrings.allFieldsMustBeCompleted),
                            backgroundColor: AppColors.mainRed,
                          ));
                          return;
                        }
                      } else
                        Navigator.pop(context, shouldRefresh);
                    }),
                Visibility(
                    visible: _hasPressedChangePassword,
                    child: SizedBox(
                      height: AppSizes.mediumDistance,
                    ))
              ]),
        ),
      ),
    );
  }
}
