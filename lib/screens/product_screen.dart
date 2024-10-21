import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:green/screens/cartProvider.dart'; // Import your CartProvider

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  // Collection reference to your product collection in Firestore
  final CollectionReference _productsRef =
      FirebaseFirestore.instance.collection('products');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: StreamBuilder(
        stream: _productsRef.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          // Fetching the product data from Firebase
          var products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index];
              String productId = product.id; // Get productId from Firestore
              String name = product['name'];  // Product name from Firestore
              double price = product['price']; // Product price from Firestore

              return ListTile(
                title: Text(name),
                subtitle: Text('Price: Rs. $price'),
                trailing: ElevatedButton(
                  onPressed: () {
                    _addToCart(productId, name, price); // Add product to cart
                  },
                  child: Text('Add to Cart'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Add product to cart with productId from Firestore
  void _addToCart(String productId, String name, double price) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    int quantity = 1; // Default quantity set to 1, modify as needed
    cart.addItem(productId, name, price, quantity);
  }
}
