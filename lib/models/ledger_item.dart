import 'package:cloud_firestore/cloud_firestore.dart';

class LedgerItem {
  final String? id; // Firestore document ID 
  final String name;
  final String customerID;
  final String contact;
  final String pay_status;
  final double credit;
  final double partial_pay;
  final String received;
  final String? imageUrl; //  for uploaded images
  final DateTime createdAt;

  LedgerItem({
    this.id,
    required this.name,
    required this.customerID,
    required this.contact,
    required this.pay_status,
    required this.credit,
    required this.partial_pay,
    required this.received,
    this.imageUrl,
    required this.createdAt,
  });

  /// Convert InventoryItem → Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'customerID': customerID,
      'contact': contact,
      'pay_status': pay_status,
      'credit': credit,
      'partial_pay':  partial_pay,
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
      pay_status: (data['pay_status'] ?? ''),
      credit: (data['credit'] ?? 0).toDouble(),
      partial_pay: (data['partial_pay'] ?? 0).toDouble(),
      received: data['received'] ?? '',
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
