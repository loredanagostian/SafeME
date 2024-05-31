import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/strings.dart';
import 'package:safe_me/constants/styles.dart';
import 'package:safe_me/managers/user_info_provider.dart';
import 'package:safe_me/models/user_static_data.dart';
import 'package:safe_me/widgets/custom_history_tile.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late UserStaticData _userData;

  @override
  Widget build(BuildContext context) {
    _userData = ref.watch(userStaticDataProvider);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: const Text(
            AppStrings.history,
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
        body: Padding(
          padding: const EdgeInsets.all(AppSizes.smallDistance),
          child: _userData.history.isNotEmpty
              ? ListView.builder(
                  itemCount: _userData.history.length,
                  itemBuilder: (context, index) {
                    final item = _userData.history[index];
                    return CustomHistoryTile(item: item);
                  },
                  shrinkWrap: true,
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_toggle_off,
                        size: 200,
                        color: AppColors.darkGray,
                      ),
                      SizedBox(height: AppSizes.bigDistance),
                      SizedBox(
                        width: 200,
                        child: Text(
                          AppStrings.noHistoryToDisplay,
                          style: AppStyles.titleStyle.copyWith(
                            color: AppColors.darkGray,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
        ));
  }
}
