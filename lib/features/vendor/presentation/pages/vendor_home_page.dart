import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makan_mate/core/widgets/announcements_banner.dart';
import '../../../vendor/domain/entities/review_entity.dart' as vendor;
import '../pages/menu_management_page.dart';
import '../pages/vendor_reviews_page.dart';
import '../pages/vendor_analytics_page.dart';
import '../pages/promotion_management_page.dart';
import '../../../vendor/presentation/bloc/vendor_bloc.dart';
import '../../../vendor/presentation/bloc/vendor_state.dart';
import '../../../vendor/presentation/bloc/vendor_event.dart';
import '../bloc/vendor_review_bloc.dart';
import '../bloc/vendor_review_event.dart';
import '../bloc/vendor_review_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VendorHomePage extends StatefulWidget {
  const VendorHomePage({super.key});

  @override
  State<VendorHomePage> createState() => _VendorHomePageState();
}

class _VendorHomePageState extends State<VendorHomePage> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  String? businessName;

  @override
  void initState() {
    super.initState();
    _loadVendorName();

    context.read<VendorBloc>().add(LoadMenuEvent());
    final vendorId = FirebaseAuth.instance.currentUser!.uid;
    context.read<VendorReviewBloc>().add(LoadVendorReviews(vendorId));
  }

  Future<void> _loadVendorName() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("vendors")
        .doc(uid)
        .get();

    if (doc.exists) {
      setState(() {
        businessName = doc.data()?["businessName"] ?? "Vendor";
      });
    }
  }

  String getGreeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    String? userRole;
    if (user != null) {
      userRole = 'all'; // adjust when you have role logic
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vendor Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnnouncementsBanner(userRole: userRole),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orange.shade100,
                    ),
                    child: const Icon(Icons.restaurant, color: Colors.orange),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "${getGreeting()}, ",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: businessName ?? "...",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 173, 107, 8),
                                ),
                              ),
                              const TextSpan(
                                text: "!",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 4),
                        const Text(
                          "Manage your restaurant menu and promotions",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Latest Review
            const Text(
              "Latest Review",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildLatestReviewSection(),

            const SizedBox(height: 30),

            // Menu Overview Carousel
            const Text(
              "Menu Overview",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            BlocBuilder<VendorBloc, VendorState>(
              builder: (context, state) {
                if (state is VendorLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is VendorLoaded) {
                  final menuItems = state.menu;

                  if (menuItems.isEmpty) {
                    return const Text("No menu items found.");
                  }

                  return Column(
                    children: [
                      SizedBox(
                        height: 240,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: menuItems.length,
                          onPageChanged: (i) {
                            setState(() => _currentPage = i);
                          },
                          itemBuilder: (context, index) {
                            final m = menuItems[index];

                            return _buildCarouselMenuCard(
                              image: m.imageUrl,
                              title: m.name,
                              description: m.description,
                              price: m.price,
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          menuItems.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? Colors.orange
                                  : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return const Text("Failed to load menus.");
              },
            ),

            const SizedBox(height: 32),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    context,
                    icon: Icons.restaurant_menu,
                    title: "Menu",
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MenuManagementPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    context,
                    icon: Icons.insights,
                    title: "Analytics",
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VendorAnalyticsPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    context,
                    icon: Icons.reviews,
                    title: "Reviews",
                    color: Colors.amber,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VendorReviewsPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    context,
                    icon: Icons.local_offer,
                    title: "Vouchers",
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PromotionManagementPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Latest Review Card (rating removed)
  Widget _buildLatestReviewSection() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VendorReviewsPage()),
        );
      },
      child: BlocBuilder<VendorReviewBloc, VendorReviewState>(
        builder: (context, state) {
          if (state is VendorReviewLoading || state is VendorReviewInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is VendorReviewError) {
            return const Text('Error loading review.');
          }

          final reviews = state is VendorReviewLoaded
              ? state.reviews
              : const <vendor.ReviewEntity>[];

          if (reviews.isEmpty) {
            return const Text('No reviews yet.');
          }

          return _buildReviewCard(reviews.first);
        },
      ),
    );
  }

  Widget _buildReviewCard(vendor.ReviewEntity r) {
    final isReplied = r.vendorReplyText != null;

    return Card(
      elevation: 3,
      color: isReplied ? Colors.white : Colors.orange.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.person, size: 40, color: Colors.orange),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.userName.isNotEmpty ? r.userName : "Customer",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(r.comment, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    "Posted: ${r.createdAt}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),

                  const SizedBox(height: 6),
                  if (!isReplied)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Pending Reply",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Carousel Menu Card
  Widget _buildCarouselMenuCard({
    required String image,
    required String title,
    required String description,
    required double price,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: image.isEmpty
                  ? Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(
                          Icons.restaurant,
                          size: 60,
                          color: Colors.white70,
                        ),
                      ),
                    )
                  : Image.network(image, fit: BoxFit.cover),
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "RM ${price.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Quick Action Buttons
  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
