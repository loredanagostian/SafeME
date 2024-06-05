import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/managers/firebase_manager.dart';
import 'package:safe_me/managers/user_info_provider.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/models/user_static_data.dart';
import 'package:safe_me/widgets/custom_alert_dialog.dart';
import 'package:safe_me/widgets/custom_friends_bottom_modal.dart';
import 'package:safe_me/widgets/custom_list_tile.dart';
import 'package:safe_me/widgets/custom_user_information_modal.dart';

class DefaultEmergencyContactsScreen extends ConsumerStatefulWidget {
  const DefaultEmergencyContactsScreen({super.key});

  @override
  ConsumerState<DefaultEmergencyContactsScreen> createState() =>
      _DefaultEmergencyContactsScreenState();
}

class _DefaultEmergencyContactsScreenState
    extends ConsumerState<DefaultEmergencyContactsScreen> {
  late UserStaticData _userData;

  @override
  void initState() {
    super.initState();
    _userData = ref.read(userStaticDataProvider);
  }

  Future<void> _showAllFriendsList(BuildContext context) async {
    bool? shouldRefresh = await showModalBottomSheet<bool>(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSizes.borders),
                topRight: Radius.circular(AppSizes.borders))),
        context: context,
        builder: (BuildContext context) {
          return CustomFriendsBottomModal();
        });

    if (shouldRefresh != null && shouldRefresh) {
      setState(() {});
    }
  }

  void _showDeleteDialog(Account friend) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: AppStrings.deleteUser,
            message:
                "${AppStrings.deleteUserMessage1} ${friend.firstName} ${friend.lastName} ${AppStrings.deleteUserMessage2_emergencyContactsList}",
            firstButtonAction: () async {
              _userData.emergencyContacts.remove(friend.userId);
              ref
                  .read(userStaticDataProvider.notifier)
                  .updateUserInfo(_userData);
              await FirebaseManager.removeEmergencyContact(friend.userId);
              Navigator.pop(context);
            },
            secondButtonAction: () {
              Navigator.pop(context);
              setState(() {});
            },
          );
        });
  }

  void _showUserInformationModal(BuildContext context, Account friend) {
    showModalBottomSheet<void>(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSizes.borders),
                topRight: Radius.circular(AppSizes.borders))),
        context: context,
        builder: (BuildContext context) {
          return Wrap(children: [
            CustomUserInformationModal(
              friend: friend,
              isEmergencyScreen: true,
            )
          ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    _userData = ref.watch(userStaticDataProvider);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: const Text(
            AppStrings.emergencyContacts,
            style: AppStyles.titleStyle,
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.mainDarkGray,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSizes.smallDistance),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${_userData.emergencyContacts.length} ${AppStrings.emergencyContacts.toLowerCase()}",
                      style: AppStyles.textComponentStyle
                          .copyWith(color: AppColors.mainBlue),
                    ),
                    Visibility(
                      visible: _userData.friends.isNotEmpty,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: SizedBox(
                          height: 35,
                          width: 35,
                          child: IconButton(
                            onPressed: () => _showAllFriendsList(context),
                            icon: const Icon(
                              Icons.person_add_outlined,
                              color: AppColors.mainDarkGray,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const Divider(
                  color: AppColors.mainDarkGray,
                  thickness: 1,
                ),
                ListView.builder(
                  itemCount: _userData.emergencyContacts.length,
                  itemBuilder: (context, index) {
                    String friendID = _userData.emergencyContacts[index];

                    return FutureBuilder(
                        future: FirebaseManager.fetchUserInfoAndReturnAccount(
                            friendID),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData) {
                            Account friendItem = snapshot.data!;
                            return GestureDetector(
                              onTap: () => _showUserInformationModal(
                                  context, friendItem),
                              child: CustomListTile(
                                photoUrl: friendItem.imageURL,
                                title:
                                    "${friendItem.firstName} ${friendItem.lastName}",
                                subtitle: friendItem.phoneNumber,
                                onDismiss: (DismissDirection direction) =>
                                    _showDeleteDialog(friendItem),
                                buttonText: '',
                                button1Action: () {},
                                buttonColor: AppColors.white,
                              ),
                            );
                          }
                          return Container();
                        });
                  },
                  shrinkWrap: true,
                )
              ]),
        ));
  }
}
