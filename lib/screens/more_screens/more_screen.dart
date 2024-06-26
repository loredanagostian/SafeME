import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/paths.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/managers/user_info_provider.dart';
import 'package:safe_me/models/user_static_data.dart';
import 'package:safe_me/screens/more_screens/default_emergency_contacts_screen.dart';
import 'package:safe_me/screens/more_screens/default_emergency_sms_screen.dart';
import 'package:safe_me/screens/more_screens/default_tracking_sms_screen.dart';
import 'package:safe_me/screens/more_screens/edit_profile_screen.dart';
import 'package:safe_me/screens/more_screens/history_screen.dart';
import 'package:safe_me/screens/onboarding_screens/login_screen.dart';
import 'package:safe_me/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> {
  User? currentUser;
  late UserStaticData account;
  bool shouldRefresh = false;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    account = ref.watch(userStaticDataProvider);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: const Text(
            AppStrings.moreTitle,
            style: AppStyles.titleStyle,
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context, shouldRefresh),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.mainDarkGray,
            ),
          ),
        ),
        body: SingleChildScrollView(
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
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    constraints:
                        const BoxConstraints(maxWidth: 175, maxHeight: 150),
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
                      onPressed: () async {
                        shouldRefresh = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditProfileScreen()));
                        if (shouldRefresh) setState(() {});
                      },
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
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HistoryScreen())),
              title: Text(
                AppStrings.history,
                style: AppStyles.textComponentStyle.copyWith(fontSize: 15),
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
                      builder: (context) => DefaultEmergencyContactsScreen())),
              title: Text(
                AppStrings.changeDefaultEmergencyContacts,
                style: AppStyles.textComponentStyle.copyWith(fontSize: 15),
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
                      builder: (context) => DefaultEmergencySmsScreen())),
              title: Text(
                AppStrings.changeEmergencySMS,
                style: AppStyles.textComponentStyle.copyWith(fontSize: 15),
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
                      builder: (context) => DefaultTrackingSmsScreen())),
              title: Text(
                AppStrings.changeTrackingSMS,
                style: AppStyles.textComponentStyle.copyWith(fontSize: 15),
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
                  await FirebaseAuth.instance.signOut().then((value) =>
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                          (route) => false));
                }),
          ]),
        ));
  }
}
