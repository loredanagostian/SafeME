import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/paths.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/managers/user_info_provider.dart';
import 'package:safe_me/models/user_static_data.dart';
import 'package:safe_me/screens/add_friend_screen.dart';
import 'package:safe_me/screens/friends_screen_fragment.dart';
import 'package:safe_me/screens/more_screen.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  late UserStaticData _userStaticData;

  @override
  void initState() {
    super.initState();
    _userStaticData = ref.read(userStaticDataProvider);
  }

  @override
  Widget build(BuildContext context) {
    _userStaticData = ref.watch(userStaticDataProvider);

    return DefaultTabController(
      length: 3,
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
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddFriendScreen())),
                icon: const Icon(
                  Icons.person_add_outlined,
                  color: AppColors.mainDarkGray,
                  size: 30,
                )),
            GestureDetector(
              onTap: () async {
                bool result = await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MoreScreen()));
                if (result) setState(() {});
              },
              child: SizedBox(
                height: 50,
                width: 50,
                child: Padding(
                    padding:
                        const EdgeInsets.only(right: AppSizes.smallDistance),
                    child: FirebaseAuth.instance.currentUser!.photoURL != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(
                                FirebaseAuth.instance.currentUser!.photoURL!))
                        : CircleAvatar(
                            backgroundImage:
                                AssetImage(AppPaths.defaultProfilePicture),
                            backgroundColor: AppColors.white,
                          )),
              ),
            )
          ],
          bottom: TabBar(
            labelStyle: AppStyles.sectionTitleStyle
                .copyWith(color: AppColors.mainDarkGray),
            unselectedLabelColor: AppColors.mediumGray,
            indicatorColor: AppColors.mainBlue,
            indicatorWeight: AppSizes.smallDistance / 2,
            padding: EdgeInsets.zero,
            indicatorPadding: const EdgeInsets.all(AppSizes.smallDistance),
            labelPadding: EdgeInsets.zero,
            tabs: [
              Tab(text: AppStrings.trackNow),
              Tab(text: AppStrings.allFriends),
              Tab(
                child: Text(
                  AppStrings.requests,
                  style: TextStyle(
                      color: _userStaticData.friendsRequest.isNotEmpty
                          ? AppColors.lightBlue
                          : AppColors.mediumGray),
                ),
              )
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FriendsScreenFragment(isTrackNow: true),
            FriendsScreenFragment(isAllFriends: true),
            FriendsScreenFragment(isRequests: true),
          ],
        ),
      ),
    );
  }
}
