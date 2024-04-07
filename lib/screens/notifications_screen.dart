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
  final Account userAccount;

  const NotificationsScreen({Key? key, required this.userAccount})
      : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
  }

  void markNotificationAsRead(NotificationModel notification) {
    List<NotificationModel> userNotifications =
        widget.userAccount.notifications;

    userNotifications.removeWhere((element) => element.id == notification.id);

    List<Map<String, dynamic>> arrayData = [];

    for (int i = 0; i < userNotifications.length; i++) {
      arrayData.add({
        'id': userNotifications[i].id,
        'body': userNotifications[i].body,
        'opened': userNotifications[i].opened,
        'senderEmail': userNotifications[i].senderEmail,
      });
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userAccount.userId)
        .update({'notifications': arrayData});

    setState(() {});
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
      body: FutureBuilder(
        future: _userDataFuture,
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
                  itemCount: userAccount.notifications.length,
                  itemBuilder: (context, index) {
                    final item = userAccount.notifications[index];

                    return GestureDetector(
                      onTap: () {
                        if (item.opened == false) markNotificationAsRead(item);
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
