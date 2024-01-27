import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/screens/more_screen.dart';
import 'package:safe_me/screens/notifications_screen.dart';
import 'package:safe_me/screens/track_location_screen.dart';
import 'package:safe_me/widgets/custom_friends_bottom_modal.dart';
import 'package:safe_me/widgets/emergency_member.dart';
import 'package:safe_me/widgets/person_live_location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart' as loc;

class HomeScreen extends StatefulWidget {
  final Account userAccount;
  const HomeScreen({super.key, required this.userAccount});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool wasLongPressed = false;
  Location location = Location();
  StreamSubscription<loc.LocationData>? locationSubscription;
  Account? emergencyUser;
  List<Account> allFriends = [];

  Future<List<Account>> fetchTrackMeFriends(List<String> friendsIds) async {
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

      final friend = Account.fromJson(data!);
      if (friend.trackMeNow) {
        friendsList.add(friend);
      }

      if (widget.userAccount.emergencyContact == friend.userId) {
        emergencyUser = friend;
      }

      allFriends.add(friend);
    }

    return friendsList;
  }

  Future<LocationPermission> getLocationPermission() async {
    var isPermission = await Geolocator.checkPermission();
    if (isPermission == LocationPermission.denied ||
        isPermission == LocationPermission.deniedForever) {
      isPermission = await Geolocator.requestPermission();
    }

    return isPermission;
  }

  Future<void> storeLocationInDB() async {
    try {
      var isPermission = await getLocationPermission();

      if (isPermission == LocationPermission.denied ||
          isPermission == LocationPermission.deniedForever) {
        throw Exception(AppStrings.locationPermissionDenied);
      }

      if (isPermission == LocationPermission.always ||
          isPermission == LocationPermission.whileInUse) {
        location.changeSettings(accuracy: loc.LocationAccuracy.high);

        locationSubscription =
            location.onLocationChanged.listen((LocationData currentLocation) {
          if (currentLocation.latitude != null &&
              currentLocation.longitude != null) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .update({
              "userLastLatitude": currentLocation.latitude,
              "userLastLongitude": currentLocation.longitude,
            });
          }
        });
      } else {
        throw Exception(AppStrings.locationPermissionDenied);
      }
    } on TimeoutException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  void showAllFriendsList(BuildContext context) {
    showModalBottomSheet<void>(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSizes.borders),
                topRight: Radius.circular(AppSizes.borders))),
        context: context,
        builder: (BuildContext context) {
          return CustomFriendsBottomModal(
            allFriends: allFriends,
            userAccount: widget.userAccount,
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
    locationSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot<Map<String, dynamic>>> stream =
        FirebaseFirestore.instance.collection('users').snapshots();

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
                icon: const Icon(
                  Icons.notifications_outlined,
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

                    return FutureBuilder<List<Account>>(
                        future: fetchTrackMeFriends(userData.friends),
                        builder: (context,
                            AsyncSnapshot<List<Account>> asyncSnapshot) {
                          if (asyncSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (asyncSnapshot.hasData) {
                            List<Account> trackMeFriends =
                                asyncSnapshot.data ?? [];

                            return Padding(
                              padding:
                                  const EdgeInsets.all(AppSizes.smallDistance),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Visibility(
                                    visible: trackMeFriends.isNotEmpty,
                                    child: const Text(
                                      AppStrings.sharingLiveLocationNow,
                                      style: AppStyles.sectionTitleStyle,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: AppSizes.smallDistance),

                                  SizedBox(
                                      height: 65,
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        itemCount: trackMeFriends.length,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final item =
                                              asyncSnapshot.data![index];
                                          return GestureDetector(
                                              onTap: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          TrackLocationScreen(
                                                            account: item,
                                                            currentUser: widget
                                                                .userAccount,
                                                          ))),
                                              child: PersonLiveLocation(
                                                  account: item));
                                        },
                                        separatorBuilder:
                                            (BuildContext context, int index) {
                                          return const SizedBox(
                                            width: AppSizes.smallDistance,
                                          );
                                        },
                                      )),
                                  const SizedBox(height: AppSizes.buttonHeight),
                                  // const SizedBox(height: AppSizes.buttonHeight), // TODO change when adding emergency group
                                  Align(
                                    alignment: Alignment.center,
                                    child: GestureDetector(
                                      onLongPress: () async {
                                        if (!wasLongPressed) {
                                          await storeLocationInDB();

                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(FirebaseAuth
                                                  .instance.currentUser!.uid)
                                              .update({
                                            "trackMeNow": true,
                                          });

                                          String message =
                                              widget.userAccount.emergencySMS;
                                          String encodedMessage =
                                              Uri.encodeFull(message);
                                          final call = Uri.parse(
                                              'sms:0733156102?body=$encodedMessage');
                                          if (await canLaunchUrl(call)) {
                                            launchUrl(call);
                                          } else {
                                            throw 'Could not launch $call';
                                          }
                                        } else {
                                          locationSubscription?.cancel();
                                          setState(() {
                                            locationSubscription = null;
                                          });

                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(FirebaseAuth
                                                  .instance.currentUser!.uid)
                                              .update({
                                            "trackMeNow": false,
                                          });
                                        }
                                        setState(() {
                                          wasLongPressed = !wasLongPressed;
                                        });
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
                                        child: wasLongPressed
                                            ? const Icon(
                                                Icons.cancel,
                                                size: 85,
                                                color: AppColors.white,
                                              )
                                            : const Icon(
                                                Icons.sos_outlined,
                                                size: 85,
                                                color: AppColors.white,
                                              ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                      visible: wasLongPressed,
                                      child: const SizedBox(
                                          height: AppSizes.bigDistance)),
                                  Align(
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      width: 175,
                                      child: Visibility(
                                          visible: wasLongPressed,
                                          child: const Text(
                                            AppStrings
                                                .emergencyGroupIsContacted,
                                            style: AppStyles.bodyStyle,
                                            textAlign: TextAlign.center,
                                          )),
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.buttonHeight),
                                  emergencyUser != null
                                      ? Row(
                                          children: [
                                            const Text(
                                              AppStrings.emergencyContact,
                                              style:
                                                  AppStyles.sectionTitleStyle,
                                            ),
                                            const SizedBox(
                                                width: AppSizes.smallDistance),
                                            IconButton(
                                                onPressed: () =>
                                                    showAllFriendsList(context),
                                                icon: const Icon(
                                                  Icons.edit_outlined,
                                                  color: AppColors.mainDarkGray,
                                                ))
                                          ],
                                        )
                                      : Container(),

                                  const SizedBox(
                                      height: AppSizes.smallDistance),
                                  emergencyUser != null
                                      ? EmergencyMember(
                                          emergencyUser: emergencyUser!)
                                      : Container(),

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
