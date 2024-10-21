import 'package:flutter/material.dart';

class CartItem {
  final String productId;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    this.quantity = 1,
  });
}

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    double total = 0.0;
    _items.forEach((_, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  void addItem(String productId, String name, double price, int quantityChange) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity += quantityChange;
      if (_items[productId]!.quantity <= 0) {
        removeItem(productId);
      } else {
        notifyListeners();
      }
    } else {
      if (quantityChange > 0) {
        _items[productId] = CartItem(productId: productId, name: name, price: price, quantity: quantityChange);
        notifyListeners();
      }
    }
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
