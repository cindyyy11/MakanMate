import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';

class MyTextfield extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;

  const MyTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.grey400),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.secondaryLight),
          ),
          fillColor: AppColors.warningLight,
          filled: true,
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.grey600),
        ),
      ),
    );
  }
}
