import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';

class PersonLiveLocation extends StatelessWidget {
  const PersonLiveLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      width: 65,
      decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(AppSizes.borders)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.smallDistance),
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
    );
  }
}
