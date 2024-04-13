import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:safe_me/constants/strings.dart';

final locationSubscription =
    StateProvider<StreamSubscription<loc.LocationData>?>((ref) => null);

class LocationManager {
  static Future<LocationPermission> getLocationPermission() async {
    var isPermission = await Geolocator.checkPermission();
    if (isPermission == LocationPermission.denied ||
        isPermission == LocationPermission.deniedForever) {
      isPermission = await Geolocator.requestPermission();
    }

    return isPermission;
  }

  static Future<bool> isLocationEnabled() async {
    bool isEnabled = await Permission.locationWhenInUse.serviceStatus.isEnabled;

    return isEnabled;
  }

  static Future<void> _storeLocationInDB(WidgetRef ref) async {
    try {
      var isPermission = await getLocationPermission();

      if (isPermission == LocationPermission.denied ||
          isPermission == LocationPermission.deniedForever) {
        throw Exception(AppStrings.locationPermissionDenied);
      }

      if (isPermission == LocationPermission.always ||
          isPermission == LocationPermission.whileInUse) {
        Location location = Location();
        location.changeSettings(accuracy: loc.LocationAccuracy.high);

        ref.read(locationSubscription.notifier).update((state) => location
                .onLocationChanged
                .listen((LocationData currentLocation) async {
              if (currentLocation.latitude != null &&
                  currentLocation.longitude != null) {
                // Fetch the last stored location from Firestore
                var userDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .get();

                if (userDoc.exists) {
                  var userLastLatitude =
                      userDoc.data()!['userLastLatitude'] as double?;
                  var userLastLongitude =
                      userDoc.data()!['userLastLongitude'] as double?;

                  // Calculate the distance between the new location and the last stored location
                  final double distance = Geolocator.distanceBetween(
                    userLastLatitude ?? 0,
                    userLastLongitude ?? 0,
                    currentLocation.latitude!,
                    currentLocation.longitude!,
                  );

                  // If the distance is more than 5 meters, update the location in Firestore
                  if (distance > 5) {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .update({
                      "userLastLatitude": currentLocation.latitude,
                      "userLastLongitude": currentLocation.longitude,
                    });
                  }
                } else {
                  // If there is no last location stored, just update with the new location
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .set({
                    "userLastLatitude": currentLocation.latitude,
                    "userLastLongitude": currentLocation.longitude,
                  });
                }
              }
            }));
      } else {
        throw Exception(AppStrings.locationPermissionDenied);
      }
    } on TimeoutException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> enableLocationSharing(WidgetRef ref) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      "trackMeNow": true,
    });

    _storeLocationInDB(ref);
  }

  static Future<void> disableLocationSharing(WidgetRef ref) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      "trackMeNow": false,
    });

    // Cancel the subscription to location updates
    ref.read(locationSubscription)?.cancel();
  }
}
