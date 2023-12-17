import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/widgets/custom_button.dart';
import 'package:safe_me/widgets/custom_textfield.dart';

class DefaultEmergencySmsScreen extends StatelessWidget {
  const DefaultEmergencySmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          AppStrings.emergencySMS,
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
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.smallDistance),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                height: 86,
                width: 230,
                padding: const EdgeInsets.all(AppSizes.mediumDistance),
                decoration: BoxDecoration(
                  color: AppColors.lightBlue.withOpacity(0.6),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSizes.borders),
                    topRight: Radius.circular(AppSizes.borders),
                    bottomLeft: Radius.circular(AppSizes.borders),
                  ),
                ),
                child: Center(
                  child: Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ",
                    style: AppStyles.hintComponentStyle.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.buttonHeight),
            const Text(
              AppStrings.enterMessageBelow,
              style: AppStyles.sectionTitleStyle,
            ),
            const SizedBox(height: AppSizes.smallDistance),
            CustomTextField(
              controller: TextEditingController(),
              hintText: "",
              isEditMessage: true,
            ),
            const SizedBox(height: AppSizes.titleFieldDistance),
            CustomButton(
                buttonColor: AppColors.mainBlue,
                buttonText: AppStrings.saveChanges,
                onTap: () {})
          ],
        ),
      ),
    );
  }
}