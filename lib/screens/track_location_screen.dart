import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/managers/notification_manager.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackLocationScreen extends StatefulWidget {
  final Account account;
  final Account currentUser;
  const TrackLocationScreen(
      {super.key, required this.account, required this.currentUser});

  @override
  State<TrackLocationScreen> createState() => _TrackLocationScreenState();
}

class _TrackLocationScreenState extends State<TrackLocationScreen> {
  late GoogleMapController mapController;
  late Account userInfos;
  late LatLng friendCurrentPosition;
  bool _added = false;

  Account getUserInfos(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic>? data;
    data = snapshot.data();

    return Account.fromJson(data!);
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _added = true;
  }

  Future<void> mymap(Account user) async {
    await mapController
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
              user.lastLatitude,
              user.lastLongitude,
            ),
            zoom: 17)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          titleSpacing: 0.0,
          title: Row(
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: Padding(
                    padding:
                        const EdgeInsets.only(right: AppSizes.smallDistance),
                    child: CircleAvatar(
                        backgroundImage:
                            FileImage(File(widget.account.imageURL)))),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.account.firstName} ${widget.account.lastName}",
                    style: AppStyles.notificationTitleStyle
                        .copyWith(color: AppColors.mainDarkGray),
                  ),
                  Text("Active now",
                      style: AppStyles.notificationBodyStyle
                          .copyWith(color: AppColors.lightGreen)),
                ],
              )
            ],
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.mainDarkGray,
            ),
          ),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.account.userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.active &&
                snapshot.hasData) {
              userInfos = getUserInfos(snapshot.requireData);

              if (_added) {
                mymap(userInfos);
              }

              friendCurrentPosition =
                  LatLng(userInfos.lastLatitude, userInfos.lastLongitude);

              return Stack(children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: friendCurrentPosition,
                    zoom: 17,
                  ),
                  mapType: MapType.normal,
                  markers: {
                    Marker(
                        position: friendCurrentPosition,
                        markerId: MarkerId('id'),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueCyan)),
                  },
                  mapToolbarEnabled: true,
                  zoomControlsEnabled: false,
                ),
                Positioned.fill(
                    bottom: 90,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.mediumDistance),
                        child: CustomButton(
                          buttonColor: AppColors.mainRed,
                          buttonText: AppStrings.notifyTracking,
                          onTap: () async {
                            NotificationManager.sendNotification(
                                token: userInfos.deviceToken,
                                body: widget.currentUser.trackingSMS,
                                friendId: userInfos.userId);
                          },
                        ),
                      ),
                    )),
                Positioned.fill(
                    bottom: 20,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.mediumDistance),
                        child: CustomButton(
                          buttonColor: AppColors.mainBlue,
                          buttonText: AppStrings.openSMSApp,
                          onTap: () async {
                            String message = widget.currentUser.trackingSMS;
                            String encodedMessage = Uri.encodeFull(message);
                            final call = Uri.parse(
                                'sms:${widget.account.phoneNumber}?body=$encodedMessage');
                            if (await canLaunchUrl(call)) {
                              launchUrl(call);
                            } else {
                              throw 'Could not launch $call';
                            }
                          },
                        ),
                      ),
                    )),
              ]);
            } else {
              return Container();
            }
          },
        ));
  }
}
