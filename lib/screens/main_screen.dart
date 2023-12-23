import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/screens/friends_screen.dart';
import 'package:safe_me/screens/home_screen.dart';
import 'package:safe_me/widgets/custom_bottom_tab_navigator.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  User? currentUser;

  Widget _getBody(int index, Account userAccount) {
    switch (index) {
      case 0:
        break;
      case 1:
        return HomeScreen(userAccount: userAccount);
      case 2:
        return FriendsScreen(userAccount: userAccount);
    }
    return HomeScreen(userAccount: userAccount);
  }

  Future<Account> getCurrentUserDatas(User user) async {
    late Account account;
    Map<String, dynamic>? data;

    await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get()
        .then((snapshot) {
      data = snapshot.docs[0].data();
    });

    if (data != null) {
      account = Account.fromJson(data!);
    }

    return account;
  }

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    int selectedIndex = ref.watch(bottomNavigatorIndex);

    return Scaffold(
        bottomNavigationBar: const CustomBottomTabNavigator(),
        body: FutureBuilder(
            future: getCurrentUserDatas(currentUser!),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return _getBody(selectedIndex, snapshot.data);
              }
              return Container();
            }));
  }
}
