import 'package:hive/hive.dart';
part 'account.g.dart';

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

  Account(
      {required this.email,
      required this.firstName,
      required this.lastName,
      required this.phoneNumber,
      required this.imageURL,
      required this.emergencyGroup,
      required this.emergencySMS,
      required this.trackingSMS,
      required this.friends,
      required this.trackMeNow});

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
    );
  }
}
