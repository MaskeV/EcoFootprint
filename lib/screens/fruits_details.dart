import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:green/screens/cartProvider.dart'; // Ensure this path is correct

class FruitDetailsScreen extends StatelessWidget {
  final String documentId;
  final String name;
  final String description;
  final String price;
  final String imageUrl;

  const FruitDetailsScreen({
    Key? key,
    required this.documentId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  }) : super(key: key);

  void _addToCart(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false); // Get CartProvider instance

    // Add item to the cart
    cartProvider.addItem(
      documentId,
      name,
      double.parse(price), // Convert the price to double
      1, // Set quantity to 1
    );

    // Show a SnackBar to confirm addition
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item added to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description.isNotEmpty ? description : 'No description available',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Price: ₹$price',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _addToCart(context), // Call _addToCart on button press
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
