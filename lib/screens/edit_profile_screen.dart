import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/widgets/custom_button.dart';
import 'package:safe_me/widgets/custom_textfield.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

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
                      padding:
                          const EdgeInsets.only(right: AppSizes.smallDistance),
                      child: Container(
                          decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(
                            'lib/assets/images/eu.jpg',
                          ),
                          fit: BoxFit.cover,
                        ),
                      )),
                    ),
                  ),
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                        height: 25,
                        width: 120,
                        decoration: BoxDecoration(
                            color: AppColors.mainBlue,
                            borderRadius:
                                BorderRadius.circular(AppSizes.borders)),
                        child: const Center(
                          child: Text(
                            "Change picture",
                            style: AppStyles.buttonTextStyle,
                          ),
                        )),
                  ),
                ),
                const SizedBox(height: AppSizes.borders),
                Text(
                  AppStrings.changeName,
                  style: AppStyles.buttonTextStyle
                      .copyWith(color: AppColors.mainDarkGray),
                ),
                CustomTextField(
                  controller: TextEditingController(),
                  hintText: "Ana Blandiana",
                  isEditProfile: true,
                ),
                const SizedBox(height: AppSizes.borders),
                Text(
                  AppStrings.changeEmail,
                  style: AppStyles.buttonTextStyle
                      .copyWith(color: AppColors.mainDarkGray),
                ),
                CustomTextField(
                  controller: TextEditingController(),
                  hintText: "lore.gostian@gmail.com",
                  isEditProfile: true,
                ),
                const SizedBox(height: AppSizes.borders),
                Text(
                  AppStrings.changePassword,
                  style: AppStyles.buttonTextStyle
                      .copyWith(color: AppColors.mainDarkGray),
                ),
                CustomTextField(
                  controller: TextEditingController(),
                  hintText: "********",
                  isEditProfile: true,
                ),
                const SizedBox(height: AppSizes.borders),
                Text(
                  AppStrings.changePhoneNumber,
                  style: AppStyles.buttonTextStyle
                      .copyWith(color: AppColors.mainDarkGray),
                ),
                CustomTextField(
                  controller: TextEditingController(),
                  hintText: "0733 156 102",
                  isEditProfile: true,
                ),
                const SizedBox(height: AppSizes.bigDistance),
                CustomButton(
                    buttonColor: AppColors.mainBlue,
                    buttonText: AppStrings.saveChanges,
                    onTap: () {})
              ]),
        ),
      ),
    );
  }
}
