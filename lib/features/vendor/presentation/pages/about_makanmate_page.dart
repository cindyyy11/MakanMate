import 'package:flutter/material.dart';

class AboutMakanMatePage extends StatelessWidget {
  const AboutMakanMatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "About MakanMate",
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Logo
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.orange[100],
              child: const Icon(Icons.restaurant, size: 50, color: Colors.orange),
            ),

            const SizedBox(height: 20),

            const Text(
              "MakanMate Vendor",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),
            const Text("Version 1.0.3", style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 20),

            const Text(
              "MakanMate helps Malaysian food vendors manage menus, "
              "promotions, analytics, and customer engagement — all in one place.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.4),
            ),

            const SizedBox(height: 20),
            const Text(
              "Our mission is to support local businesses and help them grow "
              "through digital transformation.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.4),
            ),

            const SizedBox(height: 30),

            const Text(
              "Developed by:\nAPU Software Engineering Project Team (2025)",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
