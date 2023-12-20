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
import 'package:safe_me/screens/notifications_screen.dart';
import 'package:safe_me/widgets/custom_bottom_tab_navigator.dart';
import 'package:safe_me/widgets/emergency_member.dart';
import 'package:safe_me/widgets/person_live_location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool wasLongPressed = false;
  User? currentUser;
  late Map<String, dynamic> firestoreUser;
  String userImageURL = "";

  Future<Account> getCurrentUserDatas(User user) async {
    late Account account;

    await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get()
        .then((snapshot) {
      account = Account.fromJson(snapshot.docs[0].data());
      firestoreUser = snapshot.docs[0].data();
      userImageURL = snapshot.docs[0].data()["imageURL"];
    });

    return account;
  }

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
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
          IconButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationsScreen())),
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppColors.mainDarkGray,
                size: 30,
              )),
          GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MoreScreen(user: firestoreUser))),
            child: SizedBox(
              height: 50,
              width: 50,
              child: Padding(
                padding: const EdgeInsets.only(right: AppSizes.smallDistance),
                child: userImageURL.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: FileImage(File(userImageURL)))
                    : const CircleAvatar(
                        backgroundImage:
                            AssetImage("lib/assets/images/default_account.png"),
                        backgroundColor: AppColors.white,
                      ),
              ),
            ),
          )
        ],
      ),
      backgroundColor: AppColors.white,
      bottomNavigationBar: const CustomBottomTabNavigator(),
      body: FutureBuilder(
          future: getCurrentUserDatas(currentUser!),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.connectionState == ConnectionState.done) {
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
                    const Row(
                      children: [
                        PersonLiveLocation(),
                        SizedBox(width: AppSizes.smallDistance),
                        PersonLiveLocation(),
                        SizedBox(width: AppSizes.smallDistance),
                        PersonLiveLocation(),
                      ],
                    ),
                    const SizedBox(height: AppSizes.buttonHeight),
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onLongPress: () => setState(() {
                          wasLongPressed = !wasLongPressed;
                        }),
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
                          child: Icon(
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
                    Center(
                      child: Visibility(
                          visible: wasLongPressed,
                          child: Text(
                            AppStrings.emergencyGroupIsContacted,
                            style: AppStyles.textComponentStyle
                                .copyWith(fontSize: 18),
                          )),
                    ),
                    const SizedBox(height: 2 * AppSizes.bigDistance),
                    const Text(
                      AppStrings.emergencyGroup,
                      style: AppStyles.sectionTitleStyle,
                    ),
                    const SizedBox(height: AppSizes.smallDistance),
                    const Row(
                      children: [
                        EmergencyMember(),
                        SizedBox(width: AppSizes.smallDistance),
                        EmergencyMember(),
                        SizedBox(width: AppSizes.smallDistance),
                        EmergencyMember(),
                      ],
                    ),
                  ],
                ),
              ));
            } else {
              return Container();
            }
          }),
    );
  }
}
