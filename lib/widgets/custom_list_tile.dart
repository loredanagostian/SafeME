import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/styles.dart';

class CustomListTile extends StatefulWidget {
  final String photoUrl;
  final String title;
  final String subtitle;
  final String buttonText;
  final bool isRequest;
  const CustomListTile({
    super.key,
    required this.photoUrl,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    this.isRequest = false,
  });

  @override
  State<CustomListTile> createState() => _CustomListTileState();
}

class _CustomListTileState extends State<CustomListTile> {
  Widget _getListTile() {
    return ListTile(
      title: Text(widget.title),
      titleTextStyle: AppStyles.notificationTitleStyle
          .copyWith(color: AppColors.mainDarkGray),
      subtitle: Text(widget.subtitle),
      subtitleTextStyle: AppStyles.hintComponentStyle,
      leading: SizedBox(
        height: 60,
        width: 60,
        child: Padding(
          padding: const EdgeInsets.only(right: AppSizes.smallDistance),
          child: Container(
              decoration: const BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage(
                'lib/assets/images/eu.jpg',
              ),
              fit: BoxFit.cover,
            ),
          )),
        ),
      ),
      trailing: widget.isRequest
          ? Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                height: 35,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.mainGreen,
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.done,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ),
              Container(
                height: 35,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.mainRed,
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              )
            ])
          : GestureDetector(
              onTap: () {},
              child: Container(
                height: 35,
                width: 70,
                decoration: BoxDecoration(
                    color: AppColors.mainBlue,
                    borderRadius: BorderRadius.circular(
                      AppSizes.borders,
                    )),
                child: Center(
                  child: Text(
                    widget.buttonText,
                    style: AppStyles.notificationTitleStyle
                        .copyWith(color: AppColors.white),
                  ),
                ),
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.isRequest
        ? _getListTile()
        : Dismissible(
            key: Key(widget.photoUrl),
            onDismissed: (direction) {
              // Remove the item from the data source.
              setState(() {});
            },
            background: Container(color: AppColors.mainRed),
            child: _getListTile());
  }
}
