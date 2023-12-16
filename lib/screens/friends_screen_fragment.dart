import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/widgets/custom_button.dart';
import 'package:safe_me/widgets/custom_list_tile.dart';
import 'package:safe_me/widgets/custom_search_bar.dart';

class FriendsScreenFragment extends StatelessWidget {
  final bool isTrackNow;
  final bool isGroups;
  final bool isAllFriends;
  final bool isRequests;
  final List<String> personsList;
  const FriendsScreenFragment({
    super.key,
    this.isTrackNow = false,
    this.isGroups = false,
    this.isAllFriends = false,
    this.isRequests = false,
    required this.personsList,
  });

  String returnCountType() {
    return isTrackNow
        ? "trackings"
        : (isGroups
            ? "groups"
            : (isAllFriends ? "friends" : (isRequests ? "requests" : "")));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
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
              "${personsList.length} ${returnCountType()}",
              style: AppStyles.textComponentStyle
                  .copyWith(color: AppColors.mainBlue),
            ),
            const Divider(
              color: AppColors.mainDarkGray,
              thickness: 1,
            ),
            CustomListTile(
              photoUrl: "assets/images/eu.jpg",
              title: "Lore Gostian",
              subtitle: "0733156102",
              buttonText: "TRACK",
            ),
            CustomListTile(
              photoUrl: "assets/images/eu.jpg",
              title: "Lore Gostian",
              subtitle: "0733156102",
              buttonText: "TRACK",
              isRequest: true,
            )
          ],
        ),
      ),
    );
  }
}
