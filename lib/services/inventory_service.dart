// for saving item into Firebase database
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sarisync/models/inventory_item.dart';

class InventoryService {
  //initialization
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload image to Firebase Storage
  Future<String?> uploadImage(File imageFile) async {
    try {
      print('Uploading image: ${imageFile.path}');
      final ref = _storage.ref().child(
        'inventory_images/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

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
  Future<void> addItem({
    required String name,
    required int quantity,
    required double price,
    required String category,
    required String barcode,
    required String unit,
    String? info,
    String? expirationDate,
    String? imageUrl,
  }) async {
    try {
      await _firestore.collection('inventory').add({
        'name': name,
        'quantity': quantity,
        'price': price,
        'category': category,
        'barcode': barcode,
        'unit': unit,
        'add_info': info,
        'expiration': expirationDate,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("Item added successfully!");
    } catch (e) {
      print("Error adding item: $e");
    }
  }

  // Update item in Firestore
  Future<void> updateItem(InventoryItem item) async {
    try {
      await _firestore.collection('inventory').doc(item.id).update({
        'name': item.name,
        'quantity': item.quantity,
        'price': item.price,
        'category': item.category,
        'barcode': item.barcode,
        'unit': item.unit,
        'add_info': item.add_info,
        'expiration': item.expiration,
        'imageUrl': item.imageUrl,
        'createdAt': item.createdAt, // keep original timestamp
      });

      print("Item updated successfully!");
    } catch (e) {
      print("Error updating item: $e");
    }
  }

  // Retrieve items from Firestore as a stream
  Stream<List<InventoryItem>> getInventoryItems() {
    return _firestore
        .collection('inventory')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => InventoryItem.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
