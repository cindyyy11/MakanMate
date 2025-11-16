import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/vendor_bloc.dart';
import '../bloc/vendor_event.dart';
import '../bloc/vendor_state.dart';
import '../widgets/menu_card.dart';
import '../../domain/entities/menu_item_entity.dart';
import 'add_edit_menu_page.dart';

class MenuManagementPage extends StatefulWidget {
  const MenuManagementPage({super.key});

  @override
  State<MenuManagementPage> createState() => _MenuManagementPageState();
}

class _MenuManagementPageState extends State<MenuManagementPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load menu items when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorBloc>().add(LoadMenuEvent());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToAddEditPage({MenuItemEntity? item}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<VendorBloc>(),
          child: AddEditMenuPage(menuItem: item),
        ),
      ),
    ).then((_) {
      // Refresh menu after returning from add/edit page
      context.read<VendorBloc>().add(LoadMenuEvent());
    });
  }

  void _handleDelete(String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Menu Item'),
        content: const Text('Are you sure you want to delete this menu item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<VendorBloc>().add(DeleteMenuEvent(itemId));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Menu Management',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true, 
      ),
      body: BlocListener<VendorBloc, VendorState>(
        listener: (context, state) {
          if (state is VendorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is VendorLoaded && state.menu.isEmpty) {
            // Show success message when item is deleted
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                // content: Text('Menu item deleted successfully'),
                content: Text('No menu items found.'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: BlocBuilder<VendorBloc, VendorState>(
          builder: (context, state) {
            if (state is VendorLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is VendorLoaded) {
              final menuItems = state.filteredMenu;
              final selectedCategory = state.selectedCategory;

              return Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search Menu items',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  context.read<VendorBloc>().add(
                                    SearchMenuEvent(''),
                                  );
                                },
                              )
                            : null,
                        
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.orange,
                            width: 1.5,
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.deepOrange,
                            width: 2.0,
                          ),
                        ),

                        filled: true,
                        fillColor: Colors.white, 
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (value) {
                        context.read<VendorBloc>().add(SearchMenuEvent(value));
                      },
                    ),
                  ),

                  // Dynamic Category Filters
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.categories.length,
                      itemBuilder: (context, index) {
                        final category = state.categories[index];
                        final isSelected =
                            (category == 'All' && selectedCategory == null) ||
                            (category != 'All' &&
                                selectedCategory?.toLowerCase() == category.toLowerCase());

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (_) {
                              context.read<VendorBloc>().add(
                                    FilterByCategoryEvent(
                                        category == 'All' ? null : category),
                                  );
                            },
                            selectedColor: Colors.orange[300],
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Menu Items List
                  Expanded(
                    child: menuItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.restaurant_menu,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No menu items found.',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap the + button to add your first menu item',
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              context.read<VendorBloc>().add(LoadMenuEvent());
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: menuItems.length,
                              itemBuilder: (context, index) {
                                final item = menuItems[index];
                                return MenuCard(
                                  item: item,
                                  onEdit: () =>
                                      _navigateToAddEditPage(item: item),
                                  onDelete: () => _handleDelete(item.id),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              );
            }

            if (state is VendorError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<VendorBloc>().add(LoadMenuEvent());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: Text('Press + to add a menu item.'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEditPage(),
        backgroundColor: Colors.orange[700],
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Menu', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
