import 'package:google_maps_flutter/google_maps_flutter.dart';

class SafePlace {
  final String name;
  final LatLng position;

  SafePlace({required this.name, required this.position});

  factory SafePlace.fromJson(Map<String, dynamic> json) {
    String name = json['name'];
    double lat = json['geometry']['location']['lat'];
    double lng = json['geometry']['location']['lng'];
    LatLng latLng = LatLng(lat, lng);

    return SafePlace(
      name: name,
      position: latLng,
    );
  }
}
