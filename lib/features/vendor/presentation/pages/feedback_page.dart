import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int rating = 0;
  final TextEditingController messageController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Widget star(int index) {
    return IconButton(
      icon: Icon(
        index <= rating ? Icons.star : Icons.star_border,
        size: 32,
        color: Colors.orange,
      ),
      onPressed: () {
        setState(() {
          rating = index;
        });
      },
    );
  }

  Future<void> _submitFeedback() async {
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection("vendor_feedback").add({
      "vendorId": user?.uid,
      "rating": rating,
      "message": messageController.text.trim(),
      "createdAt": Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Feedback",
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "How was your experience?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [1, 2, 3, 4, 5].map(star).toList(),
            ),

            const SizedBox(height: 20),

            const Text(
              "Any comments? (Optional)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: messageController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Tell us what you think...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.orange, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () async {
                if (rating == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select a rating")),
                  );
                  return;
                }

                await _submitFeedback();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Feedback submitted!")),
                );

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("Submit Feedback"),
            ),
          ],
        ),
      ),
    );
  }
}
