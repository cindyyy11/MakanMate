import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/core/di/injection_container.dart' as di;
import 'package:makan_mate/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:makan_mate/features/admin/presentation/bloc/admin_event.dart';
import 'package:makan_mate/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:makan_mate/features/auth/domain/entities/user_entity.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_event.dart';
import 'package:makan_mate/features/favorite/presentation/pages/favorite_page.dart';
import 'package:makan_mate/features/home/presentation/pages/home_page.dart';
import 'package:makan_mate/features/home/presentation/pages/spin_wheel_page.dart';
import 'package:makan_mate/features/vendor/presentation/pages/menu_management_page.dart';
import 'package:makan_mate/features/vendor/presentation/pages/promotion_management_page.dart';
import 'package:makan_mate/features/vendor/presentation/pages/vendor_home_page.dart';
import 'package:makan_mate/features/vendor/presentation/pages/vendor_onboarding_page.dart';
import 'package:makan_mate/features/vendor/presentation/pages/vendor_reviews_page.dart';
import 'package:makan_mate/features/vendor/presentation/pages/vendor_settings_page.dart';
import 'package:makan_mate/features/vendor/presentation/pages/vendor_analytics_page.dart';
import 'package:makan_mate/features/vendor/presentation/bloc/analytics_bloc.dart';

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
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _vendorStatusStream;

  @override
  void initState() {
    super.initState();
    _pages = _buildPagesForRole(widget.user.role);
    _items = _buildNavBarItemsForRole(widget.user.role);
    if (widget.user.role == 'vendor') {
      _vendorStatusStream = _buildVendorStatusStream();
    }
  }

  // Here is where you set the pages that the user can navigate through
  List<Widget> _buildPagesForRole(String role) {
    switch (role) {
      case 'admin':
        return [
          BlocProvider(
            create: (_) => di.sl<AdminBloc>()..add(const LoadPlatformMetrics()),
            child: const AdminDashboardPage(),
          ),
        ];
      case 'vendor':
        return [
          const VendorHomePage(),
          const MenuManagementPage(),
          const PromotionManagementPage(),
          const VendorAnalyticsPage(),
          const VendorReviewsPage(),
          const VendorSettingsPage(),
        ];
      case 'user':
      default:
        return [const HomeScreen(), const FavoritePage(), const SpinWheelPage()];
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
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Reviews',
          ),
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
          BottomNavigationBarItem(icon: Icon(Icons.casino), label: 'Spin Wheel'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user.role == 'vendor') {
      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _vendorStatusStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return _buildVendorGateView(
              title: 'Unable to load vendor status',
              message: 'Please check your connection and try again.',
              primaryLabel: 'Retry',
              primaryAction: _refreshVendorStatusStream,
            );
          }

          final doc = snapshot.data;
          if (doc == null || !doc.exists) {
            return _buildVendorGateView(
              title: 'Complete Your Vendor Profile',
              message:
                  'Share your business information so we can review your application.',
              primaryLabel: 'Start onboarding',
              primaryAction: _openVendorOnboarding,
            );
          }

          final status = _parseVendorStatus(doc.data());
          switch (status) {
            case 'approved':
              return _buildAppShell();
            case 'rejected':
              return _buildVendorGateView(
                title: 'Application Rejected',
                message:
                    'Update your details and resubmit for admin review.',
                primaryLabel: 'Update profile',
                primaryAction: _openVendorOnboarding,
              );
            case 'suspended':
              return _buildVendorGateView(
                title: 'Vendor Account Suspended',
                message:
                    'Contact support or update your information to restore access.',
                primaryLabel: 'Contact support',
                primaryAction: _openSupportEmail,
              );
            default:
              return _buildVendorGateView(
                title: 'Application Pending',
                message:
                    'Your submission is under review. We will notify you once it is approved.',
                primaryLabel: 'View submission',
                primaryAction: _openVendorOnboarding,
              );
          }
        },
      );
    }

    return _buildAppShell();
  }

  Widget _buildAppShell() {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: widget.user.role == 'admin'
          ? null
          : BottomNavigationBar(
              selectedItemColor: Colors.orange,
              unselectedItemColor: Colors.grey,
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              items: _items,
            ),
    );
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _buildVendorStatusStream() {
    return FirebaseFirestore.instance
        .collection('vendors')
        .doc(widget.user.id)
        .snapshots();
  }

  void _refreshVendorStatusStream() {
    setState(() {
      _vendorStatusStream = _buildVendorStatusStream();
    });
  }

  String _parseVendorStatus(Map<String, dynamic>? data) {
    final raw = (data?['approvalStatus'] ?? data?['status'] ?? 'pending')
        .toString()
        .toLowerCase();
    return raw;
  }

  void _openVendorOnboarding() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const VendorOnboardingPage()),
    );
  }

  void _openSupportEmail() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please contact support@makanmate.com for assistance.'),
      ),
    );
  }

  Widget _buildVendorGateView({
    required String title,
    required String message,
    required String primaryLabel,
    required VoidCallback primaryAction,
  }) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_bottom,
                  size: 56,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: primaryAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    primaryLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () =>
                    context.read<AuthBloc>().add(SignOutRequested()),
                child: const Text(
                  'Sign out',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
