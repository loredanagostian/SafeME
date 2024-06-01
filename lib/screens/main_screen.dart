import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  Widget _getBody(int index) {
    switch (index) {
      case 0:
        return SafePlacesScreen();
      case 1:
        return HomeScreen();
      case 2:
        return FriendsScreen();
    }
    return HomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    int selectedIndex = ref.watch(bottomNavigatorIndex);

    return Scaffold(
        extendBody: true,
        bottomNavigationBar: const CustomBottomTabNavigator(),
        body: _getBody(selectedIndex));
  }
}
