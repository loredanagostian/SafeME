import 'package:hive/hive.dart';
import 'package:safe_me/models/history_event.dart';
import 'package:safe_me/models/notification_model.dart';
// part 'account.g.dart';

@HiveType(typeId: 0)
class Account extends HiveObject {
  @HiveField(0)
  final String email;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  @HiveField(3)
  final String phoneNumber;

  @HiveField(4)
  final String imageURL;

  @HiveField(5)
  final String emergencySMS;

  @HiveField(6)
  final List<String> emergencyGroup;

  @HiveField(7)
  final String trackingSMS;

  @HiveField(8)
  final List<String> friends;

  @HiveField(9)
  final bool trackMeNow;

  @HiveField(10)
  final List<String> friendsRequest;

  @HiveField(11)
  final String userId;

  @HiveField(12)
  final double lastLatitude;

  @HiveField(13)
  final double lastLongitude;

  @HiveField(14)
  final String emergencyContact;

  @HiveField(15)
  final String deviceToken;

  @HiveField(16)
  final List<NotificationModel> notifications;

  @HiveField(17)
  final List<HistoryEvent> history;

  Account({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.imageURL,
    required this.emergencyGroup,
    required this.emergencySMS,
    required this.trackingSMS,
    required this.friends,
    required this.trackMeNow,
    required this.friendsRequest,
    required this.userId,
    required this.lastLatitude,
    required this.lastLongitude,
    required this.emergencyContact,
    required this.deviceToken,
    required this.notifications,
    required this.history,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    List<dynamic> emergencyGroup = json['emergencyGroup'];
    List<String> emergencyGroupIds = [];
    for (int i = 0; i < emergencyGroup.length; i++) {
      emergencyGroupIds.add(emergencyGroup[i].toString());
    }

    List<dynamic> friends = json['friends'];
    List<String> friendsListIds = [];
    for (int i = 0; i < friends.length; i++) {
      friendsListIds.add(friends[i].toString());
    }

    List<dynamic> friendsRequest = json['friendRequests'];
    List<String> friendsRequestIds = [];
    for (int i = 0; i < friendsRequest.length; i++) {
      friendsRequestIds.add(friendsRequest[i].toString());
    }

    List<dynamic> notificationsJson = json['notifications'];
    List<NotificationModel> notifications = [];
    for (int i = 0; i < notificationsJson.length; i++) {
      NotificationModel item = NotificationModel(
        body: notificationsJson[i]['body'],
        opened: notificationsJson[i]['opened'],
        id: notificationsJson[i]['id'],
        senderEmail: notificationsJson[i]['senderEmail'],
      );
      notifications.add(item);
    }

    List<dynamic> historyJson = json['history'];
    List<HistoryEvent> history = [];
    for (int i = 0; i < historyJson.length; i++) {
      HistoryEvent item = HistoryEvent(
          startDate: historyJson[i]['startDate'].toDate(),
          // endDate: historyJson[i]['endDate'].toDate(),
          // duration: historyJson[i]['duration'],
          isTrackingEvent: historyJson[i]['isTrackingEvent']);

      history.add(item);
    }

    return Account(
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      imageURL: json['imageURL'],
      emergencyGroup: emergencyGroupIds,
      emergencySMS: json['emergencySMS'],
      trackingSMS: json['trackingSMS'],
      friends: friendsListIds,
      trackMeNow: json['trackMeNow'],
      friendsRequest: friendsRequestIds,
      userId: json['userId'],
      lastLatitude: json['userLastLatitude'],
      lastLongitude: json['userLastLongitude'],
      emergencyContact: json['emergencyContact'],
      deviceToken: json['deviceToken'],
      notifications: notifications,
      history: history,
    );
  }
}
