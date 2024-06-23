import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/managers/notification_manager.dart';
import 'package:safe_me/screens/onboarding_screens/login_screen.dart';
import 'package:safe_me/screens/main_screens/main_screen.dart';
import 'package:safe_me/screens/onboarding_screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool hasOpenedAppForFirstTime = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationManager.initNotifications();
  await NotificationManager.getToken();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  hasOpenedAppForFirstTime =
      await prefs.getBool(AppStrings.hasOpenedAppForFirstTime) ?? true;
  await prefs.setBool(AppStrings.hasOpenedAppForFirstTime, true);

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appTitle,
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: false,
        canvasColor: AppColors.white,
      ),
      home: FirebaseAuth.instance.currentUser != null &&
              FirebaseAuth.instance.currentUser!.phoneNumber != null
          ? const MainScreen()
          : hasOpenedAppForFirstTime
              ? const OnboardingScreen()
              : const LoginScreen(),
    );
  }
}
