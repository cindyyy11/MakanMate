import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/rating_entity.dart';
import '../bloc/ratings_bloc.dart';
import '../bloc/ratings_event.dart';
import '../bloc/ratings_state.dart';

class SubmitRatingPage extends StatefulWidget {
  final String vendorId;

  const SubmitRatingPage({
    super.key,
    required this.vendorId,
  });

  @override
  State<SubmitRatingPage> createState() => _SubmitRatingPageState();
}

class _SubmitRatingPageState extends State<SubmitRatingPage> {
  double selectedRating = 0;
  final commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;


    return Scaffold(
      appBar: AppBar(title: Text("Rate Restaurant")),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: BlocConsumer<RatingsBloc, RatingsState>(
          listener: (context, state) {
            if (state is RatingsSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Thank you for your feedback")),
              );
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Your Rating", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),

                // Star Rating
                Row(
                  children: List.generate(5, (index) {
                    final value = index + 1.0;
                    return IconButton(
                      icon: Icon(
                        Icons.star,
                        color: selectedRating >= value ? Colors.orange : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() => selectedRating = value);
                      },
                    );
                  }),
                ),

                SizedBox(height: 20),
                Text("Your Comment"),

                TextField(
                  controller: commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Share about your experience...",
                    border: OutlineInputBorder(),
                  ),
                ),

                SizedBox(height: 20),

                state is RatingsLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () {
                          final ratingData = RatingEntity(
                            userId: userId,
                            vendorId: widget.vendorId,
                            rating: selectedRating,
                            comment: commentController.text.trim(),
                            createdAt: DateTime.now(),
                          );

                          context
                              .read<RatingsBloc>()
                              .add(SubmitRatingEvent(ratingData));
                        },
                        child: Text("Submit Rating"),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}
