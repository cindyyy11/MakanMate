import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../bloc/vendor_profile_bloc.dart';
import '../bloc/vendor_profile_event.dart';
import 'vendor_profile_page.dart';

class VendorOnboardingPage extends StatelessWidget {
  const VendorOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Onboarding'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Welcome to MakanMate!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Thank you for registering as a vendor. Before our admin team can approve '
                'your account, we need some information about your restaurant so that we '
                'can verify your business.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              _buildChecklistItem(
                icon: Icons.store,
                label: 'Restaurant details (name, address, owner information)',
              ),
              _buildChecklistItem(
                icon: Icons.phone,
                label: 'Contact phone number and support email',
              ),
              _buildChecklistItem(
                icon: Icons.access_time,
                label: 'Daily operating hours',
              ),
              _buildChecklistItem(
                icon: Icons.description,
                label: 'Short description and unique selling points',
              ),
              _buildChecklistItem(
                icon: Icons.photo_camera,
                label: 'Profile photo, logo and other supporting media',
              ),
              const SizedBox(height: 32),
              Text(
                'Once you submit these details your profile will remain in “Pending Approval”. '
                'An administrator will review the information and unlock full dashboard access '
                'once everything checks out.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.edit),
                  label: const Text(
                    'Complete Vendor Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => di.sl<VendorProfileBloc>()
                            ..add(LoadVendorProfileEvent()),
                          child: const VendorProfilePage(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistItem({
    required IconData icon,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.orange[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

