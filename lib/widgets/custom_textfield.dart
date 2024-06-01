import 'package:flutter/material.dart';
import 'package:safe_me/constants/colors.dart';
import 'package:safe_me/constants/sizes.dart';
import 'package:safe_me/constants/styles.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final bool isPassword;
  final bool isEmail;
  final bool isEditMessage;
  final bool isPhoneNumber;
  final bool isDone;

  const CustomTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.isPassword = false,
    this.isEmail = false,
    this.isEditMessage = false,
    this.isPhoneNumber = false,
    this.isDone = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscureText = true;

  TextInputType _getKeyboardType() {
    return widget.isEmail
        ? TextInputType.emailAddress
        : widget.isPhoneNumber
            ? TextInputType.number
            : TextInputType.text;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: _getKeyboardType(),
      textInputAction:
          widget.isDone ? TextInputAction.done : TextInputAction.next,
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
              _isObscureText ? Icons.visibility_off : Icons.visibility,
              color: AppColors.darkGray,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
