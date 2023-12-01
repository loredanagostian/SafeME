import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/styles.dart';

class CustomNotificationTile extends StatefulWidget {
  final bool isRead;
  final String notificationTitle;
  final String notificationBody;
  const CustomNotificationTile(
      {super.key,
      this.isRead = false,
      required this.notificationTitle,
      required this.notificationBody});

  @override
  State<CustomNotificationTile> createState() => _CustomNotificationTileState();
}

class _CustomNotificationTileState extends State<CustomNotificationTile> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.notificationTitle),
      onDismissed: (direction) {
        // Remove the item from the data source.
        setState(() {});
      },
      background: Container(color: AppColors.mainRed),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.smallDistance),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                widget.isRead
                    ? Icons.mail_outlined
                    : Icons.mark_email_unread_outlined,
                size: 33,
                color:
                    widget.isRead ? AppColors.mainDarkGray : AppColors.mainBlue,
              ),
              const SizedBox(width: AppSizes.smallDistance),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.notificationTitle,
                    style: widget.isRead
                        ? AppStyles.notificationTitleStyle
                            .copyWith(color: AppColors.mainDarkGray)
                        : AppStyles.notificationTitleStyle,
                  ),
                  Text(
                    widget.notificationBody,
                    style: widget.isRead
                        ? AppStyles.notificationBodyStyle
                            .copyWith(color: AppColors.mainDarkGray)
                        : AppStyles.notificationBodyStyle,
                  ),
                ],
              )
            ]),
      ),
    );
  }
}
