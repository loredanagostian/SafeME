import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/paths.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/managers/chat_manager.dart';
import 'package:safe_me/managers/notification_manager.dart';
import 'package:safe_me/managers/user_info_provider.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/models/user_static_data.dart';
import 'package:safe_me/screens/chat_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackLocationScreen extends ConsumerStatefulWidget {
  final Account friendAccount;
  const TrackLocationScreen({super.key, required this.friendAccount});

  @override
  ConsumerState<TrackLocationScreen> createState() =>
      _TrackLocationScreenState();
}

class _TrackLocationScreenState extends ConsumerState<TrackLocationScreen> {
  late GoogleMapController _mapController;
  late LatLng _friendCurrentPosition;
  late Account _userInfos;
  late UserStaticData _userStaticData;
  final TextEditingController _messageController = TextEditingController();
  bool _added = false;

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

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await ChatManager.sendMessage(
          widget.friendAccount.userId, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    _userStaticData = ref.watch(userStaticDataProvider);

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
                    child: widget.friendAccount.imageURL != null
                        ? CircleAvatar(
                            backgroundImage:
                                FileImage(File(widget.friendAccount.imageURL!)))
                        : CircleAvatar(
                            backgroundImage:
                                AssetImage(AppPaths.defaultProfilePicture),
                            backgroundColor: AppColors.white,
                          )),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.friendAccount.firstName} ${widget.friendAccount.lastName}",
                    style: AppStyles.notificationTitleStyle
                        .copyWith(color: AppColors.mainDarkGray),
                  ),
                  Text(AppStrings.activeNow,
                      style: AppStyles.notificationBodyStyle
                          .copyWith(color: AppColors.mediumBlue)),
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
              .doc(widget.friendAccount.userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.active &&
                snapshot.hasData) {
              return StreamBuilder(
                  stream: ChatManager.getMessages(widget.friendAccount.userId),
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
                      return docData["senderId"] ==
                              widget.friendAccount.userId &&
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
                                  body: _userStaticData.trackingSMS,
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
                              String message = _userStaticData.trackingSMS;
                              String encodedMessage = Uri.encodeFull(message);
                              final call = Uri.parse(
                                  'sms:${widget.friendAccount.phoneNumber}?body=$encodedMessage');
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
                                          friendAccount:
                                              widget.friendAccount)));
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
                              hintText: AppStrings.typeAMessageHint,
                              hintStyle: AppStyles.bodyStyle
                                  .copyWith(color: AppColors.mediumGray),
                              fillColor: AppColors.componentGray,
                              filled: true,
                              suffixIcon: IconButton(
                                  icon: Icon(Icons.send_outlined),
                                  onPressed: sendMessage),
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
                                          child:
                                              widget.friendAccount.imageURL !=
                                                      null
                                                  ? CircleAvatar(
                                                      backgroundImage:
                                                          FileImage(File(widget
                                                              .friendAccount
                                                              .imageURL!)))
                                                  : CircleAvatar(
                                                      backgroundImage:
                                                          AssetImage(AppPaths
                                                              .defaultProfilePicture),
                                                      backgroundColor:
                                                          AppColors.white,
                                                    ))),
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
