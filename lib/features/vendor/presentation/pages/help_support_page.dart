import 'package:flutter/material.dart';
import 'package:makan_mate/features/vendor/presentation/pages/feedback_page.dart';
import 'package:makan_mate/features/vendor/presentation/pages/report_issue_page.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Help & Support",
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Frequently Asked Questions",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          _faq(
            "How do I update my menu?",
            "Go to Menu Management > Edit Menu items to update prices, names, and availability.",
          ),
          _faq(
            "Why is my profile pending approval?",
            "Our admin team reviews all vendor submissions. Approval may take up to 24 hours.",
          ),
          _faq(
            "How do I redeem vouchers?",
            "Customers redeem vouchers using the QR code or voucher code shown on your POS page.",
          ),
          _faq(
            "How do I update my operating hours?",
            "Go to Vendor Profile > Edit > Operating Hours section.",
          ),

          const SizedBox(height: 24),

          const Text(
            "Contact Us",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ListTile(
            leading: const Icon(Icons.email, color: Colors.orange),
            title: const Text("makanmate.support@gmail.com"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.orange),
            title: const Text("012-3456789"),
          ),
          ListTile(
            leading: const Icon(Icons.access_time, color: Colors.orange),
            title: const Text("Mon – Fri • 9:00 AM – 6:00 PM"),
          ),

          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportIssuePage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text("Report an Issue"),
          ),

          const SizedBox(height: 12),

          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FeedbackPage(),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Colors.orange),
            ),
            child: const Text("Send Feedback"),
          ),
        ],
      ),
    );
  }

  Widget _faq(String question, String answer) {
    return Card(
      child: ExpansionTile(
        title: Text(question),
        children: [
          Padding(padding: const EdgeInsets.all(16), child: Text(answer)),
        ],
      ),
    );
  }
}
