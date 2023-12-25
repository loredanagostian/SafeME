import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/screens/more_screen.dart';

class SafePlacesScreen extends StatefulWidget {
  final Account userAccount;

  const SafePlacesScreen({super.key, required this.userAccount});

  @override
  State<SafePlacesScreen> createState() => _SafePlacesScreenState();
}

class _SafePlacesScreenState extends State<SafePlacesScreen> {
  late GoogleMapController mapController;
  late Future currentPosition;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<LatLng> _getCurrentPosition() async {
    try {
      var isPermission = await Geolocator.checkPermission();
      if (isPermission == LocationPermission.denied ||
          isPermission == LocationPermission.deniedForever) {
        isPermission = await Geolocator.requestPermission();
      }

      if (isPermission == LocationPermission.denied ||
          isPermission == LocationPermission.deniedForever) {
        throw Exception(AppStrings.locationPermissionDenied);
      }

      if (isPermission == LocationPermission.always ||
          isPermission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException(AppStrings.locationTimeout);
          },
        );

        LatLng userLocationLatLng =
            LatLng(position.latitude, position.longitude);
        return userLocationLatLng;
      } else {
        throw Exception(AppStrings.locationPermissionDenied);
      }
    } on TimeoutException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    currentPosition = _getCurrentPosition();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: const Text(
            AppStrings.safePlacesTitle,
            style: AppStyles.titleStyle,
          ),
          actions: [
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const MoreScreen())),
              child: SizedBox(
                height: 50,
                width: 50,
                child: Padding(
                    padding:
                        const EdgeInsets.only(right: AppSizes.smallDistance),
                    child: CircleAvatar(
                        backgroundImage:
                            FileImage(File(widget.userAccount.imageURL)))),
              ),
            )
          ],
        ),
        body: FutureBuilder(
          future: currentPosition,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: snapshot.data,
                  zoom: 17,
                ),
                myLocationEnabled: true,
                mapToolbarEnabled: true,
                myLocationButtonEnabled: true,
              );
            } else {
              return Container();
            }
          },
        ));
  }
}
