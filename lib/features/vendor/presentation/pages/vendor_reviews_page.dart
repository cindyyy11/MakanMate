import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../bloc/vendor_review_bloc.dart';
import '../bloc/vendor_review_event.dart';
import '../bloc/vendor_review_state.dart';
import '../widgets/review_card.dart';
import '../../domain/entities/review_entity.dart';

class VendorReviewsPage extends StatefulWidget {
  const VendorReviewsPage({super.key});

  @override
  State<VendorReviewsPage> createState() => _VendorReviewsPageState();
}

class _VendorReviewsPageState extends State<VendorReviewsPage> {
  _ReviewFilter _selectedFilter = _ReviewFilter.latest;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReviews());
  }

  void _loadReviews() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first')),
      );
      return;
    }

    try {
      // Get vendor document
      final vendorDoc = await FirebaseFirestore.instance
          .collection('vendors')
          .doc(user.uid)
          .get();
      
      if (!vendorDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vendor profile not found')),
        );
        return;
      }

      final vendorId = vendorDoc.id;
    
      // Load reviews via bloc
      context.read<VendorReviewBloc>().add(LoadVendorReviews(vendorId));
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  List<ReviewEntity> _applyFilter(List<ReviewEntity> reviews) {
    List<ReviewEntity> filtered;

    switch (_selectedFilter) {
      case _ReviewFilter.latest:
        filtered = [...reviews];
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;

      case _ReviewFilter.replied:
        filtered = reviews.where((review) {
          final hasReply = review.vendorReplyText != null && 
                          review.vendorReplyText!.trim().isNotEmpty;
          return hasReply;
        }).toList();
        filtered.sort((a, b) {
          final aReplyDate = a.vendorReplyAt ?? a.createdAt;
          final bReplyDate = b.vendorReplyAt ?? b.createdAt;
          return bReplyDate.compareTo(aReplyDate);
        });
        break;

      case _ReviewFilter.unreplied:
        filtered = reviews.where((review) {
          final hasReply = review.vendorReplyText != null && 
                          review.vendorReplyText!.trim().isNotEmpty;
          return !hasReply;
        }).toList();
        
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
    }

    return filtered;
  }

  int _getFilterCount(List<ReviewEntity> allReviews, _ReviewFilter filter) {
    switch (filter) {
      case _ReviewFilter.latest:
        return allReviews.length;
      case _ReviewFilter.replied:
        return allReviews.where((r) => 
          r.vendorReplyText != null && r.vendorReplyText!.trim().isNotEmpty
        ).length;
      case _ReviewFilter.unreplied:
        return allReviews.where((r) => 
          r.vendorReplyText == null || r.vendorReplyText!.trim().isEmpty
        ).length;
    }
  }

  void _showReplyDialog(ReviewEntity review) {
    final replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply to Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show the review being replied to
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < review.rating ? Icons.star : Icons.star_border,
                          color: Colors.orange,
                          size: 16,
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review.comment,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: replyController,
              decoration: const InputDecoration(
                hintText: 'Enter your reply...',
                border: OutlineInputBorder(),
                labelText: 'Your Reply',
              ),
              maxLines: 4,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = replyController.text.trim();
              if (text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a reply')),
                );
                return;
              }
              
              context.read<VendorReviewBloc>().add(
                ReplyToVendorReview(review.id, text),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reply sent successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Reply'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(ReviewEntity review) {
    final reasonController = TextEditingController();
    String? selectedReason;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Report Review'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select a reason:', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                ...[
                  'Inappropriate content',
                  'Spam or fake',
                  'Offensive language',
                  'Off-topic',
                  'Other',
                ].map((reason) {
                  return RadioListTile<String>(
                    title: Text(reason, style: const TextStyle(fontSize: 14)),
                    value: reason,
                    groupValue: selectedReason,
                    onChanged: (value) {
                      setDialogState(() => selectedReason = value);
                    },
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    hintText: 'Additional details (optional)...',
                    border: OutlineInputBorder(),
                    labelText: 'Details',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedReason == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a reason')),
                  );
                  return;
                }

                final details = reasonController.text.trim();
                final fullReason = details.isNotEmpty 
                    ? '$selectedReason: $details'
                    : selectedReason!;

                context.read<VendorReviewBloc>().add(
                  ReportVendorReview(review.id, fullReason),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Review reported successfully'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Report'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reviews & Ratings',
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
      body: BlocConsumer<VendorReviewBloc, VendorReviewState>(
        listener: (context, state) {
          if (state is VendorReviewError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          // Handle loading
          if (state is VendorReviewLoading || state is VendorReviewInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle error
          if (state is VendorReviewError) {
            return _buildEmpty(
              icon: Icons.error_outline,
              title: 'Failed to load reviews',
              subtitle: state.message,
              action: ElevatedButton.icon(
                onPressed: _loadReviews,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            );
          }

          // Get all reviews
          final allReviews = state is VendorReviewLoaded
              ? state.reviews
              : state is VendorReviewActionInProgress
                  ? state.current
                  : <ReviewEntity>[];

          // Apply filter
          final filtered = _applyFilter(allReviews);

          // Show empty state
          if (allReviews.isEmpty) {
            return _buildEmpty(
              icon: Icons.star_border,
              title: 'No reviews yet',
              subtitle: 'Customer reviews will appear here',
              action: ElevatedButton.icon(
                onPressed: _loadReviews,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            );
          }

          return Column(
            children: [
              // Stats header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.orange[50],
                child: Row(
                  children: [
                    _buildStatCard(
                      'Total',
                      allReviews.length.toString(),
                      Icons.reviews,
                    ),
                    const SizedBox(width: 8),
                    _buildStatCard(
                      'Replied',
                      _getFilterCount(allReviews, _ReviewFilter.replied).toString(),
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    _buildStatCard(
                      'Pending',
                      _getFilterCount(allReviews, _ReviewFilter.unreplied).toString(),
                      Icons.pending,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),

              // Filters - Made scrollable to prevent overflow
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildFilterChip(
                        'All Reviews',
                        _selectedFilter == _ReviewFilter.latest,
                        () => setState(() => _selectedFilter = _ReviewFilter.latest),
                        count: _getFilterCount(allReviews, _ReviewFilter.latest),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Replied',
                        _selectedFilter == _ReviewFilter.replied,
                        () => setState(() => _selectedFilter = _ReviewFilter.replied),
                        count: _getFilterCount(allReviews, _ReviewFilter.replied),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Unreplied',
                        _selectedFilter == _ReviewFilter.unreplied,
                        () => setState(() => _selectedFilter = _ReviewFilter.unreplied),
                        count: _getFilterCount(allReviews, _ReviewFilter.unreplied),
                      ),
                    ],
                  ),
                ),
              ),

              // Reviews list
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmpty(
                        icon: Icons.filter_list_off,
                        title: 'No ${_selectedFilter.name} reviews',
                        subtitle: 'Try selecting a different filter',
                        action: null,
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _loadReviews(),
                        child: ListView.builder(
                          itemCount: filtered.length,
                          padding: const EdgeInsets.only(bottom: 16),
                          itemBuilder: (context, index) {
                            final review = filtered[index];
                            return ReviewCard(
                              review: review,
                              onReply: review.vendorReplyText == null ||
                                      review.vendorReplyText!.trim().isEmpty
                                  ? () => _showReplyDialog(review)
                                  : null,
                              onReport: () => _showReportDialog(review),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, {Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color ?? Colors.grey[700], size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color ?? Colors.grey[900],
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap, {int? count}) {
    return FilterChip(
      label: Text(count != null ? '$label ($count)' : label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.orange,
      checkmarkColor: Colors.white,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildEmpty({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 70, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              action,
            ],
          ],
        ),
      ),
    );
  }
}

enum _ReviewFilter { latest, replied, unreplied }