import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  final String? id; // Firestore document ID 
  final String category;
  final String name;
  final double price;
  final int quantity;
  final String unit;
  final String barcode;
  final String expiration;
  final String add_info;
  final String? imageUrl; //  for uploaded images
  final DateTime createdAt;

  InventoryItem({
    this.id,
    required this.category,
    required this.name,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.barcode,
    required this.expiration,
    required this.add_info,
    this.imageUrl,
    required this.createdAt,
  });

  // Convert InventoryItem → Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'name': name,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'barcode': barcode,
      'expiration': expiration,
      'add_info': add_info,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }

  // Convert Firestore Map → InventoryItem
  factory InventoryItem.fromMap(Map<String, dynamic> data, String documentId) {
    return InventoryItem(
      id: documentId,
      category: data['category'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 0,
      unit: data['unit'] ?? 'pcs',
      barcode: data['barcode'] ?? '',
      expiration: data['expiration'] ?? '',
      add_info: data['add_info'] ?? '',
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
