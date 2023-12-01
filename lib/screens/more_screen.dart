import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/screens/edit_profile_screen.dart';
import 'package:safe_me/widgets/custom_button.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.only(right: AppSizes.smallDistance),
                  child: Container(
                      decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(
                        'lib/assets/images/eu.jpg',
                      ),
                      fit: BoxFit.cover,
                    ),
                  )),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  constraints:
                      const BoxConstraints(maxWidth: 175, maxHeight: 110),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ana Blandiana",
                        style: AppStyles.titleStyle
                            .copyWith(color: AppColors.mainDarkGray),
                      ),
                      Text(
                        "ana.blandiana@gmail.com",
                        style: AppStyles.hintComponentStyle
                            .copyWith(color: AppColors.mainDarkGray),
                      ),
                      Text(
                        "0712 123 123",
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
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditProfileScreen())),
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
              onTap: () {}),
          const SizedBox(height: AppSizes.mediumDistance),
          const Divider(
            color: AppColors.mediumGray,
            thickness: 0.6,
          ),
          ListTile(
            title: Text(
              AppStrings.changeEmergencyGroup,
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
  }
}
