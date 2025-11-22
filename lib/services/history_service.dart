import 'package:cloud_firestore/cloud_firestore.dart';
  
class HistoryService {
  static Future<void> addHistory({
    required String title,
    required String description,
    required String category, // Sales, Credit, Stocks
    double? amount,
  }) async {
    await FirebaseFirestore.instance.collection("History").add({
      "title": title,
      "description": description,
      "category": category,
      "amount": amount,
      "date": FieldValue.serverTimestamp(),

    });
  }

static Future<void> checkStockEvent({
  required String itemName,
  required int quantity,
}) async {
  if (quantity == 0) {
    await HistoryService.addHistory(
      title: "Out of Stock – $itemName",
      description: "Remaining: 0 pcs",
      category: "Stocks",
    );
  } else if (quantity <= 5) {
    await HistoryService.addHistory(
      title: "Low Stock – $itemName",
      description: "Remaining: $quantity pcs",
      category: "Stocks",
    );
  }
}

static Future<void> checkExpiryEvent({
  required String itemName,
  required String expirationDate,
}) async {
  if (expirationDate.isEmpty) return;

  try {
    final parts = expirationDate.split("/");
    if (parts.length != 3) return;

    final month = int.parse(parts[0]);
    final day = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    final exp = DateTime(year, month, day);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(exp.year, exp.month, exp.day);
    final days = expiry.difference(today).inDays;

    if (days < 0) {
      await addHistory(
        title: "Expired – $itemName",
        description: "Expired last ${exp.month}-${exp.day}-${exp.year}",
        category: "Stocks",
      );
  } else if (days == 0) {
    await addHistory(
      title: "Expiring Today – $itemName",
      description: "Will expire today (${exp.month}-${exp.day}-${exp.year})",
      category: "Stocks",
    );
  } else if (days <= 7) {
      final label = days == 1 ? "1 day" : "$days days";
      await addHistory(
        title: "Near Expiry – $itemName",
        description: "Will expire in $label (${exp.month}-${exp.day}-${exp.year})",
        category: "Stocks",
      );
    }
  } catch (e) {
    print("Expiry parsing error: $e");
  }
}


}
