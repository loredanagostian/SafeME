import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/managers/location_manager.dart';
import 'package:safe_me/managers/notification_manager.dart';
import 'package:safe_me/models/account.dart';
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
  final Account userAccount;
  const FriendsScreenFragment({
    super.key,
    this.isTrackNow = false,
    this.isGroups = false,
    this.isAllFriends = false,
    this.isRequests = false,
    required this.userAccount,
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
  late Account currentUser;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      _onSearchTextChanged(_searchController.text);
    });

    currentUser = widget.userAccount;
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

  Future<List<Account>> fetchFriends(List<String> friendsIds) async {
    var friendsFutures = friendsIds.map((friendId) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .get()
          .then((snapshot) => snapshot.data());
    }).toList();

    var friendsData = await Future.wait(friendsFutures);
    List<Account> friendsList = [];

    for (var data in friendsData) {
      if (data != null) {
        final friend = Account.fromJson(data);

        if (widget.isAllFriends || (widget.isTrackNow && friend.trackMeNow)) {
          friendsList.add(friend);
        }
      }
    }

    return friendsList;
  }

  Future<List<Account>> fetchFriendRequests(
      List<String> friendRequestsIds) async {
    var friendRequestsFutures = friendRequestsIds.map((requestId) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(requestId)
          .get()
          .then((snapshot) => snapshot.data());
    }).toList();

    var friendRequestsData = await Future.wait(friendRequestsFutures);
    List<Account> friendRequests = [];

    for (var data in friendRequestsData) {
      if (data != null) {
        friendRequests.add(Account.fromJson(data));
      }
    }

    return friendRequests;
  }

  String _getButtonText() {
    return widget.isTrackNow ? AppStrings.trackButton : AppStrings.sosButton;
  }

  Future<void> _getButton1Action(Account account, WidgetRef ref) async {
    if (widget.isTrackNow) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TrackLocationScreen(
                    account: account,
                    currentUser: currentUser,
                  )));
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

        String message = currentUser.emergencySMS;
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
          body: currentUser.emergencySMS,
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
      currentUser.emergencyContacts.isEmpty
          ? FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update({
              "friendRequests": FieldValue.arrayRemove([account.userId]),
              "friends": FieldValue.arrayUnion([account.userId]),
              "emergencyContacts": FieldValue.arrayUnion([account.userId]),
            })
          : FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update({
              "friendRequests": FieldValue.arrayRemove([account.userId]),
              "friends": FieldValue.arrayUnion([account.userId]),
            });

      if (account.emergencyContacts.isEmpty) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(account.userId)
            .update({
          "emergencyContacts": FieldValue.arrayUnion([currentUser.userId]),
        });
      }

      FirebaseFirestore.instance
          .collection('users')
          .doc(account.userId)
          .update({
        "friends":
            FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
      });

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
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .update({
                "friends": FieldValue.arrayRemove([account.userId]),
                "emergencyContacts": FieldValue.arrayRemove([account.userId]),
              });

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(account.userId)
                  .update({
                "friends": FieldValue.arrayRemove(
                    [FirebaseAuth.instance.currentUser!.uid]),
                "emergencyContacts": FieldValue.arrayRemove(
                    [FirebaseAuth.instance.currentUser!.uid]),
              });

              Navigator.pop(context);
            },
            onCancel: () {
              Navigator.pop(context);
              setState(() {});
            },
          );
        });
  }

  void _showUserInformationModal(
      BuildContext context, Account friendUser, Account user) {
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
    Stream<DocumentSnapshot<Map<String, dynamic>>> stream = FirebaseFirestore
        .instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

    return SingleChildScrollView(
        child: StreamBuilder(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData && snapshot.data!.data() != null) {
                var userData = snapshot.data!.data()!;
                currentUser = Account.fromJson(userData);

                return FutureBuilder<List<Account>>(
                    future: widget.isRequests
                        ? fetchFriendRequests(currentUser.friendsRequest)
                        : fetchFriends(currentUser.friends),
                    builder: (context,
                        AsyncSnapshot<List<Account>> accountsSnapshot) {
                      if (accountsSnapshot.connectionState ==
                          ConnectionState.waiting) {
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
                                    onTap: () => _showUserInformationModal(
                                        context, item, currentUser),
                                    child: CustomListTile(
                                      photoUrl: item.imageURL,
                                      title:
                                          "${item.firstName} ${item.lastName}",
                                      subtitle: item.phoneNumber,
                                      isRequest: widget.isRequests,
                                      buttonText: _getButtonText(),
                                      button1Action: () async {
                                        await _getButton1Action(item, ref);
                                      },
                                      button2Action: () async {
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(FirebaseAuth
                                                .instance.currentUser!.uid)
                                            .update({
                                          "friendRequests":
                                              FieldValue.arrayRemove(
                                                  [item.userId])
                                        });
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
                    });
              }
              return Container();
            }));
  }
}
