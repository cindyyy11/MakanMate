import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';
import 'package:makan_mate/features/home/presentation/bloc/home_bloc.dart';
import 'package:makan_mate/features/home/presentation/bloc/home_state.dart';

class NearbyNotificationsPage extends StatefulWidget {
  const NearbyNotificationsPage({super.key});

  @override
  State<NearbyNotificationsPage> createState() =>
      _NearbyNotificationsPageState();
}

class _NearbyNotificationsPageState extends State<NearbyNotificationsPage>
    with SingleTickerProviderStateMixin {
  bool alertsEnabled = false;
  SharedPreferences? prefs;

  Position? userPos;
  List<RestaurantEntity> nearbyRestaurants = [];

  Timer? locationTimer;

  StreamSubscription? adminPostSubscription;
  DateTime? lastPostTime;

  List<Map<String, dynamic>> adminPosts = [];

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initNotificationPlugin();
    _loadSettings();
  }

  @override
  void dispose() {
    locationTimer?.cancel();
    adminPostSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initNotificationPlugin() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _notifications.initialize(initSettings);
  }

  Future<void> _loadSettings() async {
    prefs = await SharedPreferences.getInstance();
    alertsEnabled = prefs!.getBool("nearby_alerts") ?? false;

    if (alertsEnabled) {
      _startMonitoringNearby();
      _listenToAdminPosts();
    }

    if (mounted) setState(() {});
  }

  Future<void> _toggleAlerts(bool value) async {
    alertsEnabled = value;
    await prefs!.setBool("nearby_alerts", value);

    if (value) {
      _startMonitoringNearby();
      _listenToAdminPosts();
    } else {
      locationTimer?.cancel();
      adminPostSubscription?.cancel();
    }

    if (mounted) setState(() {});
  }

  void _startMonitoringNearby() {
    locationTimer?.cancel();
    locationTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (alertsEnabled) _checkNearbyRestaurants();
    });
  }

  Future<void> _checkNearbyRestaurants() async {
    try {
      userPos = await Geolocator.getCurrentPosition();

      final state = context.read<HomeBloc>().state;
      if (state is! HomeLoaded) return;

      final all = state.recommendations;
      const radiusKm = 2.0;

      final filtered = all.where((r) {
        final v = r.vendor;

        if (v.latitude == null || v.longitude == null) return false;

        final dist = Geolocator.distanceBetween(
          userPos!.latitude,
          userPos!.longitude,
          v.latitude!,
          v.longitude!,
        );

        return dist / 1000 <= radiusKm;
      }).toList();

      if (filtered.isNotEmpty) {
        _showNotification(
          "You're near ${filtered.first.vendor.businessName}",
          "Tap to view delicious options nearby!",
        );
      }

      if (mounted) {
        setState(() => nearbyRestaurants = filtered);
      }
    } catch (e) {
      print("Nearby check error → $e");
    }
  }

  void _listenToAdminPosts() {
    adminPostSubscription?.cancel();

    adminPostSubscription = FirebaseFirestore.instance
        .collection("announcement")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isEmpty) {
        if (mounted) {
          setState(() => adminPosts = []);
        }
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      Map<String, bool> readMap = {};

      if (user != null) {
        final readSnap = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .collection("readAnnouncements")
            .get();

        for (var d in readSnap.docs) {
          final data = d.data();
          if (data["read"] == true) {
            readMap[d.id] = true;
          }
        }
      }

      adminPosts = snapshot.docs.map((doc) {
        final data = doc.data();
        final id = doc.id;
        final isRead = readMap[id] == true;

        return {
          "id": id,
          "title": data["title"],
          "content": data["content"],
          "imageUrl": data["imageUrl"],
          "createdAt": data["createdAt"],
          "isRead": isRead,
        };
      }).toList();

      final latestDoc = snapshot.docs.first;
      final latestData = latestDoc.data();
      final ts = latestData["createdAt"] as Timestamp?;
      if (ts != null) {
        final postTime = ts.toDate();
        if (lastPostTime == null || postTime.isAfter(lastPostTime!)) {
          lastPostTime = postTime;
          _showNotification(
            latestData["title"] ?? "New Announcement",
            latestData["content"] ?? "",
          );
        }
      }

      if (mounted) setState(() {});
    });
  }

  Future<void> _markAnnouncementAsRead(String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("readAnnouncements")
          .doc(postId)
          .set(
        {
          "read": true,
          "readAt": FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      final idx = adminPosts.indexWhere((p) => p["id"] == postId);
      if (idx != -1) {
        adminPosts[idx]["isRead"] = true;
        if (mounted) setState(() {});
      }
    } catch (e) {
      print("Failed to mark announcement as read → $e");
    }
  }

  Future<void> _showNotification(String title, String body) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'nearby_channel',
        'Nearby & Admin Alerts',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _notifications.show(
      Random().nextInt(999999),
      title,
      body,
      details,
    );
  }

  void _openAnnouncementPopup(Map<String, dynamic> post) async {
    final String postId = post["id"] ?? "";

    if (postId.isNotEmpty) {
      await _markAnnouncementAsRead(postId);
    }

    showDialog(
      context: context,
      builder: (_) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Theme.of(context).cardColor,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    post["imageUrl"] ?? "",
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(height: 220, color: Theme.of(context).dividerColor),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post["title"] ?? "Announcement",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        post["content"] ?? "",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),

                      const SizedBox(height: 20),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Close",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,

        // TabBar theme-aware
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.onPrimary,
          unselectedLabelColor: theme.colorScheme.onPrimary.withOpacity(0.7),
          indicatorColor: theme.colorScheme.onPrimary,
          tabs: const [
            Tab(text: "Nearby"),
            Tab(text: "Announcements"),
          ],
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _notificationToggleTile(context),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNearbyRestaurantsTab(context),
                _buildAdminAnnouncementsTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _notificationToggleTile(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : Colors.black.withOpacity(0.06),
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Enable Nearby & Admin Alerts",
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Switch(
            value: alertsEnabled,
            activeColor: theme.colorScheme.primary,
            onChanged: _toggleAlerts,
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyRestaurantsTab(BuildContext context) {
    if (nearbyRestaurants.isEmpty) {
      return _emptyState(context, "No nearby restaurants detected.");
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView.builder(
      itemCount: nearbyRestaurants.length,
      itemBuilder: (context, index) {
        final r = nearbyRestaurants[index];
        final v = r.vendor;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                color: isDark
                    ? Colors.black.withOpacity(0.5)
                    : Colors.black.withOpacity(0.06),
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                v.businessLogoUrl ?? "",
                height: 50,
                width: 50,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 50,
                  width: 50,
                  color: theme.dividerColor,
                ),
              ),
            ),
            title: Text(
              v.businessName,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              v.cuisineType ?? "-",
              style: theme.textTheme.bodyMedium,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdminAnnouncementsTab(BuildContext context) {
    if (adminPosts.isEmpty) {
      return _emptyState(context, "No announcements available.");
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView.builder(
      itemCount: adminPosts.length,
      itemBuilder: (context, index) {
        final post = adminPosts[index];
        final bool isRead = post["isRead"] == true;

        return GestureDetector(
          onTap: () => _openAnnouncementPopup(post),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  blurRadius: 6,
                  color: isDark
                      ? Colors.black.withOpacity(0.5)
                      : Colors.black.withOpacity(0.06),
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    post["imageUrl"] ?? "",
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: theme.dividerColor,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post["title"] ?? "Announcement",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight:
                              isRead ? FontWeight.w500 : FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        post["content"] ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isRead
                              ? theme.textTheme.bodyMedium!.color!
                                  .withOpacity(0.6)
                              : theme.textTheme.bodyMedium!.color!,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                if (!isRead)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),

                Icon(Icons.chevron_right,
                    color: theme.iconTheme.color?.withOpacity(0.6)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emptyState(BuildContext context, String message) {
    return Center(
      child: Text(
        message,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Theme.of(context).hintColor),
      ),
    );
  }
}
