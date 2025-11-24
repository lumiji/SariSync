class ReceiptItem {
  final String id;
  final String name;
  final double price;
  int quantity;
  final String? description;
  final String? weight;

  ReceiptItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.description,
    this.weight,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'description': description,
      'weight': weight,
    };
  }

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      description: json['description'],
      weight: json['weight'],
    );
  }

    // 💡 Cleaner computed property
  double get totalPrice => price * quantity;

}
