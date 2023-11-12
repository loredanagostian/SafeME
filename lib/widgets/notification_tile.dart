import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/styles.dart';

class NotificationTile extends StatelessWidget {
  final bool isRead;
  final String notificationTitle;
  final String notificationBody;
  const NotificationTile(
      {super.key,
      this.isRead = false,
      required this.notificationTitle,
      required this.notificationBody});

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            isRead ? Icons.mail_outlined : Icons.mark_email_unread_outlined,
            size: 33,
            color: isRead ? AppColors.mainDarkGray : AppColors.mainBlue,
          ),
          const SizedBox(width: AppSizes.smallDistance),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notificationTitle,
                style: isRead
                    ? AppStyles.notificationTitleStyle
                        .copyWith(color: AppColors.mainDarkGray)
                    : AppStyles.notificationTitleStyle,
              ),
              Text(
                notificationBody,
                style: isRead
                    ? AppStyles.notificationBodyStyle
                        .copyWith(color: AppColors.mainDarkGray)
                    : AppStyles.notificationBodyStyle,
              ),
            ],
          )
        ]);
  }
}
