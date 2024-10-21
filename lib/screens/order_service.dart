import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green/screens/cartItem.dart';

class OrderService {
  // Place an order and store it in Firestore
  static Future<bool> storeOrder(String userId, List<CartItem> cartItems, double totalPrice) async {
    CollectionReference orders = FirebaseFirestore.instance.collection('orders');

    List<Map<String, dynamic>> itemList = cartItems.map((item) {
      return {
        'documentId': item.documentId,
        'name': item.name,
        'price': item.price,
        'quantity': item.quantity,
      };
    }).toList();

    try {
      await orders.add({
        'userId': userId, 
        'items': itemList,
        'totalPrice': totalPrice,
        'paymentStatus': 'Paid',
        'orderStatus': 'Processing', // Initial order status
        'orderDate': DateTime.now(),
      });
      return true;
    } catch (e) {
      print('Error placing order: $e');
      return false;
    }
  }

  // Fetch order history
  static Future<List<Map<String, dynamic>>> getOrderHistory(String userId) async {
    CollectionReference orders = FirebaseFirestore.instance.collection('orders');

    try {
      QuerySnapshot snapshot = await orders.where('userId', isEqualTo: userId).get();
      List<Map<String, dynamic>> orderList = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'items': doc['items'],
          'totalPrice': doc['totalPrice'],
          'paymentStatus': doc['paymentStatus'],
          'orderStatus': doc['orderStatus'], // Fetch order status
          'orderDate': doc['orderDate'].toDate(),
        };
      }).toList();
      return orderList;
    } catch (e) {
      print('Error fetching order history: $e');
      return [];
    }
  }

  // Update the status of an order
  static Future<void> updateOrderStatus(String orderId, String newStatus) async {
    CollectionReference orders = FirebaseFirestore.instance.collection('orders');
    
    try {
      await orders.doc(orderId).update({
        'orderStatus': newStatus, // Update the order status
      });
    } catch (e) {
      print('Error updating order status: $e');
    }
  }
}
