import 'package:safe_me/models/history_event.dart';

class UserStaticData {
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String imageURL;
  final String emergencySMS;
  final String trackingSMS;
  final List<String> friends;
  final List<String> friendsRequest;
  final String userId;
  final List<String> emergencyContacts;
  final String deviceToken;
  final List<HistoryEvent> history;

  UserStaticData({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.imageURL,
    required this.emergencySMS,
    required this.trackingSMS,
    required this.friends,
    required this.friendsRequest,
    required this.userId,
    required this.emergencyContacts,
    required this.deviceToken,
    required this.history,
  });
}
