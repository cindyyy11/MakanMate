import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../widgets/vendor_bottom_nav_bar.dart';
import 'vendor_home_page.dart';
import 'menu_management_page.dart';
import 'vendor_analytics_page.dart';
import 'vendor_reviews_page.dart';
import 'vendor_settings_page.dart';
import '../bloc/vendor_bloc.dart';
import '../bloc/promotion_bloc.dart';
import '../bloc/promotion_event.dart';
import '../bloc/vendor_review_bloc.dart';
import '../bloc/analytics_bloc.dart';

class VendorNavigationWrapper extends StatefulWidget {
  const VendorNavigationWrapper({super.key});

  @override
  State<VendorNavigationWrapper> createState() =>
      _VendorNavigationWrapperState();
}

class _VendorNavigationWrapperState extends State<VendorNavigationWrapper> {
  int _currentIndex = 0;

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
        BlocProvider(
          create: (_) => di.sl<PromotionBloc>()..add(LoadPromotionsEvent()),
        ),
        BlocProvider(create: (_) => di.sl<VendorReviewBloc>()),
        BlocProvider(create: (_) => di.sl<AnalyticsBloc>()),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            VendorHomePage(),
            MenuManagementPage(),
            VendorAnalyticsPage(),
            VendorReviewsPage(),
            VendorSettingsPage(),
          ],
        ),
        bottomNavigationBar: VendorBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onNavItemTapped,
        ),
      ),
    );
  }
}