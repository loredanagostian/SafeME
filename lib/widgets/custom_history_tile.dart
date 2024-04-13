import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/models/history_event.dart';

class CustomHistoryTile extends StatelessWidget {
  final HistoryEvent item;

  const CustomHistoryTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
          '${item.startDate.day}/${item.startDate.month}/${item.startDate.year}'),
      titleTextStyle: AppStyles.notificationTitleStyle
          .copyWith(color: AppColors.mainDarkGray),
      // subtitle: Text('${item.duration} min'),
      // subtitleTextStyle: AppStyles.hintComponentStyle,
      leading: SizedBox(
        height: 45,
        width: 45,
        child: Padding(
            padding: const EdgeInsets.only(right: AppSizes.smallDistance),
            child: Icon(
              item.isTrackingEvent
                  ? Icons.share_location_outlined
                  : Icons.explore_outlined,
              color: AppColors.mainDarkGray,
              size: 50,
            )),
      ),
    );
  }
}
