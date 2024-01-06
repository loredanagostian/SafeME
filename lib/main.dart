import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/managers/authentication_manager.dart';
import 'package:safe_me/managers/hive_manager.dart';
import 'package:safe_me/managers/notification_manager.dart';
import 'package:safe_me/screens/login_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:safe_me/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  // await HiveManager.instance.initHiveManager();
  SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
  await NotificationManager.initNotifications();
  await NotificationManager.getToken();

  runApp(ProviderScope(child: MyApp(sharedPrefs: sharedPrefs)));
}

class MyApp extends StatelessWidget {
  SharedPreferences sharedPrefs;

  MyApp({super.key, required this.sharedPrefs});

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
      home: AuthenticationManager().isLoggedIn(sharedPrefs)
          ? const MainScreen()
          : const LoginScreen(),
    );
  }
}
