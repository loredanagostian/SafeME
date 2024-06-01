import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_me/models/user_static_data.dart';

class UserStaticProvider extends StateNotifier<UserStaticData> {
  UserStaticProvider()
      : super(UserStaticData(
            email: "",
            firstName: "",
            lastName: "",
            phoneNumber: "",
            emergencySMS: "",
            trackingSMS: "",
            friends: [],
            friendsRequest: [],
            userId: "",
            emergencyContacts: [],
            deviceToken: "",
            history: [],
            notifications: []));

  void updateUserInfo(UserStaticData user) {
    state = user;
  }
}

final userStaticDataProvider =
    StateNotifierProvider<UserStaticProvider, UserStaticData>((ref) {
  return UserStaticProvider();
});
