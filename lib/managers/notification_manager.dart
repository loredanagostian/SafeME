import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Got a message whilst in the background!');
  if (message.notification != null) {
    print('Notification Title: ${message.notification!.title}');
    print('Notification Body: ${message.notification!.body}');
  }
}

class NotificationManager {
  static String token = "";

  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
  }

  static Future<void> getToken() async {
    token = await _firebaseMessaging.getToken() ?? "";
  }

  static Future<void> sendNotification(
      {required String token,
      required String body,
      required String friendId}) async {
    try {
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                'key=AAAAHrUrYok:APA91bFF3ly4aduF-2x2dw7gh18AD7Cy3k5vF7AhoT3T88uTVvN3CIiJ0Xq9VHA3A3QmJj1XzFpEJ1b4ldu_k2_X4ceRFQMsoo8MQ-4VCz-aTRPPZFPP4kq6pRwow_3cbJoO68ojPIBz',
          },
          body: jsonEncode({
            'priority': 'high',
            'data': {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'title': body,
            },
            "notification": {
              "title": body,
              "android_channel_id": "com.example.safe_me",
            },
            "to": token,
          }));
      addNotificationToFirebase(body, friendId);
    } catch (e) {
      print(e);
    }

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  static void addNotificationToFirebase(String body, String friendId) {
    var map = <String, dynamic>{};
    map["id"] = DateTime.now().microsecondsSinceEpoch.toString();
    map["body"] = body;
    map["opened"] = false;
    map["senderEmail"] = FirebaseAuth.instance.currentUser!.email;

    FirebaseFirestore.instance.collection('users').doc(friendId).update(
      {
        "notifications": FieldValue.arrayUnion([map])
      },
    );
  }
}
