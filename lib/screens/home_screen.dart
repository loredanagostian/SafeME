import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/screens/more_screen.dart';
import 'package:safe_me/screens/track_location_screen.dart';
import 'package:safe_me/widgets/person_live_location.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  final Account userAccount;
  const HomeScreen({super.key, required this.userAccount});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool wasLongPressed = false;

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
    }

    return friendsList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: const Text(
            AppStrings.appTitle,
            style: AppStyles.titleStyle,
          ),
          actions: [
            // IconButton(
            //     onPressed: () => Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (context) => const NotificationsScreen())),
            //     icon: const Icon(
            //       Icons.notifications_outlined,
            //       color: AppColors.mainDarkGray,
            //       size: 30,
            //     )),
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
        body: FutureBuilder(
            future: fetchTrackMeFriends(widget.userAccount.friends),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return SingleChildScrollView(
                    child: Padding(
                  padding: const EdgeInsets.all(AppSizes.smallDistance),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppStrings.sharingLiveLocationNow,
                        style: AppStyles.sectionTitleStyle,
                      ),
                      const SizedBox(height: AppSizes.smallDistance),
                      SizedBox(
                          height: 65,
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              final item = snapshot.data![index];
                              return GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TrackLocationScreen(
                                                account: item,
                                                currentUser: widget.userAccount,
                                              ))),
                                  child: PersonLiveLocation(account: item));
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return const SizedBox(
                                width: AppSizes.smallDistance,
                              );
                            },
                          )),
                      const SizedBox(height: 2 * AppSizes.buttonHeight),
                      // const SizedBox(height: AppSizes.buttonHeight), // TODO change when adding emergency group
                      Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onLongPress: () async {
                            if (!wasLongPressed) {
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .update({
                                "trackMeNow": true,
                              });

                              String message = widget.userAccount.emergencySMS;
                              String encodedMessage = Uri.encodeFull(message);
                              final call = Uri.parse(
                                  'sms:0733156102?body=$encodedMessage');
                              if (await canLaunchUrl(call)) {
                                launchUrl(call);
                              } else {
                                throw 'Could not launch $call';
                              }
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
                                  color: Color.fromARGB(255, 255, 60, 0),
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
                          visible: wasLongPressed,
                          child: const SizedBox(height: AppSizes.bigDistance)),
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 175,
                          child: Visibility(
                              visible: wasLongPressed,
                              child: const Text(
                                AppStrings.emergencyGroupIsContacted,
                                style: AppStyles.bodyStyle,
                                textAlign: TextAlign.center,
                              )),
                        ),
                      ),
                      // const SizedBox(height: AppSizes.bigDistance),
                      // const Text(
                      //   AppStrings.emergencyGroup,
                      //   style: AppStyles.sectionTitleStyle,
                      // ),
                      // const SizedBox(height: AppSizes.smallDistance),
                      // const Row(
                      //   children: [
                      //     EmergencyMember(),
                      //     SizedBox(width: AppSizes.smallDistance),
                      //     EmergencyMember(),
                      //     SizedBox(width: AppSizes.smallDistance),
                      //     EmergencyMember(),
                      //   ],
                      // ),
                    ],
                  ),
                ));
              }
              return Container();
            }));
  }
}
