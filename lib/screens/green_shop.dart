import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:green/screens/cart.dart'; // Import your CartScreen
import 'package:green/screens/fruits_details.dart'; // Import the FruitDetailsScreen

class GreenShopScreen extends StatefulWidget {
  const GreenShopScreen({super.key});

  @override
  _GreenShopScreenState createState() => _GreenShopScreenState();
}

class _GreenShopScreenState extends State<GreenShopScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> householdProducts = [];
  List<Map<String, dynamic>> vegetableProducts = [];
  List<Map<String, dynamic>> fruitProducts = [];
  List<Map<String, dynamic>> filteredHouseholdProducts = [];
  List<Map<String, dynamic>> filteredVegetableProducts = [];
  List<Map<String, dynamic>> filteredFruitProducts = [];
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      // Fetch household products
      final householdSnapshot = await FirebaseFirestore.instance.collection('products').get();
      final household = householdSnapshot.docs.map((doc) {
        return {
          'documentId': doc.id,  // Fetch documentId for household products
          'name': doc['name'],
          'description': doc['description'],
          'price': doc['price'].toString(),
          'imageUrl': doc['imageUrl'],
          'category': 'household', // Added category
        };
      }).toList();

      // Fetch vegetable products
      final vegetableSnapshot = await FirebaseFirestore.instance.collection('vegetables').get();
      final vegetables = vegetableSnapshot.docs.map((doc) {
        return {
          'documentId': doc.id,  // Fetch documentId for vegetables
          'name': doc['name'],
          'description': '',  // You can provide a default description here if it's missing
          'price': doc['price'].toString(),
          'imageUrl': doc['photo_url'],
          'category': 'vegetable', // Added category
        };
      }).toList();

      // Fetch fruit products
      final fruitSnapshot = await FirebaseFirestore.instance.collection('fruits').get();
      final fruits = fruitSnapshot.docs.map((doc) {
        return {
          'documentId': doc.id,  // Fetch documentId for fruits
          'name': doc['name'],
          'description': doc['description'],
          'price': doc['price'].toString(),
          'imageUrl': doc['imageUrl'],
          'category': 'fruit', // Added category
        };
      }).toList();

      // Set the fetched data into state
      setState(() {
        householdProducts = household;
        vegetableProducts = vegetables;
        fruitProducts = fruits;
        filteredHouseholdProducts = household;
        filteredVegetableProducts = vegetables;
        filteredFruitProducts = fruits;
      });
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  void _filterProducts(String query) {
    final filteredHousehold = householdProducts
        .where((product) =>
            product['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();
    final filteredVegetables = vegetableProducts
        .where((product) =>
            product['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();
    final filteredFruits = fruitProducts
        .where((product) =>
            product['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      filteredHouseholdProducts = filteredHousehold;
      filteredVegetableProducts = filteredVegetables;
      filteredFruitProducts = filteredFruits;
    });
  }

  void _goToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(), // Navigate to CartScreen
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Green Shop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: _goToCart,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Household'),
            Tab(text: 'Vegetables'),
            Tab(text: 'Fruits'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search products...',
                border: OutlineInputBorder(),
              ),
              onChanged: _filterProducts,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductList(filteredHouseholdProducts),
                _buildProductList(filteredVegetableProducts),
                _buildProductList(filteredFruitProducts),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<Map<String, dynamic>> products) {
    if (products.isEmpty) {
      return const Center(child: Text('Loading...'));
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () {
            // Navigate to the fruit details screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FruitDetailsScreen(
                  documentId: product['documentId'],  // Pass the documentId for all product types
                  name: product['name'],
                  description: product['description'],
                  price: product['price'],
                  imageUrl: product['imageUrl'],
                ),
              ),
            );
          },
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  product['imageUrl'],
                  fit: BoxFit.cover,
                  height: 100,
                  width: double.infinity,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    product['name'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    // Add "kg" for vegetable and fruit products
                    'Price: ₹${product['price']}${(product['category'] == 'vegetable' || product['category'] == 'fruit') ? '/kg' : ''}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
