import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';

class DefaultEmergencyGroupScreen extends StatelessWidget {
  const DefaultEmergencyGroupScreen({super.key});

  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.60,
            decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppSizes.borders),
                    topRight: Radius.circular(AppSizes.borders))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSizes.mediumDistance),
                  child: Text(
                    AppStrings.allFriends,
                    style: AppStyles.titleStyle
                        .copyWith(color: AppColors.mainDarkGray),
                  ),
                ),
                // person 1
                ListTile(
                  title: Text("Brad Pitt"),
                  titleTextStyle: AppStyles.notificationTitleStyle
                      .copyWith(color: AppColors.mainDarkGray),
                  subtitle: Text("0712 123 123"),
                  subtitleTextStyle: AppStyles.hintComponentStyle,
                  leading: SizedBox(
                    height: 60,
                    width: 60,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(right: AppSizes.smallDistance),
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
                ),
                // person 2
                ListTile(
                  title: Text("Brad Pitt"),
                  titleTextStyle: AppStyles.notificationTitleStyle
                      .copyWith(color: AppColors.mainDarkGray),
                  subtitle: Text("0712 123 123"),
                  subtitleTextStyle: AppStyles.hintComponentStyle,
                  leading: SizedBox(
                    height: 60,
                    width: 60,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(right: AppSizes.smallDistance),
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
                ),
                // person 3
                ListTile(
                  title: Text("Brad Pitt"),
                  titleTextStyle: AppStyles.notificationTitleStyle
                      .copyWith(color: AppColors.mainDarkGray),
                  subtitle: Text("0712 123 123"),
                  subtitleTextStyle: AppStyles.hintComponentStyle,
                  leading: SizedBox(
                    height: 60,
                    width: 60,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(right: AppSizes.smallDistance),
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
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          AppStrings.emergencyGroup,
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
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "3 friends",
                    style: AppStyles.textComponentStyle
                        .copyWith(color: AppColors.mainBlue),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: SizedBox(
                      height: 35,
                      width: 35,
                      child: IconButton(
                        onPressed: () => _showModalBottomSheet(context),
                        icon: const Icon(
                          Icons.person_add_outlined,
                          color: AppColors.mainDarkGray,
                          size: 30,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const Divider(
                color: AppColors.mainDarkGray,
                thickness: 1,
              ),
              // person 1
              ListTile(
                title: Text("Brad Pitt"),
                titleTextStyle: AppStyles.notificationTitleStyle
                    .copyWith(color: AppColors.mainDarkGray),
                subtitle: Text("0712 123 123"),
                subtitleTextStyle: AppStyles.hintComponentStyle,
                leading: SizedBox(
                  height: 60,
                  width: 60,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(right: AppSizes.smallDistance),
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
              ),
              // person 2
              ListTile(
                title: Text("Brad Pitt"),
                titleTextStyle: AppStyles.notificationTitleStyle
                    .copyWith(color: AppColors.mainDarkGray),
                subtitle: Text("0712 123 123"),
                subtitleTextStyle: AppStyles.hintComponentStyle,
                leading: SizedBox(
                  height: 60,
                  width: 60,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(right: AppSizes.smallDistance),
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
              ),
              // person 3
              ListTile(
                title: Text("Brad Pitt"),
                titleTextStyle: AppStyles.notificationTitleStyle
                    .copyWith(color: AppColors.mainDarkGray),
                subtitle: Text("0712 123 123"),
                subtitleTextStyle: AppStyles.hintComponentStyle,
                leading: SizedBox(
                  height: 60,
                  width: 60,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(right: AppSizes.smallDistance),
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
              ),
            ]),
      ),
    );
  }
}
