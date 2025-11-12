class TransactionItem {
  final String amount;
  final String date;
  final String? id; // optional unique ID
  final String? customerName; // optional, if you’ll use one later

  TransactionItem({
    required this.amount,
    required this.date,
    this.id,
    this.customerName,
  });

  // This will make it easy to load from backend (e.g. Firebase)
  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      amount: json['amount'] ?? 'Php 0.00',
      date: json['date'] ?? '',
      id: json['id'],
      customerName: json['customerName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'date': date,
      'id': id,
      'customerName': customerName,
    };
  }
}