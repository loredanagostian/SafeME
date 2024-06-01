import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/managers/firebase_manager.dart';
import 'package:safe_me/managers/location_manager.dart';
import 'package:safe_me/managers/notification_manager.dart';
import 'package:safe_me/managers/user_info_provider.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/models/user_static_data.dart';
import 'package:safe_me/screens/track_location_screen.dart';
import 'package:safe_me/widgets/custom_alert_dialog.dart';
import 'package:safe_me/widgets/custom_list_tile.dart';
import 'package:safe_me/widgets/custom_user_information_modal.dart';
import 'package:url_launcher/url_launcher.dart';

class FriendsScreenFragment extends ConsumerStatefulWidget {
  final bool isTrackNow;
  final bool isGroups;
  final bool isAllFriends;
  final bool isRequests;
  const FriendsScreenFragment({
    super.key,
    this.isTrackNow = false,
    this.isGroups = false,
    this.isAllFriends = false,
    this.isRequests = false,
  });

  @override
  ConsumerState<FriendsScreenFragment> createState() =>
      _FriendsScreenFragmentState();
}

class _FriendsScreenFragmentState extends ConsumerState<FriendsScreenFragment> {
  List<Account> filteredData = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Account> accountsData = [];
  String totalFoundsAccounts = "";
  late UserStaticData _userStaticData;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      _onSearchTextChanged(_searchController.text);
    });

    _userStaticData = ref.read(userStaticDataProvider);
  }

  @override
  void dispose() {
    _searchController.removeListener(() {
      _onSearchTextChanged(
        _searchController.text,
      );
    });
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged(String text) {
    setState(() {
      _searchQuery = text;

      filteredData = accountsData
          .where((item) =>
              item.firstName.toLowerCase().contains(text.toLowerCase()) ||
              item.lastName.toLowerCase().contains(text.toLowerCase()))
          .toList();
    });
  }

  String returnCountType() {
    return widget.isTrackNow
        ? "trackings"
        : (widget.isGroups
            ? "groups"
            : (widget.isAllFriends
                ? "friends"
                : (widget.isRequests ? "requests" : "")));
  }

  String _getButtonText() {
    return widget.isTrackNow ? AppStrings.trackButton : AppStrings.sosButton;
  }

  Future<void> _getButton1Action(Account account, WidgetRef ref) async {
    if (widget.isTrackNow) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TrackLocationScreen(account: account)));
    }

    if (widget.isAllFriends) {
      var isPermission = await LocationManager.getLocationPermission();
      var isLocationEnabled = await Location().serviceEnabled();

      if (!isLocationEnabled) {
        isLocationEnabled = await Location().requestService();
      }
      if ((isPermission == LocationPermission.always ||
              isPermission == LocationPermission.whileInUse) &&
          isLocationEnabled) {
        await LocationManager.enableLocationSharing(ref);

        String message = _userStaticData.emergencySMS;
        String encodedMessage = Uri.encodeFull(message);
        final call =
            Uri.parse('sms:${account.phoneNumber}?body=$encodedMessage');
        if (await canLaunchUrl(call)) {
          launchUrl(call);
        } else {
          throw 'Could not launch $call';
        }

        NotificationManager.sendNotification(
          token: account.deviceToken,
          body: _userStaticData.emergencySMS,
          friendId: account.userId,
        );

        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print('Got a message whilst in the foreground!');
          if (message.notification != null) {
            print('Notification Title: ${message.notification!.title}');
            print('Notification Body: ${message.notification!.body}');
          }
        });
      }
    }

    if (widget.isRequests) {
      FirebaseManager.acceptFriendRequest(account.userId);

      if (_userStaticData.emergencyContacts.isEmpty)
        FirebaseManager.addEmergencyContact(account.userId);

      if (account.emergencyContacts.isEmpty)
        FirebaseManager.addEmergencyContactForFriend(account.userId);

      NotificationManager.sendNotification(
        token: account.deviceToken,
        body: AppStrings.friendRequestAccepted,
        friendId: account.userId,
      );
    }
  }

  void _showDeleteDialog(Account account) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: AppStrings.deleteUser,
            message:
                "${AppStrings.deleteUserMessage1} ${account.firstName} ${account.lastName} ${AppStrings.deleteUserMessage2_friendList}",
            onConfirm: () async {
              await FirebaseManager.removeFriend(account.userId);
              Navigator.pop(context);
            },
            onCancel: () {
              Navigator.pop(context);
              setState(() {});
            },
          );
        });
  }

  void _showUserInformationModal(BuildContext context, Account friendUser) {
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
              friend: friendUser,
              isRequests: widget.isRequests,
            )
          ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    _userStaticData = ref.watch(userStaticDataProvider);

    return SingleChildScrollView(
        child: FutureBuilder<List<Account>>(
            future: widget.isRequests
                ? FirebaseManager.fetchFriendRequestsAndReturnAccounts(
                    _userStaticData.friendsRequest)
                : FirebaseManager.fetchFriendsAndReturnAccounts(
                    widget.isAllFriends,
                    widget.isTrackNow,
                    _userStaticData.friends),
            builder: (context, AsyncSnapshot<List<Account>> accountsSnapshot) {
              if (accountsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (accountsSnapshot.hasData) {
                accountsData = accountsSnapshot.data!;
                totalFoundsAccounts = _searchQuery.isNotEmpty
                    ? filteredData.length.toString()
                    : accountsData.length.toString();

                return Container(
                  padding: const EdgeInsets.all(AppSizes.smallDistance),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CustomSearchBar(
                      //     onChanged: _onSearchTextChanged,
                      //     searchController: _searchController),
                      // const SizedBox(height: AppSizes.marginSize),
                      Text(
                        "$totalFoundsAccounts ${returnCountType()}",
                        style: AppStyles.textComponentStyle
                            .copyWith(color: AppColors.mainBlue),
                      ),
                      const Divider(
                        color: AppColors.mainDarkGray,
                        thickness: 1,
                      ),
                      ListView.builder(
                        itemCount: _searchQuery.isNotEmpty
                            ? filteredData.length
                            : accountsData.length,
                        itemBuilder: (context, index) {
                          final item = _searchQuery.isNotEmpty
                              ? filteredData[index]
                              : accountsData[index];

                          return GestureDetector(
                            onTap: () =>
                                _showUserInformationModal(context, item),
                            child: CustomListTile(
                              photoUrl: item.imageURL,
                              title: "${item.firstName} ${item.lastName}",
                              subtitle: item.phoneNumber,
                              isRequest: widget.isRequests,
                              buttonText: _getButtonText(),
                              button1Action: () async {
                                await _getButton1Action(item, ref);
                              },
                              button2Action: () async {
                                await FirebaseManager.declineFriendRequests(
                                    item.userId);
                              },
                              onDismiss: (DismissDirection direction) =>
                                  _showDeleteDialog(item),
                            ),
                          );
                        },
                        shrinkWrap: true,
                      )
                    ],
                  ),
                );
              }
              return Container();
            }));
  }
}
