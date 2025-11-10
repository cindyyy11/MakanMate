import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/vendor_bottom_nav_bar.dart';
import 'vendor_home_page.dart';
import 'menu_management_page.dart';
import 'vendor_reviews_page.dart';
import 'promotion_management_page.dart';
import 'vendor_settings_page.dart';
import '../bloc/vendor_bloc.dart';
import '../bloc/promotion_bloc.dart';

class VendorNavigationWrapper extends StatefulWidget {
  const VendorNavigationWrapper({super.key});

  @override
  State<VendorNavigationWrapper> createState() => _VendorNavigationWrapperState();
}

class _VendorNavigationWrapperState extends State<VendorNavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const VendorHomePage(),
    const MenuManagementPage(),
    const VendorReviewsPage(),
    const PromotionManagementPage(),
    const VendorSettingsPage(),
  ];

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<VendorBloc>()),
        BlocProvider.value(value: context.read<PromotionBloc>()),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: VendorBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onNavItemTapped,
        ),
      ),
    );
  }
}

