import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/widgets/custom_list_tile.dart';

class CustomFriendsBottomModal extends StatelessWidget {
  final List<Account> allFriends;
  final Account userAccount;
  const CustomFriendsBottomModal({
    super.key,
    required this.allFriends,
    required this.userAccount,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: allFriends.length,
      itemBuilder: (context, index) {
        final item = allFriends[index];

        return CustomListTile(
          photoUrl: item.imageURL,
          title: item.firstName,
          subtitle: item.phoneNumber,
          buttonText: AppStrings.switchContact,
          button1Action: () {
            item.userId == userAccount.emergencyContact
                ? null
                : FirebaseFirestore.instance
                    .collection('users')
                    .doc(userAccount.userId)
                    .update({
                    "emergencyContact": item.userId,
                  }).then((value) => Navigator.pop(context));
          },
          isAlreadyFriend: item.userId == userAccount.emergencyContact,
          buttonColor: item.userId == userAccount.emergencyContact
              ? AppColors.mediumGray
              : AppColors.mainBlue,
        );
      },
      shrinkWrap: true,
    );
  }
}
