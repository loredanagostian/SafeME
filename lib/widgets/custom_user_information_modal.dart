import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/widgets/custom_alert_dialog.dart';
import 'package:safe_me/widgets/custom_button.dart';

class CustomUserInformationModal extends StatelessWidget {
  final Account user;
  final Account currentUser;
  final bool isEmergencyScreen;
  const CustomUserInformationModal(
      {super.key,
      required this.user,
      required this.currentUser,
      this.isEmergencyScreen = false});

  Future<Placemark?> _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(user.lastLatitude, user.lastLongitude);
      Placemark place = placemarks[0];

      return place;
    } catch (e) {
      print(e);
    }

    return null;
  }

  void _setEmergencyContact(BuildContext context) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.userId)
        .update({
      "emergencyContacts": FieldValue.arrayUnion([user.userId]),
    }).then((value) => Navigator.pop(context));
  }

  void _showDeleteDialog(Account account, BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: isEmergencyScreen
                ? AppStrings.deleteEmergencyContact
                : AppStrings.deleteUser,
            message:
                "${AppStrings.deleteUserMessage1} ${account.firstName} ${account.lastName} ${isEmergencyScreen ? AppStrings.deleteUserMessage2_emergencyContactsList : AppStrings.deleteUserMessage2_friendList}",
            onConfirm: () async {
              if (isEmergencyScreen) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .update({
                  "emergencyContacts": FieldValue.arrayRemove([account.userId])
                });

                Navigator.of(context)
                  ..pop()
                  ..pop();
              } else {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .update({
                  "friends": FieldValue.arrayRemove([account.userId]),
                  "emergencyContacts": FieldValue.arrayRemove([account.userId]),
                });

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(account.userId)
                    .update({
                  "friends": FieldValue.arrayRemove(
                      [FirebaseAuth.instance.currentUser!.uid])
                });

                Navigator.of(context)
                  ..pop()
                  ..pop();
              }
            },
            onCancel: () {
              Navigator.pop(context);
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(
          top: AppSizes.mediumDistance,
          bottom: AppSizes.mediumDistance,
          left: AppSizes.smallDistance,
          right: AppSizes.smallDistance,
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Padding(
                      padding:
                          const EdgeInsets.only(right: AppSizes.smallDistance),
                      child: CircleAvatar(
                          backgroundImage: FileImage(File(user.imageURL)))),
                ),
              ),
              const SizedBox(height: AppSizes.smallDistance),
              Center(
                  child: Text(
                "${user.firstName} ${user.lastName}",
                style: AppStyles.titleStyle
                    .copyWith(color: AppColors.mainDarkGray),
              )),
              const SizedBox(height: AppSizes.bigDistance),
              Text(AppStrings.information,
                  style: AppStyles.textComponentStyle
                      .copyWith(fontSize: 20, color: AppColors.darkGray)),
              const Divider(
                color: AppColors.mediumGray,
                thickness: 0.6,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.email,
                    style: AppStyles.textComponentStyle
                        .copyWith(color: AppColors.darkGray),
                  ),
                  Text(
                    user.email,
                    style: AppStyles.textComponentStyle.copyWith(
                      color: AppColors.darkGray,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                ],
              ),
              const SizedBox(height: AppSizes.mediumDistance),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.phoneNumber,
                    style: AppStyles.textComponentStyle
                        .copyWith(color: AppColors.darkGray),
                  ),
                  Text(
                    user.phoneNumber,
                    style: AppStyles.textComponentStyle.copyWith(
                      color: AppColors.darkGray,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                ],
              ),
              const SizedBox(height: AppSizes.mediumDistance),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.latestLocation,
                    style: AppStyles.textComponentStyle
                        .copyWith(color: AppColors.darkGray),
                  ),
                  FutureBuilder(
                      future: _getAddressFromLatLng(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData &&
                            snapshot.connectionState == ConnectionState.done) {
                          return Text(
                            (user.lastLatitude == 0 &&
                                        user.lastLongitude == 0) ||
                                    snapshot.data == null
                                ? AppStrings.notAvailable
                                : "${snapshot.data?.street ?? AppStrings.notAvailable}\n${snapshot.data?.locality ?? ""}${snapshot.data?.country != null ? "," : ""} ${snapshot.data?.country ?? ""}",
                            style: AppStyles.textComponentStyle.copyWith(
                              color: AppColors.darkGray,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.right,
                          );
                        }
                        return Text(
                          AppStrings.notAvailable,
                          style: AppStyles.textComponentStyle.copyWith(
                            color: AppColors.darkGray,
                            fontWeight: FontWeight.w400,
                          ),
                        );
                      })
                ],
              ),
              const SizedBox(height: AppSizes.buttonHeight),
              Visibility(
                visible: !isEmergencyScreen,
                child: CustomButton(
                    buttonColor:
                        currentUser.emergencyContacts.contains(user.userId)
                            ? AppColors.mediumGray
                            : AppColors.mainBlue,
                    buttonText: AppStrings.setAsEmergencyContact,
                    onTap: () {
                      currentUser.emergencyContacts.contains(user.userId)
                          ? null
                          : _setEmergencyContact(context);
                    }),
              ),
              const SizedBox(height: AppSizes.smallDistance),
              CustomButton(
                  buttonColor: AppColors.mainRed,
                  buttonText: isEmergencyScreen
                      ? AppStrings.removeEmergencyContact
                      : AppStrings.removeFriend,
                  onTap: () => _showDeleteDialog(user, context)),
            ]));
  }
}
