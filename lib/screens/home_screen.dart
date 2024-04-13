import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/managers/chat_manager.dart';
import 'package:safe_me/managers/location_manager.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/models/history_event.dart';
import 'package:safe_me/models/notification_model.dart';
import 'package:safe_me/screens/add_friend_screen.dart';
import 'package:safe_me/screens/chat_screen.dart';
import 'package:safe_me/screens/more_screen.dart';
import 'package:safe_me/screens/notifications_screen.dart';
import 'package:safe_me/widgets/custom_bottom_tab_navigator.dart';
import 'package:safe_me/widgets/custom_friends_bottom_modal.dart';
import 'package:safe_me/widgets/emergency_member.dart';
import 'package:safe_me/widgets/person_chat_room.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final Account userAccount;
  const HomeScreen({super.key, required this.userAccount});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Account? emergencyUser;
  bool wasLongPress = false;

  Future<LocationPermission> getLocationPermission() async {
    var isPermission = await Geolocator.checkPermission();
    if (isPermission == LocationPermission.denied ||
        isPermission == LocationPermission.deniedForever) {
      isPermission = await Geolocator.requestPermission();
    }

    return isPermission;
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
        friendsList.add(friend);
      }
    }

    return friendsList;
  }

  void showAllFriendsList(BuildContext context, List<Account> friends) {
    showModalBottomSheet<void>(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSizes.borders),
                topRight: Radius.circular(AppSizes.borders))),
        context: context,
        builder: (BuildContext context) {
          return CustomFriendsBottomModal(
            allFriends: friends,
            userAccount: widget.userAccount,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot<Map<String, dynamic>>> stream =
        FirebaseFirestore.instance.collection('users').snapshots();

    Stream<QuerySnapshot<Map<String, dynamic>>> chatStream =
        FirebaseFirestore.instance.collection('chat_rooms').snapshots();

    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: const Text(
            AppStrings.appTitle,
            style: AppStyles.titleStyle,
          ),
          actions: [
            IconButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationsScreen(
                            userAccount: widget.userAccount))),
                icon: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        User? currentUser = FirebaseAuth.instance.currentUser;
                        var user = snapshot.data!.docs.firstWhere(
                            (value) => value["userId"] == currentUser!.uid);
                        Account userData = Account.fromJson(user.data());
                        List<NotificationModel> unreadNotifications = [];
                        unreadNotifications = userData.notifications
                            .where((element) => element.opened == false)
                            .toList();

                        return Icon(
                          unreadNotifications.isEmpty
                              ? Icons.notifications_outlined
                              : Icons.notifications,
                          color: unreadNotifications.isEmpty
                              ? AppColors.mainDarkGray
                              : AppColors.mainBlue,
                          size: 30,
                        );
                      }
                      return Container();
                    })),
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
        ),
        backgroundColor: AppColors.white,
        body: SingleChildScrollView(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data != null) {
                    User? currentUser = FirebaseAuth.instance.currentUser;
                    var user = snapshot.data!.docs.firstWhere(
                        (value) => value["userId"] == currentUser!.uid);
                    Account userData = Account.fromJson(user.data());

                    Future<Account> emergencyAccount;
                    if (userData.emergencyContact.isNotEmpty) {
                      emergencyAccount = FirebaseFirestore.instance
                          .collection('users')
                          .doc(userData.emergencyContact)
                          .get()
                          .then((snapshot) {
                        Map<String, dynamic>? data = snapshot.data();
                        return Account.fromJson(data ?? {});
                      });
                    } else {
                      emergencyAccount = Future(() => Account.fromJson({}));
                    }

                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: chatStream,
                        builder: (context, asyncSnapshot) {
                          if (asyncSnapshot.hasError) {
                            print("Error${asyncSnapshot.error}");
                          }
                          if (asyncSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (asyncSnapshot.hasData &&
                              asyncSnapshot.data != null) {
                            List<String> friendsId =
                                ChatManager.getFriendsIdForUser(
                                    currentUser!.uid, asyncSnapshot.data!.docs);

                            return Padding(
                              padding:
                                  const EdgeInsets.all(AppSizes.smallDistance),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    AppStrings.chatRooms,
                                    style: AppStyles.sectionTitleStyle,
                                  ),
                                  const SizedBox(
                                      height: AppSizes.smallDistance),
                                  SizedBox(
                                    height: 65,
                                    child: friendsId.length > 0
                                        ? ListView.separated(
                                            shrinkWrap: true,
                                            itemCount: friendsId.length,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              Future<Account> item =
                                                  FirebaseFirestore.instance
                                                      .collection('users')
                                                      .doc(friendsId[index])
                                                      .get()
                                                      .then((value) {
                                                Map<String, dynamic>? data =
                                                    value.data();
                                                var test = Account.fromJson(
                                                    data ?? {});
                                                return test;
                                              });
                                              return GestureDetector(
                                                  onTap: () => Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              FutureBuilder(
                                                                  future: item,
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    if (snapshot
                                                                        .hasError) {
                                                                      print(
                                                                          "Error${snapshot.error}");
                                                                    } else if (snapshot
                                                                            .connectionState ==
                                                                        ConnectionState
                                                                            .waiting) {
                                                                      return Center(
                                                                          child:
                                                                              CircularProgressIndicator());
                                                                    } else if (snapshot
                                                                        .hasData) {
                                                                      return ChatScreen(
                                                                        friendAccount:
                                                                            snapshot.data!,
                                                                        currentUserImageUrl:
                                                                            userData.imageURL,
                                                                      );
                                                                    }
                                                                    return Container();
                                                                  }))),
                                                  child: PersonChatRoom(
                                                      futureFriend: item));
                                            },
                                            separatorBuilder:
                                                (BuildContext context,
                                                    int index) {
                                              return const SizedBox(
                                                width: AppSizes.smallDistance,
                                              );
                                            },
                                          )
                                        : Container(
                                            width: 65,
                                            decoration: BoxDecoration(
                                                color: AppColors.lightGray,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppSizes.borders)),
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                  AppSizes.smallDistance),
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.add_circle,
                                                  color: AppColors.mainDarkGray,
                                                  size: 35,
                                                ),
                                                onPressed: () => ref
                                                    .read(bottomNavigatorIndex
                                                        .notifier)
                                                    .update((state) => 2),
                                              ),
                                            )),
                                  ),
                                  const SizedBox(height: AppSizes.buttonHeight),
                                  Align(
                                    alignment: Alignment.center,
                                    child: GestureDetector(
                                      onLongPress: () async {
                                        if (userData
                                            .emergencyContact.isNotEmpty) {
                                          setState(() {
                                            wasLongPress = true;
                                          });
                                          Timer(Duration(seconds: 30), () {
                                            setState(() {
                                              wasLongPress = false;
                                            });
                                          });

                                          LocationManager.enableLocationSharing(
                                              ref);

                                          // ref
                                          //     .read(startTimeSafePlaceHistory
                                          //         .notifier)
                                          //     .update(
                                          //         (state) => DateTime.now());

                                          String message =
                                              widget.userAccount.emergencySMS;
                                          String encodedMessage =
                                              Uri.encodeFull(message);

                                          Account emergencyAccount =
                                              await FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(
                                                      userData.emergencyContact)
                                                  .get()
                                                  .then((snapshot) {
                                            Map<String, dynamic>? data =
                                                snapshot.data();
                                            return Account.fromJson(data ?? {});
                                          });

                                          final call = Uri.parse(
                                              'sms:${emergencyAccount.phoneNumber}?body=$encodedMessage');
                                          if (await canLaunchUrl(call)) {
                                            launchUrl(call);
                                          } else {
                                            throw 'Could not launch $call';
                                          }

                                          // Create history element
                                          HistoryEvent historyEvent =
                                              HistoryEvent(
                                            startDate: DateTime.now(),
                                            // endDate: DateTime.now(),
                                            // duration: DateTime.now()
                                            //     .difference(ref.read(
                                            //         startTimeTrackHistory))
                                            //     .inMinutes,
                                            isTrackingEvent: true,
                                          );

                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(FirebaseAuth
                                                  .instance.currentUser!.uid)
                                              .update({
                                            "history": FieldValue.arrayUnion(
                                                [historyEvent.toMap()]),
                                          }).then((value) {
                                            // Check if there are routes available to pop
                                            if (Navigator.canPop(context)) {
                                              Navigator.pop(context);
                                            }
                                          });
                                        } else {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddFriendScreen()));
                                        }
                                      },
                                      child: Container(
                                        height: 175,
                                        width: 175,
                                        decoration: const BoxDecoration(
                                          color: AppColors.mainRed,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color.fromARGB(
                                                  255, 255, 60, 0),
                                              spreadRadius: 0,
                                              blurRadius: 80,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.sos_outlined,
                                          size: 85,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                      visible:
                                          userData.trackMeNow && wasLongPress,
                                      child: const SizedBox(
                                          height: AppSizes.bigDistance)),
                                  Align(
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      width: 175,
                                      child: Visibility(
                                          visible: userData.trackMeNow &&
                                              userData.emergencyContact
                                                  .isNotEmpty &&
                                              wasLongPress,
                                          child: const Text(
                                            AppStrings
                                                .emergencyGroupIsContacted,
                                            style: AppStyles.bodyStyle,
                                            textAlign: TextAlign.center,
                                          )),
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.buttonHeight),
                                  Row(
                                    children: [
                                      const Text(
                                        AppStrings.emergencyContact,
                                        style: AppStyles.sectionTitleStyle,
                                      ),
                                      const SizedBox(
                                          width: AppSizes.smallDistance),
                                      Visibility(
                                        visible: userData
                                            .emergencyContact.isNotEmpty,
                                        child: FutureBuilder(
                                          future:
                                              fetchFriends(userData.friends),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasError) {
                                              print("Error${snapshot.error}");
                                            } else if (snapshot.hasData) {
                                              return IconButton(
                                                  onPressed: () =>
                                                      showAllFriendsList(
                                                          context,
                                                          snapshot.data!),
                                                  icon: const Icon(
                                                    Icons.edit_outlined,
                                                    color:
                                                        AppColors.mainDarkGray,
                                                  ));
                                            }
                                            return Container();
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                      height: AppSizes.smallDistance),

                                  userData.emergencyContact.isNotEmpty
                                      ? EmergencyMember(
                                          emergencyUser: emergencyAccount)
                                      : Container(
                                          height: 100,
                                          width: 75,
                                          decoration: BoxDecoration(
                                              color: AppColors.lightGray,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppSizes.borders)),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.add_circle,
                                              color: AppColors.mainDarkGray,
                                              size: 35,
                                            ),
                                            onPressed: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AddFriendScreen())),
                                          ),
                                        ),
                                  // const Row(
                                  //   children: [
                                  //     EmergencyMember(),
                                  //     SizedBox(width: AppSizes.smallDistance),
                                  //     EmergencyMember(),
                                  //     SizedBox(width: AppSizes.smallDistance),
                                  //     EmergencyMember(),
                                  //   ],
                                  // ),
                                  const SizedBox(
                                      height: kBottomNavigationBarHeight)
                                ],
                              ),
                            );
                          }
                          return Container();
                        });
                  }
                  return Container();
                })));
  }
}
