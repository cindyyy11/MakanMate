import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AllReviewsPage extends StatefulWidget {
  final String vendorId;
  final String vendorName;

  const AllReviewsPage({
    super.key,
    required this.vendorId,
    required this.vendorName,
  });

  @override
  State<AllReviewsPage> createState() => _AllReviewsPageState();
}

class _AllReviewsPageState extends State<AllReviewsPage> {
  String selectedSort = "newest";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  /// 🔥 EXACT SAME REVIEW QUERY LOGIC AS RestaurantDetailPage
  Stream<QuerySnapshot<Map<String, dynamic>>> _watchReviews(
      String vendorId, String sortBy) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('reviews')
        .where('vendorId', isEqualTo: vendorId);

    switch (sortBy) {
      case "oldest":
        query = query.orderBy('createdAt', descending: false);
        break;
      case "highest":
        query = query
            .orderBy('rating', descending: true)
            .orderBy('createdAt', descending: true);
        break;
      case "lowest":
        query = query
            .orderBy('rating', descending: false)
            .orderBy('createdAt', descending: true);
        break;
      case "helpful":
        query = query
            .orderBy('helpfulCount', descending: true)
            .orderBy('createdAt', descending: true);
        break;
      default:
        query = query.orderBy('createdAt', descending: true);
        break;
    }

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("All Reviews • ${widget.vendorName}"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 12, bottom: 4),
            child: Row(
              children: [
                const Text(
                  "Sort by:",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: selectedSort,
                  underline: Container(height: 0),
                  items: const [
                    DropdownMenuItem(value: "newest", child: Text("Newest")),
                    DropdownMenuItem(value: "oldest", child: Text("Oldest")),
                    DropdownMenuItem(value: "highest", child: Text("Highest Rating")),
                    DropdownMenuItem(value: "lowest", child: Text("Lowest Rating")),
                    DropdownMenuItem(value: "helpful", child: Text("Most Helpful")),
                  ],
                  onChanged: (v) => setState(() => selectedSort = v!),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _watchReviews(widget.vendorId, selectedSort),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No reviews yet.",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final r = docs[i].data();

                    final double rating =
                        (r['rating'] as num?)?.toDouble() ?? 0.0;
                    final String comment = r['comment'] ?? '';
                    final Timestamp? ts = r['createdAt'];
                    final String dateStr = ts != null
                        ? ts.toDate().toString().split(" ").first
                        : "";

                    final List<dynamic> imageUrls = r['imageUrls'] ?? [];
                    final List<dynamic> tags = r['tags'] ?? [];

                    return Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// ⭐ Star + Date Row (bigger, cleaner)
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 22),
                              const SizedBox(width: 6),
                              Text(
                                rating.toStringAsFixed(1),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const Spacer(),
                              Text(
                                dateStr,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Text(
                            comment,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 12),

                          if (tags.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: tags
                                  .map(
                                    (t) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        t.toString(),
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),

                          if (tags.isNotEmpty) const SizedBox(height: 12),

                          if (imageUrls.isNotEmpty)
                            SizedBox(
                              height: 90,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: imageUrls.map((url) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        url,
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 90,
                                          height: 90,
                                          color: Colors.grey[300],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
