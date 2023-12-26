import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
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
import 'package:location/location.dart' as loc;
import 'package:location/location.dart';
import 'package:safe_me/widgets/custom_marker_icon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' show cos, sqrt, asin;

class SafePlacesScreen extends StatefulWidget {
  final Account userAccount;

  const SafePlacesScreen({super.key, required this.userAccount});

  @override
  State<SafePlacesScreen> createState() => _SafePlacesScreenState();
}

class _SafePlacesScreenState extends State<SafePlacesScreen> {
  late GoogleMapController mapController;
  late LatLng currentPosition;
  SafePlace? destinationSafePlace;
  bool isSelectedDestination = false;
  late Future markers;
  int counterId = 0;
  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  Location location = Location();
  late Marker destinationMarker;
  StreamSubscription<loc.LocationData>? locationSubscription;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<LocationPermission> getLocationPermission() async {
    var isPermission = await Geolocator.checkPermission();
    if (isPermission == LocationPermission.denied ||
        isPermission == LocationPermission.deniedForever) {
      isPermission = await Geolocator.requestPermission();
    }

    return isPermission;
  }

  Future<List<Marker>> _getNearbyPlaces() async {
    try {
      var isPermission = await getLocationPermission();

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
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${latLng.latitude},${latLng.longitude}&radius=500&key=AIzaSyDYhjj1K3NjiWRWhUVakjVQ0cLIV2YEyU4&opennow=true";
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
      markersList.add(Marker(
          markerId: MarkerId(counterId.toString()),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: item['name']),
          icon: BitmapDescriptor.fromBytes(markerIcon),
          onTap: () {
            if ((destinationSafePlace != null &&
                    destinationSafePlace!.name != name &&
                    ((destinationSafePlace!.position.latitude - lat).abs() <
                        1) &&
                    ((destinationSafePlace!.position.longitude - lng).abs() <
                        1)) ||
                !isSelectedDestination) {
              print(destinationSafePlace);
              print(lat);
              print(lng);
              setState(() {
                isSelectedDestination = true;
              });
              destinationSafePlace =
                  SafePlace(name: name, position: LatLng(lat, lng));

              getNavigation(LatLng(lat, lng));

              destinationMarker = Marker(
                markerId: MarkerId('destination'),
                position: LatLng(lat, lng),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueCyan),
              );
            } else {
              setState(() {
                isSelectedDestination = false;
                polylines = {};
              });
            }
          }));
      counterId++;
    }

    return markersList;
  }

  getNavigation(LatLng destinationPoint) async {
    location.changeSettings(accuracy: loc.LocationAccuracy.high);

    locationSubscription =
        location.onLocationChanged.listen((LocationData currentLocation) {});
    getDirections(destinationPoint);
  }

  getDirections(LatLng dst) async {
    List<LatLng> polylineCoordinates = [];
    List<dynamic> points = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyDYhjj1K3NjiWRWhUVakjVQ0cLIV2YEyU4',
        PointLatLng(currentPosition.latitude, currentPosition.longitude),
        PointLatLng(dst.latitude, dst.longitude),
        travelMode: TravelMode.driving);
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
    polylines[id] = polyline;
    setState(() {});
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

  @override
  void initState() {
    super.initState();
    markers = _getNearbyPlaces();
  }

  @override
  void dispose() {
    super.dispose();
    locationSubscription?.cancel();
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
                                  'google.navigation:q=${destinationSafePlace!.position.latitude}, ${destinationSafePlace!.position.longitude}&key=AIzaSyDYhjj1K3NjiWRWhUVakjVQ0cLIV2YEyU4'));
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
