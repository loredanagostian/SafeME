import 'dart:io';

import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/models/account.dart';

class PersonChatRoom extends StatelessWidget {
  final Future<Account> futureFriend;
  const PersonChatRoom({super.key, required this.futureFriend});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureFriend,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("Error${snapshot.error}");
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return Container(
              width: 65,
              decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(AppSizes.borders)),
              child: Padding(
                  padding: const EdgeInsets.all(AppSizes.smallDistance),
                  child: CircleAvatar(
                      backgroundImage:
                          FileImage(File(snapshot.data!.imageURL)))),
            );
          }
          return Container();
        });
  }
}
