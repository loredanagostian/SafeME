import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/models/history_event.dart';

class FirebaseManager {
  static Future<Account> fetchUserInfoAndReturnAccount(String userID) async {
    var friendFuture = await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .get()
        .then((snapshot) => snapshot.data());

    Account friendAccount;
    friendAccount = Account.fromJson(friendFuture!);

    return friendAccount;
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>>
      fetchCurrentUser() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
  }

  static Future<void> uploadNewUserData(Map<String, dynamic> userDatas) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set(userDatas);
  }

  static Future<void> addEmergencyContact(String friendID) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      "emergencyContacts": FieldValue.arrayUnion([friendID]),
    });
  }

  static Future<void> addEmergencyContactForFriend(String friendID) async {
    FirebaseFirestore.instance.collection('users').doc(friendID).update({
      "emergencyContacts":
          FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
    });
  }

  static Future<void> removeEmergencyContact(String friendID) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      "emergencyContacts": FieldValue.arrayRemove([friendID])
    });
  }

  static Future<void> changeUserInformation(
      String firstName, String lastName, String profileURL) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      "firstName": firstName,
      "lastName": lastName,
      "imageURL": profileURL
    });
  }

  static Future<void> changeTrackingSMS(String message) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({"trackingSMS": message});
  }

  static Future<void> changeEmergencySMS(String message) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({"emergencySMS": message});
  }

  static Future<void> updateUserLocation(double? lat, double? long) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      "userLastLatitude": lat,
      "userLastLongitude": long,
    });
  }

  static Future<void> setUserLocation(double? lat, double? long) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      "userLastLatitude": lat,
      "userLastLongitude": long,
    });
  }

  static Future<void> changeTrackMeNow(bool value) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      "trackMeNow": value,
    });
  }

  static Future<void> acceptFriendRequest(String friendID) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      "friendRequests": FieldValue.arrayRemove([friendID]),
      "friends": FieldValue.arrayUnion([friendID]),
    });

    FirebaseFirestore.instance.collection('users').doc(friendID).update({
      "friends":
          FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
    });
  }

  static Future<void> declineFriendRequest(String friendID) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      "friendRequests": FieldValue.arrayRemove([friendID])
    });
  }

  static Future<void> sendFriendRequest(String friendID) async {
    await FirebaseFirestore.instance.collection('users').doc(friendID).update({
      "friendRequests":
          FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
    });
  }

  static Future<void> removeFriend(String friendID) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      "friends": FieldValue.arrayRemove([friendID]),
      "emergencyContacts": FieldValue.arrayRemove([friendID]),
    });

    await FirebaseFirestore.instance.collection('users').doc(friendID).update({
      "friends":
          FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
      "emergencyContacts":
          FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
    });
  }

  static Future<List<Account>> fetchFriendRequestsAndReturnAccounts(
      List<String> friendRequestsIds) async {
    var friendRequestsFutures = friendRequestsIds.map((requestId) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(requestId)
          .get()
          .then((snapshot) => snapshot.data());
    }).toList();

    var friendRequestsData = await Future.wait(friendRequestsFutures);
    List<Account> friendRequests = [];

    for (var data in friendRequestsData) {
      if (data != null) {
        friendRequests.add(Account.fromJson(data));
      }
    }

    return friendRequests;
  }

  static Future<List<Account>> fetchFriendsAndReturnAccounts(
      bool isAllFriends, bool isTrackNow, List<String> friendsIds) async {
    var friendsFutures = friendsIds.map((friendId) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .get()
          .then((snapshot) => snapshot.data());
    }).toList();

    var friendsData = await Future.wait(friendsFutures);
    List<Account> friendsList = [];

    for (var data in friendsData) {
      if (data != null) {
        final friend = Account.fromJson(data);

        if (isAllFriends || (isTrackNow && friend.trackMeNow)) {
          friendsList.add(friend);
        }
      }
    }

    return friendsList;
  }

  static Future<void> addNewHistoryElement(HistoryEvent historyEvent) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      "history": FieldValue.arrayUnion([historyEvent.toMap()]),
    });
  }

  static Future<void> updateNotificationsList(
      List<Map<String, dynamic>> notifications) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({'notifications': notifications});
  }
}
