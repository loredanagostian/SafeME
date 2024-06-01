import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_me/models/user_dynamic_data.dart';
import 'package:safe_me/models/user_static_data.dart';

class UserStaticProvider extends StateNotifier<UserStaticData> {
  UserStaticProvider()
      : super(UserStaticData(
            email: "",
            firstName: "",
            lastName: "",
            phoneNumber: "",
            imageURL: "",
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

class UserDynamicProvider extends StateNotifier<UserDynamicData> {
  UserDynamicProvider()
      : super(UserDynamicData(
            trackMeNow: false, lastLatitude: 0, lastLongitude: 0));

  void updateUserInfo(UserDynamicData user) {
    state = user;
  }
}

final userDynamicDataProvider =
    StateNotifierProvider<UserDynamicProvider, UserDynamicData>((ref) {
  return UserDynamicProvider();
});
