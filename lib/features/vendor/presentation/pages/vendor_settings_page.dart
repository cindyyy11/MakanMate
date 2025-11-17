import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'vendor_profile_page.dart';
import 'help_support_page.dart';
import 'about_makanmate_page.dart';

import '../bloc/vendor_profile_bloc.dart';
import '../bloc/vendor_profile_state.dart';
import '../bloc/vendor_profile_event.dart';

import '../../../../core/di/injection_container.dart' as di;
import 'package:makan_mate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_event.dart';

class VendorSettingsPage extends StatelessWidget {
  const VendorSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          di.sl<VendorProfileBloc>()..add(LoadVendorProfileEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Settings',
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
        body: BlocBuilder<VendorProfileBloc, VendorProfileState>(
          builder: (context, state) {
            if (state is VendorProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is VendorProfileError) {
              return Center(
                child: Text(
                  "Failed to load profile",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (state is! VendorProfileReadyState) {
              return const Center(child: Text("No profile data"));
            }

            final profile = state.profile;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: profile.businessLogoUrl != null &&
                                  profile.businessLogoUrl!.isNotEmpty
                              ? NetworkImage(profile.businessLogoUrl!)
                              : null,
                          child: (profile.businessLogoUrl == null ||
                                  profile.businessLogoUrl!.isEmpty)
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                        const SizedBox(height: 16),

                        Text(
                          profile.businessName,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),

                        Text(profile.emailAddress,
                            style: TextStyle(color: Colors.grey[700])),

                        const SizedBox(height: 4),

                        Text(profile.contactNumber,
                            style: TextStyle(color: Colors.grey[700])),

                        const SizedBox(height: 4),

                        Text(
                          "${profile.cuisineType ?? ''} • ${profile.priceRange ?? ''}",
                          style: TextStyle(color: Colors.grey[600]),
                        ),

                        const SizedBox(height: 14),

                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider(
                                  create: (_) => di.sl<VendorProfileBloc>(),
                                  child: const VendorProfilePage(),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text("Edit Profile"),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'ACCOUNT',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),

                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text("Change Password"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),

                const SizedBox(height: 18),
                const Text(
                  'APP',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),

                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text("Help & Support"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HelpSupportPage()),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text("About MakanMate"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AboutMakanMatePage()),
                    );
                  },
                ),

                const Divider(height: 32),

                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Logout",
                      style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    final confirm = await _showConfirmDialog(
                      context,
                      title: "Logout",
                      message:
                          "Are you sure you want to logout?",
                      actionText: "Logout",
                    );

                    if (confirm == true && context.mounted) {
                      context.read<AuthBloc>().add(SignOutRequested());
                    }
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text("Delete Account", style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    final confirm = await _showConfirmDialog(
                      context,
                      title: "Delete Account",
                      message:
                          "This action is permanent. Your account and data will be deleted. Continue?",
                      actionText: "Delete",
                    );

                    if (confirm == true && context.mounted) {
                      context.read<AuthBloc>().add(DeleteAccountRequested());
                    }
                  },
                ),
                const SizedBox(height: 20
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String actionText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(actionText),
          )
        ],
      ),
    );
  }
}
