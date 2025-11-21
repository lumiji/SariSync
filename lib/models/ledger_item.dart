import 'package:cloud_firestore/cloud_firestore.dart';

class LedgerItem {
  final String? id; // Firestore document ID 
  final String name;
  final String customerID;
  final String contact;
  final String payStatus;
  final double credit;
  final double? partialPay;
  final String received;
  final String? imageUrl; //  for uploaded images
  final DateTime createdAt;

  LedgerItem({
    this.id,
    required this.name,
    required this.customerID,
    required this.contact,
    required this.payStatus,
    required this.credit,
    this.partialPay,
    required this.received,
    this.imageUrl,
    required this.createdAt,
  });

  // Convert InventoryItem → Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'customerID': customerID,
      'contact': contact,
      'payStatus': payStatus,
      'credit': credit,
      'partialPay':  partialPay,
      'received': received,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }

  /// Convert Firestore Map → InventoryItem
  factory LedgerItem.fromMap(Map<String, dynamic> data, String documentId) {
    return LedgerItem(
      id: documentId,
      name: data['name'] ?? '',
      customerID: (data['customerID'] ?? ''),
      contact: (data['contact'] ?? ''),
      payStatus: (data['payStatus'] ?? ''),
      credit: (data['credit'] ?? 0).toDouble(),
      partialPay: (data['partialPay'] ?? 0).toDouble(),
      received: data['received'] ?? '',
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
