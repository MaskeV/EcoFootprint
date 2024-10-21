import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Generate a random rating for demonstration purposes
    final double randomRating = (1 + (4 * (new DateTime.now().microsecondsSinceEpoch % 100) / 100)).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Text(product['name'] ?? 'Product Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            product['imageUrl'] != null && product['imageUrl'] != ''
                ? Image.network(product['imageUrl'])
                : const Icon(Icons.image_not_supported, size: 100),
            const SizedBox(height: 16.0),
            Text(
              product['name'] ?? 'Unknown',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              product['description'] ?? 'No description available',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Rating:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            RatingBar.builder(
              initialRating: randomRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                // Handle rating update if needed
              },
            ),
            // Add more details if needed
          ],
        ),
      ),
    );
  }
}
