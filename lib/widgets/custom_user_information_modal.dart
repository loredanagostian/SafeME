import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/paths.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/managers/firebase_manager.dart';
import 'package:safe_me/managers/user_info_provider.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/models/user_static_data.dart';
import 'package:safe_me/widgets/custom_alert_dialog.dart';
import 'package:safe_me/widgets/custom_button.dart';

class CustomUserInformationModal extends ConsumerStatefulWidget {
  final Account friend;
  final bool isEmergencyScreen;
  final bool isRequests;
  const CustomUserInformationModal(
      {super.key,
      required this.friend,
      this.isEmergencyScreen = false,
      this.isRequests = false});

  @override
  ConsumerState<CustomUserInformationModal> createState() =>
      _CustomUserInformationModalState();
}

class _CustomUserInformationModalState
    extends ConsumerState<CustomUserInformationModal> {
  late UserStaticData _userStaticData;

  Future<Placemark?> _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          widget.friend.lastLatitude, widget.friend.lastLongitude);
      Placemark place = placemarks[0];

      return place;
    } catch (e) {
      print(e);
    }

    return null;
  }

  void _setEmergencyContact(BuildContext context) {
    _userStaticData.emergencyContacts.add(widget.friend.userId);
    ref.read(userStaticDataProvider.notifier).updateUserInfo(_userStaticData);
    FirebaseManager.addEmergencyContact(widget.friend.userId)
        .then((value) => Navigator.pop(context));
  }

  void _showDeleteDialog(Account account, BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: widget.isEmergencyScreen
                ? AppStrings.deleteEmergencyContact
                : AppStrings.deleteUser,
            message:
                "${AppStrings.deleteUserMessage1} ${account.firstName} ${account.lastName} ${widget.isEmergencyScreen ? AppStrings.deleteUserMessage2_emergencyContactsList : AppStrings.deleteUserMessage2_friendList}",
            firstButtonAction: () async {
              if (widget.isEmergencyScreen) {
                _userStaticData.emergencyContacts.remove(account.userId);
                ref
                    .read(userStaticDataProvider.notifier)
                    .updateUserInfo(_userStaticData);
                await FirebaseManager.removeEmergencyContact(account.userId);

                Navigator.of(context)
                  ..pop()
                  ..pop();
              } else {
                _userStaticData.friends.remove(account.userId);
                ref
                    .read(userStaticDataProvider.notifier)
                    .updateUserInfo(_userStaticData);
                await FirebaseManager.removeFriend(account.userId);

                Navigator.of(context)
                  ..pop()
                  ..pop();
              }
            },
            secondButtonAction: () {
              Navigator.pop(context);
            },
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _userStaticData = ref.read(userStaticDataProvider);
  }

  @override
  Widget build(BuildContext context) {
    _userStaticData = ref.watch(userStaticDataProvider);

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
                      child: widget.friend.imageURL != null
                          ? CircleAvatar(
                              backgroundImage:
                                  NetworkImage(widget.friend.imageURL!))
                          : CircleAvatar(
                              backgroundImage:
                                  AssetImage(AppPaths.defaultProfilePicture),
                              backgroundColor: AppColors.white,
                            )),
                ),
              ),
              const SizedBox(height: AppSizes.smallDistance),
              Center(
                  child: Text(
                "${widget.friend.firstName} ${widget.friend.lastName}",
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
                    widget.friend.email,
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
                    widget.friend.phoneNumber,
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
                            (widget.friend.lastLatitude == 0 &&
                                        widget.friend.lastLongitude == 0) ||
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
              Visibility(
                  visible: !widget.isRequests,
                  child: const SizedBox(height: AppSizes.buttonHeight)),
              Visibility(
                visible: !widget.isEmergencyScreen && !widget.isRequests,
                child: CustomButton(
                    buttonColor: _userStaticData.emergencyContacts
                            .contains(widget.friend.userId)
                        ? AppColors.mediumGray
                        : AppColors.mainBlue,
                    buttonText: AppStrings.setAsEmergencyContact,
                    onTap: () {
                      _userStaticData.emergencyContacts
                              .contains(widget.friend.userId)
                          ? null
                          : _setEmergencyContact(context);
                    }),
              ),
              const SizedBox(height: AppSizes.smallDistance),
              Visibility(
                visible: !widget.isRequests,
                child: CustomButton(
                    buttonColor: AppColors.mainRed,
                    buttonText: widget.isEmergencyScreen
                        ? AppStrings.removeEmergencyContact
                        : AppStrings.removeFriend,
                    onTap: () => _showDeleteDialog(widget.friend, context)),
              ),
            ]));
  }
}
