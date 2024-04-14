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
          buttonText: AppStrings.addButton,
          button1Action: () {
            userAccount.emergencyContacts.contains(item.userId)
                ? null
                : FirebaseFirestore.instance
                    .collection('users')
                    .doc(userAccount.userId)
                    .update({
                    "emergencyContacts": FieldValue.arrayUnion([item.userId]),
                  }).then((value) => Navigator.pop(context));
          },
          isAlreadyFriend: userAccount.emergencyContacts.contains(item.userId),
          buttonColor: userAccount.emergencyContacts.contains(item.userId)
              ? AppColors.mediumGray
              : AppColors.mainBlue,
        );
      },
      shrinkWrap: true,
    );
  }
}
