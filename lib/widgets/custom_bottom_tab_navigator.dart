import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/screens/friends_screen.dart';
import 'package:safe_me/screens/home_screen.dart';

class CustomBottomTabNavigator extends StatefulWidget {
  const CustomBottomTabNavigator({super.key});

  @override
  State<CustomBottomTabNavigator> createState() =>
      _CustomBottomTabNavigatorState();
}

class _CustomBottomTabNavigatorState extends State<CustomBottomTabNavigator> {
  @override
  Widget build(BuildContext context) {
    int _selectedIndex = 1;

    Future<void> _onItemTapped(int index) async {
      setState(() {
        _selectedIndex = index;
      });

      switch (index) {
        case 0:
          // await FirebaseFirestore.instance
          //     .collection("users")
          //     .get()
          //     .then((event) {
          //   for (var doc in event.docs) {
          //     print("${doc.id} => ${doc.data()}");
          //   }
          // });
          break;
        case 1:
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomeScreen()));
          break;
        case 2:
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const FriendsScreen()));
          break;
      }
    }

    return Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(30), topLeft: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 228, 228, 228),
              spreadRadius: 0,
              blurRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppSizes.borders),
            topRight: Radius.circular(AppSizes.borders),
          ),
          child: BottomNavigationBar(
            backgroundColor: AppColors.white,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore),
                label: AppStrings.map,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: AppStrings.home,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.group_outlined),
                activeIcon: Icon(Icons.group),
                label: AppStrings.friends,
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: AppColors.mainDarkGray,
            selectedLabelStyle: AppStyles.bottomItemStyle
                .copyWith(color: AppColors.mainDarkGray),
            unselectedItemColor: AppColors.mediumGray,
            unselectedLabelStyle: AppStyles.bottomItemStyle,
            iconSize: 28,
            onTap: _onItemTapped,
          ),
        ));
  }
}
