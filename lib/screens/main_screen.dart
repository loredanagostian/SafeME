import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_me/models/account.dart';
import 'package:safe_me/screens/friends_screen.dart';
import 'package:safe_me/screens/home_screen.dart';
import 'package:safe_me/screens/safe_places_screen.dart';
import 'package:safe_me/widgets/custom_bottom_tab_navigator.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  Widget _getBody(int index, Account userAccount) {
    switch (index) {
      case 0:
        return SafePlacesScreen(userAccount: userAccount);
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
  Widget build(BuildContext context) {
    int selectedIndex = ref.watch(bottomNavigatorIndex);
    User? currentUser = FirebaseAuth.instance.currentUser;

    // Listen to the current user's document
    Stream<DocumentSnapshot<Map<String, dynamic>>> userStream =
        FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .snapshots();

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const CustomBottomTabNavigator(),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: userStream,
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData && snapshot.data!.data() != null) {
              Account userAccount = Account.fromJson(snapshot.data!.data()!);
              return _getBody(selectedIndex, userAccount);
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
