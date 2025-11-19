import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makan_mate/core/constants/ui_constants.dart';
import 'package:makan_mate/core/theme/app_colors.dart';
import 'package:makan_mate/core/theme/app_theme.dart';
import 'package:makan_mate/features/admin/presentation/utils/admin_utils.dart';
import 'package:makan_mate/features/admin/presentation/widgets/3d_card.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:makan_mate/core/services/push_notification_service.dart';
import 'dart:io';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isEditing = false;
  File? _profileImage;
  String? _profileImageUrl; // Store profile image URL from Firestore
  bool _isLoading = false;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _twoFactorEnabled = false;
  bool _loginAlertsEnabled = false;
  bool _isPreferencesLoading = true;
  bool _useFallbackQuery = false;

  final _settingsCollection = FirebaseFirestore.instance.collection(
    'admin_settings',
  );
  final _securityLogsCollection = FirebaseFirestore.instance.collection(
    'admin_security_logs',
  );

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPreferences();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _nameController.text = user.displayName ?? '';
        _emailController.text = user.email ?? '';
      });

      // Load profile image URL from Firestore as fallback
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data();
          final profileImageUrl = data?['profileImageUrl'] as String?;
          if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
            setState(() {
              _profileImageUrl = profileImageUrl;
            });
          }
        }
      } catch (e) {
        // Silently fail - profile image is optional
        debugPrint('Failed to load profile image from Firestore: $e');
      }

      // Reload user to get latest photoURL from Auth
      await user.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;
      if (updatedUser?.photoURL != null && updatedUser!.photoURL!.isNotEmpty) {
        setState(() {
          _profileImageUrl = updatedUser.photoURL;
        });
      }
    }
  }

  Future<void> _loadPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isPreferencesLoading = false);
      return;
    }

    try {
      final doc = await _settingsCollection.doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _emailNotifications = data['emailNotifications'] as bool? ?? true;
          _pushNotifications = data['pushNotifications'] as bool? ?? true;
          _twoFactorEnabled = data['twoFactorEnabled'] as bool? ?? false;
          _loginAlertsEnabled = data['loginAlertsEnabled'] as bool? ?? false;
          _isPreferencesLoading = false;
        });
      } else {
        await _settingsCollection.doc(user.uid).set({
          'emailNotifications': _emailNotifications,
          'pushNotifications': _pushNotifications,
          'twoFactorEnabled': _twoFactorEnabled,
          'loginAlertsEnabled': _loginAlertsEnabled,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        setState(() {
          _isPreferencesLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to load preferences: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      setState(() => _isPreferencesLoading = false);
    }
  }

  Future<bool> _saveNotificationPreferences({
    required bool emailNotifications,
    required bool pushNotifications,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    if (pushNotifications && !_pushNotifications) {
      final enabled = await PushNotificationService.enableAdminPush(user.uid);
      if (!enabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Push notifications blocked by OS settings. Please enable permissions.',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return false;
      }
    } else if (!pushNotifications && _pushNotifications) {
      await PushNotificationService.disableAdminPush(user.uid);
    }

    await _settingsCollection.doc(user.uid).set({
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    setState(() {
      _emailNotifications = emailNotifications;
      _pushNotifications = pushNotifications;
    });

    await _recordSecurityEvent(
      'notification_preferences_updated',
      metadata: {
        'emailNotifications': emailNotifications,
        'pushNotifications': pushNotifications,
      },
    );
    return true;
  }

  Future<void> _saveSecurityPreferences({
    required bool twoFactor,
    required bool loginAlerts,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _settingsCollection.doc(user.uid).set({
      'twoFactorEnabled': twoFactor,
      'loginAlertsEnabled': loginAlerts,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    setState(() {
      _twoFactorEnabled = twoFactor;
      _loginAlertsEnabled = loginAlerts;
    });

    await _recordSecurityEvent(
      'security_preferences_updated',
      metadata: {
        'twoFactorEnabled': twoFactor,
        'loginAlertsEnabled': loginAlerts,
      },
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      await _uploadProfileImage();
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_profileImage == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('admin_profiles')
          .child('${user.uid}.jpg');

      await storageRef.putFile(_profileImage!);
      final downloadUrl = await storageRef.getDownloadURL();

      await user.updatePhotoURL(downloadUrl);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'profileImageUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await user.reload();

      // Update local state with the new image URL
      setState(() {
        _profileImageUrl = downloadUrl;
      });

      await _recordSecurityEvent(
        'profile_image_updated',
        metadata: {'imageUrl': downloadUrl},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name cannot be empty')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(_nameController.text);
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _nameController.text,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        await user.reload();

        setState(() {
          _isEditing = false;
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You must be signed in with email/password to change it',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool submitting = false;
    String? currentPasswordError;
    String? newPasswordError;
    String? confirmPasswordError;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              Future<void> handleSubmit() async {
                if (submitting) return;
                final current = currentPasswordController.text.trim();
                final newPwd = newPasswordController.text.trim();
                final confirm = confirmPasswordController.text.trim();

                setModalState(() {
                  currentPasswordError = current.isEmpty
                      ? 'Current password is required'
                      : null;
                  newPasswordError = newPwd.isEmpty
                      ? 'New password is required'
                      : null;
                  confirmPasswordError = confirm.isEmpty
                      ? 'Please confirm the new password'
                      : null;
                });
                if (currentPasswordError != null ||
                    newPasswordError != null ||
                    confirmPasswordError != null) {
                  return;
                }

                if (newPwd.length < 8) {
                  setModalState(
                    () => newPasswordError =
                        'Password must be at least 8 characters',
                  );
                  return;
                }

                if (newPwd != confirm) {
                  setModalState(() {
                    confirmPasswordError = 'Passwords do not match';
                  });
                  return;
                }

                setModalState(() => submitting = true);

                try {
                  final credential = EmailAuthProvider.credential(
                    email: user!.email!,
                    password: current,
                  );
                  await user.reauthenticateWithCredential(credential);
                  await user.updatePassword(newPwd);
                  await _recordSecurityEvent('password_changed');

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password updated successfully'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                  Navigator.pop(context);
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'wrong-password') {
                    setModalState(
                      () => currentPasswordError = 'Incorrect current password',
                    );
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.message ?? 'Failed to update password'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                  setModalState(() => submitting = false);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Unexpected error: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                  setModalState(() => submitting = false);
                }
              }

              return Padding(
                padding: UIConstants.paddingLg,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: UIConstants.spacingMd),
                        Text(
                          'Change Password',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: UIConstants.spacingLg),
                    TextField(
                      controller: currentPasswordController,
                      obscureText: obscureCurrent,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        prefixIcon: const Icon(Icons.lock_clock_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureCurrent
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                          ),
                          onPressed: () {
                            setModalState(() {
                              obscureCurrent = !obscureCurrent;
                            });
                          },
                        ),
                        errorText: currentPasswordError,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingMd),
                    TextField(
                      controller: newPasswordController,
                      obscureText: obscureNew,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: const Icon(Icons.password_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureNew
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                          ),
                          onPressed: () {
                            setModalState(() {
                              obscureNew = !obscureNew;
                            });
                          },
                        ),
                        errorText: newPasswordError,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingMd),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        prefixIcon: const Icon(Icons.check_circle_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirm
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                          ),
                          onPressed: () {
                            setModalState(() {
                              obscureConfirm = !obscureConfirm;
                            });
                          },
                        ),
                        errorText: confirmPasswordError,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingXl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: UIConstants.spacingSm),
                        ElevatedButton(
                          onPressed: submitting ? null : handleSubmit,
                          child: submitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Update Password'),
                        ),
                      ],
                    ),
                    const SizedBox(height: UIConstants.spacingSm),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF2C2C2C), const Color(0xFF1E1E1E)]
                  : [Colors.white, Colors.white.withOpacity(0.95)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: UIConstants.spacingMd),
            const Text('Admin Profile'),
          ],
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded),
              onPressed: _isLoading ? null : _updateProfile,
              tooltip: 'Save changes',
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit profile',
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'logout') {
                AdminUtils.showLogoutDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      size: 20,
                      color: AppColors.error,
                    ),
                    SizedBox(width: UIConstants.spacingSm),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          return RefreshIndicator(
            onRefresh: _loadUserData,
            child: ListView(
              padding: UIConstants.paddingLg,
              children: [
                // Profile Header
                Card3D(
                  child: Container(
                    padding: UIConstants.paddingLg,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: UIConstants.borderRadiusLg,
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : (_profileImageUrl != null &&
                                            _profileImageUrl!.isNotEmpty
                                        ? NetworkImage(_profileImageUrl!)
                                        : (user?.photoURL != null &&
                                                  user!.photoURL!.isNotEmpty
                                              ? NetworkImage(user.photoURL!)
                                              : null)),
                              backgroundColor: AppColors.grey200,
                              child:
                                  _profileImage == null &&
                                      _profileImageUrl == null &&
                                      (user?.photoURL == null ||
                                          user!.photoURL!.isEmpty)
                                  ? const Icon(
                                      Icons.person_rounded,
                                      size: 60,
                                      color: AppColors.grey500,
                                    )
                                  : null,
                            ),
                            if (_isEditing)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF1E1E1E)
                                          : Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.camera_alt_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: _pickImage,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: UIConstants.spacingMd),
                        if (_isEditing)
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.person_rounded),
                            ),
                          )
                        else
                          Text(
                            user?.displayName ?? 'Admin User',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        const SizedBox(height: UIConstants.spacingSm),
                        if (_isEditing)
                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email_rounded),
                            ),
                            enabled: false,
                          )
                        else
                          Text(
                            user?.email ?? '',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColorsExtension.getTextSecondary(
                                    context,
                                  ),
                                ),
                          ),
                        const SizedBox(height: UIConstants.spacingMd),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.admin_panel_settings_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'ADMIN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (user?.emailVerified == true) ...[
                          const SizedBox(height: UIConstants.spacingSm),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.success),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: UIConstants.spacingLg),

                // Account Information
                _buildSectionHeader(context, 'Account Information'),
                const SizedBox(height: UIConstants.spacingMd),
                Card3D(
                  child: Container(
                    padding: UIConstants.paddingMd,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: UIConstants.borderRadiusLg,
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          context,
                          Icons.person_rounded,
                          'User ID',
                          user?.uid ?? 'N/A',
                        ),
                        const Divider(),
                        _buildInfoRow(
                          context,
                          Icons.email_rounded,
                          'Email',
                          user?.email ?? 'N/A',
                        ),
                        const Divider(),
                        _buildInfoRow(
                          context,
                          Icons.calendar_today_rounded,
                          'Account Created',
                          user?.metadata.creationTime != null
                              ? AdminUtils.formatDate(
                                  user!.metadata.creationTime!,
                                )
                              : 'N/A',
                        ),
                        const Divider(),
                        _buildInfoRow(
                          context,
                          Icons.access_time_rounded,
                          'Last Sign In',
                          user?.metadata.lastSignInTime != null
                              ? AdminUtils.formatDate(
                                  user!.metadata.lastSignInTime!,
                                )
                              : 'N/A',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: UIConstants.spacingLg),

                // Account Settings
                _buildSectionHeader(context, 'Account Settings'),
                const SizedBox(height: UIConstants.spacingMd),
                Card3D(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: UIConstants.borderRadiusLg,
                    ),
                    child: Column(
                      children: [
                        _buildSettingTile(
                          context,
                          Icons.lock_rounded,
                          'Change Password',
                          'Update your account password',
                          _changePassword,
                        ),
                        const Divider(),
                        _buildSettingTile(
                          context,
                          Icons.notifications_rounded,
                          'Notifications',
                          _isPreferencesLoading
                              ? 'Loading preferences...'
                              : 'Email ${_emailNotifications ? 'ON' : 'OFF'} • Push ${_pushNotifications ? 'ON' : 'OFF'}',
                          _showNotificationSettings,
                        ),
                        const Divider(),
                        _buildSettingTile(
                          context,
                          Icons.security_rounded,
                          'Security',
                          'Two-factor authentication & security',
                          _showSecuritySettings,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: UIConstants.spacingLg),

                // Security Activity
                _buildSectionHeader(context, 'Security Activity'),
                const SizedBox(height: UIConstants.spacingMd),
                _buildSecurityActivityCard(context, user),
                const SizedBox(height: UIConstants.spacingLg),

                // Danger Zone
                _buildSectionHeader(context, 'Danger Zone'),
                const SizedBox(height: UIConstants.spacingMd),
                Card3D(
                  child: Container(
                    padding: UIConstants.paddingMd,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: UIConstants.borderRadiusLg,
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildSettingTile(
                          context,
                          Icons.logout_rounded,
                          'Logout',
                          'Sign out from your admin account',
                          () => AdminUtils.showLogoutDialog(context),
                          textColor: AppColors.error,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: UIConstants.spacingXl),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: UIConstants.spacingSm),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColorsExtension.getTextSecondary(context),
          ),
          const SizedBox(width: UIConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColorsExtension.getTextSecondary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (textColor ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: textColor ?? AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  Widget _buildSecurityActivityCard(BuildContext context, User? user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card3D(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 300),
        padding: UIConstants.paddingMd,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: UIConstants.borderRadiusLg,
        ),
        child: user == null
            ? const Center(child: Text('Sign in to view security activity'))
            : StreamBuilder<QuerySnapshot>(
                stream: _useFallbackQuery
                    ? _securityLogsCollection
                          .where('adminId', isEqualTo: user.uid)
                          .snapshots()
                    : _securityLogsCollection
                          .where('adminId', isEqualTo: user.uid)
                          .orderBy('timestamp', descending: true)
                          .limit(10)
                          .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    final error = snapshot.error.toString();
                    // Check if it's an index error
                    final isIndexError =
                        error.contains('index') ||
                        error.contains('requires an index') ||
                        error.contains('FAILED_PRECONDITION');

                    return Center(
                      child: Padding(
                        padding: UIConstants.paddingMd,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.error,
                              size: 32,
                            ),
                            const SizedBox(height: UIConstants.spacingMd),
                            Text(
                              isIndexError
                                  ? 'Firestore index required'
                                  : 'Failed to load activity',
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: UIConstants.fontSizeMd,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: UIConstants.spacingSm),
                            Text(
                              isIndexError
                                  ? 'Please create a composite index for admin_security_logs:\n'
                                        'Collection: admin_security_logs\n'
                                        'Fields: adminId (Ascending), timestamp (Descending)'
                                  : error.length > 100
                                  ? '${error.substring(0, 100)}...'
                                  : error,
                              style: TextStyle(
                                color: AppColorsExtension.getTextSecondary(
                                  context,
                                ),
                                fontSize: UIConstants.fontSizeSm,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (isIndexError) ...[
                              const SizedBox(height: UIConstants.spacingMd),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _useFallbackQuery = true;
                                  });
                                },
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  size: 16,
                                ),
                                label: const Text('Retry with fallback'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(UIConstants.spacingLg),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: UIConstants.spacingMd),
                            Text('No security events recorded yet'),
                          ],
                        ),
                      ),
                    );
                  }

                  // If using fallback query, sort client-side
                  List<QueryDocumentSnapshot> sortedDocs;
                  if (_useFallbackQuery) {
                    sortedDocs = List<QueryDocumentSnapshot>.from(docs);
                    sortedDocs.sort((a, b) {
                      final aTime =
                          (a.data() as Map<String, dynamic>)['timestamp']
                              as Timestamp?;
                      final bTime =
                          (b.data() as Map<String, dynamic>)['timestamp']
                              as Timestamp?;
                      if (aTime == null && bTime == null) return 0;
                      if (aTime == null) return 1;
                      if (bTime == null) return -1;
                      return bTime.compareTo(aTime); // Descending
                    });
                    sortedDocs = sortedDocs.take(10).toList();
                  } else {
                    sortedDocs = docs;
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: sortedDocs.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: UIConstants.spacingMd),
                    itemBuilder: (context, index) =>
                        _buildSecurityLogTile(context, sortedDocs[index]),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildSecurityLogTile(
    BuildContext context,
    QueryDocumentSnapshot doc,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    final action = data['action'] as String? ?? 'activity';
    final metadata = (data['metadata'] as Map<String, dynamic>?) ?? const {};
    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

    final icon = _iconForSecurityAction(action);
    final color = _colorForSecurityAction(action, context);
    final description = _describeSecurityAction(action);
    final subtitle = _formatMetadata(metadata);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        description,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          if (timestamp != null)
            Text(
              AdminUtils.formatDate(timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColorsExtension.getTextSecondary(context),
                fontSize: UIConstants.fontSizeXs,
              ),
            ),
        ],
      ),
    );
  }

  IconData _iconForSecurityAction(String action) {
    switch (action) {
      case 'password_changed':
        return Icons.lock_reset_rounded;
      case 'notification_preferences_updated':
        return Icons.notifications_active_rounded;
      case 'security_preferences_updated':
        return Icons.security_rounded;
      case 'two_factor_enabled':
        return Icons.verified_user_rounded;
      case 'two_factor_disabled':
        return Icons.phonelink_lock_rounded;
      case 'profile_image_updated':
        return Icons.image_rounded;
      case 'sign_in':
        return Icons.login_rounded;
      case 'sign_out':
        return Icons.logout_rounded;
      case 'sign_in_failed':
        return Icons.error_outline_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  Color _colorForSecurityAction(String action, BuildContext context) {
    switch (action) {
      case 'password_changed':
        return AppColors.warning;
      case 'notification_preferences_updated':
        return AppColors.primary;
      case 'security_preferences_updated':
        return AppColors.info;
      default:
        return AppColorsExtension.getTextSecondary(context);
    }
  }

  String _describeSecurityAction(String action) {
    switch (action) {
      case 'password_changed':
        return 'Password changed';
      case 'notification_preferences_updated':
        return 'Notification preferences updated';
      case 'security_preferences_updated':
        return 'Security preferences updated';
      case 'two_factor_enabled':
        return 'Two-factor authentication enabled';
      case 'two_factor_disabled':
        return 'Two-factor authentication disabled';
      case 'profile_image_updated':
        return 'Profile picture updated';
      case 'sign_in':
        return 'Sign in';
      case 'sign_out':
        return 'Sign out';
      case 'sign_in_failed':
        return 'Failed sign-in attempt';
      default:
        return action.replaceAll('_', ' ');
    }
  }

  String _formatMetadata(Map<String, dynamic> metadata) {
    if (metadata.isEmpty) return '';
    return metadata.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join(' • ');
  }

  void _showNotificationSettings() {
    if (_isPreferencesLoading) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        bool emailPref = _emailNotifications;
        bool pushPref = _pushNotifications;
        bool saving = false;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: UIConstants.paddingLg,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.notifications_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: UIConstants.spacingMd),
                        Text(
                          'Notification Preferences',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: UIConstants.spacingLg),
                    SwitchListTile(
                      value: emailPref,
                      title: const Text('Email Alerts'),
                      subtitle: const Text(
                        'Receive email updates about admin activities',
                      ),
                      onChanged: (value) {
                        setModalState(() => emailPref = value);
                      },
                    ),
                    SwitchListTile(
                      value: pushPref,
                      title: const Text('Push Notifications'),
                      subtitle: const Text(
                        'Get push notifications for important events',
                      ),
                      onChanged: (value) {
                        setModalState(() => pushPref = value);
                      },
                    ),
                    const SizedBox(height: UIConstants.spacingLg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                        const SizedBox(width: UIConstants.spacingSm),
                        ElevatedButton(
                          onPressed: saving
                              ? null
                              : () async {
                                  setModalState(() => saving = true);
                                  final success =
                                      await _saveNotificationPreferences(
                                        emailNotifications: emailPref,
                                        pushNotifications: pushPref,
                                      );
                                  if (success && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Notification preferences updated',
                                        ),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                  if (success) {
                                    Navigator.pop(context);
                                  } else {
                                    setModalState(() => saving = false);
                                  }
                                },
                          child: saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showSecuritySettings() {
    if (_isPreferencesLoading) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        bool twoFactorPref = _twoFactorEnabled;
        bool loginAlertsPref = _loginAlertsEnabled;
        bool saving = false;
        bool updatingTwoFactor = false;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: UIConstants.paddingLg,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppColors.secondaryGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.security_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: UIConstants.spacingMd),
                        Text(
                          'Security Settings',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: UIConstants.spacingLg),
                    Container(
                      padding: UIConstants.paddingMd,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1E1E1E)
                            : AppColors.grey50,
                        borderRadius: UIConstants.borderRadiusLg,
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.1)
                              : AppColors.grey200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.phonelink_lock_rounded,
                                color: twoFactorPref
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                              const SizedBox(width: UIConstants.spacingSm),
                              Text(
                                'Two-Factor Authentication',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: UIConstants.spacingSm),
                          Text(
                            twoFactorPref
                                ? 'Enabled - SMS code required on sign in'
                                : 'Disabled - Only password required to sign in',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColorsExtension.getTextSecondary(
                                    context,
                                  ),
                                ),
                          ),
                          const SizedBox(height: UIConstants.spacingSm),
                          Row(
                            children: [
                              if (twoFactorPref)
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: updatingTwoFactor
                                        ? null
                                        : () async {
                                            setModalState(
                                              () => updatingTwoFactor = true,
                                            );
                                            final success =
                                                await _disableTwoFactorFlow();
                                            if (success) {
                                              twoFactorPref = false;
                                              await _saveSecurityPreferences(
                                                twoFactor: false,
                                                loginAlerts: loginAlertsPref,
                                              );
                                              if (mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Two-factor authentication disabled',
                                                    ),
                                                    backgroundColor:
                                                        AppColors.success,
                                                  ),
                                                );
                                              }
                                            }
                                            setModalState(
                                              () => updatingTwoFactor = false,
                                            );
                                          },
                                    icon: updatingTwoFactor
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.phonelink_lock),
                                    label: const Text('Disable'),
                                  ),
                                )
                              else
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: updatingTwoFactor
                                        ? null
                                        : () async {
                                            setModalState(
                                              () => updatingTwoFactor = true,
                                            );
                                            final success =
                                                await _enableTwoFactorFlow();
                                            if (success) {
                                              twoFactorPref = true;
                                              await _saveSecurityPreferences(
                                                twoFactor: true,
                                                loginAlerts: loginAlertsPref,
                                              );
                                              if (mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Two-factor authentication enabled',
                                                    ),
                                                    backgroundColor:
                                                        AppColors.success,
                                                  ),
                                                );
                                              }
                                            }
                                            setModalState(
                                              () => updatingTwoFactor = false,
                                            );
                                          },
                                    icon: updatingTwoFactor
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.verified_user_rounded,
                                          ),
                                    label: const Text('Enable'),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SwitchListTile(
                      value: loginAlertsPref,
                      title: const Text('Login Alerts'),
                      subtitle: const Text(
                        'Get notified when your account is accessed',
                      ),
                      onChanged: (value) {
                        setModalState(() => loginAlertsPref = value);
                      },
                    ),
                    const SizedBox(height: UIConstants.spacingLg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                        const SizedBox(width: UIConstants.spacingSm),
                        ElevatedButton(
                          onPressed: saving
                              ? null
                              : () async {
                                  setModalState(() => saving = true);
                                  await _saveSecurityPreferences(
                                    twoFactor: twoFactorPref,
                                    loginAlerts: loginAlertsPref,
                                  );
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Security preferences updated',
                                        ),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                  Navigator.pop(context);
                                },
                          child: saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<bool> _enableTwoFactorFlow() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final phoneController = TextEditingController();
    final codeController = TextEditingController();
    String? verificationId;
    bool codeSent = false;
    bool sending = false;
    bool verifying = false;
    String? phoneError;
    String? codeError;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              Future<void> sendCode() async {
                final phone = phoneController.text.trim();
                if (!RegExp(r'^\+\d{10,15}$').hasMatch(phone)) {
                  setModalState(() {
                    phoneError =
                        'Enter phone in international format (e.g., +60123456789)';
                  });
                  return;
                }
                setModalState(() {
                  phoneError = null;
                  sending = true;
                });
                try {
                  final session = await user.multiFactor.getSession();
                  await FirebaseAuth.instance.verifyPhoneNumber(
                    phoneNumber: phone,
                    multiFactorSession: session,
                    verificationCompleted: (_) {},
                    verificationFailed: (e) {
                      setModalState(() {
                        phoneError = e.message;
                        sending = false;
                      });
                    },
                    codeSent: (id, _) {
                      setModalState(() {
                        verificationId = id;
                        codeSent = true;
                        sending = false;
                      });
                    },
                    codeAutoRetrievalTimeout: (id) {
                      verificationId = id;
                    },
                  );
                } catch (e) {
                  setModalState(() {
                    phoneError = 'Failed to send code: $e';
                    sending = false;
                  });
                }
              }

              Future<void> verifyCode() async {
                final code = codeController.text.trim();
                if (verificationId == null) {
                  setModalState(() => codeError = 'Request a code first');
                  return;
                }
                if (code.length < 6) {
                  setModalState(() => codeError = 'Enter the 6-digit code');
                  return;
                }
                setModalState(() {
                  codeError = null;
                  verifying = true;
                });
                try {
                  final credential = PhoneAuthProvider.credential(
                    verificationId: verificationId!,
                    smsCode: code,
                  );
                  final assertion = PhoneMultiFactorGenerator.getAssertion(
                    credential,
                  );
                  await user.multiFactor.enroll(
                    assertion,
                    displayName: 'Admin Phone',
                  );
                  await _recordSecurityEvent(
                    'two_factor_enabled',
                    metadata: {'phoneNumber': phoneController.text.trim()},
                  );
                  await user.reload();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Two-factor authentication enabled'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                  Navigator.pop(context, true);
                } on FirebaseAuthException catch (e) {
                  setModalState(() {
                    codeError = e.message;
                    verifying = false;
                  });
                } catch (e) {
                  setModalState(() {
                    codeError = 'Failed to verify code: $e';
                    verifying = false;
                  });
                }
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: UIConstants.paddingLg,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: AppColors.secondaryGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.phone_iphone_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: UIConstants.spacingMd),
                          Expanded(
                            child: Text(
                              'Enable Two-Factor Authentication',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: UIConstants.spacingLg),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: const Icon(Icons.flag_rounded),
                          hintText: '+60123456789',
                          errorText: phoneError,
                          errorMaxLines: 2,
                        ),
                        enabled: !codeSent && !sending,
                      ),
                      const SizedBox(height: UIConstants.spacingSm),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: sending ? null : sendCode,
                          child: sending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(codeSent ? 'Resend Code' : 'Send Code'),
                        ),
                      ),
                      if (codeSent) ...[
                        const SizedBox(height: UIConstants.spacingMd),
                        TextField(
                          controller: codeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Verification Code',
                            prefixIcon: const Icon(Icons.sms_rounded),
                            errorText: codeError,
                            errorMaxLines: 2,
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingLg),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: UIConstants.spacingSm),
                            ElevatedButton(
                              onPressed: verifying ? null : verifyCode,
                              child: verifying
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Verify & Enable'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    return result ?? false;
  }

  Future<bool> _disableTwoFactorFlow() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final factors = await user.multiFactor.getEnrolledFactors();
    if (factors.isEmpty) {
      return true;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable Two-Factor Authentication'),
        content: const Text(
          'This will remove the additional verification step when signing in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Disable'),
          ),
        ],
      ),
    );

    if (confirm != true) return false;

    try {
      await user.multiFactor.unenroll(multiFactorInfo: factors.first);
      await user.reload();
      await _recordSecurityEvent('two_factor_disabled');
      return true;
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Failed to disable two-factor'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    }
  }

  Future<void> _recordSecurityEvent(
    String action, {
    Map<String, dynamic>? metadata,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _securityLogsCollection.add({
        'adminId': user.uid,
        'action': action,
        'metadata': metadata ?? {},
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Swallow errors silently – logging failure shouldn't break UX
    }
  }
}
