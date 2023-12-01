import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/widgets/custom_notification_tile.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          AppStrings.notificationsTitle,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "2 notifications unread",
                    style: AppStyles.textComponentStyle,
                  ),
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.done_all,
                        color: AppColors.mainDarkGray,
                      ),
                    ),
                  )
                ],
              ),
              const Divider(
                color: AppColors.mainDarkGray,
                thickness: 1,
              ),
              const CustomNotificationTile(
                notificationTitle: 'Notification title',
                notificationBody: 'Notification description',
              ),
              const CustomNotificationTile(
                notificationTitle: 'Notification title',
                notificationBody: 'Notification description',
                isRead: true,
              ),
            ]),
      ),
    );
  }
}
