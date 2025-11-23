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

//SALES-Cash
static Future<void> recordSalesEvent({
  required double totalAmount,
}) async {
  await addHistory(
    title: "Sales – Php ${totalAmount.toStringAsFixed(2)}",
    description: "A successful Transaction",
    category: "Sales",
    amount: totalAmount,
  );
}

// SALES-Credit
static Future<void> recordCreditEvent({
  required double totalAmount,
  required String customerName,
}) async {
  await addHistory(
    title: "Credit – Php ${totalAmount.toStringAsFixed(2)}",
    //description: "Customer: $customerName",
    description: "$customerName added to credit",
    category: "Credit",
    amount: totalAmount,
  );
}

// CREDIT
static Future<void> recordLedgerCreditEvent({
  required double amount,
  required String customerName,
  required String paymentStatus,
}) async {
  String title;
  String description;

  if (paymentStatus.toLowerCase() == "unpaid") {
    title = "Unpaid – Php ${amount.toStringAsFixed(2)}";
    description = "$customerName has 0 payments";
  } 
  else if (paymentStatus.toLowerCase() == "partial") {
    title = "Partial Payment – Php ${amount.toStringAsFixed(2)}";
    description = "$customerName made a partial payment";
  } 
  else if (paymentStatus.toLowerCase() == "paid") {
    title = "Paid – Php ${amount.toStringAsFixed(2)}";
    description = "$customerName has fully paid their total credit";
  } 
  else {
    // fallback
    title = "Credit – Php ${amount.toStringAsFixed(2)}";
    description = customerName;
  }

  await addHistory(
    title: title,
    description: description,
    category: "Credit",
    amount: amount,
  );
}

// STOCKS 
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

//STOCKS - EXPIRY
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
