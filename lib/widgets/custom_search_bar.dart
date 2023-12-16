import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/styles.dart';

class CustomSearchBar extends StatelessWidget {
  final void Function(String) onChanged;
  final TextEditingController searchController;
  const CustomSearchBar(
      {super.key, required this.onChanged, required this.searchController});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: searchController,
      onChanged: onChanged,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.fromLTRB(
          AppSizes.mediumDistance,
          AppSizes.smallDistance,
          AppSizes.mediumDistance,
          AppSizes.smallDistance,
        ),
        hintText: "Search",
        hintStyle: AppStyles.bodyStyle,
        fillColor: AppColors.componentGray,
        filled: true,
        suffixIcon: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {},
        ),
        suffixIconColor: AppColors.mainDarkGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borders),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.componentGray),
          borderRadius: BorderRadius.circular(AppSizes.borders),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.componentGray),
          borderRadius: BorderRadius.circular(AppSizes.borders),
        ),
      ),
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.text,
    );
  }
}
