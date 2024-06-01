import 'package:safe_me/models/history_event.dart';
import 'package:safe_me/models/notification_model.dart';

class UserStaticData {
  final String userId;
  final String email;
  final String phoneNumber;
  final String deviceToken;
  String firstName;
  String lastName;
  String imageURL;
  String emergencySMS;
  String trackingSMS;
  List<String> friends;
  List<String> friendsRequest;
  List<String> emergencyContacts;
  List<HistoryEvent> history;
  List<NotificationModel> notifications;

  UserStaticData(
      {required this.userId,
      required this.email,
      required this.phoneNumber,
      required this.deviceToken,
      required this.firstName,
      required this.lastName,
      required this.imageURL,
      required this.emergencySMS,
      required this.trackingSMS,
      required this.friends,
      required this.friendsRequest,
      required this.emergencyContacts,
      required this.history,
      required this.notifications});
}
