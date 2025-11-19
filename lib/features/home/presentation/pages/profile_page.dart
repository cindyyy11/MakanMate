import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/core/widgets/theme_toggle_button.dart';
import 'package:makan_mate/core/widgets/theme_wrapper.dart';
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
            body: Center(child: Text("User session expired.")),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;

        final displayName = data?["name"] ?? user.displayName ?? "Unnamed User";
        final photoURL = data?["photoURL"] ?? user.photoURL;

        return ThemeWrapper(
          child: _buildProfileUI(context, user, displayName, photoURL),
        );
      },
    );
  }

  Widget _buildProfileUI(
    BuildContext context,
    User user,
    String name,
    String? photoURL,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),

          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundImage:
                      photoURL != null ? NetworkImage(photoURL) : null,
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email ?? "",
                  style: Theme.of(context).textTheme.bodyMedium,
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
          _sectionTitle(context, "General"),

          _settingsTile(
            context: context,
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
            context: context,
            icon: Icons.lock_outline,
            title: "Change Password",
            onTap: () {
              Navigator.pushNamed(context, '/change-password');
            },
          ),

          const SizedBox(height: 20),
          _sectionTitle(context, "Preferences"),

          _settingsTile(
            context: context,
            icon: Icons.notifications_none,
            title: "Notifications",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NearbyNotificationsPage()),
              );
            },
          ),

          _settingsTile(
            context: context,
            icon: Icons.dark_mode_outlined,
            title: "Dark Mode",
            trailing: const ThemeToggleButton(),
          ),

          _settingsTile(
            context: context,
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
          _sectionTitle(context, "Delete"),

          _settingsTile(
            context: context,
            icon: Icons.delete_forever_outlined,
            title: "Delete Account",
            onTap: () {
              _confirmDeleteAccount(context);
            },
          ),

          const SizedBox(height: 30),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
            child: Text(
              "Log Out",
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 16,
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  Widget _settingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Account?"),
        content: const Text(
            "This action cannot be undone. All your data will be removed."),
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
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("$e")));
              }
            },
            child: Text(
              "Delete",
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
