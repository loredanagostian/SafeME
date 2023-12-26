import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/models/safe_place.dart';
import 'package:safe_me/screens/more_screen.dart';
import 'package:http/http.dart' as http;

class SafePlacesScreen extends StatefulWidget {
  final Account userAccount;

  const SafePlacesScreen({super.key, required this.userAccount});

  @override
  State<SafePlacesScreen> createState() => _SafePlacesScreenState();
}

class _SafePlacesScreenState extends State<SafePlacesScreen> {
  late GoogleMapController mapController;
  late LatLng currentPosition;
  late Future markers;
  int counterId = 0;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<List<Marker>> _getCurrentPosition() async {
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

        currentPosition = userLocationLatLng;

        return _getNearbyLocations(
            userLocationLatLng, 'AIzaSyDYhjj1K3NjiWRWhUVakjVQ0cLIV2YEyU4');
        // return userLocationLatLng;
      } else {
        throw Exception(AppStrings.locationPermissionDenied);
      }
    } on TimeoutException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Marker>> _getNearbyLocations(LatLng latLng, String apiKey) async {
    String uri =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${latLng.latitude},${latLng.longitude}&radius=500&key=$apiKey&opennow=true";
    var url = Uri.parse(uri);
    var response = await http.post(url);
    List<SafePlace> safePlaces = [];
    Map<String, dynamic> json = jsonDecode(response.body);
    List<Marker> markersList = [];

    for (var item in (json['results'] as List)) {
      safePlaces.add(SafePlace.fromJson(item));
      double lat = item['geometry']['location']['lat'];
      double lng = item['geometry']['location']['lng'];
      markersList.add(Marker(
        markerId: MarkerId(counterId.toString()),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: item['name']),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
      counterId++;
    }

    return markersList;
  }

  @override
  void initState() {
    super.initState();
    markers = _getCurrentPosition();
    // markers = _getNearbyLocations();
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
          future: markers,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: currentPosition,
                  zoom: 17,
                ),
                myLocationEnabled: true,
                mapToolbarEnabled: true,
                myLocationButtonEnabled: true,
                markers: Set<Marker>.of(snapshot.data),
              );
            } else {
              return Container();
            }
          },
        ));
  }
}
