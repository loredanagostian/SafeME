import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/paths.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:safe_me/screens/onboarding_screens/login_screen.dart';
import 'package:safe_me/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isOnboarding;
  const OnboardingScreen({super.key, this.isOnboarding = true});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final List<Widget> items = [
    Image.asset(
      AppPaths.onboardingSOS,
      fit: BoxFit.contain,
    ),
    Image.asset(
      AppPaths.onboardingTrack,
      fit: BoxFit.contain,
    ),
    Image.asset(
      AppPaths.onboardingNavigate,
      fit: BoxFit.contain,
    ),
    Image.asset(
      AppPaths.onboardingChat,
      fit: BoxFit.contain,
    )
  ];
  final List<String> itemsStrings = [
    AppStrings.onboardingSOS,
    AppStrings.onboardingTrack,
    AppStrings.onboardingNavigate,
    AppStrings.onboardingChat
  ];
  final CarouselController carouselController = CarouselController();

  int currentIndex = 0;

  Widget buildStyledText(String text) {
    return Text(
      text,
      style: AppStyles.titleStyle.copyWith(color: AppColors.mainDarkGray),
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          AppStrings.appTitle,
          style: AppStyles.titleStyle,
        ),
        titleSpacing: widget.isOnboarding ? AppSizes.smallDistance : -40,
        actions: [
          Visibility(
            visible: currentIndex != 3,
            child: TextButton(
                onPressed: () => carouselController.animateToPage(3),
                child: Text(
                  AppStrings.skip,
                  style: AppStyles.sectionTitleStyle.copyWith(fontSize: 20),
                )),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CarouselSlider(
            carouselController: carouselController,
            options: CarouselOptions(
              autoPlay: false,
              enlargeCenterPage: false,
              enableInfiniteScroll: false,
              viewportFraction: 1.0,
              aspectRatio: 1 / 1,
              onPageChanged: (index, reason) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
            items: items,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSizes.mediumDistance),
            child: IndexedStack(
              index: currentIndex,
              alignment: AlignmentDirectional.center,
              children: itemsStrings
                  .map((element) => buildStyledText(element))
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSizes.buttonHeight),
          DotsIndicator(
            dotsCount: items.length,
            position: currentIndex,
            decorator: DotsDecorator(
              activeColor: AppColors.lightBlue,
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.smallDistance),
              ),
              activeSize:
                  const Size(AppSizes.marginSize, AppSizes.smallDistance),
              color: AppColors.lightGray,
              spacing: EdgeInsets.all(3),
            ),
          ),
          Visibility(
              visible: currentIndex == 3,
              child: Column(
                children: [
                  const SizedBox(height: AppSizes.buttonHeight),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: AppSizes.smallDistance,
                        right: AppSizes.smallDistance,
                        bottom: AppSizes.mediumDistance),
                    child: CustomButton(
                        buttonColor: AppColors.mainBlue,
                        buttonText: widget.isOnboarding
                            ? AppStrings.begin
                            : AppStrings.finish,
                        onTap: () async {
                          if (widget.isOnboarding) {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.setBool(
                                AppStrings.hasOpenedAppForFirstTime, false);
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => LoginScreen()));
                          } else {
                            Navigator.pop(context);
                          }
                        }),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
