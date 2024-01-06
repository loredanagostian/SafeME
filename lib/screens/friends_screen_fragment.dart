import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/managers/notification_manager.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/screens/track_location_screen.dart';
import 'package:safe_me/widgets/custom_list_tile.dart';
import 'package:safe_me/widgets/custom_search_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class FriendsScreenFragment extends StatefulWidget {
  final bool isTrackNow;
  final bool isGroups;
  final bool isAllFriends;
  final bool isRequests;
  final List<String> friendsList;
  final List<String> friendRequests;
  final Account userAccount;
  const FriendsScreenFragment({
    super.key,
    this.isTrackNow = false,
    this.isGroups = false,
    this.isAllFriends = false,
    this.isRequests = false,
    this.friendRequests = const [],
    required this.friendsList,
    required this.userAccount,
  });

  @override
  State<FriendsScreenFragment> createState() => _FriendsScreenFragmentState();
}

class _FriendsScreenFragmentState extends State<FriendsScreenFragment> {
  List<Account> filteredData = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Account> accountsData = [];
  late Future _futureFriends;
  late Future _futureRequests;
  String totalFoundsAccounts = "";

  @override
  void initState() {
    super.initState();

    _futureFriends = fetchFriends(widget.friendsList);
    _futureRequests = fetchFriendRequests(widget.friendRequests);

    _searchController.addListener(() {
      _onSearchTextChanged(_searchController.text);
    });
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

      if (widget.isAllFriends) {
        friendsList.add(Account.fromJson(data!));
      }

      if (widget.isTrackNow) {
        final friend = Account.fromJson(data!);
        if (friend.trackMeNow) {
          friendsList.add(friend);
        }
      }
    }

    return friendsList;
  }

  Future<List<Account>> fetchFriendRequests(
      List<String> friendRequestsIds) async {
    List<Account> friendRequests = [];

    for (int i = 0; i < friendRequestsIds.length; i++) {
      Map<String, dynamic>? data;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(friendRequestsIds[i].toString())
          .get()
          .then((snapshot) {
        data = snapshot.data();
      });

      friendRequests.add(Account.fromJson(data!));
    }

    return friendRequests;
  }

  String _getButtonText() {
    return widget.isTrackNow ? AppStrings.trackButton : AppStrings.sosButton;
  }

  Future<String> getAccountId(Account account) async {
    String data = "";

    await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: account.email)
        .get()
        .then((snapshot) {
      data = snapshot.docs[0].id;
    });

    return data;
  }

  Future<void> _getButton1Action(Account account) async {
    if (widget.isTrackNow) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TrackLocationScreen(
                    account: account,
                    currentUser: widget.userAccount,
                  )));
    }

    if (widget.isAllFriends) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        "trackMeNow": true,
      });

      String message = widget.userAccount.emergencySMS;
      String encodedMessage = Uri.encodeFull(message);
      final call = Uri.parse('sms:${account.phoneNumber}?body=$encodedMessage');
      if (await canLaunchUrl(call)) {
        launchUrl(call);
      } else {
        throw 'Could not launch $call';
      }

      NotificationManager.sendNotification(account.deviceToken,
          AppStrings.sosButton, AppStrings.openAppToTrack, account.userId);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        if (message.notification != null) {
          print('Notification Title: ${message.notification!.title}');
          print('Notification Body: ${message.notification!.body}');
        }
      });
    }

    if (widget.isRequests) {
      String accountId = await getAccountId(account);

      widget.userAccount.emergencyContact.isEmpty
          ? FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update({
              "friendRequests": FieldValue.arrayRemove([accountId]),
              "friends": FieldValue.arrayUnion([accountId]),
              "emergencyContact": account.userId,
            })
          : FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update({
              "friendRequests": FieldValue.arrayRemove([accountId]),
              "friends": FieldValue.arrayUnion([accountId]),
            });

      if (account.emergencyContact.isEmpty) {
        FirebaseFirestore.instance.collection('users').doc(accountId).update({
          "emergencyContact": widget.userAccount.userId,
        });
      }

      FirebaseFirestore.instance.collection('users').doc(accountId).update({
        "friends":
            FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FutureBuilder(
          future: widget.isRequests ? _futureRequests : _futureFriends,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              accountsData = snapshot.data!;
              totalFoundsAccounts = _searchQuery.isNotEmpty
                  ? filteredData.length.toString()
                  : accountsData.length.toString();

              return Container(
                padding: const EdgeInsets.all(AppSizes.smallDistance),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomSearchBar(
                        onChanged: _onSearchTextChanged,
                        searchController: _searchController),
                    const SizedBox(height: AppSizes.marginSize),
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

                        return CustomListTile(
                          photoUrl: item.imageURL,
                          title: item.firstName,
                          subtitle: item.phoneNumber,
                          isRequest: widget.isRequests,
                          buttonText: _getButtonText(),
                          button1Action: () async {
                            await _getButton1Action(item);
                          },
                          button2Action: () async {
                            String accountId = await getAccountId(item);
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .update({
                              "friendRequests":
                                  FieldValue.arrayRemove([accountId])
                            });
                          },
                          onDismiss: (DismissDirection direction) async {
                            String accountId = await getAccountId(item);
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .update({
                              "friends": FieldValue.arrayRemove([accountId])
                            });

                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(accountId)
                                .update({
                              "friends": FieldValue.arrayRemove(
                                  [FirebaseAuth.instance.currentUser!.uid])
                            });
                          },
                        );
                      },
                      shrinkWrap: true,
                    )
                  ],
                ),
              );
            }
            return Container();
          }),
    );
  }
}
