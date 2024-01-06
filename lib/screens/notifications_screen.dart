import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/models/notification_model.dart';
import 'package:safe_me/widgets/custom_notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  final Account userAccount;

  const NotificationsScreen({super.key, required this.userAccount});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  void markNotificationAsRead(NotificationModel notification) {
    List<NotificationModel> userNotifications =
        widget.userAccount.notifications;

    userNotifications.removeWhere((element) => element.id == notification.id);

    List<Map<String, dynamic>> arrayData = [];

    for (int i = 0; i < userNotifications.length; i++) {
      arrayData.add({
        'id': userNotifications[i].id,
        'title': userNotifications[i].title,
        'body': userNotifications[i].body,
        'opened': userNotifications[i].opened
      });
    }
    Map<String, dynamic> updatedData = {
      'id': notification.id,
      'title': notification.title,
      'body': notification.body,
      'opened': true,
    };

    arrayData.add(updatedData);

    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userAccount.userId)
        .update({'notifications': arrayData});
  }

  void markAllNotificationsAsRead() {
    List<NotificationModel> userNotifications =
        widget.userAccount.notifications;
    for (NotificationModel notification in userNotifications) {
      if (!notification.opened) {
        markNotificationAsRead(notification);
      }
    }
  }

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
                      Text(
                        "${widget.userAccount.notifications.length} notifications unread",
                        style: AppStyles.textComponentStyle,
                      ),
                      SizedBox(
                        height: 30,
                        width: 30,
                        child: IconButton(
                          onPressed: () => markAllNotificationsAsRead(),
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
                  ListView.builder(
                    itemCount: widget.userAccount.notifications.length,
                    itemBuilder: (context, index) {
                      final item = widget.userAccount.notifications[index];

                      return GestureDetector(
                        onTap: () => markNotificationAsRead(item),
                        child: CustomNotificationTile(
                          notificationTitle: item.title,
                          notificationBody: item.body,
                          opened: item.opened,
                        ),
                      );
                    },
                    shrinkWrap: true,
                  )
                ])));
  }
}
