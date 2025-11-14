import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isDarkMode = false;
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 25),

          Center(
            child: Text("My profile",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 25),

          // Profile Photo + Edit Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 45,
                backgroundImage:
                    user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                backgroundColor: Colors.grey[300],
                child: user?.photoURL == null
                    ? const Text("Profile Photos",
                        style: TextStyle(color: Colors.grey))
                    : null,
              ),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
                child: const Text("Edit profile"),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Text(user?.email ?? "-",
              style: TextStyle(color: Colors.grey[600])),

          const SizedBox(height: 20),

          // Name & Bio
          Text(user?.displayName ?? "Name",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text("Bio", style: TextStyle(color: Colors.grey[600])),

          const SizedBox(height: 25),

          // Tabs (3)
          Row(
            children: [
              _tabButton("Posts", 0),
              _tabButton("Favorites", 1),
              _tabButton("Reviews", 2),
            ],
          ),

          const SizedBox(height: 20),

          // Placeholder grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: List.generate(
              6,
              (index) => Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tab Button
  Widget _tabButton(String label, int index) {
    bool active = index == selectedTab;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.grey[400] : Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.black : Colors.grey[700])),
          ),
        ),
      ),
    );
  }
}
