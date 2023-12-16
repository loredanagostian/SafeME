import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/screens/friends_screen_fragment.dart';
import 'package:safe_me/widgets/custom_bottom_tab_navigator.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

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
              onTap: () {},
              child: SizedBox(
                height: 50,
                width: 50,
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSizes.smallDistance),
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
        bottomNavigationBar: const CustomBottomTabNavigator(),
        body: const TabBarView(
          // physics: AlwaysScrollableScrollPhysics(),
          children: [
            FriendsScreenFragment(
              isTrackNow: true,
              personsList: [],
            ),
            FriendsScreenFragment(
              isGroups: true,
              personsList: [],
            ),
            FriendsScreenFragment(
              isAllFriends: true,
              personsList: [],
            ),
            FriendsScreenFragment(
              isRequests: true,
              personsList: [],
            ),
          ],
        ),
      ),
    );
  }
}
