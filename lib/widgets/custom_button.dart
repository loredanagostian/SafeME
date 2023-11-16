import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/styles.dart';

class CustomButton extends StatelessWidget {
  final Color buttonColor;
  final String buttonText;
  final Function() onTap;
  final bool isGoogle;
  const CustomButton(
      {super.key,
      required this.buttonColor,
      required this.buttonText,
      required this.onTap,
      this.isGoogle = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          height: AppSizes.buttonHeight,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: isGoogle ? AppColors.white : buttonColor,
              borderRadius: BorderRadius.circular(AppSizes.borders),
              border: Border.all(color: AppColors.mediumGray)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Visibility(
                  visible: isGoogle,
                  child: Image.asset(
                    'lib/assets/images/google.png',
                    height: 25,
                  )),
              Visibility(
                  visible: isGoogle,
                  child: const SizedBox(width: AppSizes.smallDistance)),
              Text(
                buttonText,
                style: isGoogle
                    ? AppStyles.buttonTextStyle
                        .copyWith(color: AppColors.mainDarkGray)
                    : AppStyles.buttonTextStyle,
              ),
            ],
          ),
        ));
  }
}
