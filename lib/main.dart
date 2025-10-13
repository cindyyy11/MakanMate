import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:makan_mate/screens/home_screen.dart';
import 'screens/auth_page.dart';
import 'firebase_options.dart';
import 'screens/login_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await GoogleSignIn.instance.initialize(
    clientId: '400315761727-mkpcelmpnfm7bdtp94k4n42boa8b5ud7.apps.googleusercontent.com',
    serverClientId: '400315761727-2gk4u6jv5b5f3j3v4t1h1f4b3q7k5j4m.apps.googleusercontent.com',
  );

    runApp(const MyApp());
  }
 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
    );
  }
}


// void main() {
//   runApp(MyApp());

//    var db= FirebaseFirestore.instance;

//   // Create a new user with a first and last name
//   final user = <String, dynamic>{
//     "first": "Ada",
//     "last": "Lovelace",
//     "born": 1815
// };

// // Add a new document with a generated ID
// db.collection("users").add(user).then((DocumentReference doc) =>
//     print('DocumentSnapshot added with ID: ${doc.id}'));
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'MakanMate AI',
//       theme: ThemeData(
//         primarySwatch: Colors.green,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: AuthPage(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
