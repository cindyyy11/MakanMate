import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/vendor_bloc.dart';
import '../bloc/vendor_event.dart';
import '../bloc/vendor_state.dart';
import '../../domain/entities/menu_item_entity.dart';

class AddEditMenuPage extends StatefulWidget {
  final MenuItemEntity? menuItem; // null for add, non-null for edit

  const AddEditMenuPage({super.key, this.menuItem});

  @override
  State<AddEditMenuPage> createState() => _AddEditMenuPageState();
}

class _AddEditMenuPageState extends State<AddEditMenuPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _imagePicker = ImagePicker();
  
  bool _isAvailable = true;
  File? _selectedImage;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.menuItem != null) {
      // Edit mode - populate fields
      final item = widget.menuItem!;
      _nameController.text = item.name;
      _categoryController.text = item.category;
      _priceController.text = item.price.toStringAsFixed(2);
      _descriptionController.text = item.description;
      _caloriesController.text = item.calories.toString();
      _isAvailable = item.available;
      _currentImageUrl = item.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _caloriesController.dispose();
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
        _currentImageUrl = null; // Clear old URL when new image is selected
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _currentImageUrl = null;
    });
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text);
    final calories = int.tryParse(_caloriesController.text);

    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      return;
    }

    if (calories == null || calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid calories')),
      );
      return;
    }

    final menuItem = MenuItemEntity(
      id: widget.menuItem?.id ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _categoryController.text.trim(),
      price: price,
      calories: calories,
      imageUrl: _currentImageUrl ?? '',
      available: _isAvailable,
    );

    if (widget.menuItem == null) {
      // Add new item
      context.read<VendorBloc>().add(
            AddMenuEvent(menuItem, imageFile: _selectedImage),
          );
    } else {
      // Update existing item
      context.read<VendorBloc>().add(
            UpdateMenuEvent(menuItem, imageFile: _selectedImage),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.menuItem != null;

    return BlocListener<VendorBloc, VendorState>(
      listener: (context, state) {
        if (state is VendorLoaded) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditMode ? 'Menu item updated successfully!' : 'Menu item added successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is VendorError) {
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
          title: const Text('Menu Info'),
          elevation: 0,
        ),
        body: BlocBuilder<VendorBloc, VendorState>(
          builder: (context, state) {
            final isLoading = state is ImageUploading || state is VendorLoading;

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        const Text(
                          'Menu Management',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.edit, size: 18, color: Colors.grey[600]),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Featured Image Section
                    Row(
                      children: [
                        // Main image
                        Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTap: isLoading ? null : _pickImage,
                            child: Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Stack(
                                children: [
                                  if (_selectedImage != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        _selectedImage!,
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  else if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        _currentImageUrl!,
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.image_not_supported, size: 48),
                                      ),
                                    )
                                  else
                                    const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_photo_alternate, size: 48),
                                          SizedBox(height: 8),
                                          Text('Tap to add image'),
                                        ],
                                      ),
                                    ),
                                  if ((_selectedImage != null || _currentImageUrl != null) && !isLoading)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: IconButton(
                                        icon: const Icon(Icons.close, color: Colors.white),
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.black.withOpacity(0.6),
                                        ),
                                        onPressed: _removeImage,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Add image button
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: isLoading ? null : _pickImage,
                            child: Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: const Center(
                                child: Icon(Icons.add, size: 32),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Name Field
                    const Text(
                      'Name',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'Enter menu item name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Categories Field
                    const Text(
                      'Categories',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _categoryController,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'e.g., Mains, Appetizers, Desserts',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Price and Available Toggle
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Price',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _priceController,
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
                                    return 'Please enter a price';
                                  }
                                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                    return 'Please enter a valid price';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Available?',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            Switch(
                              value: _isAvailable,
                              onChanged: isLoading
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _isAvailable = value;
                                      });
                                    },
                              activeThumbColor: Colors.orange[700],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Calories Field
                    const Text(
                      'Calories',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _caloriesController,
                      enabled: !isLoading,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter calories',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter calories';
                        }
                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                          return 'Please enter valid calories';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description Field
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
                        hintText: 'Enter description',
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
                    const SizedBox(height: 32),

                    // Upload/Save Button
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
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Upload',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

