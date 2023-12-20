import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/screens/default_emergency_group_screen.dart';
import 'package:safe_me/screens/default_emergency_sms_screen.dart';
import 'package:safe_me/screens/default_tracking_sms_screen.dart';
import 'package:safe_me/screens/edit_profile_screen.dart';
import 'package:safe_me/screens/login_screen.dart';
import 'package:safe_me/widgets/custom_button.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
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
    return FutureBuilder(
        future: getCurrentUserDatas(currentUser!),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
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
              body: Padding(
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
                                style: AppStyles.titleStyle
                                    .copyWith(color: AppColors.mainDarkGray),
                              ),
                              Text(
                                account.email,
                                overflow: TextOverflow.visible,
                                style: AppStyles.hintComponentStyle
                                    .copyWith(color: AppColors.mainDarkGray),
                              ),
                              Text(
                                account.phoneNumber,
                                style: AppStyles.hintComponentStyle
                                    .copyWith(color: AppColors.mainDarkGray),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 100,
                        alignment: Alignment.topRight,
                        child: IconButton(
                            onPressed: () => Navigator.pushReplacement(
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
                  const SizedBox(height: AppSizes.bigDistance),
                  CustomButton(
                      buttonColor: AppColors.mainBlue,
                      buttonText: AppStrings.logout,
                      // SIGN OUT
                      onTap: () async {
                        await FirebaseAuth.instance.signOut().then((value) =>
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                                (route) => false));
                      }),
                  const SizedBox(height: AppSizes.mediumDistance),
                  const Divider(
                    color: AppColors.mediumGray,
                    thickness: 0.6,
                  ),
                  ListTile(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const DefaultEmergencyGroupScreen())),
                    title: Text(
                      AppStrings.changeEmergencyGroup,
                      style:
                          AppStyles.textComponentStyle.copyWith(fontSize: 15),
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
                      style:
                          AppStyles.textComponentStyle.copyWith(fontSize: 15),
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
                            builder: (context) =>
                                const DefaultTrackingSmsScreen())),
                    title: Text(
                      AppStrings.changeTrackingSMS,
                      style:
                          AppStyles.textComponentStyle.copyWith(fontSize: 15),
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
                ]),
              ),
            );
          } else {
            return Container();
          }
        });
  }
}
