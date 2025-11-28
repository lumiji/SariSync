# SariSync

A lightweight, Android Flutter app for managing inventory, processing sales, and syncing data in real-time using Firebase. Designed for small sarisari store owners and employees who need quick, reliable inventory management on mobile.

Developers: 
    Escrupulo, Ma. Asherah Francine Faith S. BSCS 3-B AI
    Porras, Jessie Loraine P. BSCS 3-B AI

---

## Features

### Core Functionality
- **Barcode Scanning** — Quickly save items by scanning barcodes
- **Real-time Sales Processing** — Create receipts, manage cash & credit transactions, track change
- **Inventory Management** — Monitor stock levels, update quantities, prevent overselling
- **Multi-User Support** — PIN-protected accounts for family or employee access on shared devices
- **Cloud Sync** — Firebase Firestore keeps inventory and sales data in sync across devices

### Sales & Payments
- **Cash & Credit Transactions** — Support both payment methods with automatic change calculation
- **Customer Tracking** — Record credit sales with customer names for follow-up
- **Transaction History** — View sales history and credit outstanding balances
- **Receipt Generation** — Generate and print detailed receipts with transaction numbers and timestamps

### Media & Documents
- **Image Capture & Storage** — Attach photos to inventory items (product images, stock photos)
- **PDF Export** — Generate printable reports
- **Cached Images** — Fast loading of remote product images

### User Experience
- **Social Sign-In** — Quick login with Google or Facebook (no password needed)
- **Intuitive UI** — Swipe actions for quick edit/delete, modern Material Design
- **User Guides & Support** — Built-in help documentation and contact support form

---

## Quick Start

