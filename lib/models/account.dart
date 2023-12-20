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

  Account({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.imageURL,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
        email: json['email'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        phoneNumber: json['phoneNumber'],
        imageURL: json['imageURL']);
  }
}
