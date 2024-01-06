import 'dart:ui' as ui;

import 'package:flutter/services.dart';

class CustomMarkerIcon {
  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  static Future<Uint8List> addCustomIcon() async {
    final Uint8List markerIcon =
        await getBytesFromAsset("lib/assets/images/location.png", 120);
    return markerIcon;
  }
}