### Prerequisites
- **Flutter** 3.9.2 or higher
- **Dart** 3.9.2 or higher
- **Firebase Project** (Firestore, Auth, Storage)
- **Android Studio** / **Xcode** for emulator/device testing

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/sarisync.git
   cd sarisync
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   - Create a Firebase project at [firebase.google.com](https://firebase.google.com)
   - Enable **Authentication** (Google, Facebook providers)
   - Enable **Firestore Database**
   - Enable **Firebase Storage**
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place files in the appropriate directories:
     - Android: `android/app/`
     - iOS: `ios/Runner/`

4. **Configure social login**
   - Set up Google Sign-In credentials in Firebase Console
   - Set up Facebook App ID in Firebase Console
   - Update `android/app/build.gradle` and `ios/Runner/Info.plist` with credentials

5. **Run the app**
   ```bash
   flutter run
   ```

---

## Project Structure

```
sarisync/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models (ReceiptItem, etc.)
│   ├── services/                 # Firebase, auth, local storage services
│   ├── views/                    # Pages (Home, Receipt, UserGuide, etc.)
│   ├── widgets/                  # Reusable UI components
├── assets/                       # Images, icons, splash screens
├── pubspec.yaml                  # Dependencies & config
└── README.md                     # This file
```

---

## Key Services

### `auth_flow_service.dart`
Handles user authentication flow:
- Post-login setup (account info, logged-in status)
- PIN creation/verification for multi-user device access
- Navigation to PIN or home screen

### `process_sale.dart`
Processes sales transactions:
- Validates stock availability
- Deducts inventory from Firestore
- Records transaction with items, payment method, and totals
- Handles both cash and credit payments

### `history_service.dart`
Tracks sales history:
- Records cash sales events
- Records credit sales with customer details
- Enables sales reporting and analytics

### `local_storage_service.dart`
Manages local device storage:
- Saves account info and PIN (securely)
- Stores small flags for offline capability

---

## Data Models

### ReceiptItem
Represents an item in a receipt:
```dart
class ReceiptItem {
  String id;
  String name;
  double price;
  int quantity;
  String unit;
  String add_info;  // Additional info (e.g., brand, size)
}
```

### Transaction
Stored in Firestore:
```
users/{uid}/sales/{transactionId}
├── items: List<Map>
├── paymentMethod: 'cash' | 'credit'
├── totalAmount: double
├── totalPaid: double (cash only)
├── change: double (cash only)
├── customerName: string (credit only)
├── status: 'paid' | 'credit'
└── createdAt: timestamp
```

---

## Authentication & Security

- **Social Sign-In** — Google & Facebook (no password management)
- **PIN Protection** — Each user has a 4-6 digit PIN for device access
- **Firebase Auth** — Secure token-based authentication
- **Firestore Rules** — Data is user-scoped; users can only access their own inventory and sales

### Suggested Firestore Rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid}/{document=**} {
      allow read, write: if request.auth.uid == uid;
    }
  }
}
```

---

## Dependencies

| Package | Purpose |
|---------|---------|
| `firebase_core` | Firebase initialization |
| `firebase_auth` | User authentication |
| `cloud_firestore` | Real-time database |
| `firebase_storage` | File storage (images, PDFs) |
| `google_sign_in` | Google authentication |
| `flutter_facebook_auth` | Facebook authentication |
| `mobile_scanner` | QR/barcode scanning |
| `image_picker` | Camera & gallery image selection |
| `cached_network_image` | Optimized remote image caching |
| `pdf` | PDF generation |
| `printing` | Print & save PDFs |
| `audioplayers` | Scan beep sound feedback |
| `flutter_slidable` | Swipe actions on list items |
| `shared_preferences` | Local key-value storage |
| `connectivity_plus` | Network status monitoring |

---

## Usage Workflow

### 1. Sign In
- User opens app → social login (Google/Facebook)
- If first login → create PIN
- Otherwise → enter PIN to unlock

### 2. Scan & Add Items
- Tap **Scan** → point camera at barcode code
- Item details load from inventory
- Adjust quantity with +/- buttons

### 3. Process Sale
- Select **Payment Method** (Cash or Credit)
- For Cash: enter amount paid → app calculates change
- For Credit: enter customer name
- Review receipt details
- Tap **Save** → transaction saved to Firestore

### 4. View History
- Go to **Sales History** tab
- Filter by sales, stock, or credit categories
- View credit outstanding balances

### 5. Manage Inventory
- Go to **Inventory** tab
- Add/edit items, update stock levels
- Attach product photos
- Items sync in real-time

---

## Development

### Running Tests
```bash
flutter test
```

### Build APK (Android)
```bash
flutter build apk --release
```

### Build IPA (iOS)
```bash
flutter build ios --release
```

### Code Style
- Follow Dart conventions ([dart.dev/guides/language/effective-dart](https://dart.dev/guides/language/effective-dart))
- Use `flutter analyze` to check for issues
- Format code with `dart format .`

---

## Common Tasks

### Add a New Page
1. Create `lib/views/new_page.dart`
2. Extend `StatelessWidget` or `StatefulWidget`
3. Add route to `main.dart` navigation

### Add a Firestore Collection
1. Define data model in `lib/models/`
2. Create service in `lib/services/` for CRUD operations
3. Use `FirebaseFirestore.instance.collection('name').doc(id)...`

### Handle Offline Sync
- Data is cached locally in shared_preferences
- Use `connectivity_plus` to detect when online
- Call sync function when connection restored

---

## Troubleshooting

### Firebase Connection Issues
- Verify `google-services.json` and `GoogleService-Info.plist` are in correct locations
- Check Firebase console for enabled services
- Ensure app SHA-1 fingerprint is registered for Android

### Scanner Not Working
- Grant camera permissions (check manifest)
- Test with a valid QR/barcode
- Ensure good lighting

### Sync Not Working
- Check internet connection (`connectivity_plus`)
- Verify Firestore rules allow user access
- Check Firebase console for quota/billing issues

### PIN Screen Not Showing
- Clear app cache: `flutter clean` → `flutter pub get` → `flutter run`
- Verify `shared_preferences` is initialized
- Check `auth_flow_service.dart` logic

---

## Support

For issues, questions, or feature requests:
- Open an issue on GitHub
- Email: 'jessieloraine.porras@wvsu.edu.ph' or 'ma.asherahrancinefaith.escrupulo@wvsu.edu.ph"

---

## License

SariSync is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

## Acknowledgments

- Built with **Flutter** & **Dart**
- Backend powered by **Firebase**
- Icons from **Material Design**
- Community contributions welcome!

---

## 🚦 Roadmap

### v1.1 (Planned)
- [ ] Full-text inventory search
- [ ] Sales analytics & charts
- [ ] phone number receipt delivery or credit due notification
- [ ] Multi-store support
- [ ] Barcode label printing
- [ ] Offline-first functionality

### v1.2 (Future)
- [ ] Mobile app notifications
- [ ] Customer loyalty tracking
- [ ] Integration with accounting software
- [ ] Desktop/web app
- [ ] Multi-language support
- [ ] Support e-loads

---

**Last Updated:** November 28, 2025  
**Version:** 1.0.0
