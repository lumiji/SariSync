import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryItem {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String category; // "Sales", "Credit", "Stocks"
  final double? amount; // optional for stocks events

  HistoryItem({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "date": date.toIso8601String(),
      "category": category,
      "amount": amount,
    };
  }

  
  static HistoryItem fromMap(String id, Map<String, dynamic> map) {
  
    final title = (map["title"] ?? '') as String;
    final description = (map["description"] ?? '') as String;
    final category = (map["category"] ?? 'Unknown') as String;
    final amount = (map["amount"] != null)
        ? (map["amount"] is num ? (map["amount"] as num).toDouble() : double.tryParse(map["amount"].toString()))
        : null;

   
    DateTime parsedDate;
    final rawDate = map["date"];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
  
      parsedDate = DateTime.now();
    }

    return HistoryItem(
      id: id,
      title: title,
      description: description,
      date: parsedDate,
      category: category,
      amount: amount,
    );
  }
}
