import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/styles.dart';

class EmergencyMember extends StatelessWidget {
  const EmergencyMember({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: 75,
      decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(AppSizes.borders)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.smallDistance),
            child: Container(
                height: 65,
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
          Flexible(
            child: Text(
              "Lore Gostian Gostian",
              style: AppStyles.textComponentStyle.copyWith(fontSize: 11),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
