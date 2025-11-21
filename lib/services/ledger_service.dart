// for saving customer into Firebase database
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sarisync/models/ledger_item.dart';


class LedgerService {
  //initialization
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload image to Firebase Storage
  Future<String?> uploadImage(File imageFile) async {
    try {
      print('Uploading image: ${imageFile.path}');
      final ref = _storage
          .ref()
          .child('ledger_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      await ref.putFile(imageFile);

      final downloadUrl = await ref.getDownloadURL();
      print('Upload successful, URL: $downloadUrl');
      
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Add item to Firestore
  Future<void> addLedgerItem({
    required String name,
    required String customerID,
    required String contact,
    required String payStatus,
    required double credit,
    double? partialPay,
    required String received,
    String? imageUrl,
  }) async {
    try {
      await _firestore.collection('ledger').add({
        'name': name,
        'customerID': customerID,
        'contact': contact,
        'payStatus': payStatus,
        'credit': credit,
        'partialPay':  partialPay,
        'received': received,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("Item added successfully!");
    } catch (e) {
      print("Error adding item: $e");
    }
  }

  // Retrieve items from Firestore as a stream
  Stream<List<LedgerItem>> getLedgerItems() {
    return _firestore
        .collection('ledger')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LedgerItem.fromMap(doc.data(), doc.id))
            .toList());
  }
}
