import 'package:safe_me/models/history_event.dart';
import 'package:safe_me/models/notification_model.dart';
// part 'account.g.dart';

class Account {
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String imageURL;
  final String emergencySMS;
  final String trackingSMS;
  final List<String> friends;
  final bool trackMeNow;
  final List<String> friendsRequest;
  final String userId;
  final double lastLatitude;
  final double lastLongitude;
  final List<String> emergencyContacts;
  final String deviceToken;
  final List<NotificationModel> notifications;
  final List<HistoryEvent> history;

  Account({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.imageURL,
    required this.emergencySMS,
    required this.trackingSMS,
    required this.friends,
    required this.trackMeNow,
    required this.friendsRequest,
    required this.userId,
    required this.lastLatitude,
    required this.lastLongitude,
    required this.emergencyContacts,
    required this.deviceToken,
    required this.notifications,
    required this.history,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    List<dynamic> emergencyContacts = json['emergencyContacts'];
    List<String> emergencyContactsIds =
        emergencyContacts.map((contact) => contact.toString()).toList();

    List<dynamic> friends = json['friends'];
    List<String> friendsListIds =
        friends.map((friend) => friend.toString()).toList();

    List<dynamic> friendsRequest = json['friendRequests'];
    List<String> friendsRequestIds =
        friendsRequest.map((request) => request.toString()).toList();

    List<dynamic> notificationsJson = json['notifications'];
    List<NotificationModel> notifications =
        notificationsJson.map((notification) {
      return NotificationModel(
        body: notification['body'],
        opened: notification['opened'],
        id: notification['id'],
        senderEmail: notification['senderEmail'],
      );
    }).toList();

    List<dynamic> historyJson = json['history'];
    List<HistoryEvent> history = historyJson.map((event) {
      return HistoryEvent(
        startDate: event['startDate'].toDate(),
        isTrackingEvent: event['isTrackingEvent'],
        city: event['city'],
        country: event['country'],
      );
    }).toList();

    return Account(
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      imageURL: json['imageURL'],
      emergencySMS: json['emergencySMS'],
      trackingSMS: json['trackingSMS'],
      friends: friendsListIds,
      trackMeNow: json['trackMeNow'],
      friendsRequest: friendsRequestIds,
      userId: json['userId'],
      lastLatitude: json['userLastLatitude'],
      lastLongitude: json['userLastLongitude'],
      emergencyContacts: emergencyContactsIds,
      deviceToken: json['deviceToken'],
      notifications: notifications,
      history: history,
    );
  }
}
