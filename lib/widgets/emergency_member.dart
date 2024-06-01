import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/paths.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/models/account.dart';

class EmergencyMember extends StatelessWidget {
  final Future<Account> emergencyUser;
  const EmergencyMember({super.key, required this.emergencyUser});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: emergencyUser,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("Error${snapshot.error}");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            return Container(
              width: 75,
              decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(AppSizes.borders)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.smallDistance),
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: snapshot.data!.imageURL != null
                          ? CircleAvatar(
                              backgroundImage:
                                  NetworkImage(snapshot.data!.imageURL!))
                          : CircleAvatar(
                              backgroundImage:
                                  AssetImage(AppPaths.defaultProfilePicture),
                              backgroundColor: AppColors.white,
                            ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      "${snapshot.data!.firstName}\n${snapshot.data!.lastName}",
                      style: AppStyles.textComponentStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }
          return Container();
        });
  }
}
