import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/widgets/custom_button.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final void Function() onConfirm;
  final void Function() onCancel;
  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSizes.borders))),
      backgroundColor: AppColors.componentGray,
      title: Center(
        child: Text(
          title,
          style: AppStyles.titleStyle
              .copyWith(color: AppColors.mainRed, fontWeight: FontWeight.w600),
        ),
      ),
      content: Text(
        message,
        style: AppStyles.bodyStyle,
        textAlign: TextAlign.center,
      ),
      actionsPadding: EdgeInsets.only(
          top: AppSizes.bigDistance,
          bottom: AppSizes.mediumDistance,
          left: AppSizes.bigDistance,
          right: AppSizes.bigDistance),
      actions: [
        SizedBox(
          height: 40,
          child: CustomButton(
              buttonColor: AppColors.mainRed,
              buttonText: AppStrings.delete,
              onTap: onConfirm),
        ),
        SizedBox(height: AppSizes.smallDistance),
        SizedBox(
          height: 40,
          child: CustomButton(
              buttonColor: AppColors.componentGray,
              buttonText: AppStrings.cancel,
              buttonTextColor: AppColors.mainDarkGray,
              onTap: onCancel),
        ),
      ],
    );
  }
}
