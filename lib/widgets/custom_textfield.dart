import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/styles.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final bool isEmail;
  final bool isEditProfile;
  final bool isEditMessage;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.isEmail = false,
    this.isEditProfile = false,
    this.isEditMessage = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscureText = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      maxLines: widget.isEditMessage ? 10 : 1,
      minLines: widget.isEditMessage ? 10 : 1,
      style: AppStyles.textComponentStyle,
      obscureText: widget.isPassword ? _isObscureText : false,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.fromLTRB(
          AppSizes.mediumDistance,
          AppSizes.smallDistance,
          AppSizes.smallDistance,
          AppSizes.smallDistance,
        ),
        errorStyle: AppStyles.validatorMessagesStyle,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borders),
          borderSide: const BorderSide(
            color: AppColors.componentGray,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borders),
          borderSide: const BorderSide(
            color: AppColors.componentGray,
          ),
        ),
        filled: true,
        hintStyle: AppStyles.hintComponentStyle,
        hintText: widget.hintText,
        fillColor: AppColors.componentGray,
        suffixIcon: Visibility(
          visible: widget.isPassword,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isObscureText = !_isObscureText;
              });
            },
            child: Icon(
              _isObscureText ? Icons.visibility : Icons.visibility_off,
              color: AppColors.darkGray,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
