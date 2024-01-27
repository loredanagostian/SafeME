import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/managers/notification_manager.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/widgets/custom_list_tile.dart';
import 'package:safe_me/widgets/custom_search_bar.dart';
import 'package:safe_me/widgets/custom_snackbar.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  List<Account> filteredData = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Account> accountsData = [];
  String totalFoundsAccounts = "";

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      _onSearchTextChanged(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(() {
      _onSearchTextChanged(
        _searchController.text,
      );
    });
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged(String text) {
    setState(() {
      _searchQuery = text;

      filteredData = accountsData
          .where((item) =>
              item.firstName.toLowerCase().contains(text.toLowerCase()) ||
              item.lastName.toLowerCase().contains(text.toLowerCase()))
          .toList();
    });
  }

  Future<List<Account>> fetchAllUsers(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    List<String> usersIds = docs.map((doc) => doc.id).toList();
    List<Future<Account>> futureAccounts = [];

    for (String userId in usersIds) {
      Future<Account> accountFuture = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .then((snapshot) {
        Map<String, dynamic>? data = snapshot.data();
        return Account.fromJson(data ?? {});
      });

      futureAccounts.add(accountFuture);
    }
    return Future.wait(futureAccounts);
  }

  bool userAlreadyFriend(Account account) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    for (String userId in account.friends) {
      if (userId == currentUserId) return true;
    }

    return false;
  }

  bool userAlreadyRequested(Account account) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    for (String userId in account.friendsRequest) {
      if (userId == currentUserId) return true;
    }

    return false;
  }

  Color getButtonColor(Account account) {
    if (userAlreadyFriend(account)) return AppColors.mediumGray;
    if (userAlreadyRequested(account)) return AppColors.mainGreen;
    return AppColors.mainBlue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: const Text(
            AppStrings.allUsers,
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
        body: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData) {
                return FutureBuilder<List<Account>>(
                    future: fetchAllUsers(snapshot.data!.docs),
                    builder:
                        (context, AsyncSnapshot<List<Account>> asyncSnapshot) {
                      if (asyncSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (asyncSnapshot.hasData) {
                        List<Account> accountsData = asyncSnapshot.data!;
                        totalFoundsAccounts = _searchQuery.isNotEmpty
                            ? filteredData.length.toString()
                            : accountsData.length.toString();

                        return Container(
                          padding: const EdgeInsets.all(AppSizes.smallDistance),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomSearchBar(
                                  onChanged: _onSearchTextChanged,
                                  searchController: _searchController),
                              const SizedBox(height: AppSizes.marginSize),
                              Text(
                                "$totalFoundsAccounts total users",
                                style: AppStyles.textComponentStyle
                                    .copyWith(color: AppColors.mainBlue),
                              ),
                              const Divider(
                                color: AppColors.mainDarkGray,
                                thickness: 1,
                              ),
                              ListView.builder(
                                itemCount: _searchQuery.isNotEmpty
                                    ? filteredData.length
                                    : accountsData.length,
                                itemBuilder: (context, index) {
                                  final item = _searchQuery.isNotEmpty
                                      ? filteredData[index]
                                      : accountsData[index];

                                  return CustomListTile(
                                    photoUrl: item.imageURL,
                                    title: item.firstName,
                                    subtitle: item.phoneNumber,
                                    buttonText: userAlreadyFriend(item)
                                        ? AppStrings.addedButton
                                        : AppStrings.addButton,
                                    isAlreadyFriend: userAlreadyFriend(item),
                                    button1Action: () async {
                                      if (item.email !=
                                          FirebaseAuth
                                              .instance.currentUser!.email) {
                                        String itemId = FirebaseAuth
                                            .instance.currentUser!.uid;

                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(itemId)
                                            .update({
                                          "friendRequests":
                                              FieldValue.arrayUnion([
                                            FirebaseAuth
                                                .instance.currentUser!.uid
                                          ]),
                                        }).then((value) =>
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                        const SnackBar(
                                                  content: CustomSnackbarContent(
                                                      snackBarMessage: AppStrings
                                                          .userAddedSuccessfully),
                                                  backgroundColor:
                                                      AppColors.mainGreen,
                                                )));

                                        NotificationManager.sendNotification(
                                          token: item.deviceToken,
                                          body: AppStrings.newFriendRequest,
                                          friendId: item.userId,
                                        );
                                      }
                                    },
                                    buttonColor: item.email ==
                                            FirebaseAuth
                                                .instance.currentUser!.email
                                        ? AppColors.mediumGray
                                        : getButtonColor(item),
                                  );
                                },
                                shrinkWrap: true,
                              )
                            ],
                          ),
                        );
                      } else {
                        return Container();
                      }
                    });
              }
              return Container();
            }));
  }
}
