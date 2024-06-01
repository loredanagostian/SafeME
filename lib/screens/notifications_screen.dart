import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/managers/firebase_manager.dart';
import 'package:safe_me/managers/user_info_provider.dart';
import 'package:safe_me/models/notification_model.dart';
import 'package:safe_me/models/user_static_data.dart';
import 'package:safe_me/widgets/custom_notification_tile.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  late UserStaticData _userStaticData;
  bool shouldRefresh = false;

  @override
  void initState() {
    super.initState();
    _userStaticData = ref.read(userStaticDataProvider);
  }

  Future<void> markNotificationAsRead(NotificationModel notification,
      List<NotificationModel> userNotifications) async {
    // Remove the notification from the list
    var item = userNotifications.firstWhere(
      (x) =>
          x.id == notification.id &&
          x.body == notification.body &&
          x.opened == notification.opened &&
          x.senderEmail == notification.senderEmail,
    );

    userNotifications.remove(item);

    // Prepare updated notifications list
    List<Map<String, dynamic>> arrayData = [];
    for (int i = 0; i < userNotifications.length; i++) {
      arrayData.add({
        'id': userNotifications[i].id,
        'body': userNotifications[i].body,
        'opened': userNotifications[i].opened,
        'senderEmail': userNotifications[i].senderEmail,
      });
    }

    // Add the tapped notification with opened state changed
    arrayData.add({
      'id': notification.id,
      'body': notification.body,
      'opened': true,
      'senderEmail': notification.senderEmail,
    });

    // Update local data
    _userStaticData.notifications.remove(item);
    _userStaticData.notifications.add(NotificationModel(
        id: notification.id,
        body: notification.body,
        opened: true,
        senderEmail: notification.senderEmail));
    ref.read(userStaticDataProvider.notifier).updateUserInfo(_userStaticData);

    // Update Firestore with the entire notifications list
    await FirebaseManager.updateNotificationsList(arrayData)
        .then((value) => setState(() {
              shouldRefresh = true;
            }));
  }

  void markAllNotificationsAsRead(List<NotificationModel> userNotifications) {
    for (NotificationModel notification in userNotifications) {
      if (!notification.opened) {
        markNotificationAsRead(notification, userNotifications);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _userStaticData = ref.watch(userStaticDataProvider);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: const Text(
            AppStrings.notificationsTitle,
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
                    "${_userStaticData.notifications.length} notifications",
                    style: AppStyles.textComponentStyle,
                  ),
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: IconButton(
                      onPressed: () => markAllNotificationsAsRead(
                          _userStaticData.notifications),
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
                itemCount: _userStaticData.notifications.length,
                itemBuilder: (context, index) {
                  final item = _userStaticData.notifications[index];

                  return GestureDetector(
                    onTap: () {
                      if (item.opened == false)
                        markNotificationAsRead(
                            item, _userStaticData.notifications);
                    },
                    child: CustomNotificationTile(
                      notificationTitle: item.body,
                      notificationBody: item.senderEmail,
                      opened: item.opened,
                    ),
                  );
                },
                shrinkWrap: true,
              ),
            ],
          ),
        ));
  }
}
