import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sarisync/models/receipt_item.dart';

class Receipt {
  final String id;
  final String transactionId;
  final List<ReceiptItem> items;
  final String paymentMethod;
  final double totalAmount;
  final double totalPaid;
  final double change;
  final DateTime dateTime;
  final String status;
  final String? customer;

  Receipt({
    required this.id,
    required this.transactionId,
    required this.items,
    required this.paymentMethod,
    required this.totalAmount,
    required this.totalPaid,
    required this.change,
    required this.dateTime,
    required this.status,
    this.customer,
  });

  // Convert Receipt → Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'items': items.map((item) => item.toJson()).toList(),
      'paymentMethod': paymentMethod,
      'totalAmount': totalAmount,
      'totalPaid': totalPaid,
      'change': change,
      'dateTime': Timestamp.fromDate(dateTime),
      'status': status,
      'customer': customer,
    };
  }

  // Convert Firestore → Receipt
  factory Receipt.fromMap(Map<String, dynamic> data, String documentId) {
    return Receipt(
      id: documentId,
      transactionId: data['transactionId'] ?? '',
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => ReceiptItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      paymentMethod: data['paymentMethod'] ?? '',
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      totalPaid: (data['totalPaid'] ?? 0).toDouble(),
      change: (data['change'] ?? 0).toDouble(),
      dateTime: (data['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? '',
      customer: data['customer'],
    );
  }
}
