import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_me/screens/friends_screen.dart';
import 'package:safe_me/screens/home_screen.dart';
import 'package:safe_me/widgets/custom_bottom_tab_navigator.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  Widget _getBody(int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        return const HomeScreen();
      case 2:
        return const FriendsScreen();
    }
    return const HomeScreen();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int selectedIndex = ref.watch(bottomNavigatorIndex);

    return Scaffold(
      bottomNavigationBar: const CustomBottomTabNavigator(),
      body: _getBody(selectedIndex),
    );
  }
}
