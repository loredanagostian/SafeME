import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/keys.dart';
import 'package:safe_me/constants/paths.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/managers/firebase_manager.dart';
import 'package:safe_me/managers/location_manager.dart';
import 'package:safe_me/managers/user_info_provider.dart';
import 'package:safe_me/models/history_event.dart';
import 'package:safe_me/models/safe_place.dart';
import 'package:safe_me/models/user_static_data.dart';
import 'package:safe_me/screens/more_screen.dart';
import 'package:http/http.dart' as http;
import 'package:safe_me/widgets/custom_place_bottom_modal.dart';
import 'package:safe_me/widgets/custom_marker_icon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' show cos, sqrt, asin;

class SafePlacesScreen extends ConsumerStatefulWidget {
  const SafePlacesScreen({super.key});

  @override
  ConsumerState<SafePlacesScreen> createState() => _SafePlacesScreenState();
}

class _SafePlacesScreenState extends ConsumerState<SafePlacesScreen> {
  late GoogleMapController mapController;
  late LatLng currentPosition;
  late Future markers;
  late Marker destinationMarker;
  late Stream<Position> positionStream;
  SafePlace? destinationSafePlace;
  bool isSelectedDestination = false;
  int counterId = 0;
  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<List<Marker>> _getNearbyPlaces() async {
    try {
      var isPermission = await LocationManager.getLocationPermission();

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

        return _getNearbyLocations(userLocationLatLng);
      } else {
        throw Exception(AppStrings.locationPermissionDenied);
      }
    } on TimeoutException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Marker>> _getNearbyLocations(LatLng latLng) async {
    String uri =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${latLng.latitude},${latLng.longitude}&radius=500&key=${AppKeys.googleMapsKey}&opennow=true";
    var url = Uri.parse(uri);
    var response = await http.post(url);
    List<SafePlace> safePlaces = [];
    Map<String, dynamic> json = jsonDecode(response.body);
    List<Marker> markersList = [];
    Uint8List markerIcon = await CustomMarkerIcon.addCustomIcon();

    for (var item in (json['results'] as List)) {
      safePlaces.add(SafePlace.fromJson(item));
      double lat = item['geometry']['location']['lat'];
      double lng = item['geometry']['location']['lng'];
      String name = item['name'];
      List<dynamic> categoriesJson = item['types'];
      List<String> categories = [];
      for (int i = 0; i < categoriesJson.length; i++) {
        categories.add(categoriesJson[i].toString());
      }
      markersList.add(Marker(
          markerId: MarkerId(counterId.toString()),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: item['name']),
          icon: BitmapDescriptor.fromBytes(markerIcon),
          onTap: () {
            if (!isSelectedDestination) {
              showPlaceInformationModal(
                  context,
                  name,
                  getDistance(LatLng(lat, lng)).toStringAsFixed(2),
                  categories,
                  LatLng(lat, lng),
                  ref);
            }
          }));
      counterId++;
    }

    return markersList;
  }

  getDirections(LatLng dst) async {
    List<LatLng> polylineCoordinates = [];
    List<dynamic> points = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        AppKeys.googleMapsKey,
        PointLatLng(currentPosition.latitude, currentPosition.longitude),
        PointLatLng(dst.latitude, dst.longitude),
        travelMode: TravelMode.walking);
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        points.add({'lat': point.latitude, 'lng': point.longitude});
      });
    } else {
      print(result.errorMessage);
    }
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 5,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  double getDistance(LatLng destposition) {
    return calculateDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        destposition.latitude,
        destposition.longitude);
  }

  void showPlaceInformationModal(BuildContext context, String placeName,
      String kmAway, List<String> categories, LatLng latLng, WidgetRef ref) {
    showModalBottomSheet<void>(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSizes.borders),
                topRight: Radius.circular(AppSizes.borders))),
        context: context,
        builder: (BuildContext context) {
          return CustomPlaceBottomModal(
            placeName: placeName,
            kmAway: kmAway,
            categories: categories,
            onTap: () {
              Navigator.pop(context);

              setState(() {
                isSelectedDestination = true;
              });

              destinationSafePlace =
                  SafePlace(name: placeName, position: latLng);

              getDirections(latLng);

              destinationMarker = Marker(
                markerId: MarkerId('destination'),
                position: latLng,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueCyan),
              );
            },
          );
        });
  }

  @override
  void initState() {
    super.initState();
    markers = _getNearbyPlaces();

    // Define location settings with a 5-meter change filter
    var locationOptions = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter:
            5); // Set the minimum distance change (in meters) for updates

    // Initialize the position stream with the desired accuracy and distance filter
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationOptions);
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
              onTap: () async {
                bool result = await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MoreScreen()));
                if (result) setState(() {});
              },
              child: SizedBox(
                height: 50,
                width: 50,
                child: Padding(
                    padding:
                        const EdgeInsets.only(right: AppSizes.smallDistance),
                    child: FirebaseAuth.instance.currentUser!.photoURL != null
                        ? CircleAvatar(
                            backgroundImage: FileImage(File(
                                FirebaseAuth.instance.currentUser!.photoURL!)))
                        : CircleAvatar(
                            backgroundImage:
                                AssetImage(AppPaths.defaultProfilePicture),
                            backgroundColor: AppColors.white,
                          )),
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
              return Stack(children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: currentPosition,
                    zoom: 17,
                  ),
                  myLocationEnabled: true,
                  mapToolbarEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  markers: Set<Marker>.of(snapshot.data),
                  polylines: Set<Polyline>.of(polylines.values),
                ),
                Visibility(
                  visible: isSelectedDestination,
                  child: Positioned(
                      bottom: 130,
                      right: 25,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: AppColors.mainRed),
                        child: Center(
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              // Create history element
                              HistoryEvent historyEvent = HistoryEvent(
                                  startDate: DateTime.now(),
                                  isTrackingEvent: false,
                                  city: (await placemarkFromCoordinates(
                                              currentPosition.latitude,
                                              currentPosition.longitude))[0]
                                          .locality ??
                                      "",
                                  country: (await placemarkFromCoordinates(
                                              currentPosition.latitude,
                                              currentPosition.longitude))[0]
                                          .country ??
                                      "");

                              setState(() {
                                isSelectedDestination = false;
                                polylines = {};
                              });

                              UserStaticData _userStaticData =
                                  ref.watch(userStaticDataProvider);
                              _userStaticData.history.add(historyEvent);
                              ref
                                  .read(userStaticDataProvider.notifier)
                                  .updateUserInfo(_userStaticData);

                              FirebaseManager.addNewHistoryElement(historyEvent)
                                  .then((value) {
                                // Check if there are routes available to pop
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              });
                            },
                          ),
                        ),
                      )),
                ),
                Visibility(
                  visible: isSelectedDestination,
                  child: Positioned(
                      bottom: 75,
                      right: 25,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: AppColors.mainBlue),
                        child: Center(
                          child: IconButton(
                            icon: const Icon(
                              Icons.navigation_outlined,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              await launchUrl(Uri.parse(
                                  'google.navigation:q=${destinationSafePlace!.position.latitude}, ${destinationSafePlace!.position.longitude}&key=${AppKeys.googleMapsKey}&mode=w'));
                            },
                          ),
                        ),
                      )),
                )
              ]);
            } else {
              return Container();
            }
          },
        ));
  }
}
