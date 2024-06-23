import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/paths.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/managers/chat_manager.dart';
import 'package:safe_me/managers/firebase_manager.dart';
import 'package:safe_me/managers/location_manager.dart';
import 'package:safe_me/managers/user_info_provider.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/models/history_event.dart';
import 'package:safe_me/models/user_static_data.dart';
import 'package:safe_me/screens/friends_screens/add_friend_screen.dart';
import 'package:safe_me/screens/friends_screens/chat_screen.dart';
import 'package:safe_me/screens/more_screens/default_emergency_contacts_screen.dart';
import 'package:safe_me/screens/more_screens/more_screen.dart';
import 'package:safe_me/screens/main_screens/notifications_screen.dart';
import 'package:safe_me/screens/onboarding_screens/onboarding_screen.dart';
import 'package:safe_me/widgets/custom_alert_dialog.dart';
import 'package:safe_me/widgets/custom_bottom_tab_navigator.dart';
import 'package:safe_me/widgets/emergency_member.dart';
import 'package:safe_me/widgets/person_chat_room.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Account? emergencyUser;
  bool wasLongPress = false;
  late UserStaticData _userStaticData;

  Future<LocationPermission> getLocationPermission() async {
    var isPermission = await Geolocator.checkPermission();
    if (isPermission == LocationPermission.denied ||
        isPermission == LocationPermission.deniedForever) {
      isPermission = await Geolocator.requestPermission();
    }

    return isPermission;
  }

  void _showDeleteDialog(Account account) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: AppStrings.deleteChatTitle,
            message:
                "${AppStrings.deleteUserMessage1} ${account.firstName} ${account.lastName} ${AppStrings.deleteChatMessage}",
            firstButtonAction: () async {
              await ChatManager.deleteAllMessages(
                  FirebaseAuth.instance.currentUser!.uid, account.userId);

              Navigator.pop(context);
            },
            secondButtonAction: () {
              Navigator.pop(context);
              setState(() {});
            },
          );
        });
  }

  Future<Placemark?> _getAddressFromLatLng(Account user) async {
    try {
      if (user.lastLatitude != 0 || user.lastLongitude != 0) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            user.lastLatitude, user.lastLongitude);
        Placemark place = placemarks[0];

        return place;
      }
    } catch (e) {
      print(e);
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _userStaticData = ref.read(userStaticDataProvider);
    _initializeUserData();
  }

  void _initializeUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      var userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        var userData = Account.fromJson(userSnapshot.docs.first.data());
        ref.read(userStaticDataProvider.notifier).updateUserInfo(UserStaticData(
            email: userData.email,
            firstName: userData.firstName,
            lastName: userData.lastName,
            phoneNumber: userData.phoneNumber,
            emergencySMS: userData.emergencySMS,
            trackingSMS: userData.trackingSMS,
            friends: userData.friends,
            friendsRequest: userData.friendsRequest,
            userId: userData.userId,
            emergencyContacts: userData.emergencyContacts,
            deviceToken: userData.deviceToken,
            history: userData.history,
            notifications: userData.notifications));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot<Map<String, dynamic>>> stream =
        FirebaseFirestore.instance.collection('users').snapshots();

    Stream<QuerySnapshot<Map<String, dynamic>>> chatStream =
        FirebaseFirestore.instance.collection('chat_rooms').snapshots();

    _userStaticData = ref.watch(userStaticDataProvider);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: Row(
            children: [
              const Text(
                AppStrings.appTitle,
                style: AppStyles.titleStyle,
              ),
              IconButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              OnboardingScreen(isOnboarding: false))),
                  icon: Icon(
                    Icons.help_outline,
                    color: AppColors.lightBlue,
                    size: 30,
                  )),
            ],
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  bool shouldRefresh = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NotificationsScreen()));

                  if (shouldRefresh) setState(() {});
                },
                icon: Icon(
                  _userStaticData.notifications
                          .where((element) => element.opened == false)
                          .toList()
                          .isEmpty
                      ? Icons.notifications_outlined
                      : Icons.notifications,
                  color: _userStaticData.notifications
                          .where((element) => element.opened == false)
                          .toList()
                          .isEmpty
                      ? AppColors.mainDarkGray
                      : AppColors.mainBlue,
                  size: 30,
                )),
            GestureDetector(
              onTap: () async {
                bool shouldRefresh = await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MoreScreen()));
                if (shouldRefresh) setState(() {});
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
                    List<Account> emergencyAccounts = [];
                    if (userData.emergencyContacts.isNotEmpty) {
                      List<Future<Account>> futures = userData.emergencyContacts
                          .map((e) async => await FirebaseManager
                              .fetchUserInfoAndReturnAccount(e))
                          .toList();

                      Future.wait(futures).then((List<Account> accounts) {
                        emergencyAccounts.addAll(accounts);
                      });
                    }

                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: chatStream,
                        builder: (context, asyncSnapshot) {
                          if (asyncSnapshot.hasError) {
                            print("Error ${asyncSnapshot.error}");
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
                                              Future<Account> item = FirebaseManager
                                                  .fetchUserInfoAndReturnAccount(
                                                      friendsId[index]);
                                              return GestureDetector(
                                                  onLongPress: () async =>
                                                      _showDeleteDialog(
                                                          await item),
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
                                                                              snapshot.data!);
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
                                  FutureBuilder(
                                    future: _getAddressFromLatLng(userData),
                                    builder: (context, locationSnapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.active) {
                                        return Align(
                                          alignment: Alignment.center,
                                          child: GestureDetector(
                                            onLongPress: () async {
                                              if (userData.emergencyContacts
                                                  .isNotEmpty) {
                                                setState(() {
                                                  wasLongPress = true;
                                                });
                                                Timer(Duration(seconds: 10),
                                                    () {
                                                  setState(() {
                                                    wasLongPress = false;
                                                  });
                                                });

                                                LocationManager
                                                    .enableLocationSharing(ref);

                                                String message = _userStaticData
                                                    .emergencySMS;
                                                String encodedMessage =
                                                    Uri.encodeFull(message);
                                                List<String> phoneNumbers =
                                                    List<String>.from(
                                                        emergencyAccounts.map(
                                                            (e) =>
                                                                e.phoneNumber));
                                                String phoneNumbersString =
                                                    phoneNumbers.join(',');

                                                final call = Uri.parse(
                                                    'smsto:${phoneNumbersString}?body=$encodedMessage');
                                                if (await canLaunchUrl(call)) {
                                                  launchUrl(call);
                                                } else {
                                                  throw 'Could not launch $call';
                                                }

                                                // Create history element
                                                HistoryEvent historyEvent =
                                                    HistoryEvent(
                                                        startDate:
                                                            DateTime.now(),
                                                        isTrackingEvent: true,
                                                        city: snapshot.hasData
                                                            ? locationSnapshot
                                                                    .data
                                                                    ?.locality ??
                                                                ""
                                                            : "",
                                                        country: snapshot
                                                                .hasData
                                                            ? locationSnapshot
                                                                    .data
                                                                    ?.country ??
                                                                ""
                                                            : "");

                                                _userStaticData.history
                                                    .add(historyEvent);
                                                ref
                                                    .read(userStaticDataProvider
                                                        .notifier)
                                                    .updateUserInfo(
                                                        _userStaticData);

                                                FirebaseManager
                                                        .addNewHistoryElement(
                                                            historyEvent)
                                                    .then((value) {
                                                  // Check if there are routes available to pop
                                                  if (Navigator.canPop(
                                                      context)) {
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
                                        );
                                      }
                                      return Container();
                                    },
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
                                              userData.emergencyContacts
                                                  .isNotEmpty &&
                                              wasLongPress,
                                          child: const Text(
                                            AppStrings
                                                .emergencyContactsAreContacted,
                                            style: AppStyles.bodyStyle,
                                            textAlign: TextAlign.center,
                                          )),
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.buttonHeight),
                                  Row(
                                    children: [
                                      const Text(
                                        AppStrings.emergencyContacts,
                                        style: AppStyles.sectionTitleStyle,
                                      ),
                                      const SizedBox(
                                          width: AppSizes.smallDistance),
                                      Visibility(
                                        visible: userData
                                            .emergencyContacts.isNotEmpty,
                                        child: FutureBuilder(
                                          future: FirebaseManager
                                              .fetchFriendsAndReturnAccounts(
                                                  false,
                                                  false,
                                                  userData.friends),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasError) {
                                              print("Error${snapshot.error}");
                                            } else if (snapshot.hasData) {
                                              return IconButton(
                                                  onPressed: () => Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              DefaultEmergencyContactsScreen())),
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
                                  userData.emergencyContacts.isNotEmpty
                                      ? SizedBox(
                                          height: 115,
                                          child: ListView.separated(
                                            shrinkWrap: true,
                                            itemCount: userData
                                                .emergencyContacts.length,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              Future<Account> item = FirebaseManager
                                                  .fetchUserInfoAndReturnAccount(
                                                      userData.emergencyContacts[
                                                          index]);
                                              return EmergencyMember(
                                                  emergencyUser: item);
                                            },
                                            separatorBuilder:
                                                (BuildContext context,
                                                    int index) {
                                              return const SizedBox(
                                                width: AppSizes.smallDistance,
                                              );
                                            },
                                          ),
                                        )
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
