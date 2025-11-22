//import 'package:cloud_firestore/cloud_firestore.dart';

// MODEL
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
    return HistoryItem(
      id: id,
      title: map["title"],
      description: map["description"],
      category: map["category"],
      amount: (map["amount"] != null) ? map["amount"]!.toDouble() : null,
      date: DateTime.parse(map["date"]),
    );
  }
}
