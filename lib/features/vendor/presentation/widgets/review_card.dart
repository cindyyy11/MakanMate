import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  @override
  void initState() {
    super.initState();
    // _loadUser();
  }

  // Future<void> _loadUser() async {
  //   try {
  //     final user = await UserService().getUser(widget.review.userId);
  //     if (mounted) {
  //       setState(() {
  //         _user = user;
  //         _isLoadingUser = false;
  //       });
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() {
  //         _isLoadingUser = false;
  //       });
  //     }
  //   }
  // }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today, ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE, HH:mm').format(date);
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String userName = 'Anonymous';
    String? userImageUrl;

    if (authState is Authenticated) {
      userName = authState.user.displayName ?? authState.user.email;
      userImageUrl = authState.user.photoUrl;
    }

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
                  backgroundColor: Colors.grey[300],
                  backgroundImage: userImageUrl != null
                      ? CachedNetworkImageProvider(userImageUrl)
                      : null,
                  child: userImageUrl == null
                      ? Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
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
                              userName,
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
            // Attached Images
            if (widget.review.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.review.imageUrls.length,
                  itemBuilder: (context, index) {
                    final isLast = index == widget.review.imageUrls.length - 1;
                    final hasMore =
                        widget.review.imageUrls.length > 3 && index == 2;
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
                        if (hasMore && !isLast)
                          Positioned.fill(
                            child: Container(
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
            // Likes Count
            if (widget.review.helpfulCount > 0) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.favorite, color: Colors.red[300], size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.review.helpfulCount} likes',
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
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.business,
                          size: 16,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          "Vendor's Reply",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.review.vendorReplyText!,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                    if (widget.review.vendorReplyAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(widget.review.vendorReplyAt!),
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
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
                  if (widget.onReport != null)
                    ElevatedButton.icon(
                      onPressed: widget.onReport,
                      icon: const Icon(Icons.flag, size: 18),
                      label: const Text('Report'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
