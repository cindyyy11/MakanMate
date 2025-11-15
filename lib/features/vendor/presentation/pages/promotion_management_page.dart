import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/promotion_bloc.dart';
import '../bloc/promotion_event.dart';
import '../bloc/promotion_state.dart';
import '../widgets/promotion_card.dart';
import '../../domain/entities/promotion_entity.dart';
import 'add_edit_promotion_page.dart';

class PromotionManagementPage extends StatefulWidget {
  const PromotionManagementPage({super.key});

  @override
  State<PromotionManagementPage> createState() =>
      _PromotionManagementPageState();
}

class _PromotionManagementPageState extends State<PromotionManagementPage> {
  @override
  void initState() {
    super.initState();
    // Load promotions when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PromotionBloc>().add(LoadPromotionsEvent());
    });
  }

  void _navigateToAddEditPage({PromotionEntity? promotion}) {
    // Capture the existing bloc from the current page's context
    final bloc = context.read<PromotionBloc>();

    Navigator.push(
      context,
      MaterialPageRoute(
        // Use a different parameter name or `_` to avoid shadowing the
        // outer context. Pass the captured bloc instance forward.
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: AddEditPromotionPage(promotion: promotion),
        ),
      ),
    ).then((_) {
      // Refresh promotions after returning
      bloc.add(LoadPromotionsEvent());
    });
  }

  void _handleDeactivate(String promotionId) {
    // Capture bloc from the current widget context so the dialog builder
    // doesn't try to read from a context without the provider.
    final bloc = context.read<PromotionBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Deactivate Promotion'),
        content: const Text(
          'Are you sure you want to deactivate this promotion?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              bloc.add(DeactivatePromotionEvent(promotionId));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Deals & Promotions',
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
      body: BlocListener<PromotionBloc, PromotionState>(
        listener: (context, state) {
          if (state is PromotionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<PromotionBloc, PromotionState>(
          builder: (context, state) {
            if (state is PromotionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PromotionLoaded) {
              final promotions = state.filteredPromotions;
              final selectedStatus = state.selectedStatus;

              return Column(
                children: [
                  // Filter Buttons
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Filter by status',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Colors.orange,    // <- Visible border color
                            width: 1.5,
                          ),
                        ),
                        // Border when clicked (focused)
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.deepOrange, // <- Stronger focus color
                            width: 2.0,
                          ),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('All')),
                        DropdownMenuItem(value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'approved', child: Text('Approved')),
                        DropdownMenuItem(value: 'active', child: Text('Active')),
                        DropdownMenuItem(value: 'expired', child: Text('Expired')),
                        DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                        DropdownMenuItem(value: 'deactivated', child: Text('Deactivated')),
                      ],
                      onChanged: (value) {
                        context.read<PromotionBloc>()
                            .add(FilterPromotionsByStatusEvent(value));
                      },
                    ),
                  ),


                  // Create New Promotion Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _navigateToAddEditPage(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Create New Promotion',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Promotions List
                  Expanded(
                    child: promotions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.local_offer,
                                    size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No promotions found.',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap "Create New Promotion" to add your first promotion',
                                  style: TextStyle(color: Colors.grey[500]),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              context
                                  .read<PromotionBloc>()
                                  .add(LoadPromotionsEvent());
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: promotions.length,
                              itemBuilder: (context, index) {
                                final promotion = promotions[index];
                                return PromotionCard(
                                  promotion: promotion,
                                  onEdit: () =>
                                      _navigateToAddEditPage(promotion: promotion),
                                  onDeactivate: () =>
                                      _handleDeactivate(promotion.id),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              );
            }

            if (state is PromotionError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<PromotionBloc>()
                            .add(LoadPromotionsEvent());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return const Center(
              child: Text('Press "Create New Promotion" to add a promotion.'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterButton(
    String label,
    bool isSelected,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

