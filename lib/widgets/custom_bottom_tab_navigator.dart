import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';

final bottomNavigatorIndex = StateProvider<int>((ref) => 1);

class CustomBottomTabNavigator extends ConsumerStatefulWidget {
  const CustomBottomTabNavigator({super.key});

  @override
  ConsumerState<CustomBottomTabNavigator> createState() =>
      _CustomBottomTabNavigatorState();
}

class _CustomBottomTabNavigatorState
    extends ConsumerState<CustomBottomTabNavigator> {
  void _onItemTapped(int index) {
    ref.read(bottomNavigatorIndex.notifier).update((state) => index);
  }

  @override
  Widget build(BuildContext context) {
    int selectedIndex = ref.watch(bottomNavigatorIndex);

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
            currentIndex: selectedIndex,
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
