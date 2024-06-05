import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/widgets/custom_button.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String firstButtonLabel;
  final String? secondButtonLabel;
  final void Function() firstButtonAction;
  final void Function()? secondButtonAction;
  const CustomAlertDialog(
      {super.key,
      required this.title,
      required this.message,
      required this.firstButtonAction,
      this.firstButtonLabel = AppStrings.delete,
      this.secondButtonAction,
      this.secondButtonLabel = AppStrings.cancel});

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
          textAlign: TextAlign.center,
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
              buttonText: firstButtonLabel,
              onTap: firstButtonAction),
        ),
        SizedBox(height: AppSizes.smallDistance),
        ...[
          secondButtonAction != null && secondButtonLabel != null
              ? SizedBox(
                  height: 40,
                  child: CustomButton(
                      buttonColor: AppColors.componentGray,
                      buttonText: secondButtonLabel!,
                      buttonTextColor: AppColors.mainDarkGray,
                      onTap: secondButtonAction!),
                )
              : Container()
        ],
      ],
    );
  }
}
