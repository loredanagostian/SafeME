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
  final List<dynamic> emergencyGroup;

  @HiveField(7)
  final String trackingSMS;

  Account({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.imageURL,
    required this.emergencyGroup,
    required this.emergencySMS,
    required this.trackingSMS,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      imageURL: json['imageURL'],
      emergencyGroup: json['emergencyGroup'],
      emergencySMS: json['emergencySMS'],
      trackingSMS: json['trackingSMS'],
    );
  }
}
