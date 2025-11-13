import 'package:flutter/material.dart';

class LogoTheme extends StatelessWidget {
  final double width;
  final double height;
  final double left;
  final double top;
  final double borderRadius;
  final String imagePath;

  const LogoTheme({
    super.key,
    this.width = 131,
    this.height = 87,
    this.left = 11,
    this.top = 20,
    this.borderRadius = 30,
    this.imagePath = 'assets/images/logos/makanmate_logo.jpg',
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          imagePath,
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
