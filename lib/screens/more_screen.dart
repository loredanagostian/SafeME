import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/screens/default_emergency_contacts_screen.dart';
import 'package:safe_me/screens/default_emergency_sms_screen.dart';
import 'package:safe_me/screens/default_tracking_sms_screen.dart';
import 'package:safe_me/screens/edit_profile_screen.dart';
import 'package:safe_me/screens/history_screen.dart';
import 'package:safe_me/screens/login_screen.dart';
import 'package:safe_me/widgets/custom_bottom_tab_navigator.dart';
import 'package:safe_me/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> {
  User? currentUser;
  late Account account;

  Future<Account> getCurrentUserDatas(User user) async {
    Map<String, dynamic>? data;

    await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get()
        .then((snapshot) {
      data = snapshot.docs[0].data();
    });

    if (data != null) {
      account = Account.fromJson(data!);
    }

    return account;
  }

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    Stream<DocumentSnapshot<Map<String, dynamic>>> stream = FirebaseFirestore
        .instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: const Text(
            AppStrings.moreTitle,
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
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: stream,
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                    snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData && snapshot.data!.data() != null) {
                  account = Account.fromJson(snapshot.data!.data()!);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSizes.smallDistance),
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 100,
                            width: 100,
                            child: Padding(
                                padding: const EdgeInsets.only(
                                    right: AppSizes.smallDistance),
                                child: CircleAvatar(
                                    backgroundImage:
                                        FileImage(File(account.imageURL)))),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              constraints: const BoxConstraints(
                                  maxWidth: 175, maxHeight: 150),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${account.firstName} ${account.lastName}",
                                    style: AppStyles.titleStyle.copyWith(
                                        color: AppColors.mainDarkGray),
                                  ),
                                  Text(
                                    account.email,
                                    overflow: TextOverflow.visible,
                                    style: AppStyles.hintComponentStyle
                                        .copyWith(
                                            color: AppColors.mainDarkGray),
                                  ),
                                  Text(
                                    account.phoneNumber,
                                    style: AppStyles.hintComponentStyle
                                        .copyWith(
                                            color: AppColors.mainDarkGray),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 100,
                            alignment: Alignment.topRight,
                            child: IconButton(
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            EditProfileScreen(user: account))),
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: AppColors.mainDarkGray,
                                )),
                          )
                        ],
                      ),
                      const Divider(
                        color: AppColors.mediumGray,
                        thickness: 0.6,
                      ),
                      ListTile(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HistoryScreen())),
                        title: Text(
                          AppStrings.history,
                          style: AppStyles.textComponentStyle
                              .copyWith(fontSize: 15),
                        ),
                        leading: const Icon(
                          Icons.history,
                          size: 35,
                          color: AppColors.mainDarkGray,
                        ),
                      ),
                      const Divider(
                        color: AppColors.mediumGray,
                        thickness: 0.6,
                      ),
                      ListTile(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    DefaultEmergencyContactsScreen(
                                        userAccount: account))),
                        title: Text(
                          AppStrings.changeDefaultEmergencyContacts,
                          style: AppStyles.textComponentStyle
                              .copyWith(fontSize: 15),
                        ),
                        leading: const Icon(
                          Icons.group_outlined,
                          size: 35,
                          color: AppColors.mainDarkGray,
                        ),
                      ),
                      const Divider(
                        color: AppColors.mediumGray,
                        thickness: 0.6,
                      ),
                      ListTile(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DefaultEmergencySmsScreen(
                                      emergencySMS: account.emergencySMS,
                                    ))),
                        title: Text(
                          AppStrings.changeEmergencySMS,
                          style: AppStyles.textComponentStyle
                              .copyWith(fontSize: 15),
                        ),
                        leading: const Icon(
                          Icons.sms_outlined,
                          size: 35,
                          color: AppColors.mainDarkGray,
                        ),
                      ),
                      const Divider(
                        color: AppColors.mediumGray,
                        thickness: 0.6,
                      ),
                      ListTile(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DefaultTrackingSmsScreen(
                                      trackingSMS: account.trackingSMS,
                                    ))),
                        title: Text(
                          AppStrings.changeTrackingSMS,
                          style: AppStyles.textComponentStyle
                              .copyWith(fontSize: 15),
                        ),
                        leading: const Icon(
                          Icons.share_location_outlined,
                          size: 35,
                          color: AppColors.mainDarkGray,
                        ),
                      ),
                      const Divider(
                        color: AppColors.mediumGray,
                        thickness: 0.6,
                      ),
                      ListTile(
                        onTap: () async {
                          final call = Uri.parse('tel:112');
                          if (await canLaunchUrl(call)) {
                            launchUrl(call);
                          } else {
                            throw 'Could not launch $call';
                          }
                        },
                        title: Text(
                          AppStrings.call112,
                          style: AppStyles.textComponentStyle
                              .copyWith(color: AppColors.mainRed, fontSize: 15),
                        ),
                        leading: const Icon(
                          Icons.emergency_outlined,
                          size: 35,
                          color: AppColors.mainRed,
                        ),
                      ),
                      const SizedBox(height: AppSizes.bigDistance),
                      CustomButton(
                          buttonColor: AppColors.mainBlue,
                          buttonText: AppStrings.logout,
                          // SIGN OUT
                          onTap: () async {
                            ref
                                .read(bottomNavigatorIndex.notifier)
                                .update((state) => 1);
                            await FirebaseAuth.instance.signOut().then(
                                (value) => Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen()),
                                    (route) => false));
                          }),
                    ]),
                  );
                } else {
                  return Container();
                }
              }
              return Container();
            }));
  }
}
