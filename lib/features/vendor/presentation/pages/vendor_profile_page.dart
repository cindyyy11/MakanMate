import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../bloc/vendor_profile_bloc.dart';
import '../bloc/vendor_profile_event.dart';
import '../bloc/vendor_profile_state.dart';
import '../../domain/entities/vendor_profile_entity.dart';
import '../widgets/certifications_section.dart';

class VendorProfilePage extends StatefulWidget {
  const VendorProfilePage({super.key});

  @override
  State<VendorProfilePage> createState() => _VendorProfilePageState();
}

class _VendorProfilePageState extends State<VendorProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _shortDescriptionController = TextEditingController();
  final _imagePicker = ImagePicker();
  final Uuid _uuid = const Uuid();

  bool _isEditing = false;
  File? _selectedProfilePhoto;
  Map<String, OperatingHours> _operatingHours = {};
  List<OutletEntity> _outlets = [];
  String _approvalStatus = 'pending';

  bool get _isProfileEditable => _approvalStatus.toLowerCase() != 'rejected';

  @override
  void initState() {
    super.initState();
    context.read<VendorProfileBloc>().add(LoadVendorProfileEvent());
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _businessAddressController.dispose();
    _shortDescriptionController.dispose();
    super.dispose();
  }

  void _populateFields(VendorProfileEntity profile) {
    _businessNameController.text = profile.businessName;
    _contactNumberController.text = profile.contactNumber;
    _emailController.text = profile.emailAddress;
    _businessAddressController.text = profile.businessAddress;
    _shortDescriptionController.text = profile.shortDescription;
    _operatingHours = Map.from(profile.operatingHours);
    _outlets = List.from(profile.outlets);
    _approvalStatus = profile.approvalStatus;
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _selectedProfilePhoto = File(image.path);
      });
      context.read<VendorProfileBloc>().add(UploadProfilePhotoEvent(_selectedProfilePhoto!));
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Profile Photo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Get current profile to preserve photo URL and certifications
    final currentState = context.read<VendorProfileBloc>().state;
    String? profilePhotoUrl;
    List<CertificationEntity> certifications = [];
    DateTime createdAt = DateTime.now();
    if (currentState is VendorProfileReadyState) {
      profilePhotoUrl = currentState.profile.profilePhotoUrl;
      certifications = currentState.profile.certifications;
      createdAt = currentState.profile.createdAt;
    }

    final profile = VendorProfileEntity(
      id: user.uid,
      profilePhotoUrl: profilePhotoUrl,
      businessName: _businessNameController.text.trim(),
      contactNumber: _contactNumberController.text.trim(),
      emailAddress: _emailController.text.trim(),
      businessAddress: _businessAddressController.text.trim(),
      operatingHours: _operatingHours,
      shortDescription: _shortDescriptionController.text.trim(),
      approvalStatus: _approvalStatus,
      outlets: _outlets,
      certifications: certifications,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );

    context.read<VendorProfileBloc>().add(UpdateVendorProfileEvent(profile));
  }

  void _showOperatingHoursDialog() {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final selectedDays = <String>{};
    String? bulkOpenTime;
    String? bulkCloseTime;
    bool bulkIsClosed = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.white),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Operating Hours',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bulk Edit Section
                        Card(
                          color: Colors.blue[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.edit_calendar, color: Colors.blue[700]),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Bulk Edit',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Select days and set same hours for all:',
                                  style: TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 12),
                                // Day checkboxes
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: days.map((day) {
                                    return FilterChip(
                                      label: Text(day.substring(0, 3)),
                                      selected: selectedDays.contains(day),
                                      onSelected: (selected) {
                                        setDialogState(() {
                                          if (selected) {
                                            selectedDays.add(day);
                                          } else {
                                            selectedDays.remove(day);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 16),
                                SwitchListTile(
                                  title: const Text('Closed'),
                                  value: bulkIsClosed,
                                  onChanged: (value) {
                                    setDialogState(() {
                                      bulkIsClosed = value;
                                    });
                                  },
                                ),
                                if (!bulkIsClosed) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          decoration: InputDecoration(
                                            labelText: 'Open Time',
                                            hintText: '09:00',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          onChanged: (value) {
                                            bulkOpenTime = value;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextField(
                                          decoration: InputDecoration(
                                            labelText: 'Close Time',
                                            hintText: '18:00',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          onChanged: (value) {
                                            bulkCloseTime = value;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.check),
                                      label: const Text('Apply to Selected Days'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: selectedDays.isEmpty
                                          ? null
                                          : () {
                                              setDialogState(() {
                                                for (final day in selectedDays) {
                                                  _operatingHours[day] = OperatingHours(
                                                    day: day,
                                                    openTime: bulkIsClosed ? null : bulkOpenTime,
                                                    closeTime: bulkIsClosed ? null : bulkCloseTime,
                                                    isClosed: bulkIsClosed,
                                                  );
                                                }
                                              });
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Applied to ${selectedDays.length} day(s)',
                                                  ),
                                                  duration: const Duration(seconds: 1),
                                                ),
                                              );
                                            },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Individual Day Settings
                        const Text(
                          'Individual Day Settings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...days.map((day) {
                          final hours = _operatingHours[day] ??
                              OperatingHours(day: day, isClosed: true);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange[100],
                                child: Text(
                                  day.substring(0, 1),
                                  style: TextStyle(
                                    color: Colors.orange[900],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(day),
                              subtitle: Text(
                                hours.isClosed
                                    ? 'Closed'
                                    : '${hours.openTime ?? 'N/A'} - ${hours.closeTime ?? 'N/A'}',
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: _buildDayHoursEditor(day, hours, setDialogState),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                // Footer buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayHoursEditor(
      String day, OperatingHours hours, StateSetter setDialogState) {
    final openTimeController = TextEditingController(text: hours.openTime ?? '09:00');
    final closeTimeController = TextEditingController(text: hours.closeTime ?? '18:00');
    bool isClosed = hours.isClosed;

    return StatefulBuilder(
      builder: (context, setState) => Column(
        children: [
          SwitchListTile(
            title: const Text('Closed'),
            value: isClosed,
            onChanged: (value) {
              setState(() {
                isClosed = value;
              });
            },
          ),
          if (!isClosed) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: openTimeController,
                    decoration: InputDecoration(
                      labelText: 'Open Time (HH:mm)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: closeTimeController,
                    decoration: InputDecoration(
                      labelText: 'Close Time (HH:mm)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setDialogState(() {
                  _operatingHours[day] = OperatingHours(
                    day: day,
                    openTime: isClosed ? null : openTimeController.text,
                    closeTime: isClosed ? null : closeTimeController.text,
                    isClosed: isClosed,
                  );
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Hours updated'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update'),
            ),
          ),
        ],
      ),
    );
  }

  void _showOutletDialog({OutletEntity? outlet}) {
    final isEdit = outlet != null;
    final nameController = TextEditingController(text: outlet?.name ?? '');
    final addressController = TextEditingController(text: outlet?.address ?? '');
    final contactController = TextEditingController(text: outlet?.contactNumber ?? '');
    Map<String, OperatingHours> outletHours = Map.from(outlet?.operatingHours ?? {});

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(isEdit ? Icons.edit : Icons.add, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isEdit ? 'Edit Outlet' : 'Add Outlet',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Outlet Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: addressController,
                          decoration: const InputDecoration(
                            labelText: 'Address',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: contactController,
                          decoration: const InputDecoration(
                            labelText: 'Contact Number',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Operating Hours',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        ...['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
                            .map((day) {
                          final dayHours = outletHours[day] ??
                              OperatingHours(day: day, isClosed: true);
                          return ListTile(
                            title: Text(day),
                            subtitle: Text(dayHours.isClosed
                                ? 'Closed'
                                : '${dayHours.openTime} - ${dayHours.closeTime}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              _showOutletHoursDialog(day, outletHours, (updatedHours) {
                                setDialogState(() {
                                  outletHours = updatedHours;
                                });
                              });
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (isEdit)
                        TextButton.icon(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text('Delete', style: TextStyle(color: Colors.red)),
                          onPressed: () {
                            setState(() {
                              _outlets.removeWhere((o) => o.id == outlet.id);
                            });
                            Navigator.pop(context);
                            _saveProfile();
                          },
                        )
                      else
                        const SizedBox(),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final newOutlet = OutletEntity(
                                id: outlet?.id ?? _uuid.v4(),
                                name: nameController.text.trim(),
                                address: addressController.text.trim(),
                                contactNumber: contactController.text.trim(),
                                operatingHours: outletHours,
                                createdAt: outlet?.createdAt ?? DateTime.now(),
                                updatedAt: DateTime.now(),
                              );

                              setState(() {
                                if (isEdit) {
                                  final index = _outlets.indexWhere((o) => o.id == outlet.id);
                                  if (index != -1) {
                                    _outlets[index] = newOutlet;
                                  }
                                } else {
                                  _outlets.add(newOutlet);
                                }
                              });
                              Navigator.pop(context);
                              _saveProfile();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOutletHoursDialog(String day, Map<String, OperatingHours> hours,
      Function(Map<String, OperatingHours>) onUpdate) {
    final dayHours = hours[day] ?? OperatingHours(day: day, isClosed: true);
    final openTimeController = TextEditingController(text: dayHours.openTime ?? '09:00');
    final closeTimeController = TextEditingController(text: dayHours.closeTime ?? '18:00');
    bool isClosed = dayHours.isClosed;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Operating Hours - $day'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Closed'),
                value: isClosed,
                onChanged: (value) {
                  setDialogState(() {
                    isClosed = value;
                  });
                },
              ),
              if (!isClosed) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: openTimeController,
                  decoration: const InputDecoration(labelText: 'Open Time (HH:mm)'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: closeTimeController,
                  decoration: const InputDecoration(labelText: 'Close Time (HH:mm)'),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedHours = Map<String, OperatingHours>.from(hours);
                updatedHours[day] = OperatingHours(
                  day: day,
                  openTime: isClosed ? null : openTimeController.text,
                  closeTime: isClosed ? null : closeTimeController.text,
                  isClosed: isClosed,
                );
                onUpdate(updatedHours);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VendorProfileBloc, VendorProfileState>(
      listener: (context, state) {
        if (state is VendorProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _isEditing = false;
          });
        } else if (state is VendorProfileReadyState && !_isEditing) {
          _populateFields(state.profile);
        } else if (state is VendorProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is ImageUploaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ImageUploadError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Vendor Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.orange,
          centerTitle: true,
          elevation: 0,
          actions: [
            if (!_isEditing && _isProfileEditable)
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Profile',
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              ),
          ],
        ),
        body: BlocBuilder<VendorProfileBloc, VendorProfileState>(
          builder: (context, state) {
            if (state is VendorProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final profileState =
                state is VendorProfileReadyState ? state : null;

            if (state is VendorProfileError && profileState == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<VendorProfileBloc>()
                            .add(LoadVendorProfileEvent());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final profile = profileState?.profile;
            final isLoading =
                state is ImageUploading || state is VendorProfileUpdating;

            if (_isEditing) {
              return _buildEditView(profile, isLoading);
            } else {
              return _buildViewMode(profileState);
            }
          },
        ),
      ),
    );
  }

  Widget _buildViewMode(VendorProfileReadyState? state) {
    if (state == null) {
      return const Center(child: Text('No profile data available'));
    }

    final profile = state.profile;
    final status = profile.approvalStatus.toLowerCase();
    final bool isPending = status != 'approved' && status != 'rejected';
    final bool isRejected = status == 'rejected';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPending || isRejected) ...[
            Card(
              color: isRejected ? Colors.red[50] : Colors.orange[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isRejected ? Icons.block : Icons.hourglass_bottom,
                      color: isRejected ? Colors.red[400] : Colors.orange[400],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isRejected
                                ? 'Profile Rejected'
                                : 'Approval Pending',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isRejected
                                  ? Colors.red[700]
                                  : Colors.orange[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isRejected
                                ? 'Your submission was rejected. Please contact support for assistance.'
                                : 'An admin is reviewing your submission. You will be notified once it is approved.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Profile Photo
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: profile.profilePhotoUrl != null &&
                          profile.profilePhotoUrl!.isNotEmpty
                      ? NetworkImage(profile.profilePhotoUrl!)
                      : null,
                  child: profile.profilePhotoUrl == null ||
                          profile.profilePhotoUrl!.isEmpty
                      ? const Icon(Icons.person, size: 70)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Business Info Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.business, color: Colors.orange[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          profile.businessName.isEmpty
                              ? 'Business Name'
                              : profile.businessName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow(Icons.phone, 'Contact', profile.contactNumber),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.email, 'Email', profile.emailAddress),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.location_on, 'Address', profile.businessAddress),
                  if (profile.shortDescription.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.shortDescription,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Operating Hours Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.orange[700]),
                      const SizedBox(width: 12),
                      const Text(
                        'Operating Hours',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
                      .map((day) {
                    final hours = profile.operatingHours[day] ??
                        OperatingHours(day: day, isClosed: true);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            day,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            hours.isClosed
                                ? 'Closed'
                                : '${hours.openTime ?? 'N/A'} - ${hours.closeTime ?? 'N/A'}',
                            style: TextStyle(
                              color: hours.isClosed ? Colors.grey : Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Outlets Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.store, color: Colors.orange[700]),
                      const SizedBox(width: 12),
                      const Text(
                        'Outlets',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${profile.outlets.length}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (profile.outlets.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'No outlets added yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    )
                  else
                    ...profile.outlets.map((outlet) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: Colors.grey[50],
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange[100],
                              child: Icon(Icons.store, color: Colors.orange[700]),
                            ),
                            title: Text(
                              outlet.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(outlet.address),
                                const SizedBox(height: 4),
                                Text(outlet.contactNumber),
                              ],
                            ),
                          ),
                        )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Certifications Section
          CertificationsSection(
            certifications: profile.certifications,
            isEditing: false,
            isAdmin: false, // TODO: Check if user is admin
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEditView(VendorProfileEntity? profile, bool isLoading) {
    final bool canEdit = _isProfileEditable && !isLoading;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Photo Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _selectedProfilePhoto != null
                        ? FileImage(_selectedProfilePhoto!)
                        : (profile?.profilePhotoUrl != null &&
                                profile!.profilePhotoUrl!.isNotEmpty
                            ? NetworkImage(profile.profilePhotoUrl!)
                            : null) as ImageProvider?,
                    child: _selectedProfilePhoto == null &&
                            (profile?.profilePhotoUrl == null ||
                                profile!.profilePhotoUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 70)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.orange,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 24, color: Colors.white),
                    onPressed: canEdit ? _showImagePickerDialog : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.photo_camera),
                label: const Text('Change Photo'),
                onPressed: canEdit ? _showImagePickerDialog : null,
              ),
            ),
            const SizedBox(height: 32),

          if (!canEdit) ...[
            Card(
              color: Colors.orange[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lock, color: Colors.orange[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Profile editing is available once your account is approved.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange[800],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

            // Business Name
            _buildTextField(
              label: 'Business Name',
              controller: _businessNameController,
              enabled: canEdit,
              icon: Icons.business,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter business name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Contact Number
            _buildTextField(
              label: 'Contact Number',
              controller: _contactNumberController,
              enabled: canEdit,
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter contact number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Email Address
            _buildTextField(
              label: 'Email Address',
              controller: _emailController,
              enabled: canEdit,
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter email address';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Business Address
            _buildTextField(
              label: 'Business Address',
              controller: _businessAddressController,
              enabled: canEdit,
              icon: Icons.location_on,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter business address';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Operating Hours
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.orange[700]),
                            const SizedBox(width: 12),
                            const Text(
                              'Operating Hours',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                          onPressed:
                              canEdit ? _showOperatingHoursDialog : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
                        .map((day) {
                      final hours = _operatingHours[day] ??
                          OperatingHours(day: day, isClosed: true);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(day),
                            Text(
                              hours.isClosed
                                  ? 'Closed'
                                  : '${hours.openTime ?? 'N/A'} - ${hours.closeTime ?? 'N/A'}',
                              style: TextStyle(
                                color: hours.isClosed ? Colors.grey : Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Short Description
            _buildTextField(
              label: 'Short Description',
              controller: _shortDescriptionController,
              enabled: canEdit,
              icon: Icons.description,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Outlets Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.store, color: Colors.orange[700]),
                            const SizedBox(width: 12),
                            const Text(
                              'Outlets',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add Outlet'),
                          onPressed:
                              canEdit ? () => _showOutletDialog() : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_outlets.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'No outlets added yet',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      )
                    else
                      ..._outlets.map((outlet) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: Colors.grey[50],
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange[100],
                                child: Icon(Icons.store, color: Colors.orange[700]),
                              ),
                              title: Text(outlet.name),
                              subtitle: Text(outlet.address),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: canEdit
                                    ? () => _showOutletDialog(outlet: outlet)
                                    : null,
                              ),
                            ),
                          )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Certifications Section
            CertificationsSection(
              certifications: profile?.certifications ?? [],
              isEditing: canEdit,
              isAdmin: false, // TODO: Check if user is admin
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            setState(() {
                              _isEditing = false;
                            });
                            context.read<VendorProfileBloc>().add(LoadVendorProfileEvent());
                          },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.orange),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: canEdit ? _saveProfile : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Save Profile',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
      ),
      validator: validator,
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? 'Not set' : value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
