import 'package:flutter/material.dart';

enum VendorNavItem {
  home('Home', 'assets/icons/icon_home.png'),
  menu('Menu', 'assets/icons/icon_menu.png'),
  analytics('Analytics', 'assets/icons/icon_voucher.png'),
  review('Review', 'assets/icons/icon_review.png'),
  settings('Settings', 'assets/icons/icon_settings.png');

  final String label;
  final String iconPath;

  const VendorNavItem(this.label, this.iconPath);

  int get navIndex {
    switch (this) {
      case VendorNavItem.home:
        return 0;
      case VendorNavItem.menu:
        return 1;
      case VendorNavItem.analytics:
        return 2;
      case VendorNavItem.review:
        return 3;
      case VendorNavItem.settings:
        return 4;
    }
  }
}

class VendorBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const VendorBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange[700], // Orange-brown background
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: VendorNavItem.values.map((item) {
              final isSelected = currentIndex == item.navIndex;
              return Expanded(
                  child: GestureDetector(
                  onTap: () => onTap(item.navIndex),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon with selected background
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.amber[200] // Light yellow background when selected
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            item.iconPath,
                            width: 24,
                            height: 24,
                            color: Colors.black, // Black outline icons
                            colorBlendMode: BlendMode.srcATop,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Label (optional, can be hidden if you want icons only)
                        // Text(
                        //   item.label,
                        //   style: TextStyle(
                        //     fontSize: 10,
                        //     color: isSelected ? Colors.white : Colors.black87,
                        //     fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

