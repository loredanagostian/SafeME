import 'package:safe_me/models/notification_model.dart';

class UserDynamicData {
  final bool trackMeNow;
  final double lastLatitude;
  final double lastLongitude;
  final List<NotificationModel> notifications;

  UserDynamicData({
    required this.trackMeNow,
    required this.lastLatitude,
    required this.lastLongitude,
    required this.notifications,
  });
}
