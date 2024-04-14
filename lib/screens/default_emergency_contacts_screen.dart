import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/widgets/custom_alert_dialog.dart';
import 'package:safe_me/widgets/custom_friends_bottom_modal.dart';
import 'package:safe_me/widgets/custom_list_tile.dart';
import 'package:safe_me/widgets/custom_user_information_modal.dart';

class DefaultEmergencyContactsScreen extends StatefulWidget {
  final Account userAccount;
  const DefaultEmergencyContactsScreen({
    super.key,
    required this.userAccount,
  });

  @override
  State<DefaultEmergencyContactsScreen> createState() =>
      _DefaultEmergencyContactsScreenState();
}

class _DefaultEmergencyContactsScreenState
    extends State<DefaultEmergencyContactsScreen> {
  void _showAllFriendsList(
      BuildContext context, List<Account> friends, Account user) {
    showModalBottomSheet<void>(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSizes.borders),
                topRight: Radius.circular(AppSizes.borders))),
        context: context,
        builder: (BuildContext context) {
          return CustomFriendsBottomModal(
            allFriends: friends,
            userAccount: user,
          );
        });
  }

  void _showDeleteDialog(Account account) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: AppStrings.deleteUser,
            message:
                "${AppStrings.deleteUserMessage1} ${account.firstName} ${account.lastName} ${AppStrings.deleteUserMessage2_emergencyContactsList}",
            onConfirm: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .update({
                "emergencyContacts": FieldValue.arrayRemove([account.userId])
              });

              Navigator.pop(context);
            },
            onCancel: () {
              Navigator.pop(context);
              setState(() {});
            },
          );
        });
  }

  Future<List<Account>> fetchEmergencyContacts(
      List<String> emergencyContactIds) async {
    List<Future<Account>> futures = emergencyContactIds
        .map((e) => FirebaseFirestore.instance
                .collection('users')
                .doc(e)
                .get()
                .then((snapshot) {
              Map<String, dynamic>? data = snapshot.data();
              return Account.fromJson(data ?? {});
            }))
        .toList();

    List<Account> emergencyAccounts = await Future.wait(futures);
    return emergencyAccounts;
  }

  Future<List<Account>> fetchFriends(List<String> friendIds) async {
    List<Future<Account>> futures = friendIds
        .map((e) => FirebaseFirestore.instance
                .collection('users')
                .doc(e)
                .get()
                .then((snapshot) {
              Map<String, dynamic>? data = snapshot.data();
              return Account.fromJson(data ?? {});
            }))
        .toList();

    List<Account> friends = await Future.wait(futures);
    return friends;
  }

  void _showUserInformationModal(
      BuildContext context, Account friendUser, Account user) {
    showModalBottomSheet<void>(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSizes.borders),
                topRight: Radius.circular(AppSizes.borders))),
        context: context,
        builder: (BuildContext context) {
          return Wrap(children: [
            CustomUserInformationModal(
              user: friendUser,
              currentUser: user,
              isEmergencyScreen: true,
            )
          ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    Stream<DocumentSnapshot<Map<String, dynamic>>> stream = FirebaseFirestore
        .instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: const Text(
            AppStrings.emergencyContacts,
            style: AppStyles.titleStyle,
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.mainDarkGray,
            ),
          ),
        ),
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: stream,
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                    snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData && snapshot.data!.data() != null) {
                  Account account = Account.fromJson(snapshot.data!.data()!);

                  return FutureBuilder<List<dynamic>>(
                      future: Future.wait([
                        fetchEmergencyContacts(account.emergencyContacts),
                        fetchFriends(account.friends),
                      ]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator(); // Show loading indicator while fetching data
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (snapshot.hasData) {
                          List<Account> emergencyAccounts = snapshot.data![0];
                          List<Account> friends = snapshot.data![1];

                          // Now you have both emergencyContacts and friends data
                          return Padding(
                            padding:
                                const EdgeInsets.all(AppSizes.smallDistance),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "${emergencyAccounts.length} ${AppStrings.emergencyContacts.toLowerCase()}",
                                        style: AppStyles.textComponentStyle
                                            .copyWith(
                                                color: AppColors.mainBlue),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: SizedBox(
                                          height: 35,
                                          width: 35,
                                          child: IconButton(
                                            onPressed: () =>
                                                _showAllFriendsList(
                                                    context, friends, account),
                                            icon: const Icon(
                                              Icons.person_add_outlined,
                                              color: AppColors.mainDarkGray,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const Divider(
                                    color: AppColors.mainDarkGray,
                                    thickness: 1,
                                  ),
                                  ListView.builder(
                                    itemCount: emergencyAccounts.length,
                                    itemBuilder: (context, index) {
                                      final item = emergencyAccounts[index];

                                      return GestureDetector(
                                        onTap: () => _showUserInformationModal(
                                            context, item, account),
                                        child: CustomListTile(
                                          photoUrl: item.imageURL,
                                          title: item.firstName,
                                          subtitle: item.phoneNumber,
                                          onDismiss:
                                              (DismissDirection direction) =>
                                                  _showDeleteDialog(item),
                                          buttonText: '',
                                          button1Action: () {},
                                          buttonColor: AppColors.white,
                                        ),
                                      );
                                    },
                                    shrinkWrap: true,
                                  )
                                ]),
                          );
                        }
                        return Container();
                      });
                }
              }
              return Container();
            }));
  }
}
