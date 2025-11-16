import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _photoController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedGender = "Prefer not to say";
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // Load user info
  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _nameController.text = user.displayName ?? "";
    _photoController.text = user.photoURL ?? "";

    try {
      final doc =
          await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        _cityController.text = data["city"] ?? "";
        _stateController.text = data["state"] ?? "";
        _countryController.text = data["country"] ?? "";
        _phoneController.text = data["phone"] ?? "";
        _selectedGender = data["gender"] ?? "Prefer not to say";
      }
    } catch (e) {
      print("Failed to load profile info: $e");
    }

    setState(() {});
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    File file = File(picked.path);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _loading = true);

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child("profile_photos")
          .child("${user.uid}.jpg");

      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      _photoController.text = downloadUrl;
      await user.updatePhotoURL(downloadUrl);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({"photoURL": downloadUrl}, SetOptions(merge: true));

      _showMessage("Profile photo updated!");
    } catch (e) {
      _showMessage("Failed to upload photo.");
    }

    setState(() => _loading = false);
  }

  Future<void> _saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) return _showMessage("Name cannot be empty.");

    setState(() => _loading = true);

    try {
      await user.updateDisplayName(name);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({
        "name": name,
        "city": _cityController.text.trim(),
        "state": _stateController.text.trim(),
        "country": _countryController.text.trim(),
        "phone": _phoneController.text.trim(),
        "gender": _selectedGender,
        "photoURL": _photoController.text.trim(),
        "email": user.email,
      }, SetOptions(merge: true));

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Success"),
          content: const Text("Your profile has been updated."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      _showMessage("Failed to update profile.");
    }

    setState(() => _loading = false);
  }

  void _showMessage(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Notice"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.orange[300],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile photo
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundImage: _photoController.text.isNotEmpty
                        ? NetworkImage(_photoController.text)
                        : null,
                    backgroundColor: Colors.grey[300],
                    child: _photoController.text.isEmpty
                        ? const Icon(Icons.person, size: 55, color: Colors.white70)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    icon: const Icon(Icons.upload, color: Colors.orange),
                    label: const Text(
                      "Upload Profile Photo",
                      style: TextStyle(color: Colors.orange),
                    ),
                    onPressed: _pickAndUploadImage,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            _buildLabel("Full Name"),
            _inputField(_nameController),
            const SizedBox(height: 18),

            _buildLabel("Phone Number"),
            _inputField(_phoneController, keyboard: TextInputType.phone),
            const SizedBox(height: 18),

            _buildLabel("Gender"),
            _genderDropdown(),
            const SizedBox(height: 18),

            _buildLabel("City"),
            _inputField(_cityController),
            const SizedBox(height: 18),

            _buildLabel("State"),
            _inputField(_stateController),
            const SizedBox(height: 18),

            _buildLabel("Country"),
            _countryPicker(),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Changes",
                        style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  Widget _inputField(TextEditingController controller,
      {TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _countryPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: CountryCodePicker(
        onChanged: (code) {
          setState(() {
            _countryController.text = code.name ?? code.code ?? "";
          });
        },

        initialSelection: _countryController.text.isNotEmpty
            ? _countryController.text
            : "MY",

        showCountryOnly: true,
        showOnlyCountryWhenClosed: true,
        alignLeft: true,
        showDropDownButton: true,
        dialogSize: const Size(350, 500),
        searchDecoration: const InputDecoration(
          hintText: "Search country...",
        ),
      ),
    );
  }

  Widget _genderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButton<String>(
        value: _selectedGender,
        isExpanded: true,
        underline: const SizedBox(),
        items: ["Male", "Female", "Prefer not to say"].map((g) {
          return DropdownMenuItem(value: g, child: Text(g));
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedGender = value!);
        },
      ),
    );
  }
}
