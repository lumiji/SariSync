class ReceiptItem {
  final String id;
  final String name;
  final double price;
  int quantity;
  final String? add_info;
  final String? unit;

  ReceiptItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.add_info,
    this.unit,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'description': add_info,
      'unit': unit,
    };
  }

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      add_info: json['description'],
      unit: json['unit'],
    );
  }

    // Cleaner computed property
  double get totalPrice => price * quantity;

}
