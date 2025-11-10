import 'package:flutter/material.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';

class LoginpageButton extends StatelessWidget {
  final Function()? onTap;
  final String text;

  const LoginpageButton({
    super.key,
    required this.onTap,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: UIConstants.borderRadiusSm,
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textOnDark,
              fontWeight: FontWeight.bold,
              fontSize: UIConstants.fontSizeLg,
            ),
          ),
        ),
      ),
    );
  }
}
