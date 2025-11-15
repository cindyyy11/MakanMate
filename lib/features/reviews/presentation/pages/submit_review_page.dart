import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:makan_mate/features/reviews/domain/entities/review_entity.dart';
import 'package:makan_mate/features/reviews/presentation/bloc/review_bloc.dart';
import 'package:makan_mate/features/reviews/presentation/bloc/review_event.dart';
import 'package:makan_mate/features/reviews/presentation/bloc/review_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubmitReviewPage extends StatefulWidget {
  final String vendorId;
  const SubmitReviewPage({super.key, required this.vendorId});

  @override
  State<SubmitReviewPage> createState() => _SubmitReviewPageState();
}

class _SubmitReviewPageState extends State<SubmitReviewPage> {
  double rating = 0;
  double taste = 0, service = 0, ambiance = 0, value = 0;

  final commentController = TextEditingController();
  List<String> selectedTags = [];
  List<XFile> pickedImages = [];
  List<String> commonTags = [];

  @override
  void initState() {
    super.initState();
    loadCommonTags();
  }

  Future<void> loadCommonTags() async {
    final snap =
        await FirebaseFirestore.instance.collection("common_tags").get();

    setState(() {
      commonTags = snap.docs
          .map((doc) => doc.data()["label"]?.toString() ?? "")
          .where((t) => t.isNotEmpty)
          .toList();
    });
  }

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final images = await picker.pickMultiImage();

    if (images != null) {
      setState(() {
        pickedImages = images;
      });
    }
  }

  Future<List<String>> uploadImages(String reviewId) async {
    List<String> urls = [];

    for (int i = 0; i < pickedImages.length; i++) {
      final img = pickedImages[i];
      final ref =
          FirebaseStorage.instance.ref().child("reviews/$reviewId/img_$i.jpg");

      await ref.putFile(File(img.path));
      urls.add(await ref.getDownloadURL());
    }

    return urls;
  }

  Future<void> _showPopup(String title, String message) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Write a Review"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: BlocConsumer<ReviewBloc, ReviewState>(
        listener: (context, state) async {
          if (state is ReviewSuccess) {
            await _showPopup("Success", "Thank you for your review!");
            Navigator.pop(context, true);
          } else if (state is ReviewFailure) {
            await _showPopup("Error", state.message);
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ratingSection(),
              const SizedBox(height: 20),
              _aspectRatings(),
              const SizedBox(height: 20),
              _commentBox(),
              const SizedBox(height: 20),
              _tagSelector(),
              const SizedBox(height: 20),
              _imagePickerUI(),
              const SizedBox(height: 30),
              _submitButton(user),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------
  // UI Components
  // ---------------------------

  Widget _ratingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Overall Rating",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 10),
        Row(
          children: List.generate(5, (index) {
            final value = (index + 1).toDouble();
            return IconButton(
              onPressed: () => setState(() => rating = value),
              icon: Icon(Icons.star,
                  size: 32, color: rating >= value ? Colors.amber : Colors.grey),
            );
          }),
        ),
      ],
    );
  }

  Widget _aspectRatings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _aspectRow("Taste", (v) => taste = v, taste),
        _aspectRow("Service", (v) => service = v, service),
        _aspectRow("Ambiance", (v) => ambiance = v, ambiance),
        _aspectRow("Value", (v) => value = v, value),
      ],
    );
  }

  Widget _aspectRow(String label, Function(double) onChanged, double current) {
    return Row(
      children: [
        SizedBox(width: 90, child: Text(label)),
        Expanded(
          child: Slider(
            value: current,
            min: 0,
            max: 5,
            divisions: 5,
            label: current.toString(),
            onChanged: (val) => setState(() => onChanged(val)),
          ),
        ),
      ],
    );
  }

  Widget _commentBox() {
    return TextField(
      controller: commentController,
      maxLines: 4,
      decoration: const InputDecoration(
        labelText: "Write your review...",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _tagSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Tags (optional)",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: commonTags.map((tag) {
            final isSelected = selectedTags.contains(tag);
            return ChoiceChip(
              label: Text(tag),
              selected: isSelected,
              selectedColor: Colors.black,
              backgroundColor: Colors.grey[300],
              labelStyle:
                  TextStyle(color: isSelected ? Colors.white : Colors.black),
              onSelected: (val) {
                setState(() {
                  val ? selectedTags.add(tag) : selectedTags.remove(tag);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _imagePickerUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Photos (optional)",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),

        ElevatedButton(onPressed: pickImages, child: const Text("Add Images")),

        const SizedBox(height: 10),

        if (pickedImages.isNotEmpty)
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: pickedImages.map((img) {
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(img.path),
                        width: 90, height: 90, fit: BoxFit.cover),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _submitButton(User? user) {
    return ElevatedButton(
      onPressed: () async {
        if (rating == 0) {
          return _showPopup("Missing Rating", "Please give an overall rating.");
        }
        if (commentController.text.trim().isEmpty) {
          return _showPopup("Missing Comment", "Please write a short review.");
        }

        final reviewId =
            FirebaseFirestore.instance.collection("reviews").doc().id;

        final imageUrls = await uploadImages(reviewId);

        final review = ReviewEntity(
          id: reviewId,
          userId: user?.uid ?? "",
          itemId: "",
          vendorId: widget.vendorId,
          outletId: null,
          rating: rating,
          comment: commentController.text.trim(),
          imageUrls: imageUrls,
          aspectRatings: {
            "taste": taste,
            "service": service,
            "ambiance": ambiance,
            "value": value,
          },
          tags: selectedTags,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        context.read<ReviewBloc>().add(SubmitReviewEvent(review));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: const Text("Submit Review"),
    );
  }
}
