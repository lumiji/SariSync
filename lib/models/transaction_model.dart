import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionItem {
  final double totalAmount;
  final DateTime createdAt;
  final String transactionId;
  final String paymentMethod;

  TransactionItem({
    required this.totalAmount,
    required this.createdAt,
    required this.transactionId,
    required this.paymentMethod,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      totalAmount: (json['totalAmount'] != null)
        ? double.tryParse(json['totalAmount'].toString()) ?? 0.0
        : 0.0,
      createdAt: json['createdAt'] is Timestamp
        ? (json['createdAt'] as Timestamp).toDate()
        : DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now(),
      transactionId: json['transactionId'],
      paymentMethod: json['paymentMethod'],
    );
  }
}