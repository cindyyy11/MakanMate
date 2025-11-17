import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:makan_mate/features/favorite/presentation/pages/favorite_page.dart';
import 'package:makan_mate/features/home/presentation/pages/dietary_settings_page.dart';
import 'package:makan_mate/features/home/presentation/pages/nearby_notifications_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to view profile.")),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        FirebaseAuth.instance.currentUser?.reload();
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          return const Scaffold(
              body: Center(child: Text("User session expired.")));
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;

        final displayName = data?["name"] ?? user.displayName ?? "Unnamed User";
        final photoURL = data?["photoURL"] ?? user.photoURL;

        return _buildProfileUI(context, user, displayName, photoURL);
      },
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Account?"),
        content: const Text(
          "This action is permanent. All your data and reviews will be removed."
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseAuth.instance.currentUser?.delete();
                Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileUI(
      BuildContext context, User user, String name, String? photoURL) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange[300],
        centerTitle: true,
        title: const Text(
          "My Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 25),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundImage:
                      photoURL != null ? NetworkImage(photoURL) : null,
                  backgroundColor: Colors.grey[300],
                  child: photoURL == null
                      ? const Icon(Icons.person,
                          size: 50, color: Colors.white70)
                      : null,
                ),
                const SizedBox(height: 12),

                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),
                Text(
                  user.email ?? "",
                  style: TextStyle(color: Colors.grey[600]),
                ),

                const SizedBox(height: 16),

                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfilePage(),
                      ),
                    );
                  },
                  child: const Text("Edit Profile"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          _sectionTitle("General"),
          _settingsTile(
            icon: Icons.favorite_border,
            title: "Favorite Restaurants",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritePage()),
              );
            },
          ),

          _settingsTile(
            icon: Icons.lock_outline,
            title: "Change Password",
            onTap: () {
              Navigator.pushNamed(context, '/change-password');
            },
          ),

          const SizedBox(height: 20),
          _sectionTitle("Preferences"),
          _settingsTile(
            icon: Icons.notifications_none,
            title: "Notifications",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NearbyNotificationsPage()),
              );
            },
          ),

          // _settingsTile(
          //   icon: Icons.dark_mode_outlined,
          //   title: "Dark Mode",
          //   onTap: () {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(
          //           content: Text("Dark mode toggle coming soon!")),
          //     );
          //   },
          // ),

        // _settingsTile(
        //   icon: Icons.language_outlined,
        //   title: "Language",
        //   onTap: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (_) => const LanguageSettingsPage()),
        //     );
        //   },
        // ),

        _settingsTile(
          icon: Icons.restaurant_menu_outlined,
          title: "Dietary Rules",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DietarySettingsPage()),
            );
          },
        ),

          const SizedBox(height: 20),

          _sectionTitle("Delete"),
          _settingsTile(
            icon: Icons.delete_forever_outlined,
            title: "Delete Account",
            onTap: () => _confirmDeleteAccount(context),
          ),

          const SizedBox(height: 30),

          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text(
                    "Log Out?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: const Text(
                    "Are you sure you want to log out?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context); 
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/login', (route) => false);
                      },
                      child: const Text(
                        "Log Out",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: const Text(
              "Log Out",
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}