import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _loading = false;

  Future<void> _changePassword() async {
    final current = _currentController.text.trim();
    final newPass = _newController.text.trim();
    final confirm = _confirmController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      return _showMessage("All fields are required.");
    }
    if (newPass.length < 6) {
      return _showMessage("New password must be at least 6 characters.");
    }
    if (newPass != confirm) {
      return _showMessage("New passwords do not match.");
    }

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        throw "User not found";
      }

      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: current,
      );
      await user.reauthenticateWithCredential(cred);

      await user.updatePassword(newPass);

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Success!"),
          content: const Text("Your password has been updated successfully."),
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
      setState(() => _loading = false);

      String msg = "Something went wrong. Please try again.";

      if (e.toString().contains("wrong-password") ||
          e.toString().contains("invalid-credential")) {
        msg = "Your current password is incorrect.";
      } else if (e.toString().contains("requires-recent-login")) {
        msg =
            "For security reasons, please log in again to change your password.";
      }

      _showMessage(msg);
    }
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Oops!",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(message),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
        centerTitle: true,
      ),

      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _inputField("Current Password", _currentController),
            const SizedBox(height: 15),
            _inputField("New Password", _newController),
            const SizedBox(height: 15),
            _inputField("Confirm New Password", _confirmController),
            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _changePassword,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text("Update Password"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
      ),
    );
  }
}
