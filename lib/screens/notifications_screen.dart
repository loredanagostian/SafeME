import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/models/notification_model.dart';
import 'package:safe_me/widgets/custom_notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
  }

  void markNotificationAsRead(NotificationModel notification,
      List<NotificationModel> userNotifications) {
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

    // Update Firestore with the entire notifications list
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({'notifications': arrayData});
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
    Stream<DocumentSnapshot<Map<String, dynamic>>> stream = FirebaseFirestore
        .instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

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
      body: StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!.data()!;
          Account userAccount = Account.fromJson(data);

          return Padding(
            padding: const EdgeInsets.all(AppSizes.smallDistance),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${userAccount.notifications.length} notifications",
                      style: AppStyles.textComponentStyle,
                    ),
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: IconButton(
                        onPressed: () => markAllNotificationsAsRead(
                            userAccount.notifications),
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
                  itemCount: userAccount.notifications.length,
                  itemBuilder: (context, index) {
                    final item = userAccount.notifications[index];

                    return GestureDetector(
                      onTap: () {
                        if (item.opened == false)
                          markNotificationAsRead(
                              item, userAccount.notifications);
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
          );
        },
      ),
    );
  }
}
