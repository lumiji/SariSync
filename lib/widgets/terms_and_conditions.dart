import 'package:flutter/material.dart';

Future<bool> showTermsAndConditionsDialog({
  required BuildContext context,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => TermsAndConditionsDialog(),
  );

  return result ?? false; // default to false when closed
}

 class TermsAndConditionsDialog extends StatelessWidget {
  const TermsAndConditionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Terms and Conditions",
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome to SariSync!",
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "By creating an account, you agree to the following terms:",
              style: TextStyle(fontFamily: 'Inter'),
            ),
            SizedBox(height: 16),

            _buildTermSection(
              "1. Account Usage",
              "You are responsible for maintaining the confidentiality of your account credentials and for all activities under your account.",
            ),
            _buildTermSection(
              "2. Data Collection",
              "We collect and store sales data, inventory information, and account details to provide our services. Your data is securely stored in Firebase.",
            ),
            _buildTermSection(
              "3. Privacy",
              "We respect your privacy. Your personal information will not be shared with third parties without your consent.",
            ),
            _buildTermSection(
              "4. Service Availability",
              "We strive to provide uninterrupted service, but cannot guarantee 100% uptime. We are not liable for any losses due to service interruptions.",
            ),
            _buildTermSection(
              "5. User Conduct",
              "You agree not to use SariSync for any illegal activities or in ways that could damage our service or other users.",
            ),
            _buildTermSection(
              "6. Changes to Terms",
              "We reserve the right to modify these terms at any time. Continued use of the app constitutes acceptance of updated terms.",
            ),

            SizedBox(height: 12),
            Text(
              "Last updated: November 2024",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            "Close",
            style: TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF1565C0),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1565C0),
          ),
          child: Text(
            "Accept",
            style: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildTermSection(String title, String content) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}
