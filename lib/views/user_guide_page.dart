import 'package:flutter/material.dart';

class UserGuidePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: const Text(
          'SariSync — User Guide',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Quick Start', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              '1) Sign in\n'
              '- Open the app and sign in with Google or Facebook. Your account will be used to sync your data to Firestore.\n\n'
              '2) Create or scan items\n'
              '- Use the scanner to scan a QR/barcode to find an item quickly, or tap + to create a new record manually.\n\n'
              '3) Add photos & documents\n'
              '- Attach photos from the camera or gallery. PDFs can be uploaded and later printed or shared.\n\n'
              '4) Sync & share\n'
              '- Data is saved to Firebase Firestore for real‑time sync across devices. Use share/export features to send a PDF or item link.\n\n'
              '5) Search & manage\n'
              '- Use the app search to find records. Swipe list items for quick actions (edit, delete, share).\n\n'
              '6) Settings & offline\n'
              '- The app monitors connectivity and stores small flags locally. Work offline and sync will occur when reconnecting.',
            ),
            SizedBox(height: 16),
            Text('Detailed Flow', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              'Onboarding & Account\n'
              '- First launch shows the splash screen. Sign in to enable cloud sync and personalized data.\n\n'
              'Item lifecycle\n'
              '- Create: Tap the add button, enter details, attach images or documents, and save.\n'
              '- Scan: Open scanner, align code; the app will look up or create the matched item.\n'
              '- Edit: Open an item to update fields, replace media, or change sharing options.\n\n'
              'Media & Documents\n'
              '- Images: Use image picker to attach camera photos or gallery images. Remote images are shown with caching.\n'
              '- PDFs: Generate or upload PDFs; use the printing feature to print or save.\n\n'
              'Export & Print\n'
              '- Use the export button on an item or list to generate a PDF report. The printing feature lets you print or create a shareable file.\n\n'
              'Error reporting\n'
              '- If something goes wrong, use Contact Support to describe the issue. Include steps to reproduce, screenshots, and app version.\n\n'
              'Privacy & Data\n'
              '- Your content is stored in the app\'s Firebase project (Firestore & Storage). Authentication providers manage identity; local preferences remain on device.',
            ),
            SizedBox(height: 16),
            Text('Tips & Best Practices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              '• Keep your app updated to get the latest fixes and features.\n'
              '• When scanning, ensure good lighting and steady device for best recognition.\n'
              '• Use meaningful item titles and categories to improve searchability.\n'
              '• Regularly back up important PDFs and documents outside the app if required by your workflow.',
            ),
            SizedBox(height: 20),
            Text('Still need help?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Open Contact Support from the app menu and provide details about the issue.'),
          ],
        ),
      ),
    );
  }
}
