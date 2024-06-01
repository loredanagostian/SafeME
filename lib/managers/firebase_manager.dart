import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_me/models/account.dart';

class FirebaseManager {
  static Future<Account> fetchUserInfo(String userID) async {
    var friendFuture = await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .get()
        .then((snapshot) => snapshot.data());

    Account friendAccount;
    friendAccount = Account.fromJson(friendFuture!);

    return friendAccount;
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

  static Future<void> addEmergencyContact(String friendID) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      "emergencyContacts": FieldValue.arrayUnion([friendID]),
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
}
