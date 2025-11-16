import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:makan_mate/features/auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/review_entity.dart';

class ReviewCard extends StatefulWidget {
  final ReviewEntity review;
  final VoidCallback? onReply;
  final VoidCallback? onReport;

  const ReviewCard({
    super.key,
    required this.review,
    this.onReply,
    this.onReport,
  });

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  String? _userName;
  String? _userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _userName = widget.review.userName.isNotEmpty
        ? widget.review.userName
        : 'Anonymous User';
    _loadCustomerInfo();
  }

  Future<void> _loadCustomerInfo() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.review.userId)
          .get();

      if (userDoc.exists && mounted) {
        final data = userDoc.data();
        setState(() {
          _userName = data?['displayName'] ??
              data?['name'] ??
              data?['username'] ??
              data?['email']?.split('@')[0] ??
              _userName;
          _userPhotoUrl = data?['photoUrl'] ?? data?['photoURL'];
        });
      } else if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _userName?.isNotEmpty == true
        ? _userName!
        : 'Anonymous User';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Information and Rating
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.orange[100],
                  backgroundImage: _userPhotoUrl != null
                      ? CachedNetworkImageProvider(_userPhotoUrl!)
                      : null,
                  child: _userPhotoUrl == null
                      ? Text(
                          displayName[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                // Customer Name, Date, and Rating
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Report Icon
                          if (widget.onReport != null)
                            IconButton(
                              icon: const Icon(
                                Icons.flag_outlined,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: widget.onReport,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(widget.review.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      // Rating Stars
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < widget.review.rating.floor()
                                ? Icons.star
                                : index < widget.review.rating
                                    ? Icons.star_half
                                    : Icons.star_border,
                            color: Colors.amber,
                            size: 18,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Review Comment
            if (widget.review.comment.isNotEmpty)
              Text(
                widget.review.comment,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),

            // Tags (if any)
            if (widget.review.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.review.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // Attached Images
            if (widget.review.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.review.imageUrls.length > 3 
                      ? 3 
                      : widget.review.imageUrls.length,
                  itemBuilder: (context, index) {
                    final hasMore = widget.review.imageUrls.length > 3 && index == 2;
                    return Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: widget.review.imageUrls[index],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.error),
                              ),
                            ),
                          ),
                        ),
                        if (hasMore)
                          Positioned.fill(
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.black54,
                              ),
                              child: Center(
                                child: Text(
                                  '+${widget.review.imageUrls.length - 3}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],

            // Aspect Ratings (if any)
            if (widget.review.aspectRatings.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              ...widget.review.aspectRatings.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatAspectName(entry.key),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          return Icon(
                            index < entry.value.floor()
                                ? Icons.star
                                : index < entry.value
                                    ? Icons.star_half
                                    : Icons.star_border,
                            color: Colors.orange[400],
                            size: 14,
                          );
                        }),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],

            // Likes Count
            if (widget.review.helpfulCount > 0) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.thumb_up, color: Colors.blue[300], size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.review.helpfulCount} helpful',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],

            // Vendor Reply Section
            if (widget.review.vendorReplyText != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.store,
                          size: 16,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Vendor's Reply",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                        ),
                        const Spacer(),
                        if (widget.review.vendorReplyAt != null)
                          Text(
                            _formatDate(widget.review.vendorReplyAt!),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green[700],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.review.vendorReplyText!,
                      style: const TextStyle(fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],

            // Action Buttons (Reply and Report)
            if (widget.review.vendorReplyText == null &&
                (widget.onReply != null || widget.onReport != null)) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.onReply != null)
                    ElevatedButton.icon(
                      onPressed: widget.onReply,
                      icon: const Icon(Icons.reply, size: 18),
                      label: const Text('Reply'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  if (widget.onReply != null && widget.onReport != null)
                    const SizedBox(width: 8),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatAspectName(String key) {
    // Convert camelCase or snake_case to readable format
    return key
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        )
        .replaceAll('_', ' ')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
