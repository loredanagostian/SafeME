import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/managers/chat_manager.dart';
import 'package:safe_me/managers/notification_manager.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/screens/chat_screen.dart';
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
  late GoogleMapController _mapController;
  late Account _userInfos;
  late LatLng _friendCurrentPosition;
  bool _added = false;
  final TextEditingController _messageController = TextEditingController();

  Account getUserInfos(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic>? data;
    data = snapshot.data();

    return Account.fromJson(data!);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _added = true;
  }

  Future<void> mymap(Account user) async {
    await _mapController
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
              user.lastLatitude,
              user.lastLongitude,
            ),
            zoom: 17)));
  }

  Widget _createIconButton(
      Color buttonColor, IconData buttonIcon, Function() onPressed) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(shape: BoxShape.circle, color: buttonColor),
      child: Center(
        child: IconButton(
          icon: Icon(
            buttonIcon,
            color: Colors.white,
          ),
          onPressed: onPressed,
        ),
      ),
    );
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
                  Text(AppStrings.activeNow,
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
              return StreamBuilder(
                  stream: ChatManager.getMessages(
                      widget.account.userId, widget.currentUser.userId),
                  builder: (context, snapshot2) {
                    if (snapshot2.hasError) {
                      return Text('Error${snapshot2.error}');
                    }

                    if (snapshot2.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    QueryDocumentSnapshot<Object?>? latestMessage;

                    var matchingDocuments =
                        snapshot2.data!.docs.where((document) {
                      Map<String, dynamic> docData =
                          document.data() as Map<String, dynamic>;
                      return docData["senderId"] == widget.account.userId &&
                          (docData["timestamp"] as Timestamp).toDate().isAfter(
                              (DateTime.now())
                                  .subtract(Duration(minutes: 5))) &&
                          (docData["timestamp"] as Timestamp)
                              .toDate()
                              .isBefore(DateTime.now());
                    }).toList();

                    if (matchingDocuments.isNotEmpty) {
                      latestMessage = matchingDocuments.first;
                    } else {
                      latestMessage = null;
                    }

                    Map<String, dynamic> message = latestMessage != null
                        ? latestMessage.data() as Map<String, dynamic>
                        : {};

                    bool isMessageSentByCurrentUser = false;
                    _userInfos = getUserInfos(snapshot.requireData);

                    if (_added) {
                      mymap(_userInfos);
                    }

                    _friendCurrentPosition = LatLng(
                        _userInfos.lastLatitude, _userInfos.lastLongitude);

                    return Stack(children: [
                      GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: _friendCurrentPosition,
                          zoom: 17,
                        ),
                        mapType: MapType.normal,
                        markers: {
                          Marker(
                              position: _friendCurrentPosition,
                              markerId: MarkerId('id'),
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueCyan)),
                        },
                        mapToolbarEnabled: true,
                        zoomControlsEnabled: false,
                      ),
                      Positioned(
                          top: 15,
                          right: 15,
                          child: _createIconButton(
                            AppColors.mainRed,
                            Icons.notifications_outlined,
                            () async {
                              NotificationManager.sendNotification(
                                  token: _userInfos.deviceToken,
                                  body: widget.currentUser.trackingSMS,
                                  friendId: _userInfos.userId);
                            },
                          )),
                      Positioned(
                          top: 75,
                          right: 15,
                          child: _createIconButton(
                            AppColors.mainBlue,
                            Icons.sms_outlined,
                            () async {
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
                          )),
                      Positioned(
                          bottom: 25,
                          left: 15,
                          child: _createIconButton(
                            AppColors.mainRed,
                            Icons.forum_outlined,
                            () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                            friendAccount: widget.account,
                                            currentUserImageUrl:
                                                widget.currentUser.imageURL,
                                          )));
                            },
                          )),
                      Positioned(
                          bottom: 25,
                          left: 70,
                          right: 15,
                          child: TextFormField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.fromLTRB(
                                AppSizes.mediumDistance,
                                AppSizes.smallDistance,
                                AppSizes.mediumDistance,
                                AppSizes.smallDistance,
                              ),
                              hintText: "Type a message",
                              hintStyle: AppStyles.bodyStyle
                                  .copyWith(color: AppColors.mediumGray),
                              fillColor: AppColors.componentGray,
                              filled: true,
                              suffixIcon: const Icon(Icons.send_outlined),
                              suffixIconColor: AppColors.mainDarkGray,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.borders),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: AppColors.componentGray),
                                borderRadius:
                                    BorderRadius.circular(AppSizes.borders),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: AppColors.componentGray),
                                borderRadius:
                                    BorderRadius.circular(AppSizes.borders),
                              ),
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            keyboardType: TextInputType.text,
                          )),
                      message.isNotEmpty
                          ? Stack(
                              children: [
                                Visibility(
                                  visible: !isMessageSentByCurrentUser,
                                  child: Positioned(
                                      bottom: 85,
                                      left: 15,
                                      child: SizedBox(
                                          height: 50,
                                          width: 50,
                                          child: CircleAvatar(
                                              backgroundImage: FileImage(File(
                                                  widget.account.imageURL))))),
                                ),
                                Visibility(
                                  visible: !isMessageSentByCurrentUser,
                                  child: Positioned(
                                    bottom: 85,
                                    left: 75,
                                    child: Container(
                                      height: 70,
                                      width: 220,
                                      padding: const EdgeInsets.all(
                                          AppSizes.mediumDistance),
                                      decoration: BoxDecoration(
                                        color: AppColors.mediumBlue,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(
                                                AppSizes.borders),
                                            topRight: Radius.circular(
                                                AppSizes.borders),
                                            bottomRight: Radius.circular(
                                                AppSizes.borders)),
                                      ),
                                      child: Center(
                                        child: Text(
                                          message["message"],
                                          style: AppStyles.hintComponentStyle
                                              .copyWith(
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                    ]);
                  });
            }
            return Container();
          },
        ));
  }
}
