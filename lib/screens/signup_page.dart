import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import '../components/loginpage_button.dart';
import '../components/my_textfield.dart';


class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // text editing controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();

  DateTime? birthDate;
  String selectedCountryCode = '+60';
  String selectedRole = 'customer'; // 'customer' or 'vendor' 

  // date picker
  Future<void> pickBirthDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        birthDate = pickedDate;
      });
    }
  }

  // sign up method
  void signUserUp() async {
    if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Passwords do not match'),
          content: Text('Please make sure both passwords are the same.'),
        ),
      );
      return;
    }

    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        birthDate == null) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Missing Information'),
          content: Text('Please fill in all the required fields.'),
        ),
      );
      return;
    }

    try {
      UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

      String uid = userCredential.user!.uid;

      final timestamp = Timestamp.now();

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': '$selectedCountryCode ${phoneController.text.trim()}',
        'birthDate': birthDate!.toIso8601String(),
        'createdAt': timestamp,
        'isGuest': false,
        'role': selectedRole, // 'customer' or 'vendor'
      });

      if (selectedRole == 'vendor') {
        await FirebaseFirestore.instance.collection('vendors').doc(uid).set({
          'vendorId': uid,
          'profilePhotoUrl': null,
          'businessLogoUrl': null,
          'businessName': '',
          'contactNumber': '',
          'emailAddress': emailController.text.trim(),
          'businessAddress': '',
          'operatingHours': <String, dynamic>{},
          'shortDescription': '',
          'outlets': <Map<String, dynamic>>[],
          'certifications': <Map<String, dynamic>>[],
          'approvalStatus': 'pending',
          'createdAt': timestamp,
          'updatedAt': timestamp,
        });

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/vendorOnboarding');
        return;
      }

      if (!mounted) return;
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'Password should be at least 6 characters.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      } else {
        message = 'Sign up failed. Try again later.';
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign Up Failed'),
          content: Text(message),
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                iconSize: 28,
                onPressed: () => Navigator.pop(context),
              ),

              // logo
              Center(
                child: Image.asset(
                  'assets/images/logos/makanmate_logo.jpg',
                  height: 100,
                ),
              ),

              const SizedBox(height: 20),

              // title
              const Center(
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Text(
                  "Create your MakanMate account!",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),


            const SizedBox(height: 25),

            // First Name
            MyTextfield(
              controller: firstNameController,
              hintText: 'First Name',
              obscureText: false,
            ),
            const SizedBox(height: 10),

            // Last Name
            MyTextfield(
              controller: lastNameController,
              hintText: 'Last Name',
              obscureText: false,
            ),
            const SizedBox(height: 10),

            // email textfield
            MyTextfield(
              controller: emailController,
              hintText: 'Email',
              obscureText: false,
            ),

            const SizedBox(height: 10),

            // Birth Date picker
            GestureDetector(
              onTap: pickBirthDate,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      birthDate == null
                          ? 'Select Birth Date'
                          : '${birthDate!.day}/${birthDate!.month}/${birthDate!.year}',
                      style: TextStyle(
                        color: birthDate == null
                            ? Colors.grey[600]
                            : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    const Icon(Icons.calendar_month, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Phone number + country code
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // 🌍 Country Code Picker
                  Container(
                    padding: const EdgeInsets.only(left: 8),
                    child: CountryCodePicker(
                      onChanged: (country) {
                        setState(() {
                          selectedCountryCode = country.dialCode ?? '+60';
                        });
                      },
                      initialSelection: 'MY', // default Malaysia
                      favorite: const ['+60', 'MY'],
                      showCountryOnly: false,
                      showOnlyCountryWhenClosed: false,
                      alignLeft: false,
                      padding: EdgeInsets.zero,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // 📞 Phone Number Field
                  Expanded(
                    child: TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        hintText: 'Phone Number',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ),

            const SizedBox(height: 10),

            // Role Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account Type *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedRole = 'customer';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedRole == 'customer'
                                  ? Colors.amber[400]
                                  : Colors.amber[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: selectedRole == 'customer'
                                    ? Colors.amber[700]!
                                    : Colors.amber[300]!,
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Customer',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedRole = 'vendor';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selectedRole == 'vendor'
                                  ? Colors.amber[400]
                                  : Colors.amber[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: selectedRole == 'vendor'
                                    ? Colors.amber[700]!
                                    : Colors.amber[300]!,
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Vendor',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // password textfield
            MyTextfield(
              controller: passwordController,
              hintText: 'Password',
              obscureText: true,
            ),

            const SizedBox(height: 10),

            // confirm password textfield
            MyTextfield(
              controller: confirmPasswordController,
              hintText: 'Confirm Password',
              obscureText: true,
            ),

            const SizedBox(height: 25),

            // sign up button
            LoginpageButton(
              onTap: signUserUp,
              text: 'Sign Up',
            ),

            const SizedBox(height: 10),

            // divider
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
                  Expanded(
                    child: Divider(
                      thickness: 0.5,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // already have an account?
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account?",
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    )
    );
  }
}
