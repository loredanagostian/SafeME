import 'dart:io';

import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/screens/add_friend_screen.dart';

class EmergencyMember extends StatelessWidget {
  final Account? emergencyUser;
  const EmergencyMember({super.key, required this.emergencyUser});

  @override
  Widget build(BuildContext context) {
    return emergencyUser != null
        ? Container(
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
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircleAvatar(
                        backgroundImage:
                            FileImage(File(emergencyUser!.imageURL))),
                  ),
                ),
                Flexible(
                  child: Text(
                    "${emergencyUser!.firstName} ${emergencyUser!.lastName}",
                    style: AppStyles.textComponentStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          )
        : Container(
            height: 100,
            width: 75,
            decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(AppSizes.borders)),
            child: IconButton(
              icon: Icon(
                Icons.add_circle,
                color: AppColors.mainDarkGray,
                size: 35,
              ),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddFriendScreen())),
            ),
          );
  }
}
