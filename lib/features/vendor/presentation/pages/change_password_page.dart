import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;

  bool showOld = false;
  bool showNew = false;
  bool showConfirm = false;

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // STEP 1 — Reauthenticate
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPasswordController.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);

      // STEP 2 — Check passwords match
      if (newPasswordController.text.trim() != confirmPasswordController.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("New passwords do not match")),
        );
        setState(() => isLoading = false);
        return;
      }

      // STEP 3 — Update password
      await user.updatePassword(newPasswordController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      String message = "Something went wrong";

      if (e.code == "wrong-password") {
        message = "Your old password is incorrect";
      } else if (e.code == "weak-password") {
        message = "Your new password is too weak";
      } else if (e.code == "requires-recent-login") {
        message = "Please log in again to change your password";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  // UI Component for password field
  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback toggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? "Required field" : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Change Password",
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

              // SECTION TITLE
              const Text(
                "Update Your Password",
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              const Text(
                "Enter your current password and create a new one.",
                style: TextStyle(
                  fontSize: 14, 
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 25),

              // Old password
              _passwordField(
                label: "Old Password",
                controller: oldPasswordController,
                obscure: !showOld,
                toggle: () => setState(() => showOld = !showOld),
              ),

              const SizedBox(height: 20),

              // New password
              _passwordField(
                label: "New Password",
                controller: newPasswordController,
                obscure: !showNew,
                toggle: () => setState(() => showNew = !showNew),
              ),

              const SizedBox(height: 20),

              // Confirm new password
              _passwordField(
                label: "Confirm New Password",
                controller: confirmPasswordController,
                obscure: !showConfirm,
                toggle: () => setState(() => showConfirm = !showConfirm),
              ),

              const SizedBox(height: 30),

              // Submit button
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          _changePassword();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Update Password",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
