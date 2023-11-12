import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';

class AppStyles {
  static const TextStyle titleStyle = TextStyle(
      color: AppColors.mainBlue,
      fontFamily: 'Poppins',
      fontSize: 24,
      fontWeight: FontWeight.bold);

  static const TextStyle sectionTitleStyle = TextStyle(
      color: AppColors.darkGray,
      fontFamily: 'Poppins',
      fontSize: 14,
      fontWeight: FontWeight.w600);

  static const TextStyle notificationTitleStyle = TextStyle(
      color: AppColors.mainBlue,
      fontFamily: 'Poppins',
      fontSize: 16,
      fontWeight: FontWeight.w500);

  static const TextStyle notificationBodyStyle = TextStyle(
      color: AppColors.mainBlue,
      fontFamily: 'Poppins',
      fontSize: 12,
      fontWeight: FontWeight.w400);

  static const TextStyle bodyStyle = TextStyle(
      color: AppColors.darkGray,
      fontFamily: 'Poppins',
      fontSize: 16,
      fontWeight: FontWeight.w400);
}
