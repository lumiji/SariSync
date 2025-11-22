import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sarisync/models/receipt_item.dart';

class ReceiptService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String> createReceipt({
  required String transactionId,
  required List<ReceiptItem> items,
  required double total,
  double? totalPaid,
  double? change,
  String? customerID,
  String? name, 
  required String paymentMethod,
  required String status,
  required DateTime createdAt,
}) async {
  final receiptData = {
    'transactionId': transactionId, 
    'items': items.map((e) => e.toJson()).toList(),
    'totalAmount': total,
    'totalPaid': totalPaid ?? total,
    'change': change ?? 0.0,
    'customerID': customerID,
    'name' : name,
    'paymentMethod': paymentMethod,
    'status': status,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  await firestore.collection('receipts').doc(transactionId).set(receiptData);

  return transactionId;
}


  Future<Map<String, dynamic>?> getReceipt(String id) async {
    final doc = await firestore.collection('receipts').doc(id).get();
    return doc.data();
  }

  Future<List<Map<String, dynamic>>> getReceiptsByCustomer(String customerID) async {
    final snapshot = await firestore
        .collection('receipts')
        .where('customerID', isEqualTo: customerID)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((d) => d.data()).toList();
  }
}
