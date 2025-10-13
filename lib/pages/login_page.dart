// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/my_textfield.dart';
import '../components/loginpage_button.dart';
import '../components/square_tile.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //tex editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //sign user in method
void wrongCredentialMessage() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Login failed'),
      content: const Text('Email or password is incorrect.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

  void signUserIn() async{
    //try sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } 
    on FirebaseAuthException catch (e) {
      print('Login error: ${e.code}');
      wrongCredentialMessage();
    }
  }

  void signInAsGuest() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      print('Signed in as guest!');
      // Navigate to your main/home page after login
      // Example:
      // Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      print('Guest login failed: ${e.code}');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Guest Login Failed'),
          content: Text(e.message ?? 'Unknown error'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[200],
      body: Column(
        children: [
          //logo
          Image.asset('assets/images/logos/makanmate_logo.jpg'),

          SizedBox(height: 20),

          //Welcome
          Text(
            "Login",
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Welcome to MakanMate!",
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
            ),
          ),

          SizedBox(height: 25),

          //email textfield
          MyTextfield(
            controller: emailController,
            hintText: 'Email',
            obscureText: false,
          ),
          SizedBox(height: 10),

          //password textfield
          MyTextfield(
            controller: passwordController,
            hintText: 'Password',
            obscureText: true,
          ),

          SizedBox(height: 10),

          //forgot password
          Padding(padding:  const EdgeInsets.symmetric(horizontal: 25.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("Forgot Password?",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ]),
          ),

          SizedBox(height: 25),
          
          //Log in
          LoginpageButton(
            onTap: signUserIn,
            text: 'Log In',
          ),

          SizedBox(height: 40),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    thickness: 0.5,
                    color: Colors.grey[400],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text("  Or login with  ",
                  style: TextStyle(color: Colors.grey[700])
                  ),
                ),
                Expanded(
                  child: Divider(
                    thickness: 0.5,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 30),

          //gmail
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SquareTile(imagePath: "assets/images/logos/gmail_logo.jpg"),
            ],
          ),

          SizedBox(height: 30),

          //not a member? register now
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account?",
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(width: 4),
              GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignupPage()),
                    );
                  },
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
            TextButton(
              onPressed: signInAsGuest,
              child: Text(
                "Continue as Guest",
                style: TextStyle(
                  color: Colors.grey[600],
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
