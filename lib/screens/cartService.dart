import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green/screens/cartItem.dart';

class CartService {
  final CollectionReference _cartCollection =
      FirebaseFirestore.instance.collection('cart');

  Future<void> updateCart(Map<String, CartItem> items) async {
    Map<String, dynamic> cartData = {
      'items': items.map((key, item) => MapEntry(key, item.toMap())),
    };

    try {
      // Store entire cart under a specific user ID
      await _cartCollection.doc('user_cart').set(cartData);
    } catch (e) {
      print('Error updating cart: $e');
    }
  }

  Future<Map<String, CartItem>> fetchCart() async {
    try {
      DocumentSnapshot snapshot = await _cartCollection.doc('user_cart').get();
      if (snapshot.exists) {
        Map<String, dynamic> cartData = snapshot.data() as Map<String, dynamic>;
        Map<String, CartItem> fetchedItems = {};
        cartData['items'].forEach((key, data) {
          fetchedItems.putIfAbsent(key, () => CartItem.fromMap(data));
        });
        return fetchedItems;
      }
    } catch (e) {
      print('Error fetching cart: $e');
    }
    return {};
  }

  Future<void> clearCart() async {
    try {
      await _cartCollection.doc('user_cart').delete();
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }
}
