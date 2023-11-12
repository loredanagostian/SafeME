import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/widgets/custom_bottom_tab_navigator.dart';
import 'package:safe_me/widgets/custom_button.dart';
import 'package:safe_me/widgets/custom_textfield.dart';
import 'package:safe_me/widgets/notification_tile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appTitle,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: MyHomePage(title: AppStrings.appTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      extendBody: true,
      bottomNavigationBar: CustomBottomTabNavigator(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        title: Text(
          widget.title,
          style: AppStyles.titleStyle,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
                style: AppStyles.sectionTitleStyle,
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              CustomTextField(
                controller: _emailController,
                hintText: AppStrings.email,
              ),
              SizedBox(height: AppSizes.mediumDistance),
              CustomTextField(
                controller: _passwordController,
                hintText: AppStrings.password,
                isPassword: true,
              ),
              SizedBox(height: AppSizes.mediumDistance),
              CustomButton(
                buttonColor: AppColors.mainBlue,
                buttonText: AppStrings.login,
                onTap: () {},
                isGoogle: true,
              ),
              SizedBox(height: AppSizes.mediumDistance),
              NotificationTile(
                  notificationTitle: "notificationTitle",
                  notificationBody: "notificationBody"),
              SizedBox(height: AppSizes.mediumDistance),
              NotificationTile(
                notificationTitle: "notificationTitle",
                notificationBody: "notificationBody",
                isRead: true,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
