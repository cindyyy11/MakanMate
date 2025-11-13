import 'package:flutter/material.dart';

class Searchbar extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onSubmitted;
  final VoidCallback? onFilterPressed;
  final String hintText;
  final Color backgroundColor;
  final Color iconColor;
  final double borderRadius;

  const Searchbar({
    super.key,
    this.controller,
    this.onSubmitted,
    this.onFilterPressed,
    this.hintText = 'Search for food, restaurants...',
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.orange,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search bar container
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: TextField(
              controller: controller,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: Icon(Icons.search, color: iconColor),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
