import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/widgets/custom_list_tile.dart';
import 'package:safe_me/widgets/custom_search_bar.dart';

class FriendsScreenFragment extends StatelessWidget {
  final bool isTrackNow;
  final bool isGroups;
  final bool isAllFriends;
  final bool isRequests;
  final List<String> friendsList;
  const FriendsScreenFragment({
    super.key,
    this.isTrackNow = false,
    this.isGroups = false,
    this.isAllFriends = false,
    this.isRequests = false,
    required this.friendsList,
  });

  String returnCountType() {
    return isTrackNow
        ? "trackings"
        : (isGroups
            ? "groups"
            : (isAllFriends ? "friends" : (isRequests ? "requests" : "")));
  }

  Future<List<Account>> fetchFriends(List<String> friendsIds) async {
    List<Account> friendsList = [];

    for (int i = 0; i < friendsIds.length; i++) {
      Map<String, dynamic>? data;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(friendsIds[i].toString())
          .get()
          .then((snapshot) {
        data = snapshot.data();
      });

      if (isAllFriends) {
        friendsList.add(Account.fromJson(data!));
      }

      if (isTrackNow) {
        final friend = Account.fromJson(data!);
        if (friend.trackMeNow) {
          friendsList.add(friend);
        }
      }

      if (isGroups) {
        return [];
      }

      if (isRequests) {
        return [];
      }
    }

    return friendsList;
  }

  String _getButtonText() {
    return isTrackNow ? AppStrings.trackButton : AppStrings.sosButton;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchFriends(friendsList),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Container(
              padding: const EdgeInsets.all(AppSizes.smallDistance),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSearchBar(
                    onChanged: (String) {},
                    searchController: TextEditingController(),
                  ),
                  const SizedBox(height: AppSizes.marginSize),
                  Text(
                    "${friendsList.length} ${returnCountType()}",
                    style: AppStyles.textComponentStyle
                        .copyWith(color: AppColors.mainBlue),
                  ),
                  const Divider(
                    color: AppColors.mainDarkGray,
                    thickness: 1,
                  ),
                  ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var item = snapshot.data![index];
                      return CustomListTile(
                        photoUrl: item.imageURL,
                        title: item.firstName,
                        subtitle: item.phoneNumber,
                        buttonText: _getButtonText(),
                      );
                    },
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                ],
              ),
            );
          }
          return Container();
        });
  }
}
