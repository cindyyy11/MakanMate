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
  // Local filter state
  _ReviewFilter _selectedFilter = _ReviewFilter.latest;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReviews());
  }

  void _loadReviews() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Assuming vendorId == restaurantId
      context.read<VendorReviewBloc>().add(LoadVendorReviews(user.uid));
    }
  }

  List<ReviewEntity> _applyFilter(List<ReviewEntity> reviews) {
    switch (_selectedFilter) {
      case _ReviewFilter.latest:
        // Already sorted newest first by repository; ensure order
        final sorted = [...reviews];
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return sorted;
      case _ReviewFilter.replied:
        final replied = reviews
            .where(
              (r) =>
                  (r.vendorReplyText != null && r.vendorReplyText!.isNotEmpty),
            )
            .toList();
        replied.sort((a, b) {
          final aAt = a.vendorReplyAt ?? a.updatedAt;
          final bAt = b.vendorReplyAt ?? b.updatedAt;
          return bAt.compareTo(aAt);
        });
        return replied;
      case _ReviewFilter.unreplied:
        final unreplied = reviews
            .where(
              (r) => r.vendorReplyText == null || r.vendorReplyText!.isEmpty,
            )
            .toList();
        unreplied.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return unreplied;
    }
  }

  void _showReplyDialog(ReviewEntity review) {
    final replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply to Review'),
        content: TextField(
          controller: replyController,
          decoration: const InputDecoration(
            hintText: 'Enter your reply...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (replyController.text.trim().isNotEmpty) {
                context.read<VendorReviewBloc>().add(
                  ReplyToVendorReview(review.id, replyController.text.trim()),
                );
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reply sent successfully')),
                );
              }
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a reason for reporting this review:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Enter reason...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              if (reasonController.text.trim().isNotEmpty) {
                context.read<VendorReviewBloc>().add(
                  ReportVendorReview(review.id, reasonController.text.trim()),
                );
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Review reported successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Report'),
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
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          // Handle no signed-in user to avoid infinite spinner
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser == null) {
            return _buildEmpty(
              icon: Icons.person_off,
              title: 'Not signed in',
              subtitle: 'Sign in to view and manage reviews',
              action: ElevatedButton(
                onPressed: _loadReviews,
                child: const Text('Retry'),
              ),
            );
          }

          if (state is VendorReviewLoading || state is VendorReviewInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is VendorReviewError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading reviews',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadReviews,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final reviews = state is VendorReviewLoaded
              ? state.reviews
              : state is VendorReviewActionInProgress
              ? state.current
              : <ReviewEntity>[];

          final filtered = _applyFilter(reviews);

          if (filtered.isEmpty) {
            final emptySubtitle = _selectedFilter == _ReviewFilter.latest
                ? 'There are no comments recently'
                : _selectedFilter == _ReviewFilter.replied
                ? 'No replied reviews yet'
                : 'No reviews awaiting reply';
            return _buildEmpty(
              icon: Icons.star,
              title: 'No reviews',
              subtitle: emptySubtitle,
              action: ElevatedButton(
                onPressed: _loadReviews,
                child: const Text('Refresh'),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Latest Customer Feedback',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              // Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    _buildFilterChip(
                      'Latest',
                      _selectedFilter == _ReviewFilter.latest,
                      () {
                        setState(() => _selectedFilter = _ReviewFilter.latest);
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Replied',
                      _selectedFilter == _ReviewFilter.replied,
                      () {
                        setState(() => _selectedFilter = _ReviewFilter.replied);
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Unreplied',
                      _selectedFilter == _ReviewFilter.unreplied,
                      () {
                        setState(
                          () => _selectedFilter = _ReviewFilter.unreplied,
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Reviews List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _loadReviews();
                  },
                  child: BlocBuilder(
                    builder: (context, state) {
                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final review = filtered[index];
                          return ReviewCard(
                            review: review,
                            onReply: review.vendorReplyText == null
                                ? () => _showReplyDialog(review)
                                : null,
                            onReport: () => _showReportDialog(review),
                          );
                        },
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

  // Helpers
  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.orange,
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
    );
  }

  Widget _buildEmpty({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(color: Colors.grey[500])),
          if (action != null) ...[const SizedBox(height: 12), action],
        ],
      ),
    );
  }
}

enum _ReviewFilter { latest, replied, unreplied }
