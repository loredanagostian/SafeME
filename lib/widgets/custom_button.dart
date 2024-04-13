import 'package:flutter/material.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/styles.dart';

class CustomButton extends StatelessWidget {
  final Color buttonColor;
  final String buttonText;
  final Function() onTap;
  final Color? buttonTextColor;
  const CustomButton({
    super.key,
    required this.buttonColor,
    required this.buttonText,
    required this.onTap,
    this.buttonTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          height: AppSizes.buttonHeight,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(AppSizes.borders),
              border: Border.all(color: buttonColor)),
          child: Center(
            child: Text(
              buttonText,
              style: buttonTextColor != null
                  ? AppStyles.buttonTextStyle.copyWith(color: buttonTextColor)
                  : AppStyles.buttonTextStyle,
            ),
          ),
        ));
  }
}
