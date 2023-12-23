import 'dart:io';

import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/models/account.dart';

class PersonLiveLocation extends StatelessWidget {
  final Account account;
  const PersonLiveLocation({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 65,
      decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(AppSizes.borders)),
      child: Padding(
          padding: const EdgeInsets.all(AppSizes.smallDistance),
          child:
              CircleAvatar(backgroundImage: FileImage(File(account.imageURL)))),
    );
  }
}
