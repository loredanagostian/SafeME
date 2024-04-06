import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/widgets/custom_button.dart';

class CustomPlaceBottomModal extends StatelessWidget {
  final String placeName;
  final String kmAway;
  final List<String> categories;
  final void Function() onTap;
  const CustomPlaceBottomModal({
    super.key,
    required this.placeName,
    required this.kmAway,
    required this.categories,
    required this.onTap,
  });

  Widget _returnTagContainer(String text, Color containerColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 5, bottom: 5),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(AppSizes.borders),
        ),
        child: Text(
          text,
          style: AppStyles.textComponentStyle.copyWith(color: AppColors.white),
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    categories.removeWhere((item) => item.contains("_"));

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.5,
        child: Stack(children: [
          Container(
            padding: const EdgeInsets.only(
              top: AppSizes.bigDistance,
              bottom: AppSizes.bigDistance,
              left: AppSizes.mediumDistance,
              right: AppSizes.mediumDistance,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  placeName,
                  style: AppStyles.titleStyle,
                ),
                Text(
                  AppStrings.openNow,
                  style: AppStyles.textComponentStyle
                      .copyWith(color: AppColors.lightGreen),
                ),
                const SizedBox(height: 5),
                _returnTagContainer(
                    "$kmAway ${AppStrings.xKmAway}", AppColors.mainRed),
                const SizedBox(height: AppSizes.mediumDistance),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.categories,
                      style: AppStyles.hintComponentStyle
                          .copyWith(color: AppColors.mainDarkGray),
                    ),
                    const SizedBox(width: AppSizes.smallDistance),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            categories.length >= 1
                                ? _returnTagContainer(
                                    categories[0], AppColors.mainBlue)
                                : Container(),
                            categories.length >= 2
                                ? _returnTagContainer(
                                    categories[1], AppColors.mainBlue)
                                : Container()
                          ],
                        ),
                        Row(
                          children: [
                            categories.length >= 3
                                ? _returnTagContainer(
                                    categories[2], AppColors.mainBlue)
                                : Container(),
                            categories.length >= 4
                                ? _returnTagContainer(
                                    categories[3], AppColors.mainBlue)
                                : Container()
                          ],
                        ),
                        Row(
                          children: [
                            categories.length >= 5
                                ? _returnTagContainer(
                                    categories[4], AppColors.mainBlue)
                                : Container(),
                            categories.length >= 6
                                ? _returnTagContainer(
                                    categories[5], AppColors.mainBlue)
                                : Container()
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          Positioned.fill(
            bottom: AppSizes.smallDistance,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.mediumDistance),
                child: CustomButton(
                    buttonColor: AppColors.mainBlue,
                    buttonText: AppStrings.startNavigation,
                    onTap: onTap),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
