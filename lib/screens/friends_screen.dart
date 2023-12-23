import 'dart:io';

import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/screens/friends_screen_fragment.dart';
import 'package:safe_me/screens/more_screen.dart';

class FriendsScreen extends StatefulWidget {
  final Account userAccount;
  const FriendsScreen({super.key, required this.userAccount});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: const Text(
            AppStrings.yourFriendsTitle,
            style: AppStyles.titleStyle,
          ),
          actions: [
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.person_add_outlined,
                  color: AppColors.mainDarkGray,
                  size: 30,
                )),
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const MoreScreen())),
              child: SizedBox(
                height: 50,
                width: 50,
                child: Padding(
                    padding:
                        const EdgeInsets.only(right: AppSizes.smallDistance),
                    child: CircleAvatar(
                        backgroundImage:
                            FileImage(File(widget.userAccount.imageURL)))),
              ),
            )
          ],
          bottom: TabBar(
            labelStyle: AppStyles.sectionTitleStyle
                .copyWith(color: AppColors.mainDarkGray),
            unselectedLabelColor: AppColors.mediumGray,
            indicatorColor: AppColors.mainBlue,
            indicatorWeight: AppSizes.smallDistance,
            padding: EdgeInsets.zero,
            indicatorPadding: const EdgeInsets.all(AppSizes.smallDistance),
            labelPadding: EdgeInsets.zero,
            tabs: const [
              Tab(text: AppStrings.trackNow),
              Tab(text: AppStrings.groups),
              Tab(text: AppStrings.allFriends),
              Tab(text: AppStrings.requests)
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FriendsScreenFragment(
              isTrackNow: true,
              friendsList: [],
            ),
            FriendsScreenFragment(
              isGroups: true,
              friendsList: [],
            ),
            FriendsScreenFragment(
              isAllFriends: true,
              friendsList: widget.userAccount.friends,
            ),
            FriendsScreenFragment(
              isRequests: true,
              friendsList: [],
            ),
          ],
        ),
      ),
    );
  }
}
