import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/styles.dart';

class CustomSnackbarContent extends StatelessWidget {
  final String snackBarMessage;
  const CustomSnackbarContent({super.key, required this.snackBarMessage});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.bigDistance,
      child: Row(children: [
        const Icon(
          Icons.priority_high,
          color: AppColors.white,
        ),
        const SizedBox(width: AppSizes.smallDistance),
        Flexible(
          child: Text(
            snackBarMessage,
            style: AppStyles.bottomItemStyle.copyWith(color: AppColors.white),
          ),
        )
      ]),
    );
  }
}
