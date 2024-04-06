import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/styles.dart';

class CustomNotificationTile extends StatefulWidget {
  final bool opened;
  final String notificationTitle;
  final String notificationBody;
  const CustomNotificationTile({
    super.key,
    required this.notificationTitle,
    required this.notificationBody,
    required this.opened,
  });

  @override
  State<CustomNotificationTile> createState() => _CustomNotificationTileState();
}

class _CustomNotificationTileState extends State<CustomNotificationTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.smallDistance),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              widget.opened
                  ? Icons.mail_outlined
                  : Icons.mark_email_unread_outlined,
              size: 33,
              color:
                  widget.opened ? AppColors.mainDarkGray : AppColors.mainBlue,
            ),
            const SizedBox(width: AppSizes.smallDistance),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.notificationTitle,
                  style: widget.opened
                      ? AppStyles.notificationTitleStyle
                          .copyWith(color: AppColors.mainDarkGray)
                      : AppStyles.notificationTitleStyle,
                ),
                Text(
                  widget.notificationBody,
                  style: widget.opened
                      ? AppStyles.notificationBodyStyle
                          .copyWith(color: AppColors.mainDarkGray)
                      : AppStyles.notificationBodyStyle,
                ),
              ],
            )
          ]),
    );
  }
}
