import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/managers/firebase_manager.dart';
import 'package:safe_me/managers/user_info_provider.dart';
import 'package:safe_me/models/user_static_data.dart';
import 'package:safe_me/screens/more_screen.dart';
import 'package:safe_me/widgets/custom_button.dart';
import 'package:safe_me/widgets/custom_textfield.dart';

class DefaultTrackingSmsScreen extends ConsumerStatefulWidget {
  const DefaultTrackingSmsScreen({super.key});

  @override
  ConsumerState<DefaultTrackingSmsScreen> createState() =>
      _DefaultTrackingSmsScreenState();
}

class _DefaultTrackingSmsScreenState
    extends ConsumerState<DefaultTrackingSmsScreen> {
  late TextEditingController trackingSMSController;

  @override
  void initState() {
    super.initState();
    trackingSMSController = TextEditingController(
        text: ref.read(userStaticDataProvider).trackingSMS);

    trackingSMSController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    trackingSMSController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          AppStrings.trackingSMS,
          style: AppStyles.titleStyle,
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.mainDarkGray,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.smallDistance),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  height: 86,
                  width: 230,
                  padding: const EdgeInsets.all(AppSizes.mediumDistance),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppSizes.borders),
                      topRight: Radius.circular(AppSizes.borders),
                      bottomLeft: Radius.circular(AppSizes.borders),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      trackingSMSController.text,
                      style: AppStyles.hintComponentStyle.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.buttonHeight),
              const Text(
                AppStrings.enterMessageBelow,
                style: AppStyles.sectionTitleStyle,
              ),
              const SizedBox(height: AppSizes.smallDistance),
              CustomTextField(
                controller: trackingSMSController,
                isEditMessage: true,
                isDone: true,
              ),
              const SizedBox(height: AppSizes.titleFieldDistance),
              CustomButton(
                  buttonColor: AppColors.mainBlue,
                  buttonText: AppStrings.saveChanges,
                  onTap: () {
                    UserStaticData _userStaticProvider =
                        ref.watch(userStaticDataProvider);
                    _userStaticProvider.trackingSMS =
                        trackingSMSController.text;
                    ref
                        .read(userStaticDataProvider.notifier)
                        .updateUserInfo(_userStaticProvider);
                    FirebaseManager.changeTrackingSMS(
                            trackingSMSController.text)
                        .then((value) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MoreScreen()));
                    });
                  })
            ],
          ),
        ),
      ),
    );
  }
}
