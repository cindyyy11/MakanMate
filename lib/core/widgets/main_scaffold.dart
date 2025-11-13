import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/core/di/injection_container.dart' as di;
import 'package:makan_mate/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_event.dart';
import 'package:makan_mate/features/admin/presentation/pages/admin_main_page.dart';
import 'package:makan_mate/features/auth/domain/entities/user_entity.dart';
import 'package:makan_mate/features/favorite/presentation/pages/favorite_page.dart';
import 'package:makan_mate/features/home/presentation/pages/home_page.dart';
import 'package:makan_mate/features/vendor/presentation/pages/menu_management_page.dart';
import 'package:makan_mate/features/vendor/presentation/pages/promotion_management_page.dart';
import 'package:makan_mate/features/vendor/presentation/pages/vendor_home_page.dart';
import 'package:makan_mate/features/vendor/presentation/pages/vendor_reviews_page.dart';
import 'package:makan_mate/features/vendor/presentation/pages/vendor_settings_page.dart';

class MainScaffold extends StatefulWidget {
  final UserEntity user;
  const MainScaffold({Key? key, required this.user}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  late final List<Widget> _pages;
  late final List<BottomNavigationBarItem> _items;

  @override
  void initState() {
    super.initState();
    _pages = _buildPagesForRole(widget.user.role);
    _items = _buildNavBarItemsForRole(widget.user.role);
  }

  // Here is where you set the pages that the user can navigate through
  List<Widget> _buildPagesForRole(String role) {
    switch (role) {
      case 'admin':
        return [
          BlocProvider(
            create: (_) => di.sl<AdminBloc>()..add(const LoadPlatformMetrics()),
            child: const AdminMainPage(),
          ),
        ];
      case 'vendor':
        return [
          const VendorHomePage(),
          const MenuManagementPage(),
          const PromotionManagementPage(),
          const VendorReviewsPage(),
          const VendorSettingsPage(),
        ];
      case 'user':
      default:
        return [const HomeScreen(), const FavoritePage()];
    }
  }

  //Here is where you add Navigation Bar Icons (MUST BE IN ORDER WITH THE Widget list above)
  List<BottomNavigationBarItem> _buildNavBarItemsForRole(String role) {
    switch (role) {
      case 'vendor':
        return [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'Promotions',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Reviews'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'App Settings',
          ),
        ];
      case 'user':
      default:
        return [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: widget.user.role == 'admin'
          ? null // Admin dashboard doesn't need bottom nav
          : BottomNavigationBar(
              selectedItemColor: Colors.orange,
              unselectedItemColor: Colors.grey,
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              items: _items,
            ),
    );
  }
}

