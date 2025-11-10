import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../bloc/promotion_bloc.dart';
import '../bloc/promotion_event.dart';
import '../bloc/promotion_state.dart';
import '../../domain/entities/promotion_entity.dart';

class AddEditPromotionPage extends StatefulWidget {
  final PromotionEntity? promotion; // null for add, non-null for edit

  const AddEditPromotionPage({super.key, this.promotion});

  @override
  State<AddEditPromotionPage> createState() => _AddEditPromotionPageState();
}

class _AddEditPromotionPageState extends State<AddEditPromotionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountPercentageController = TextEditingController();
  final _flatDiscountController = TextEditingController();
  final _buyQuantityController = TextEditingController();
  final _getQuantityController = TextEditingController();
  final _imagePicker = ImagePicker();

  PromotionType _selectedType = PromotionType.discount;
  DateTime? _startDate;
  DateTime? _expiryDate;
  File? _selectedImage;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.promotion != null) {
      // Edit mode - populate fields
      final promo = widget.promotion!;
      _titleController.text = promo.title;
      _descriptionController.text = promo.description;
      _selectedType = promo.type;
      _startDate = promo.startDate;
      _expiryDate = promo.expiryDate;
      _currentImageUrl = promo.imageUrl;

      if (promo.discountPercentage != null) {
        _discountPercentageController.text =
            promo.discountPercentage!.toStringAsFixed(0);
      }
      if (promo.flatDiscountAmount != null) {
        _flatDiscountController.text =
            promo.flatDiscountAmount!.toStringAsFixed(2);
      }
      if (promo.buyQuantity != null) {
        _buyQuantityController.text = promo.buyQuantity.toString();
      }
      if (promo.getQuantity != null) {
        _getQuantityController.text = promo.getQuantity.toString();
      }
    } else {
      // Default dates for new promotion
      _startDate = DateTime.now();
      _expiryDate = DateTime.now().add(const Duration(days: 30));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _discountPercentageController.dispose();
    _flatDiscountController.dispose();
    _buyQuantityController.dispose();
    _getQuantityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _currentImageUrl = null;
      });
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_expiryDate != null && _expiryDate!.isBefore(picked)) {
          _expiryDate = picked.add(const Duration(days: 30));
        }
      });
    }
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and expiry dates')),
      );
      return;
    }

    // Validate type-specific fields
    if (_selectedType == PromotionType.discount) {
      final percentage = double.tryParse(_discountPercentageController.text);
      if (percentage == null || percentage <= 0 || percentage > 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid discount percentage (1-100)')),
        );
        return;
      }
    } else if (_selectedType == PromotionType.flatDiscount) {
      final amount = double.tryParse(_flatDiscountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid discount amount')),
        );
        return;
      }
    } else if (_selectedType == PromotionType.buyXGetY) {
      final buyQty = int.tryParse(_buyQuantityController.text);
      final getQty = int.tryParse(_getQuantityController.text);
      if (buyQty == null || buyQty <= 0 || getQty == null || getQty <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter valid quantities')),
        );
        return;
      }
    }

    final promotion = PromotionEntity(
      id: widget.promotion?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _selectedType,
      status: widget.promotion?.status ?? PromotionStatus.pending,
      discountPercentage: _selectedType == PromotionType.discount
          ? double.tryParse(_discountPercentageController.text)
          : null,
      flatDiscountAmount: _selectedType == PromotionType.flatDiscount
          ? double.tryParse(_flatDiscountController.text)
          : null,
      buyQuantity: _selectedType == PromotionType.buyXGetY
          ? int.tryParse(_buyQuantityController.text)
          : null,
      getQuantity: _selectedType == PromotionType.buyXGetY
          ? int.tryParse(_getQuantityController.text)
          : null,
      imageUrl: _currentImageUrl ?? '',
      startDate: _startDate!,
      expiryDate: _expiryDate!,
      createdAt: widget.promotion?.createdAt ?? DateTime.now(),
      approvedAt: widget.promotion?.approvedAt,
      approvedBy: widget.promotion?.approvedBy,
    );

    if (widget.promotion == null) {
      context.read<PromotionBloc>().add(
            AddPromotionEvent(promotion, imageFile: _selectedImage),
          );
    } else {
      context.read<PromotionBloc>().add(
            UpdatePromotionEvent(promotion, imageFile: _selectedImage),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.promotion != null;
    final dateFormat = DateFormat('MMM dd, yyyy');

    return BlocListener<PromotionBloc, PromotionState>(
      listener: (context, state) {
        if (state is PromotionLoaded) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditMode
                    ? 'Promotion updated successfully!'
                    : 'Promotion created! Waiting for admin approval.',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is PromotionError) {
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
          title: Text(isEditMode ? 'Edit Promotion' : 'Create Promotion'),
          elevation: 0,
        ),
        body: BlocBuilder<PromotionBloc, PromotionState>(
          builder: (context, state) {
            final isLoading =
                state is PromotionImageUploading || state is PromotionLoading;

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section
                    GestureDetector(
                      onTap: isLoading ? null : _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : _currentImageUrl != null &&
                                    _currentImageUrl!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      _currentImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.image_not_supported,
                                              size: 48),
                                    ),
                                  )
                                : const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate, size: 48),
                                        SizedBox(height: 8),
                                        Text('Tap to add image'),
                                      ],
                                    ),
                                  ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Title',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'Enter promotion title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Promotion Type
                    const Text(
                      'Promotion Type',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    IgnorePointer(
                      ignoring: isLoading,
                      child: DropdownButtonFormField<PromotionType>(
                        value: _selectedType,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: PromotionType.values.map((type) {
                        String label;
                        switch (type) {
                          case PromotionType.discount:
                            label = 'Discount (%)';
                            break;
                          case PromotionType.flatDiscount:
                            label = 'Flat Discount (RM)';
                            break;
                          case PromotionType.buyXGetY:
                            label = 'Buy X Get Y';
                            break;
                          case PromotionType.birthday:
                            label = 'Birthday Voucher';
                            break;
                        }
                        return DropdownMenuItem(
                          value: type,
                          child: Text(label),
                        );
                      }).toList(),
                      onChanged: isLoading
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedType = value;
                                });
                              }
                            },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Type-specific fields
                    if (_selectedType == PromotionType.discount) ...[
                      const Text(
                        'Discount Percentage',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _discountPercentageController,
                        enabled: !isLoading,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'e.g., 20',
                          suffixText: '%',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter discount percentage';
                          }
                          final percentage = double.tryParse(value);
                          if (percentage == null ||
                              percentage <= 0 ||
                              percentage > 100) {
                            return 'Please enter a valid percentage (1-100)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ] else if (_selectedType == PromotionType.flatDiscount) ...[
                      const Text(
                        'Discount Amount',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _flatDiscountController,
                        enabled: !isLoading,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          prefixText: 'RM ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter discount amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ] else if (_selectedType == PromotionType.buyXGetY) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Buy Quantity',
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _buyQuantityController,
                                  enabled: !isLoading,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: '1',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Required';
                                    }
                                    final qty = int.tryParse(value);
                                    if (qty == null || qty <= 0) {
                                      return 'Invalid';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Get Quantity',
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _getQuantityController,
                                  enabled: !isLoading,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: '1',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Required';
                                    }
                                    final qty = int.tryParse(value);
                                    if (qty == null || qty <= 0) {
                                      return 'Invalid';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      enabled: !isLoading,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Enter promotion description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Start Date
                    const Text(
                      'Start Date',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: isLoading ? null : _pickStartDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _startDate != null
                                  ? dateFormat.format(_startDate!)
                                  : 'Select start date',
                              style: TextStyle(
                                color: _startDate != null
                                    ? Colors.black87
                                    : Colors.grey[600],
                              ),
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Expiry Date
                    const Text(
                      'Expiry Date',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: isLoading ? null : _pickExpiryDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _expiryDate != null
                                  ? dateFormat.format(_expiryDate!)
                                  : 'Select expiry date',
                              style: TextStyle(
                                color: _expiryDate != null
                                    ? Colors.black87
                                    : Colors.grey[600],
                              ),
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[700],
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
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                isEditMode ? 'Update Promotion' : 'Create Promotion',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

