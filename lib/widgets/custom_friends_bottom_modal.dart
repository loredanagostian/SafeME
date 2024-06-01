import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/managers/firebase_manager.dart';
import 'package:safe_me/managers/user_info_provider.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/models/user_static_data.dart';
import 'package:safe_me/widgets/custom_list_tile.dart';

class CustomFriendsBottomModal extends ConsumerStatefulWidget {
  const CustomFriendsBottomModal({super.key});

  @override
  ConsumerState<CustomFriendsBottomModal> createState() =>
      _CustomFriendsBottomModalState();
}

class _CustomFriendsBottomModalState
    extends ConsumerState<CustomFriendsBottomModal> {
  late UserStaticData _userStaticData;

  @override
  Widget build(BuildContext context) {
    _userStaticData = ref.watch(userStaticDataProvider);

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _userStaticData.friends.length,
      itemBuilder: (context, index) {
        final friendId = _userStaticData.friends[index];

        return FutureBuilder(
            future: FirebaseManager.fetchUserInfoAndReturnAccount(friendId),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.done) {
                Account friendItem = snapshot.data!;

                return CustomListTile(
                  photoUrl: friendItem.imageURL,
                  title: friendItem.firstName,
                  subtitle: friendItem.phoneNumber,
                  buttonText: AppStrings.addButton,
                  button1Action: () {
                    _userStaticData.emergencyContacts
                            .contains(friendItem.userId)
                        ? null
                        : {
                            _userStaticData.emergencyContacts.add(friendId),
                            ref
                                .read(userStaticDataProvider.notifier)
                                .updateUserInfo(_userStaticData),
                            FirebaseManager.addEmergencyContact(friendId)
                                .then((value) => Navigator.pop(context))
                          };
                  },
                  isAlreadyFriend: _userStaticData.emergencyContacts
                      .contains(friendItem.userId),
                  buttonColor: _userStaticData.emergencyContacts
                          .contains(friendItem.userId)
                      ? AppColors.mediumGray
                      : AppColors.mainBlue,
                );
              }
              return Container();
            });
      },
    );
  }
}
