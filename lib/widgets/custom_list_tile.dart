import 'dart:io';

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
  final bool isAlreadyFriend;
  final void Function() button1Action;
  final void Function()? button2Action;
  final Color buttonColor;
  final void Function(DismissDirection)? onDismiss;
  const CustomListTile({
    super.key,
    required this.photoUrl,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.button1Action,
    this.onDismiss,
    this.isRequest = false,
    this.isAlreadyFriend = false,
    this.buttonColor = AppColors.mainBlue,
    this.button2Action,
  });

  @override
  State<CustomListTile> createState() => _CustomListTileState();
}

class _CustomListTileState extends State<CustomListTile> {
  Widget _getListTile() {
    return ListTile(
      title: Text(widget.title),
      titleTextStyle: widget.isAlreadyFriend
          ? AppStyles.notificationTitleStyle
              .copyWith(color: AppColors.mediumGray)
          : AppStyles.notificationTitleStyle
              .copyWith(color: AppColors.mainDarkGray),
      subtitle: Text(widget.subtitle),
      subtitleTextStyle: widget.isAlreadyFriend
          ? AppStyles.hintComponentStyle.copyWith(color: AppColors.mediumGray)
          : AppStyles.hintComponentStyle,
      leading: SizedBox(
        height: 60,
        width: 60,
        child: Padding(
            padding: const EdgeInsets.only(right: AppSizes.smallDistance),
            child: CircleAvatar(
                backgroundImage: FileImage(File(widget.photoUrl)))),
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
                  onPressed: widget.button1Action,
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
                  onPressed: widget.button2Action,
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              )
            ])
          : GestureDetector(
              onTap: widget.isAlreadyFriend ? null : widget.button1Action,
              child: Container(
                height: 35,
                width: 70,
                decoration: BoxDecoration(
                    color: widget.buttonColor,
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
        : widget.onDismiss != null
            ? Dismissible(
                key: Key(widget.photoUrl),
                onDismissed: widget.onDismiss,
                background: Container(
                  decoration: BoxDecoration(
                    color: AppColors.mainRed,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(AppSizes.borders),
                      bottomRight: Radius.circular(AppSizes.borders),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(right: AppSizes.mediumDistance),
                      child: Icon(
                        Icons.delete_outline,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                child: _getListTile())
            : _getListTile();
  }
}
