import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:green/screens/cartProvider.dart'; // Import CartProvider
import 'package:green/screens/order_history_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Razorpay _razorpay;
  String? _orderId; // To track the order ID

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear(); // Removes all listeners
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _saveOrder(response.paymentId); // Save the order to Firestore
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet selected: ${response.walletName}')),
    );
  }

  // Save order details in Firestore
  void _saveOrder(String? paymentId) async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final currentUser = FirebaseAuth.instance.currentUser; // Fetch current user

    if (currentUser != null) {
      var orderDetails = {
        'userId': currentUser.uid, // Get user ID from FirebaseAuth
        'items': cart.items.values.map((item) => {
          'name': item.name,
          'quantity': item.quantity,
          'price': item.price,
        }).toList(),
        'totalPrice': cart.totalAmount,
        'orderStatus': 'Processing', // Initial status
        'paymentId': paymentId,
        'orderDate': DateTime.now(),
      };

      // Save order to Firestore
      var orderRef = await FirebaseFirestore.instance.collection('orders').add(orderDetails);

      // Store the order ID
      setState(() {
        _orderId = orderRef.id; // Update order ID
        cart.clearCart(); // Clear the cart and trigger UI update
      });

      // Optional: Show a confirmation message after saving order
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order placed successfully! Order ID: $_orderId')),
      );
    }
  }

  // Function to open Razorpay checkout
  void openCheckout(double amount) {
    var options = {
      'key': dotenv.env['RAZORPAY_KEY'] ,
      'amount': (amount * 100).toInt(),
      'name': 'Ecofootprint',
      'description': 'Cart Payment',
      'prefill': {
        'contact': '9422843071',
        'email': 'vmaske7071@gmail.com',
      },
      'theme': {'color': '#59B954'},
      'method': {
        'upi': true,
        'card': true,
        'netbanking': true,
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  // Fetch order status from Firestore
  Stream<DocumentSnapshot>? _orderStream() {
    if (_orderId != null) {
      return FirebaseFirestore.instance.collection('orders').doc(_orderId).snapshots();
    }
    return null; // Return null if no order ID is set
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: const Color.fromARGB(255, 59, 89, 152),
      ),
      body: Column(
        children: [
          // Always visible View Order History button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => OrderHistoryScreen(),
                ));
              },
              child: const Text('View Order History'),
            ),
          ),
          // Cart items list or message if empty
          cart.itemCount == 0
              ? const Center(
                  child: Text('No items in your cart!'),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) {
                      var cartItems = cart.items.values.toList();
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: ListTile(
                          title: Text(cartItems[i].name),
                          subtitle: Text('Quantity: ${cartItems[i].quantity}'),
                          trailing: Text('Rs. ${cartItems[i].price * cartItems[i].quantity}'),
                          leading: Row(
                            mainAxisSize: MainAxisSize.min, // To fit buttons closely
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  if (cartItems[i].quantity > 1) {
                                    cart.addItem(
                                      cartItems[i].productId,
                                      cartItems[i].name,
                                      cartItems[i].price,
                                      -1, // Decrease quantity
                                    );
                                  } else {
                                    cart.removeItem(cartItems[i].productId);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  cart.addItem(
                                    cartItems[i].productId,
                                    cartItems[i].name,
                                    cartItems[i].price,
                                    1, // Increase quantity
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: Rs. ${cart.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    openCheckout(cart.totalAmount);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    backgroundColor: const Color.fromARGB(255, 180, 198, 103),
                  ),
                  child: const Text('Proceed to Pay'),
                ),
              ],
            ),
          ),
          if (_orderId != null) // Show order status if order ID exists
            StreamBuilder<DocumentSnapshot>( 
              stream: _orderStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Error tracking order'),
                  );
                }

                var orderData = snapshot.data!;
                var orderStatus = orderData['orderStatus'];

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Order Status: $orderStatus',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
