import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../bloc/vendor_profile_bloc.dart';
import '../bloc/vendor_profile_event.dart';
import '../../domain/entities/vendor_profile_entity.dart';

class CertificationsSection extends StatelessWidget {
  final List<CertificationEntity> certifications;
  final bool isEditing;
  final bool isAdmin; // For admin verification features

  const CertificationsSection({
    super.key,
    required this.certifications,
    required this.isEditing,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.verified_user, color: Colors.orange[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Certifications Info',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis, // prevent overflow
                        ),
                      ),
                    ],
                  ),
                ),
                if (isEditing)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                    onPressed: () => _showAddCertificationDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (certifications.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.verified_user_outlined,
                          size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'No certifications added yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...certifications.map((cert) => _buildCertificationCard(
                    context,
                    cert,
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificationCard(
      BuildContext context, CertificationEntity certification) {
    final statusColor = _getStatusColor(certification.status);
    final statusIcon = _getStatusIcon(certification.status);
    final statusText = _getStatusText(certification.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        certification.type,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statusText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isEditing)
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditCertificationDialog(context, certification);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, certification);
                      }
                    },
                  ),
                if (isAdmin && certification.status == CertificationStatus.pending)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _verifyCertification(context, certification),
                        tooltip: 'Verify',
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _rejectCertification(context, certification),
                        tooltip: 'Reject',
                      ),
                    ],
                  ),
              ],
            ),
            if (certification.certificateNumber != null &&
                certification.certificateNumber!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.badge, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Certificate #: ${certification.certificateNumber}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
            ],
            if (certification.expiryDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Expires: ${DateFormat('MMM dd, yyyy').format(certification.expiryDate!)}',
                    style: TextStyle(
                      color: certification.expiryDate!.isBefore(DateTime.now())
                          ? Colors.red
                          : Colors.grey[700],
                      fontSize: 14,
                      fontWeight: certification.expiryDate!.isBefore(DateTime.now())
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
            if (certification.certificateImageUrl != null &&
                certification.certificateImageUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _showCertificateImage(context, certification),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      certification.certificateImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (certification.rejectionReason != null &&
                certification.rejectionReason!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rejection Reason:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red[900],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            certification.rejectionReason!,
                            style: TextStyle(color: Colors.red[800]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(CertificationStatus status) {
    switch (status) {
      case CertificationStatus.verified:
        return Colors.green;
      case CertificationStatus.pending:
        return Colors.orange;
      case CertificationStatus.rejected:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(CertificationStatus status) {
    switch (status) {
      case CertificationStatus.verified:
        return Icons.check_circle;
      case CertificationStatus.pending:
        return Icons.pending;
      case CertificationStatus.rejected:
        return Icons.cancel;
    }
  }

  String _getStatusText(CertificationStatus status) {
    switch (status) {
      case CertificationStatus.verified:
        return 'Verified';
      case CertificationStatus.pending:
        return 'Pending';
      case CertificationStatus.rejected:
        return 'Rejected';
    }
  }

  void _showAddCertificationDialog(BuildContext context) {
    final availableTypes = [
      'Halal',
      'Vegetarian',
      'Vegan',
      'Alcohol-Free',
      'Gluten-Free',
      'Organic',
      'Kosher',
      'Other'
    ];
    String? selectedType;
    final certificateNumberController = TextEditingController();
    DateTime? expiryDate;
    File? certificateImage;
    final imagePicker = ImagePicker();

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
                      const Icon(Icons.add_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Add Certification',
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Certification Type',
                            border: OutlineInputBorder(),
                          ),
                          items: availableTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedType = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: certificateNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Certificate Number (Optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 3650)),
                            );
                            if (date != null) {
                              setDialogState(() {
                                expiryDate = date;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Expiry Date (Optional)',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              expiryDate != null
                                  ? DateFormat('MMM dd, yyyy').format(expiryDate!)
                                  : 'Select date',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (certificateImage != null)
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                certificateImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        else
                          InkWell(
                            onTap: () async {
                              final image = await imagePicker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 85,
                              );
                              if (image != null) {
                                setDialogState(() {
                                  certificateImage = File(image.path);
                                });
                              }
                            },
                            child: Container(
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate, size: 48),
                                  SizedBox(height: 8),
                                  Text('Tap to upload certificate image'),
                                ],
                              ),
                            ),
                          ),
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
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: selectedType == null
                            ? null
                            : () {
                                final certification = CertificationEntity(
                                  id: const Uuid().v4(),
                                  type: selectedType!,
                                  certificateNumber:
                                      certificateNumberController.text.trim().isEmpty
                                          ? null
                                          : certificateNumberController.text.trim(),
                                  expiryDate: expiryDate,
                                  status: CertificationStatus.pending,
                                  createdAt: DateTime.now(),
                                  updatedAt: DateTime.now(),
                                );

                                context.read<VendorProfileBloc>().add(
                                      AddCertificationEvent(
                                        certification,
                                        certificateImageFile: certificateImage,
                                      ),
                                    );
                                Navigator.pop(context);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Add'),
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

  void _showEditCertificationDialog(
      BuildContext context, CertificationEntity certification) {
    final availableTypes = [
      'Halal',
      'Vegetarian',
      'Vegan',
      'Alcohol-Free',
      'Gluten-Free',
      'Organic',
      'Kosher',
      'Other'
    ];
    String selectedType = certification.type;
    final certificateNumberController =
        TextEditingController(text: certification.certificateNumber ?? '');
    DateTime? expiryDate = certification.expiryDate;
    File? certificateImage;
    final imagePicker = ImagePicker();

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
                      const Icon(Icons.edit, color: Colors.white),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Edit Certification',
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Certification Type',
                            border: OutlineInputBorder(),
                          ),
                          items: availableTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedType = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: certificateNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Certificate Number (Optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: expiryDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 3650)),
                            );
                            if (date != null) {
                              setDialogState(() {
                                expiryDate = date;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Expiry Date (Optional)',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              expiryDate != null
                                  ? DateFormat('MMM dd, yyyy').format(expiryDate!)
                                  : 'Select date',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (certificateImage != null)
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                certificateImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        else if (certification.certificateImageUrl != null)
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                certification.certificateImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(child: Icon(Icons.image_not_supported)),
                              ),
                            ),
                          )
                        else
                          InkWell(
                            onTap: () async {
                              final image = await imagePicker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 85,
                              );
                              if (image != null) {
                                setDialogState(() {
                                  certificateImage = File(image.path);
                                });
                              }
                            },
                            child: Container(
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate, size: 48),
                                  SizedBox(height: 8),
                                  Text('Tap to upload certificate image'),
                                ],
                              ),
                            ),
                          ),
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
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final updatedCertification = certification.copyWith(
                            type: selectedType,
                            certificateNumber:
                                certificateNumberController.text.trim().isEmpty
                                    ? null
                                    : certificateNumberController.text.trim(),
                            expiryDate: expiryDate,
                            updatedAt: DateTime.now(),
                          );

                          context.read<VendorProfileBloc>().add(
                                UpdateCertificationEvent(
                                  updatedCertification,
                                  certificateImageFile: certificateImage,
                                ),
                              );
                          Navigator.pop(context);
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

  void _showDeleteConfirmation(
      BuildContext context, CertificationEntity certification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Certification'),
        content: Text('Are you sure you want to delete ${certification.type} certification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<VendorProfileBloc>().add(
                    DeleteCertificationEvent(certification.id),
                  );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCertificateImage(
      BuildContext context, CertificationEntity certification) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text('${certification.type} Certificate'),
              backgroundColor: Colors.orange,
            ),
            Image.network(
              certification.certificateImageUrl!,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }

  void _verifyCertification(
      BuildContext context, CertificationEntity certification) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<VendorProfileBloc>().add(
            VerifyCertificationEvent(certification.id, user.uid),
          );
    }
  }

  void _rejectCertification(
      BuildContext context, CertificationEntity certification) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Certification'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Rejection Reason',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                context.read<VendorProfileBloc>().add(
                      RejectCertificationEvent(
                        certification.id,
                        user.uid,
                        reasonController.text.trim(),
                      ),
                    );
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

