import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportIssuePage extends StatefulWidget {
  const ReportIssuePage({super.key});

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  final _descriptionController = TextEditingController();

  final List<String> categories = [
    "App Bug",
    "Login Issue",
    "Profile / Vendor Info Issue",
    "Menu Management Problem",
    "Analytics Not Loading",
    "Promotion / Voucher Issue",
    "Others"
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitIssue() async {
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection("vendor_issues").add({
      "vendorId": user?.uid,
      "category": _selectedCategory,
      "description": _descriptionController.text.trim(),
      "createdAt": Timestamp.now(),
      "status": "pending",
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Report an Issue",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.orange,
        elevation: 0,
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // CATEGORY SECTION
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select Issue Category",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        hintText: "Choose a category",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.orange, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
                        ),
                      ),
                      items: categories.map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      ).toList(),
                      onChanged: (value) => setState(() => _selectedCategory = value),
                      validator: (value) => value == null ? "Please select a category" : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // DESCRIPTION SECTION
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Describe the Issue",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: "Explain the issue in detail...",
                        alignLabelWithHint: true,
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
                      validator: (value) => value == null || value.isEmpty
                          ? "Description is required"
                          : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // SUBMIT BUTTON
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _submitIssue();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Issue submitted!")),
                    );

                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Submit Issue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
