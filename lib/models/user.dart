class User {
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String imageURL;

  User({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.imageURL,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        email: json['email'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        phoneNumber: json['phoneNumber'],
        imageURL: json['imageURL']);
  }
}
