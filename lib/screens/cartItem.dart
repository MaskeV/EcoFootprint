class CartItem {
  final String documentId;
  final String name;
  final double price; // Change to double for price
  final String imageUrl;
  int quantity;

  CartItem({
    required this.documentId,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  // Convert CartItem instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'documentId': documentId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  // Create a CartItem instance from a Map
  factory CartItem.fromMap(Map<String, dynamic> data) {
    return CartItem(
      documentId: data['documentId'] ?? '', // Default to empty string if null
      name: data['name'] ?? '',
      price: data['price']?.toDouble() ?? 0.0, // Ensure price is a double
      imageUrl: data['imageUrl'] ?? '',
      quantity: data['quantity'] ?? 1, // Default to 1 if null
    );
  }
}

