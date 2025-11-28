import 'package:flutter/material.dart';

class AboutSariSyncPage extends StatelessWidget {
  const AboutSariSyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: Text(
          "About SariSync",
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About SariSync',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 12),
            Text(
              'SariSync is a cross‑platform Flutter app designed to help users '
              'organize, sync, and share sarisari store related records and documents '
              'quickly and securely. It combines cloud storage, secure '
              'authentication, scanning, and document tools for fast, reliable '
              'cataloging and distribution of information.',
            ),
            const SizedBox(height: 14),
            Text('Key features', 
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              )),
            const SizedBox(height: 8),
            Text('• Real‑time cloud sync via Firebase Firestore\n'
                 '• File and media storage using Firebase Storage\n'
                 '• Sign in with Google and Facebook\n'
                 '• Barcode scanning with audible feedback\n'
                 '• Capture and pick images, cached remote images\n'
                 '• PDF generation and printing for reports\n'
                 '• Offline-friendly flags and connectivity monitoring'),
            const SizedBox(height: 16),
            Text('Privacy & data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 8),
            Text(
              'User data and documents are stored in SariSync Firebase project '
              '(Firestore and Storage). Authentication providers manage user '
              'identity. Sensitive local flags are kept on device. Users control '
              'what they upload and share.',
            ),
            const SizedBox(height: 16),
            Text('Technical stack',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 8),
            Text(
              'Built with Flutter (Dart). Uses Firebase for backend services '
              'and additional packages for scanning, media handling, PDF '
              'generation, printing, audio feedback, caching, and connectivity.',
            ),
            const SizedBox(height: 18),
            Text(
              'SariSync helps you organize, sync, and share store records and '
              'documents effortlessly. Sign in, scan items, upload photos and '
              'PDFs, and generate printable reports — all from a fast and '
              'secure app.',
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: Text('Version 1.0.0', 
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                )),
            ),
          ],
        ),
      ),
    );
  }
}
