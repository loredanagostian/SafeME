import 'dart:io';

import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/screens/more_screen.dart';
import 'package:safe_me/screens/notifications_screen.dart';
import 'package:safe_me/widgets/emergency_member.dart';
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
                  onLongPress: () async {
                    if (!wasLongPressed) {
                      String message = widget.userAccount.emergencySMS;
                      String encodedMessage = Uri.encodeFull(message);
                      final call =
                          Uri.parse('sms:0733156102?body=$encodedMessage');
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
              const SizedBox(height: AppSizes.bigDistance),
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
        )));
  }
}
